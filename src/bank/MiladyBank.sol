// SPDX-License-Identifier: VPL-1.0
pragma solidity ^0.8.20;

import {PoolId, PoolIdLibrary} from "v4-core/src/types/PoolId.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {Hooks} from "v4-core/src/libraries/Hooks.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {BalanceDelta} from "v4-core/src/types/BalanceDelta.sol";
import {BeforeSwapDelta, toBeforeSwapDelta} from "@uniswap/v4-core/src/types/BeforeSwapDelta.sol";
import {StateLibrary} from "v4-core/src/libraries/StateLibrary.sol";
import {IERC20} from "v4-core/lib/forge-std/src/interfaces/IERC20.sol";
import {Currency, CurrencyLibrary} from "v4-core/src/types/Currency.sol";
import {TickMath} from "v4-core/src/libraries/TickMath.sol";
import {ReentrancyGuard} from "v4-core/lib/solmate/src/utils/ReentrancyGuard.sol";
import {Owned} from "v4-core/lib/solmate/src/auth/Owned.sol";

import {BaseHook} from "v4-periphery/src/utils/BaseHook.sol";

import {TruncatedOracle} from "../libraries/TruncatedOracle.sol";

contract MiladyBank is BaseHook, ReentrancyGuard, Owned {
    using StateLibrary for IPoolManager;
    using PoolIdLibrary for PoolKey;
    using CurrencyLibrary for Currency;
    using TruncatedOracle for TruncatedOracle.Observation[65535];

    struct UserPosition {
        int256 deposits; // Changed from uint256 to int256
        int256 borrows; // Changed from uint256 to int256
    }

    struct LendingPool {
        int256 totalDeposits; // Changed from uint256 to int256
        int256 totalBorrows; // Changed from uint256 to int256
        int256 lastInterestRate; // Basis points (e.g., 500 = 5%)
        uint256 lastUpdateTimestamp;
        mapping(address => UserPosition) userPositions;
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
    event Deposit(address indexed user, PoolId indexed poolId, int256 amount);
    event Withdraw(address indexed user, PoolId indexed poolId, int256 amount);
    event Borrow(address indexed user, PoolId indexed poolId, int256 amount);
    event Repay(address indexed user, PoolId indexed poolId, int256 amount);
    event Liquidation(
        address indexed liquidator,
        address indexed user,
        PoolId indexed poolId,
        uint256 debtAmount,
        uint256 collateralLiquidated
    );

    constructor(IPoolManager _poolManager, address _router) BaseHook(_poolManager) Owned(msg.sender) {
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
        (, int24 tick,,) = poolManager.getSlot0(key.toId());
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
        uint160 sqrtPriceX96 = TickMath.getSqrtPriceAtTick(twapTick);
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

        pool.lastInterestRate = 500; // 5% base rate
        pool.lastUpdateTimestamp = block.timestamp;

        return BaseHook.beforeInitialize.selector;
    }

    function _afterInitialize(address, PoolKey calldata key, uint160, int24 tick) internal override returns (bytes4) {
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
        require(collateralToLiquidate <= uint256(position.deposits), "Too much collateral");

        // Transfer debt tokens from liquidator
        IERC20(Currency.unwrap(key.currency1)).transferFrom(msg.sender, address(this), debtAmount);

        // Reduce user's debt and collateral
        position.borrows -= int256(debtAmount);
        position.deposits -= int256(collateralToLiquidate);
        pool.totalBorrows -= int256(debtAmount);
        pool.totalDeposits -= int256(collateralToLiquidate);

        // Transfer collateral to liquidator
        key.currency0.transfer(msg.sender, collateralToLiquidate);

        emit Liquidation(msg.sender, user, poolId, debtAmount, collateralToLiquidate);
    }

    function checkHealth(address user, PoolKey calldata key) public view returns (uint256 healthFactor) {
        PoolId poolId = key.toId();
        LendingPool storage pool = lendingPools[poolId];
        UserPosition storage position = pool.userPositions[user];

        if (position.borrows == 0) return type(uint256).max;

        uint256 collateralValue = uint256(position.deposits) * getPrice(key);
        uint256 borrowValue = uint256(position.borrows);

        healthFactor = (collateralValue * 10000) / (borrowValue * LIQUIDATION_THRESHOLD);
    }

    function deposit(PoolKey calldata key, int256 amount) external nonReentrant {
        address depositor = msg.sender == router ? tx.origin : msg.sender;
        PoolId poolId = key.toId();
        LendingPool storage pool = lendingPools[poolId];
        UserPosition storage position = pool.userPositions[depositor];

        IERC20(Currency.unwrap(key.currency0)).transferFrom(depositor, address(this), uint256(amount));
        position.deposits += amount;
        pool.totalDeposits += amount;

        emit Deposit(depositor, poolId, amount);
    }

    function withdraw(PoolKey calldata key, int256 amount) external nonReentrant {
        address withdrawer = msg.sender == router ? tx.origin : msg.sender;
        PoolId poolId = key.toId();
        LendingPool storage pool = lendingPools[poolId];
        UserPosition storage position = pool.userPositions[withdrawer];

        require(position.deposits >= amount, "Insufficient deposits");

        // Check if withdrawal would put pool at risk
        uint256 newUtilization = (uint256(pool.totalBorrows) * 10000) / uint256(pool.totalDeposits - amount);
        require(newUtilization <= 9000, "Utilization would be too high"); // Max 90% utilization

        position.deposits -= amount;
        pool.totalDeposits -= amount;

        // Transfer tokens back to user
        key.currency0.transfer(withdrawer, uint256(amount));

        emit Withdraw(withdrawer, poolId, amount);
    }

    // Calculate dynamic interest rate based on utilization
    function calculateInterestRate(LendingPool storage pool) internal view returns (int256) {
        if (pool.totalDeposits == 0) return 500;

        int256 utilizationRate = (pool.totalBorrows * 10000) / pool.totalDeposits;

        return 500 + utilizationRate / 10;
    }

    function _beforeAddLiquidity(
        address sender,
        PoolKey calldata key,
        IPoolManager.ModifyLiquidityParams calldata params,
        bytes calldata
    ) internal override returns (bytes4) {
        PoolId poolId = key.toId();
        LendingPool storage pool = lendingPools[poolId];

        // Update interest rates based on new position
        int256 newRate = calculateInterestRate(pool);
        pool.lastInterestRate = newRate;

        // Calculate liquidity delta
        int256 liquidityChange = params.liquidityDelta;
        if (liquidityChange > 0) {
            // Adding liquidity
            pool.totalDeposits += liquidityChange;

            // Update user position
            UserPosition storage position = pool.userPositions[sender];
            position.deposits += liquidityChange;
            emit Deposit(sender, poolId, liquidityChange);
        } else if (liquidityChange < 0) {
            // Removing liquidity
            pool.totalDeposits += liquidityChange; // Will subtract since liquidityChange is negative
        }

        return BaseHook.beforeAddLiquidity.selector;
    }

    function _beforeRemoveLiquidity(
        address sender,
        PoolKey calldata key,
        IPoolManager.ModifyLiquidityParams calldata params,
        bytes calldata
    ) internal override returns (bytes4) {
        PoolId poolId = key.toId();
        LendingPool storage pool = lendingPools[poolId];

        // Update interest rates based on new position
        int256 newRate = calculateInterestRate(pool);
        pool.lastInterestRate = newRate;

        // Calculate liquidity delta
        int256 liquidityChange = params.liquidityDelta;
        if (liquidityChange < 0) {
            // Removing liquidity
            UserPosition storage position = pool.userPositions[sender];
            require(int256(position.deposits) >= int256(-liquidityChange), "Insufficient deposits");

            // Check if withdrawal would put pool at risk
            int256 newUtilization =
                ((int256(pool.totalBorrows) * 10000) / (int256(pool.totalDeposits) + liquidityChange));
            require(newUtilization <= 9000, "Utilization would be too high"); // Max 90% utilization

            position.deposits += liquidityChange; // Will subtract since liquidityChange is negative
            pool.totalDeposits += liquidityChange;
            emit Withdraw(sender, poolId, -liquidityChange);
        } else if (liquidityChange > 0) {
            // Adding liquidity
            pool.totalDeposits += liquidityChange;

            // Update user position
            UserPosition storage position = pool.userPositions[sender];
            position.deposits += liquidityChange;
            emit Deposit(sender, poolId, liquidityChange);
        }

        return BaseHook.beforeRemoveLiquidity.selector;
    }

    // Handle borrowing through swaps
    function _beforeSwap(address sender, PoolKey calldata key, IPoolManager.SwapParams calldata params, bytes calldata)
        internal
        override
        returns (bytes4, BeforeSwapDelta, uint24)
    {
        PoolId poolId = key.toId();
        LendingPool storage pool = lendingPools[poolId];
        UserPosition storage position = pool.userPositions[sender];
        // Update borrow amounts based on swap
        if (params.zeroForOne) {
            // Borrowing
            int256 borrowAmount = params.amountSpecified;
            require(borrowAmount > 0, "Invalid borrow amount");

            require((position.borrows + borrowAmount) * 100 <= position.deposits * 75, "Exceeds collateral ratio");
            position.borrows += borrowAmount;
            pool.totalBorrows += borrowAmount;
            emit Borrow(sender, poolId, borrowAmount);
        } else {
            // Repaying
            int256 repayAmount = params.amountSpecified;
            require(repayAmount > 0, "Invalid repay amount");

            require(position.borrows >= repayAmount, "Repaying too much");
            position.borrows -= repayAmount;
            pool.totalBorrows -= repayAmount;
            emit Repay(sender, poolId, repayAmount);
        }

        pool.lastInterestRate = calculateInterestRate(pool);
        return (BaseHook.beforeSwap.selector, toBeforeSwapDelta(0, 0), 0);
    }

    // Accrue interest after swaps
    function _afterSwap(address, PoolKey calldata key, IPoolManager.SwapParams calldata, BalanceDelta, bytes calldata)
        internal
        override
        returns (bytes4, int128)
    {
        PoolId poolId = key.toId();
        LendingPool storage pool = lendingPools[poolId];

        // Calculate and apply interest with better precision
        uint256 timeElapsed = block.timestamp - pool.lastUpdateTimestamp;
        // Multiply by 1e18 for better precision before division
        int256 interest =
            (pool.totalBorrows * pool.lastInterestRate * int256(timeElapsed) * 1e18) / (int256(365 days) * 10000);
        interest = interest / 1e18; // Scale back down

        pool.totalBorrows += interest;
        pool.lastUpdateTimestamp = block.timestamp;

        return (BaseHook.afterSwap.selector, 0);
    }

    // View functions for external integrations
    function getPoolState(PoolKey calldata key)
        external
        view
        returns (int256 totalDeposits, int256 totalBorrows, int256 currentRate, int256 utilization)
    {
        PoolId poolId = key.toId();
        LendingPool storage pool = lendingPools[poolId];

        return (
            pool.totalDeposits,
            pool.totalBorrows,
            pool.lastInterestRate,
            pool.totalDeposits == 0 ? int256(0) : (pool.totalBorrows * 10000) / pool.totalDeposits
        );
    }
}
