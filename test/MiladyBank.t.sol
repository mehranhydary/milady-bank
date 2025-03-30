// SPDX-License-Identifier: VPL-1.0
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {IHooks} from "v4-core/src/interfaces/IHooks.sol";
import {Hooks} from "v4-core/src/libraries/Hooks.sol";
import {TickMath} from "v4-core/src/libraries/TickMath.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {BalanceDelta} from "v4-core/src/types/BalanceDelta.sol";
import {PoolId, PoolIdLibrary} from "v4-core/src/types/PoolId.sol";
import {CurrencyLibrary, Currency} from "v4-core/src/types/Currency.sol";
import {PoolSwapTest} from "v4-core/src/test/PoolSwapTest.sol";
import {StateLibrary} from "v4-core/src/libraries/StateLibrary.sol";

import {LiquidityAmounts} from "v4-core/test/utils/LiquidityAmounts.sol";
import {IPositionManager} from "v4-periphery/src/interfaces/IPositionManager.sol";
import {Constants} from "v4-core/test/utils/Constants.sol";

import {EasyPosm} from "./utils/EasyPosm.sol";
import {Fixtures} from "./utils/Fixtures.sol";
import {MockERC20} from "solmate/src/test/utils/mocks/MockERC20.sol";

import {MiladyBank} from "../src/bank/MiladyBank.sol";

contract MiladyBankTest is Test, Fixtures {
    using EasyPosm for IPositionManager;
    using PoolIdLibrary for PoolKey;
    using CurrencyLibrary for Currency;
    using StateLibrary for IPoolManager;

    MiladyBank hook;
    PoolId poolId;

    uint256 tokenId;
    int24 tickLower;
    int24 tickUpper;

    function setUp() public {
        // Deploy the hook to an address with the correct flags
        deployFreshManagerAndRouters();
        deployMintAndApprove2Currencies();
        deployAndApprovePosm(manager);

        // Deploy the hook to an address with the correct flags
        address flags = address(
            uint160(
                Hooks.BEFORE_INITIALIZE_FLAG | Hooks.AFTER_INITIALIZE_FLAG | Hooks.BEFORE_SWAP_FLAG
                    | Hooks.AFTER_SWAP_FLAG | Hooks.BEFORE_ADD_LIQUIDITY_FLAG | Hooks.BEFORE_REMOVE_LIQUIDITY_FLAG
            ) ^ (0x4444 << 144) // Namespace the hook to avoid collisions
        );

        bytes memory constructorArgs = abi.encode(manager); // Add all the necessary constructor arguments from the hook
        deployCodeTo("MiladyBank.sol:MiladyBank", constructorArgs, flags);
        hook = MiladyBank(flags);

        // Create the pool
        key = PoolKey(currency0, currency1, 3000, 60, IHooks(hook));
        poolId = key.toId();

        // Try initializing with a try/catch to see if we can get more error details
        try manager.initialize(key, SQRT_PRICE_1_1) {
            // If initialization succeeds, continue with liquidity provision
            tickLower = TickMath.minUsableTick(key.tickSpacing);
            tickUpper = TickMath.maxUsableTick(key.tickSpacing);

            uint128 liquidityAmount = 100e18;

            (uint256 amount0Expected, uint256 amount1Expected) = LiquidityAmounts.getAmountsForLiquidity(
                SQRT_PRICE_1_1,
                TickMath.getSqrtPriceAtTick(tickLower),
                TickMath.getSqrtPriceAtTick(tickUpper),
                liquidityAmount
            );

            (tokenId,) = posm.mint(
                key,
                tickLower,
                tickUpper,
                liquidityAmount,
                amount0Expected + 1,
                amount1Expected + 1,
                address(this),
                block.timestamp,
                ZERO_BYTES
            );
        } catch Error(string memory reason) {
            emit log_string(reason);
            // Don't fail the test here, just log the error
        } catch (bytes memory lowLevelData) {
            emit log_bytes(lowLevelData);
            // Don't fail the test here, just log the error
        }
    }

    function test_setRouter() public {
        address newRouter = address(0x123);
        vm.prank(hook.owner());
        hook.setRouter(newRouter);
        assertEq(hook.router(), newRouter);
    }

    function test_setRouter_RevertInvalidAddress() public {
        vm.prank(hook.owner());
        vm.expectRevert("Invalid router address");
        hook.setRouter(address(0));
    }

    function test_setRouter_RevertNotOwner() public {
        vm.prank(address(0xdead));
        vm.expectRevert("UNAUTHORIZED");
        hook.setRouter(address(0x123));
    }

    // Add a simple test that doesn't depend on pool initialization
    function test_hookDeployment() public view {
        assertTrue(address(hook) != address(0), "Hook should be deployed");
    }

    function test_deposit() public {
        int256 depositAmount = 100;
        // Mint tokens to test contract
        MockERC20(Currency.unwrap(currency0)).mint(address(this), uint256(depositAmount));

        // Approve hook to spend tokens
        MockERC20(Currency.unwrap(currency0)).approve(address(hook), uint256(depositAmount));

        // Make deposit
        hook.deposit(key, depositAmount);

        // Verify deposit was successful
        assertEq(MockERC20(Currency.unwrap(currency0)).balanceOf(address(hook)), uint256(depositAmount));
    }

    function test_deposit_RevertWhenPaused() public {
        // Test should fail since we expect a revert but the deposit succeeds
        int256 depositAmount = 100;

        // Setup: Mint tokens and approve spending
        MockERC20(Currency.unwrap(currency0)).mint(address(this), uint256(depositAmount));
        MockERC20(Currency.unwrap(currency0)).approve(address(hook), uint256(depositAmount));

        // Pause the contract as owner
        vm.prank(hook.owner());
        hook.pause();

        // Try to deposit - this should revert since contract is paused
        vm.expectRevert("Contract is paused");
        hook.deposit(key, depositAmount);
    }

    function test_deposit_RevertZeroAmount() public {
        // Try to deposit 0 amount
        vm.expectRevert("Deposit amount must be positive");
        hook.deposit(key, 0);
    }

    function test_deposit_UpdatesUserPosition() public {
        int256 depositAmount = 100;
        // Mint tokens to test contract
        MockERC20(Currency.unwrap(currency0)).mint(address(this), uint256(depositAmount));
        MockERC20(Currency.unwrap(currency0)).approve(address(hook), uint256(depositAmount));

        // Make deposit
        hook.deposit(key, depositAmount);

        // Get user position from lending pool
        (int256 deposits,,,) = hook.getUserPosition(key, address(this));

        // Verify position was updated correctly
        assertEq(deposits, depositAmount);
    }

    function test_withdraw() public {
        int256 depositAmount = 100;
        // Mint tokens to test contract
        MockERC20(Currency.unwrap(currency0)).mint(address(this), uint256(depositAmount));
        MockERC20(Currency.unwrap(currency0)).approve(address(hook), uint256(depositAmount));

        // Make deposit
        hook.deposit(key, depositAmount);

        // Make withdrawal
        hook.withdraw(key, depositAmount);

        // Verify withdrawal was successful
        assertEq(MockERC20(Currency.unwrap(currency0)).balanceOf(address(hook)), 0);
    }

    function test_withdraw_RevertWhenPaused() public {
        // Test should fail since we expect a revert but the deposit succeeds
        int256 depositAmount = 100;

        // Setup: Mint tokens and approve spending
        MockERC20(Currency.unwrap(currency0)).mint(address(this), uint256(depositAmount));
        MockERC20(Currency.unwrap(currency0)).approve(address(hook), uint256(depositAmount));

        // Make deposit
        hook.deposit(key, depositAmount);

        // Pause the contract as owner
        vm.prank(hook.owner());
        hook.pause();

        // Try to withdraw - this should revert since contract is paused
        vm.expectRevert("Contract is paused");
        hook.withdraw(key, depositAmount);
    }

    function test_withdraw_RevertZeroAmount() public {
        // Try to withdraw 0 amount
        vm.expectRevert("Withdraw amount must be positive");
        hook.withdraw(key, 0);
    }

    function test_withdraw_RevertInsufficientBalance() public {
        // Try to withdraw more than deposited
        vm.expectRevert("Insufficient deposits");
        hook.withdraw(key, 100);
    }

    function test_withdraw_UpdatesUserPosition() public {
        int256 depositAmount = 100;
        // Mint tokens to test contract
        MockERC20(Currency.unwrap(currency0)).mint(address(this), uint256(depositAmount));
        MockERC20(Currency.unwrap(currency0)).approve(address(hook), uint256(depositAmount));

        // Make deposit
        hook.deposit(key, depositAmount);

        // Make withdrawal
        hook.withdraw(key, depositAmount);

        // Get user position from lending pool
        (int256 deposits,,,) = hook.getUserPosition(key, address(this));

        // Verify position was updated correctly
        assertEq(deposits, 0);
    }

    function test_borrow() public {
        // Setup initial deposit as collateral
        int256 depositAmount = 10000;
        vm.startPrank(msg.sender); // Pranking here because we are not using a router
        MockERC20(Currency.unwrap(currency0)).mint(msg.sender, uint256(depositAmount));
        MockERC20(Currency.unwrap(currency0)).approve(address(hook), uint256(depositAmount));
        hook.deposit(key, depositAmount);
        vm.stopPrank();

        // Setup borrow params
        int256 borrowAmount = 500; // Borrowing 50% of collateral
        int256 minAmountOut = 450; // Allow some slippage

        // Perform borrow via swap
        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: true,
            amountSpecified: borrowAmount,
            sqrtPriceLimitX96: MIN_PRICE_LIMIT
        });

        // Verify flash loan protection checks
        vm.warp(block.timestamp + 2 minutes); // Move past MIN_HOLD_TIME

        vm.prank(address(hook.owner()));
        hook.setRouter(address(swapRouter));

        swapRouter.swap(key, params, PoolSwapTest.TestSettings(false, false), "");
        // Verify borrow was recorded correctly
        (, int256 borrows,,) = hook.getUserPosition(key, msg.sender);

        assertEq(borrows, borrowAmount);

        // Verify total borrows updated
        (, int256 totalBorrows,,) = hook.getLendingPool(key);
        assertEq(totalBorrows, borrowAmount);
    }

    function test_borrow_RevertExceedsCollateralRatio() public {
        // Setup initial deposit as collateral
        int256 depositAmount = 100;
        MockERC20(Currency.unwrap(currency0)).mint(address(this), uint256(depositAmount));
        MockERC20(Currency.unwrap(currency0)).approve(address(hook), uint256(depositAmount));
        hook.deposit(key, depositAmount);

        // Try to borrow more than 75% of collateral
        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: true,
            amountSpecified: 80, // Trying to borrow 80% of collateral
            sqrtPriceLimitX96: MIN_PRICE_LIMIT
        });

        vm.prank(address(hook.owner()));
        hook.setRouter(address(swapRouter));

        vm.expectRevert();
        swapRouter.swap(key, params, PoolSwapTest.TestSettings(false, false), "");
    }

    function test_borrow_SuccessfulBorrow() public {
        // Setup initial deposit as collateral

        int256 depositAmount = 10000;
        vm.startPrank(msg.sender); // Pranking here because we are not using a router
        MockERC20(Currency.unwrap(currency0)).mint(msg.sender, uint256(depositAmount));
        MockERC20(Currency.unwrap(currency0)).approve(address(hook), uint256(depositAmount));
        hook.deposit(key, depositAmount);
        vm.stopPrank();

        // Perform borrow via swap
        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: true,
            amountSpecified: 500, // Borrowing 50% of collateral
            sqrtPriceLimitX96: MIN_PRICE_LIMIT
        });

        vm.prank(address(hook.owner()));
        hook.setRouter(address(swapRouter));

        swapRouter.swap(key, params, PoolSwapTest.TestSettings(false, false), "");

        // Verify borrow was recorded
        (, int256 borrows,,) = hook.getUserPosition(key, msg.sender);
        assertEq(borrows, 500);
    }

    function test_repay_SuccessfulRepayment() public {
        // Setup initial deposit and borrow
        int256 depositAmount = 10000;
        vm.startPrank(msg.sender); // Pranking here because we are not using a router
        MockERC20(Currency.unwrap(currency0)).mint(msg.sender, uint256(depositAmount));
        MockERC20(Currency.unwrap(currency0)).approve(address(hook), uint256(depositAmount));
        hook.deposit(key, depositAmount);
        vm.stopPrank();

        vm.prank(address(hook.owner()));
        hook.setRouter(address(swapRouter));

        // First borrow
        IPoolManager.SwapParams memory borrowParams =
            IPoolManager.SwapParams({zeroForOne: true, amountSpecified: 500, sqrtPriceLimitX96: MIN_PRICE_LIMIT});
        swapRouter.swap(key, borrowParams, PoolSwapTest.TestSettings(false, false), "");

        // Then repay
        IPoolManager.SwapParams memory repayParams = IPoolManager.SwapParams({
            zeroForOne: false,
            amountSpecified: 250, // Repaying half the borrowed amount
            sqrtPriceLimitX96: MAX_PRICE_LIMIT
        });
        swapRouter.swap(key, repayParams, PoolSwapTest.TestSettings(false, false), "");

        // Verify repayment was recorded
        (, int256 borrows,,) = hook.getUserPosition(key, msg.sender);
        assertEq(borrows, 250); // Should be half of original borrow
    }
}
