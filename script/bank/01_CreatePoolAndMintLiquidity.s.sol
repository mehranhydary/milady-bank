// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {PositionManager} from "v4-periphery/src/PositionManager.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {CurrencyLibrary, Currency} from "v4-core/src/types/Currency.sol";
import {Actions} from "v4-periphery/src/libraries/Actions.sol";
import {LiquidityAmounts} from "v4-core/test/utils/LiquidityAmounts.sol";
import {TickMath} from "v4-core/src/libraries/TickMath.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";

import {Constants} from "../base/Constants.sol";
import {Config} from "../base/Config.sol";

contract CreatePoolAndAddLiquidityScript is Script, Constants, Config {
    using CurrencyLibrary for Currency;

    uint24 lpFee = 3000; // Need to determine if this is enough
    int24 tickSpacing = 60; // Look into if you want to mak this tighter (45 or something)

    uint160 startingPrice = 79228162514264337593543950336; // floor(sqrt(1) * 2^96); need to also determine what the current price should be... prob look at the actual price of ETH on the day you launch this

    uint256 public token0Amount = 1e16; // 0.01 ETH
    uint256 public token1Amount = 18e6; // 18 USDC (6 decimals)

    int24 tickLower = -887220; // must be a multiple of tickSpacing (-60 * 14787)
    int24 tickUpper = 887220; // must be a multiple of tickSpacing (60 * 14787)

    function run() external {
        // Swap currency0 and currency1 since USDC address is lower than WETH
        PoolKey memory pool = PoolKey({
            currency0: currency1, // USDC
            currency1: currency0, // WETH
            fee: lpFee,
            tickSpacing: tickSpacing,
            hooks: hookContract
        });
        bytes memory hookData = new bytes(0);

        uint128 liquidity = LiquidityAmounts.getLiquidityForAmounts(
            startingPrice,
            TickMath.getSqrtPriceAtTick(tickLower),
            TickMath.getSqrtPriceAtTick(tickUpper),
            token1Amount, // USDC amount
            token0Amount // WETH amount
        );

        uint256 amount0Max = token1Amount + 1 wei; // USDC
        uint256 amount1Max = token0Amount + 1 wei; // WETH

        (bytes memory actions, bytes[] memory mintParams) =
            _mintLiquidityParams(pool, tickLower, tickUpper, liquidity, amount0Max, amount1Max, address(this), hookData);

        // multicall parameters
        bytes[] memory params = new bytes[](2);

        // initialize pool
        params[0] = abi.encodeWithSelector(posm.initializePool.selector, pool, startingPrice, hookData);

        // mint liquidity
        params[1] = abi.encodeWithSelector(
            posm.modifyLiquidities.selector, abi.encode(actions, mintParams), block.timestamp + 60
        );

        // if the pool is an ETH pair, native tokens are to be transferred
        uint256 valueToPass = currency1.isAddressZero() ? amount1Max : 0; // Check currency1 (WETH) for native ETH

        vm.startBroadcast();
        tokenApprovals();
        vm.stopBroadcast();

        // multicall to atomically create pool & add liquidity
        vm.broadcast();
        posm.multicall{value: valueToPass}(params);
    }

    /// @dev helper function for encoding mint liquidity operation
    /// @dev does NOT encode SWEEP, developers should take care when minting liquidity on an ETH pair
    function _mintLiquidityParams(
        PoolKey memory poolKey,
        int24 _tickLower,
        int24 _tickUpper,
        uint256 liquidity,
        uint256 amount0Max,
        uint256 amount1Max,
        address recipient,
        bytes memory hookData
    ) internal pure returns (bytes memory, bytes[] memory) {
        bytes memory actions = abi.encodePacked(uint8(Actions.MINT_POSITION), uint8(Actions.SETTLE_PAIR));

        bytes[] memory params = new bytes[](2);
        params[0] = abi.encode(poolKey, _tickLower, _tickUpper, liquidity, amount0Max, amount1Max, recipient, hookData);
        params[1] = abi.encode(poolKey.currency0, poolKey.currency1);
        return (actions, params);
    }

    function tokenApprovals() public {
        if (!currency0.isAddressZero()) {
            token0.approve(address(PERMIT2), type(uint256).max);
            PERMIT2.approve(address(token0), address(posm), type(uint160).max, type(uint48).max);
        }
        if (!currency1.isAddressZero()) {
            token1.approve(address(PERMIT2), type(uint256).max);
            PERMIT2.approve(address(token1), address(posm), type(uint160).max, type(uint48).max);
        }
    }
}
