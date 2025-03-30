# Milady Bank Protocol V0

Milady Bank is a lending and borrowing protocol built with Uniswap v4 hooks. The protocol focuses on offering optimized interest rates.

## 🏦 24-Hour Hackathon Project 🚀

This innovative lending protocol was built in just **24 hours** during the **Unichain Friends and Family Hackathon** (March 29-30, 2024)! It showcases groundbreaking possibilities for optimized lending using Uniswap v4's powerful hook system.

---

⚠️ **IMPORTANT SECURITY NOTICE** ⚠️

This is an experimental proof-of-concept created during a hackathon environment. The codebase:

-   Has not been security audited
-   Needs significant additional development
-   Is NOT ready for production use
-   Should be used at your own risk

---

## Architecture

### MiladyBank Contract

This contract is the central component of the protocol, handling:

-   **Deposit Management**: Users can deposit assets to earn interest and use as collateral
-   **Borrowing Logic**: Facilitates borrowing against deposited collateral
-   **Interest Rate Model**: Dynamic interest rates based on utilization
-   **Health Monitoring**: Tracks user positions and collateralization ratios
-   **Liquidation Triggers**: Initiates liquidations when positions become unhealthy

Key features:

-   Isolated risk markets for each asset pair
-   Optimized capital efficiency through Uniswap v4 integration
-   Real-time interest rate adjustments

#### Truncated Oracle Implementation

MiladyBank integrates Uniswap v4's truncated oracle hook for secure price feeds:

-   **Manipulation Resistance**: The oracle limits price movement per block, making it significantly more expensive to manipulate
-   **Geometric Mean Formula**: Records asset prices using a geometric mean calculation
-   **Smoothed Price Impact**: Large swaps (legitimate or malicious) have their price impact smoothed over time
-   **Enhanced Security**: Requires sustained price manipulation across multiple blocks, protecting against flash loan attacks
-   **TWAP Integration**: Uses time-weighted average prices with a 30-minute period for stable pricing

The truncated oracle is critical for the protocol's liquidation system, ensuring positions aren't unfairly liquidated due to temporary price spikes or manipulation attempts.

### MiladyBankRouter Contract

This contract serves as the user facing interface to the protocol:

-   **Simplified Interactions**: Provides easy-to-use functions for deposits, withdrawals, borrows, and repayments
-   **Multi-Asset Operations**: Allows operations across multiple assets in a single transaction
-   **Position Management**: Helps users manage their lending/borrowing positions
-   **Flash Loan Integration**: Supports flash loans for advanced use cases

Key features:

-   Gas-optimized transaction batching
-   Slippage protection for users
-   Simplified position management

## How to use

1. **Deposit Assets**: Add liquidity to the pool to start earning interest
2. **Borrow Assets**: Once collateral is deposited, borrow other assets through swaps
3. **Repay Loans**: Return borrowed assets through reverse swaps
4. **Withdraw**: Remove your deposited assets when desired

## What's next

### MiladyBank Contract Roadmap

-   **Risk Parameter Optimization**: Fine-tuning collateralization ratios and liquidation thresholds
-   **Advanced Interest Rate Models**: Implementing more sophisticated models based on market conditions
-   **Governance Integration**: Adding protocol governance for parameter adjustments
-   **Insurance Fund**: Developing a protocol safety mechanism
-   **Oracle Improvements**: Enhancing the truncated oracle with additional security features and fallback mechanisms

### MiladyBankRouter Roadmap

-   **Position Optimization**: Automatic position rebalancing to minimize liquidation risk
-   **Limit Orders**: Setting conditional borrows/repayments based on interest rates
-   **Strategy Integration**: Connecting with yield strategies for idle assets
-   **Mobile-Friendly Interface**: Simplified interactions for mobile users

### Multi-Asset Expansion

As we add more assets (ETH, BTC, USDC, USDT, etc.), the architecture will evolve:

-   **Isolated Markets**: Each asset pair will have its own risk parameters
-   **Cross-Collateralization**: Optional pooling of collateral across markets
-   **Oracle Network Expansion**: Additional price feeds for new assets
-   **Risk-Adjusted Interest Rates**: Different rates based on asset volatility
-   **Liquidity Mining Incentives**: Targeted rewards for underserved markets

The modular design allows for seamless addition of new assets without disrupting existing markets.

### Current Test Coverage for MiladyBank

The test suite currently covers core functionality:

**Contract Setup & Admin**

-   Hook deployment and initialization
-   Router address setting and validation
-   Pause/unpause functionality
-   Owner permission checks

**Deposits & Withdrawals**

-   Basic deposit functionality
-   Deposit amount validation
-   Deposit state updates
-   Basic withdrawal functionality
-   Withdrawal amount validation
-   Withdrawal state updates
-   Paused contract restrictions

**Borrowing**

-   Basic borrow via swaps
-   Collateral ratio enforcement
-   Flash loan protection
-   Borrow amount tracking
-   Interest rate calculations

**Repayment**

-   Basic repayment via swaps
-   Repayment amount validation
-   Position updates after repayment

### Additional Tests Needed

**Edge Cases & Security**

-   Reentrancy protection
-   Integer overflow/underflow
-   Extreme price movement scenarios
-   Maximum position sizes
-   Dust amounts

**Interest Accrual**

-   Interest calculation accuracy
-   Interest compounding
-   Interest distribution
-   Rate updates

**Liquidations**

-   Liquidation triggers
-   Liquidation bonus calculations
-   Partial liquidations
-   Failed liquidation scenarios

**Oracle Integration**

-   Price feed failures
-   Stale price protection
-   Price manipulation resistance

**Multi-Asset Interactions**

-   Cross-collateral positions
-   Multi-asset liquidations
-   Asset-specific parameters

**Integration Tests**

-   Complex user flows
-   Multi-operation sequences
-   External protocol interactions

## Testing

To test the protocol locally:

1. Get a Unichain RPC URL from Alchemy:

    - Create an account at https://www.alchemy.com/
    - Create a new app for Unichain network
    - Copy the HTTPS endpoint URL

2. Start Anvil with a fork:

-   Run `anvil --fork-url https://mainnet.unichain.org`

3. Test your code

-   Run `forge test --fork-url http://localhost:8545`
