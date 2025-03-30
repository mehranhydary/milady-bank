// SPDX-License-Identifier: VPL-1.0
pragma solidity ^0.8.20;

import {BaseHook} from "v4-periphery/src/utils/BaseHook.sol";
import {PoolId, PoolIdLibrary} from "v4-core/src/types/PoolId.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {Hooks} from "v4-core/src/libraries/Hooks.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {BalanceDelta} from "v4-core/src/types/BalanceDelta.sol";
import {IERC20} from "v4-core/lib/forge-std/src/interfaces/IERC20.sol";
import {TickMath} from "v4-core/src/libraries/TickMath.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import {TruncatedOracle} from "./libraries/TruncatedOracle.sol";

contract MiladyBank is BaseHook, ReentrancyGuard {
    using PoolIdLibrary for PoolKey;
    using TruncatedOracle for TruncatedOracle.Observation[65535];

    struct LendingPool {
        uint256 totalDeposits;
        uint256 totalBorrows;
        uint256 lastUpdateTimestamp;
        uint256 baseRate; // Base interest rate in basis points
        uint256 utilizationMultiplier; // Multiplier for utilization rate
        uint256 lastInterestRate; // Last calculated interest rate
        mapping(address => UserPosition) userPositions;
    }

    struct UserPosition {
        uint256 deposits;
        uint256 borrows;
        uint256 lastInterestAccrual;
    }

    struct ObservationState {
        uint16 index;
        uint16 cardinality;
        uint16 cardinalityNext;
    }

    uint32 public constant TWAP_PERIOD = 30 minutes;
    uint32 public constant STALENESS_PERIOD = 35 minutes;

    address public router;
    uint256 public constant LIQUIDATION_THRESHOLD = 8000; // 80%
    uint256 public constant LIQUIDATION_BONUS = 500; // 5%
    // Oracle-related state variables
    mapping(bytes32 => TruncatedOracle.Observation[65535]) public observations;
    mapping(bytes32 => ObservationState) public states;
    mapping(PoolId => LendingPool) public lendingPools;

    // Events
    event Deposit(address indexed user, PoolId indexed poolId, uint256 amount);
    event Withdraw(address indexed user, PoolId indexed poolId, uint256 amount);
    event Borrow(address indexed user, PoolId indexed poolId, uint256 amount);
    event Repay(address indexed user, PoolId indexed poolId, uint256 amount);
    event Liquidation(
        address indexed liquidator,
        address indexed user,
        PoolId indexed poolId,
        uint256 debtAmount,
        uint256 collateralLiquidated
    );

    constructor(IPoolManager _poolManager, address _router) BaseHook(_poolManager) {
        router = _router;
    }

    function getHookPermissions() public pure override returns (Hooks.Permissions memory) {
        return Hooks.Permissions({
            beforeInitialize: true,
            afterInitialize: true,
            beforeAddLiquidity: true,
            afterAddLiquidity: false,
            beforeRemoveLiquidity: true,
            afterRemoveLiquidity: false,
            beforeSwap: true,
            afterSwap: true,
            beforeDonate: false,
            afterDonate: false,
            beforeSwapReturnDelta: false,
            afterSwapReturnDelta: false,
            afterAddLiquidityReturnDelta: false,
            afterRemoveLiquidityReturnDelta: false
        });
    }

    function _blockTimestamp() internal view returns (uint32) {
        return uint32(block.timestamp);
    }

    function _updateOracle(PoolKey calldata key) private {
        bytes32 id = keccak256(abi.encode(key));
        (, int24 tick,) = poolManager.getSlot0(key.toId());
        uint128 liquidity = poolManager.getLiquidity(key.toId());

        (states[id].index, states[id].cardinality) = observations[id].write(
            states[id].index, _blockTimestamp(), tick, liquidity, states[id].cardinality, states[id].cardinalityNext
        );
    }

    function getPrice(PoolKey calldata key) public view returns (uint256) {
        bytes32 id = keccak256(abi.encode(key));
        uint32[] memory secondsAgos = new uint32[](2);
        secondsAgos[0] = TWAP_PERIOD;
        secondsAgos[1] = 0;

        (int48[] memory tickCumulatives,) = observations[id].observe(
            _blockTimestamp(),
            secondsAgos,
            0, // current tick
            states[id].index,
            poolManager.getLiquidity(key.toId()),
            states[id].cardinality
        );

        int24 twapTick = int24((tickCumulatives[1] - tickCumulatives[0]) / int48(uint48(TWAP_PERIOD)));
        uint160 sqrtPriceX96 = TickMath.getSqrtRatioAtTick(twapTick);
        return uint256(sqrtPriceX96) * uint256(sqrtPriceX96) >> 192;
    }

    function isStale(PoolKey calldata key) public view returns (bool) {
        bytes32 id = keccak256(abi.encode(key));
        uint32[] memory secondsAgos = new uint32[](1);
        secondsAgos[0] = 0;

        (int48[] memory tickCumulatives,) = observations[id].observe(
            _blockTimestamp(),
            secondsAgos,
            0,
            states[id].index,
            poolManager.getLiquidity(key.toId()),
            states[id].cardinality
        );

        return block.timestamp > uint256(uint48(tickCumulatives[0])) + STALENESS_PERIOD;
    }

    function beforeInitialize(address, PoolKey calldata key, uint160, bytes calldata)
        external
        onlyPoolManager
        returns (bytes4)
    {
        PoolId poolId = key.toId();
        LendingPool storage pool = lendingPools[poolId];

        pool.baseRate = 500; // 5% base rate
        pool.utilizationMultiplier = 2000; // 20% max additional rate
        pool.lastUpdateTimestamp = block.timestamp;

        return BaseHook.beforeInitialize.selector;
    }

    function afterInitialize(address, PoolKey calldata key, uint160, int24 tick)
        external
        onlyPoolManager
        returns (bytes4)
    {
        bytes32 id = keccak256(abi.encode(key));
        (states[id].cardinality, states[id].cardinalityNext) = observations[id].initialize(_blockTimestamp(), tick);
        return BaseHook.afterInitialize.selector;
    }

    function liquidate(PoolKey calldata key, address user, uint256 debtAmount) external nonReentrant {
        require(!isStale(key), "Stale oracle");
        require(checkHealth(user, key) < 10000, "Position is healthy");

        PoolId poolId = key.toId();
        LendingPool storage pool = lendingPools[poolId];
        UserPosition storage position = pool.userPositions[user];

        uint256 price = getPrice(key);

        // Calculate collateral to liquidate including bonus
        uint256 collateralToLiquidate = (debtAmount * (10000 + LIQUIDATION_BONUS) / 10000) / price;
        require(collateralToLiquidate <= position.deposits, "Too much collateral");

        // Transfer debt tokens from liquidator
        IERC20(address(key.currency1)).transferFrom(msg.sender, address(this), debtAmount);

        // Reduce user's debt and collateral
        position.borrows -= debtAmount;
        position.deposits -= collateralToLiquidate;
        pool.totalBorrows -= debtAmount;
        pool.totalDeposits -= collateralToLiquidate;

        // Transfer collateral to liquidator
        IERC20(address(key.currency0)).transfer(msg.sender, collateralToLiquidate);

        emit Liquidation(msg.sender, user, poolId, debtAmount, collateralToLiquidate);
    }

    function checkHealth(address user, PoolKey calldata key) public view returns (uint256 healthFactor) {
        PoolId poolId = key.toId();
        LendingPool storage pool = lendingPools[poolId];
        UserPosition storage position = pool.userPositions[user];

        if (position.borrows == 0) return type(uint256).max;

        uint256 collateralValue = position.deposits * getPrice(key);
        uint256 borrowValue = position.borrows;

        healthFactor = (collateralValue * 10000) / (borrowValue * LIQUIDATION_THRESHOLD);
    }

    function deposit(PoolKey calldata key, uint256 amount) external nonReentrant {
        address depositor = msg.sender == router ? tx.origin : msg.sender;
        PoolId poolId = key.toId();
        LendingPool storage pool = lendingPools[poolId];
        UserPosition storage position = pool.userPositions[depositor];

        IERC20(address(key.currency0)).transferFrom(depositor, address(this), amount);
        position.deposits += amount;
        pool.totalDeposits += amount;

        emit Deposit(depositor, poolId, amount);
    }

    function withdraw(PoolKey calldata key, uint256 amount) external nonReentrant {
        address withdrawer = msg.sender == router ? tx.origin : msg.sender;
        PoolId poolId = key.toId();
        LendingPool storage pool = lendingPools[poolId];
        UserPosition storage position = pool.userPositions[withdrawer];

        require(position.deposits >= amount, "Insufficient deposits");

        // Check if withdrawal would put pool at risk
        uint256 newUtilization = ((pool.totalBorrows * 10000) / (pool.totalDeposits - amount));
        require(newUtilization <= 9000, "Utilization would be too high"); // Max 90% utilization

        position.deposits -= amount;
        pool.totalDeposits -= amount;

        // Transfer tokens back to user
        IERC20(address(key.currency0)).transfer(withdrawer, amount);

        emit Withdraw(withdrawer, poolId, amount);
    }

    // Calculate dynamic interest rate based on utilization
    function calculateInterestRate(LendingPool storage pool) internal view returns (uint256) {
        if (pool.totalDeposits == 0) return pool.baseRate;

        uint256 utilization = (pool.totalBorrows * 10000) / pool.totalDeposits;
        uint256 variableRate = (utilization * pool.utilizationMultiplier) / 10000;

        return pool.baseRate + variableRate;
    }

    function beforeAddLiquidity(address, PoolKey calldata key, uint160, BalanceDelta params)
        external
        returns (bytes4)
    {
        PoolId poolId = key.toId();
        LendingPool storage pool = lendingPools[poolId];

        // Update interest rates based on new position
        uint256 newRate = calculateInterestRate(pool);
        pool.lastInterestRate = newRate;

        // Update pool state
        if (params.amount0() > 0) {
            pool.totalDeposits += uint256(params.amount0());
        } else {
            pool.totalDeposits -= uint256(-params.amount0());
        }

        return BaseHook.beforeAddLiquidity.selector;
    }

    function beforeRemoveLiquidity(address, PoolKey calldata key, uint160, BalanceDelta params)
        external
        returns (bytes4)
    {
        PoolId poolId = key.toId();
        LendingPool storage pool = lendingPools[poolId];

        // Update interest rates based on new position
        uint256 newRate = calculateInterestRate(pool);
        pool.lastInterestRate = newRate;

        // Update pool state
        if (params.amount0() > 0) {
            pool.totalDeposits += uint256(params.amount0());
        } else {
            pool.totalDeposits -= uint256(-params.amount0());
        }

        return BaseHook.beforeRemoveLiquidity.selector;
    }

    // Handle borrowing through swaps
    function beforeSwap(address sender, PoolKey calldata key, IPoolManager.SwapParams calldata params)
        external
        onlyPoolManager
        returns (bytes4)
    {
        PoolId poolId = key.toId();
        LendingPool storage pool = lendingPools[poolId];
        UserPosition storage position = pool.userPositions[sender];
        // Update borrow amounts based on swap
        if (params.zeroForOne) {
            // Borrowing
            require(
                (position.borrows + params.amountSpecified) <= (position.deposits * 75) / 100, // 75% collateral ratio
                "Insufficient collateral"
            );
            position.borrows += params.amountSpecified;
            pool.totalBorrows += params.amountSpecified;
            emit Borrow(sender, poolId, params.amountSpecified);
        } else {
            // Repaying
            require(position.borrows >= params.amountSpecified, "Repaying too much");
            position.borrows -= params.amountSpecified;
            pool.totalBorrows -= params.amountSpecified;
            emit Repay(sender, poolId, params.amountSpecified);
        }

        pool.lastInterestRate = calculateInterestRate(pool);
        return BaseHook.beforeSwap.selector;
    }

    // Accrue interest after swaps
    function afterSwap(address, PoolKey calldata key, IPoolManager.SwapParams calldata, BalanceDelta)
        external
        returns (bytes4)
    {
        PoolId poolId = key.toId();
        LendingPool storage pool = lendingPools[poolId];

        // Calculate and apply interest with better precision
        uint256 timeElapsed = block.timestamp - pool.lastUpdateTimestamp;
        // Multiply by 1e18 for better precision before division
        uint256 interest = (pool.totalBorrows * pool.lastInterestRate * timeElapsed * 1e18) / (365 days * 10000);
        interest = interest / 1e18; // Scale back down

        pool.totalBorrows += interest;
        pool.lastUpdateTimestamp = block.timestamp;

        return BaseHook.afterSwap.selector;
    }

    // View functions for external integrations
    function getPoolState(PoolKey calldata key)
        external
        view
        returns (uint256 totalDeposits, uint256 totalBorrows, uint256 currentRate, uint256 utilization)
    {
        PoolId poolId = key.toId();
        LendingPool storage pool = lendingPools[poolId];

        return (
            pool.totalDeposits,
            pool.totalBorrows,
            pool.lastInterestRate,
            pool.totalDeposits == 0 ? 0 : (pool.totalBorrows * 10000) / pool.totalDeposits
        );
    }
}
