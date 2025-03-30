// SPDX-License-Identifier: VPL-1.0
pragma solidity ^0.8.20;

import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {MiladyBank} from "../bank/MiladyBank.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Currency, CurrencyLibrary} from "v4-core/src/types/Currency.sol";
import {BalanceDelta} from "v4-core/src/types/BalanceDelta.sol";
import {BaseRouter} from "./BaseRouter.sol";
import {TokenUtils} from "../utils/TokenUtils.sol";

contract MiladyBankRouter is BaseRouter {
    using CurrencyLibrary for Currency;
    using TokenUtils for Currency;

    MiladyBank public immutable bank;

    // Events
    event Deposited(address indexed user, address token, int256 amount);
    event Withdrawn(address indexed user, address token, int256 amount);
    event Borrowed(address indexed user, address token, int256 amount);
    event Repaid(address indexed user, address token, int256 amount);

    constructor(IPoolManager _poolManager, MiladyBank _bank) BaseRouter(_poolManager) {
        bank = _bank;
    }

    // Basic operations
    function deposit(PoolKey calldata key, int256 depositAmount) external {
        require(depositAmount > 0, "Deposit amount must be positive");
        uint256 amount = TokenUtils.transferFromUser(key.currency0, msg.sender, address(this), depositAmount);
        TokenUtils.approve(key.currency0, address(bank), amount);
        bank.deposit(key, depositAmount);
        emit Deposited(msg.sender, Currency.unwrap(key.currency0), depositAmount);
    }

    function withdraw(PoolKey calldata key, int256 withdrawAmount) external {
        require(withdrawAmount > 0, "Withdraw amount must be positive");
        bank.withdraw(key, withdrawAmount);
        TokenUtils.transfer(key.currency0, msg.sender, uint256(withdrawAmount));
        emit Withdrawn(msg.sender, Currency.unwrap(key.currency0), withdrawAmount);
    }

    function borrow(PoolKey calldata key, int256 borrowAmount) external {
        require(borrowAmount > 0, "Borrow amount must be positive");

        BalanceDelta delta = executeSwap(key, true, borrowAmount, "");

        // Transfer borrowed tokens to user
        int256 borrowedAmount = -delta.amount1(); // Negative since tokens flow out of pool
        TokenUtils.transfer(key.currency1, msg.sender, uint256(borrowedAmount));
        emit Borrowed(msg.sender, Currency.unwrap(key.currency1), borrowedAmount);
    }

    function repay(PoolKey calldata key, int256 repayAmount) external {
        require(repayAmount > 0, "Repay amount must be positive");
        uint256 amount = TokenUtils.transferFromUser(key.currency1, msg.sender, address(this), repayAmount);
        TokenUtils.approve(key.currency1, address(bank), amount);

        executeSwap(key, false, repayAmount, "");

        // Return any leftover tokens to user
        uint256 leftover = IERC20(Currency.unwrap(key.currency1)).balanceOf(address(this));
        if (leftover > 0) {
            TokenUtils.transfer(key.currency1, msg.sender, leftover);
        }
        emit Repaid(msg.sender, Currency.unwrap(key.currency1), repayAmount);
    }

    // Combined operations
    function depositAndBorrow(PoolKey calldata key, int256 depositAmount, int256 borrowAmount, int256) external {
        // First deposit collateral
        require(depositAmount > 0, "Deposit amount must be positive");
        uint256 amount = TokenUtils.transferFromUser(key.currency0, msg.sender, address(this), depositAmount);
        TokenUtils.approve(key.currency0, address(bank), amount);
        bank.deposit(key, depositAmount);
        emit Deposited(msg.sender, Currency.unwrap(key.currency0), depositAmount);

        // Then borrow
        require(borrowAmount > 0, "Borrow amount must be positive");
        BalanceDelta delta = executeSwap(key, true, borrowAmount, "");
        int256 borrowedAmount = -delta.amount1();
        TokenUtils.transfer(key.currency1, msg.sender, uint256(borrowedAmount));
        emit Borrowed(msg.sender, Currency.unwrap(key.currency1), borrowedAmount);
    }

    function repayAndWithdraw(PoolKey calldata key, int256 repayAmount, int256 withdrawAmount, int256) external {
        // First repay
        require(repayAmount > 0, "Repay amount must be positive");
        uint256 amount = TokenUtils.transferFromUser(key.currency1, msg.sender, address(this), repayAmount);
        TokenUtils.approve(key.currency1, address(bank), amount);
        executeSwap(key, false, repayAmount, "");
        emit Repaid(msg.sender, Currency.unwrap(key.currency1), repayAmount);

        // Then withdraw
        require(withdrawAmount > 0, "Withdraw amount must be positive");
        bank.withdraw(key, withdrawAmount);
        TokenUtils.transfer(key.currency0, msg.sender, uint256(withdrawAmount));
        emit Withdrawn(msg.sender, Currency.unwrap(key.currency0), withdrawAmount);
    }

    // Helper function for emergency withdrawal
    function emergencyWithdraw(PoolKey calldata key, int256 withdrawAmount) external {
        require(withdrawAmount > 0, "Withdraw amount must be positive");
        bank.withdraw(key, withdrawAmount);
        TokenUtils.transfer(key.currency0, msg.sender, uint256(withdrawAmount));
        emit Withdrawn(msg.sender, Currency.unwrap(key.currency0), withdrawAmount);
    }
}
