// SPDX-License-Identifier: VPL-1.0
pragma solidity ^0.8.20;

import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {Currency, CurrencyLibrary} from "v4-core/src/types/Currency.sol";
import {BalanceDelta} from "v4-core/src/types/BalanceDelta.sol";
import {Owned} from "v4-core/lib/solmate/src/auth/Owned.sol";
import {TickMath} from "v4-core/src/libraries/TickMath.sol";

import {TokenUtils} from "../utils/TokenUtils.sol";

abstract contract BaseRouter is Owned {
    using CurrencyLibrary for Currency;
    using TokenUtils for Currency;

    IPoolManager public immutable poolManager;
    bool public paused;

    // Events
    event Deposited(address indexed user, address token, int256 amount);
    event Withdrawn(address indexed user, address token, int256 amount);
    event Borrowed(address indexed user, address token, int256 amount, int256 amountOut);
    event Repaid(address indexed user, address token, int256 amount, int256 amountIn);
    event Paused(address indexed owner);
    event Unpaused(address indexed owner);

    constructor(IPoolManager _poolManager, address _owner) Owned(_owner) {
        poolManager = _poolManager;
    }

    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    function pause() external onlyOwner {
        require(!paused, "Contract is already paused");
        paused = true;
        emit Paused(msg.sender);
    }

    function unpause() external onlyOwner {
        require(paused, "Contract is not paused");
        paused = false;
        emit Unpaused(msg.sender);
    }

    function executeSwap(PoolKey calldata key, bool zeroForOne, int256 amountSpecified, bytes memory hookData)
        internal
        returns (BalanceDelta)
    {
        // Validate amountSpecified to prevent overflow/underflow
        require(amountSpecified != type(int256).min, "Amount cannot be min int256");

        // Set sqrtPriceLimitX96 based on direction to limit slippage
        uint160 sqrtPriceLimitX96 = zeroForOne
            ? TickMath.MIN_SQRT_PRICE + 1 // Minimum price for 0->1 swaps
            : TickMath.MAX_SQRT_PRICE - 1; // Maximum price for 1->0 swaps

        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: zeroForOne,
            amountSpecified: amountSpecified,
            sqrtPriceLimitX96: sqrtPriceLimitX96
        });

        return poolManager.swap(key, params, hookData);
    }
}
