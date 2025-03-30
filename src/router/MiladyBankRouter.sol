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
import {ReentrancyGuard} from "v4-core/lib/solmate/src/utils/ReentrancyGuard.sol";
import {Owned} from "v4-core/lib/solmate/src/auth/Owned.sol";

/**
 * @notice Open items and improvements needed for MiladyBankRouter
 * @dev The following items should be addressed before production deployment
 *
 * 1. Add input validation for PoolKey parameters
 *    - Validate currency addresses
 *    - Check fee tier bounds
 *    - Verify hook contracts
 *
 * 2. Consider implementing flash loan protection
 *    - Add minimum hold time for borrowed assets
 *    - Implement rate limiting
 *    - Add checks for suspicious transaction patterns
 *
 * 3. Add events for emergency actions
 *    - Log pause/unpause with reason
 *    - Track emergency withdrawals
 *    - Monitor critical state changes
 *
 * 4. Consider adding access control for router registration in bank
 *    - Implement role-based permissions
 *    - Add admin controls
 *    - Create allowlist of approved routers
 */
contract MiladyBankRouter is BaseRouter, ReentrancyGuard, Owned {
    using CurrencyLibrary for Currency;
    using TokenUtils for Currency;

    MiladyBank public immutable bank;
    bool public paused;

    // Events
    event Deposited(address indexed user, address token, int256 amount);
    event Withdrawn(address indexed user, address token, int256 amount);
    event Borrowed(address indexed user, address token, int256 amount, int256 amountOut);
    event Repaid(address indexed user, address token, int256 amount, int256 amountIn);
    event Paused(address indexed owner);
    event Unpaused(address indexed owner);

    constructor(IPoolManager _poolManager, MiladyBank _bank) BaseRouter(_poolManager) Owned(msg.sender) {
        bank = _bank;
        paused = false;
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

    // Basic operations
    function deposit(PoolKey calldata key, int256 depositAmount) external nonReentrant whenNotPaused {
        require(depositAmount > 0, "Deposit amount must be positive");
        require(uint256(depositAmount) <= type(uint256).max, "Amount exceeds uint256 max");
        uint256 amount = TokenUtils.transferFromUser(key.currency0, msg.sender, address(this), depositAmount);
        TokenUtils.approve(key.currency0, address(bank), amount);
        bank.deposit(key, depositAmount);
        emit Deposited(msg.sender, Currency.unwrap(key.currency0), depositAmount);
    }

    function withdraw(PoolKey calldata key, int256 withdrawAmount) external nonReentrant whenNotPaused {
        require(withdrawAmount > 0, "Withdraw amount must be positive");
        require(uint256(withdrawAmount) <= type(uint256).max, "Amount exceeds uint256 max");
        bank.withdraw(key, withdrawAmount);
        TokenUtils.transfer(key.currency0, msg.sender, uint256(withdrawAmount));
        emit Withdrawn(msg.sender, Currency.unwrap(key.currency0), withdrawAmount);
    }

    function borrow(PoolKey calldata key, int256 borrowAmount, int256 minAmountOut)
        external
        nonReentrant
        whenNotPaused
    {
        require(borrowAmount > 0, "Borrow amount must be positive");
        require(uint256(borrowAmount) <= type(uint256).max, "Amount exceeds uint256 max");
        require(minAmountOut > 0, "MinAmountOut must be positive");
        require(uint256(minAmountOut) <= type(uint256).max, "MinAmountOut exceeds uint256 max");

        BalanceDelta delta = executeSwap(key, true, borrowAmount, "");

        // Transfer borrowed tokens to user
        int256 borrowedAmount = -delta.amount1(); // Negative since tokens flow out of pool
        require(borrowedAmount >= minAmountOut, "Insufficient output amount");
        require(uint256(borrowedAmount) <= type(uint256).max, "Borrowed amount exceeds uint256 max");
        TokenUtils.transfer(key.currency1, msg.sender, uint256(borrowedAmount));
        emit Borrowed(msg.sender, Currency.unwrap(key.currency1), borrowAmount, borrowedAmount);
    }

    function repay(PoolKey calldata key, int256 repayAmount, int256 maxAmountIn) external nonReentrant whenNotPaused {
        require(repayAmount > 0, "Repay amount must be positive");
        require(uint256(repayAmount) <= type(uint256).max, "Amount exceeds uint256 max");
        require(maxAmountIn > 0, "MaxAmountIn must be positive");
        require(uint256(maxAmountIn) <= type(uint256).max, "MaxAmountIn exceeds uint256 max");

        uint256 amount = TokenUtils.transferFromUser(key.currency1, msg.sender, address(this), repayAmount);
        TokenUtils.approve(key.currency1, address(bank), amount);

        BalanceDelta delta = executeSwap(key, false, repayAmount, "");
        int256 amountIn = delta.amount1();
        require(amountIn <= maxAmountIn, "Excessive input amount");

        // Return any leftover tokens to user
        uint256 leftover = IERC20(Currency.unwrap(key.currency1)).balanceOf(address(this));
        if (leftover > 0) {
            TokenUtils.transfer(key.currency1, msg.sender, leftover);
        }
        emit Repaid(msg.sender, Currency.unwrap(key.currency1), repayAmount, amountIn);
    }

    // Combined operations
    function depositAndBorrow(
        PoolKey calldata key,
        int256 depositAmount,
        int256 borrowAmount,
        int256 minAmountOut,
        int256 maxAmountIn
    ) external nonReentrant whenNotPaused {
        // First deposit collateral
        require(depositAmount > 0, "Deposit amount must be positive");
        require(uint256(depositAmount) <= type(uint256).max, "Deposit amount exceeds uint256 max");
        require(borrowAmount > 0, "Borrow amount must be positive");
        require(uint256(borrowAmount) <= type(uint256).max, "Borrow amount exceeds uint256 max");
        require(minAmountOut > 0, "MinAmountOut must be positive");
        require(uint256(minAmountOut) <= type(uint256).max, "MinAmountOut exceeds uint256 max");
        require(maxAmountIn > 0, "MaxAmountIn must be positive");
        require(uint256(maxAmountIn) <= type(uint256).max, "MaxAmountIn exceeds uint256 max");

        uint256 amount = TokenUtils.transferFromUser(key.currency0, msg.sender, address(this), depositAmount);
        TokenUtils.approve(key.currency0, address(bank), amount);
        bank.deposit(key, depositAmount);
        emit Deposited(msg.sender, Currency.unwrap(key.currency0), depositAmount);

        // Then borrow with slippage protection
        BalanceDelta delta = executeSwap(key, true, borrowAmount, "");
        int256 borrowedAmount = -delta.amount1();
        require(borrowedAmount >= minAmountOut, "Insufficient output amount");
        require(borrowedAmount <= maxAmountIn, "Excessive input amount");
        require(uint256(borrowedAmount) <= type(uint256).max, "Borrowed amount exceeds uint256 max");
        TokenUtils.transfer(key.currency1, msg.sender, uint256(borrowedAmount));
        emit Borrowed(msg.sender, Currency.unwrap(key.currency1), borrowAmount, borrowedAmount);
    }

    function repayAndWithdraw(
        PoolKey calldata key,
        int256 repayAmount,
        int256 withdrawAmount,
        int256 maxAmountIn,
        int256 minAmountOut
    ) external nonReentrant whenNotPaused {
        // First repay with slippage protection
        require(repayAmount > 0, "Repay amount must be positive");
        require(uint256(repayAmount) <= type(uint256).max, "Repay amount exceeds uint256 max");
        require(withdrawAmount > 0, "Withdraw amount must be positive");
        require(uint256(withdrawAmount) <= type(uint256).max, "Withdraw amount exceeds uint256 max");
        require(maxAmountIn > 0, "MaxAmountIn must be positive");
        require(uint256(maxAmountIn) <= type(uint256).max, "MaxAmountIn exceeds uint256 max");
        require(minAmountOut > 0, "MinAmountOut must be positive");
        require(uint256(minAmountOut) <= type(uint256).max, "MinAmountOut exceeds uint256 max");

        uint256 amount = TokenUtils.transferFromUser(key.currency1, msg.sender, address(this), repayAmount);
        TokenUtils.approve(key.currency1, address(bank), amount);
        BalanceDelta delta = executeSwap(key, false, repayAmount, "");
        int256 amountIn = delta.amount1();
        require(amountIn <= maxAmountIn, "Excessive input amount");
        require(amountIn >= minAmountOut, "Insufficient output amount");
        emit Repaid(msg.sender, Currency.unwrap(key.currency1), repayAmount, amountIn);

        // Then withdraw
        bank.withdraw(key, withdrawAmount);
        TokenUtils.transfer(key.currency0, msg.sender, uint256(withdrawAmount));
        emit Withdrawn(msg.sender, Currency.unwrap(key.currency0), withdrawAmount);
    }

    // Helper function for emergency withdrawal - can be called even when paused
    function emergencyWithdraw(PoolKey calldata key, int256 withdrawAmount) external nonReentrant onlyOwner {
        require(withdrawAmount > 0, "Withdraw amount must be positive");
        require(uint256(withdrawAmount) <= type(uint256).max, "Amount exceeds uint256 max");
        bank.withdraw(key, withdrawAmount);
        TokenUtils.transfer(key.currency0, msg.sender, uint256(withdrawAmount));
        emit Withdrawn(msg.sender, Currency.unwrap(key.currency0), withdrawAmount);
    }
}
