// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {MiladyBank} from "./MiladyBank.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MiladyRouter {
    IPoolManager public immutable poolManager;
    MiladyBank public immutable bank;

    constructor(IPoolManager _poolManager, MiladyBank _bank) {
        poolManager = _poolManager;
        bank = _bank;
    }

    // Deposit collateral and borrow in one transaction
    function depositAndBorrow(PoolKey calldata key, uint256 depositAmount, uint256 borrowAmount, uint256 minAmountOut)
        external
    {
        // First deposit collateral
        IERC20(address(key.currency0)).transferFrom(msg.sender, address(this), depositAmount);
        IERC20(address(key.currency0)).approve(address(bank), depositAmount);
        bank.deposit(key, depositAmount);

        // Then perform the borrow swap
        IPoolManager.SwapParams memory params =
            IPoolManager.SwapParams({zeroForOne: true, amountSpecified: borrowAmount, sqrtPriceLimitX96: 0});

        // Execute swap through pool manager
        // Note: You'll need to handle the actual swap logic here
        // This might involve using Uniswap's swap router or direct pool interaction
    }

    // Repay loan and withdraw collateral in one transaction
    function repayAndWithdraw(PoolKey calldata key, uint256 repayAmount, uint256 withdrawAmount, uint256 minAmountOut)
        external
    {
        // First repay the loan through swap
        IERC20(address(key.currency1)).transferFrom(msg.sender, address(this), repayAmount);

        IPoolManager.SwapParams memory params =
            IPoolManager.SwapParams({zeroForOne: false, amountSpecified: repayAmount, sqrtPriceLimitX96: 0});

        // Execute repayment swap
        // Note: Implement swap logic here

        // Then withdraw collateral
        bank.withdraw(key, withdrawAmount);

        // Transfer withdrawn collateral back to user
        IERC20(address(key.currency0)).transfer(msg.sender, withdrawAmount);
    }

    // Helper function for emergency withdrawal
    function emergencyWithdraw(PoolKey calldata key, uint256 withdrawAmount) external {
        bank.withdraw(key, withdrawAmount);
        IERC20(address(key.currency0)).transfer(msg.sender, withdrawAmount);
    }
}
