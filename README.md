# Milady Bank Protocol V0

This is a protocol that takes a new approach to borrowing and lending on chain. This protocol uses Uniswap v4 Hooks for optimized interest rates.

## Basics

1. There is a dynamic interest rate model (5%). As users use the liquidity, the interest rate will update in real time.
2. There is a pool that tracks deposits and borrows, handles interest accrual, and updates state on position changes.

## How to use?

1. Users deposit their asset into the pool by adding liquidity
2. Once liquidity is added, they can brorrow through swaps
3. They can repay through reverse swaps

<details>
<summary>Updating to v4-template:latest</summary>

This template is actively maintained -- you can update the v4 dependencies, scripts, and helpers:

```bash
git remote add template https://github.com/uniswapfoundation/v4-template
git fetch template
git merge template/main <BRANCH> --allow-unrelated-histories
```

</details>

---

### Check Forge Installation

_Ensure that you have correctly installed Foundry (Forge) Stable. You can update Foundry by running:_

```
foundryup
```

> _v4-template_ appears to be _incompatible_ with Foundry Nightly. See [foundry announcements](https://book.getfoundry.sh/announcements) to revert back to the stable build

## Set up

_requires [foundry](https://book.getfoundry.sh)_

```
forge install
forge test
```

### Local Development (Anvil)

Other than writing unit tests (recommended!), you can only deploy & test hooks on [anvil](https://book.getfoundry.sh/anvil/)

```bash
# start anvil, a local EVM chain
anvil

# in a new terminal
forge script script/Anvil.s.sol \
    --rpc-url http://localhost:8545 \
    --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
    --broadcast
```

See [script/](script/) for hook deployment, pool creation, liquidity provision, and swapping.

---

<details>
<summary><h2>Troubleshooting</h2></summary>

### _Permission Denied_

When installing dependencies with `forge install`, Github may throw a `Permission Denied` error

Typically caused by missing Github SSH keys, and can be resolved by following the steps [here](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh)

Or [adding the keys to your ssh-agent](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#adding-your-ssh-key-to-the-ssh-agent), if you have already uploaded SSH keys

### Hook deployment failures

Hook deployment failures are caused by incorrect flags or incorrect salt mining

1. Verify the flags are in agreement:
    - `getHookCalls()` returns the correct flags
    - `flags` provided to `HookMiner.find(...)`
2. Verify salt mining is correct:
    - In **forge test**: the _deployer_ for: `new Hook{salt: salt}(...)` and `HookMiner.find(deployer, ...)` are the same. This will be `address(this)`. If using `vm.prank`, the deployer will be the pranking address
    - In **forge script**: the deployer must be the CREATE2 Proxy: `0x4e59b44847b379578588920cA78FbF26c0B4956C`
        - If anvil does not have the CREATE2 deployer, your foundry may be out of date. You can update it with `foundryup`

</details>

---

Additional resources:

[Uniswap v4 docs](https://docs.uniswap.org/contracts/v4/overview)

[v4-periphery](https://github.com/uniswap/v4-periphery) contains advanced hook implementations that serve as a great reference

[v4-core](https://github.com/uniswap/v4-core)

[v4-by-example](https://v4-by-example.org)

FYI

MiladyBank.sol: Core contract with main logic
LendingPool.sol: Pool-related structs and functions
OracleManager.sol: Oracle-related functions and TWAP logic
LiquidationManager.sol: Liquidation and health check functions
InterestRateModel.sol: Interest rate calculations
Events.sol: Event definitions
Types.sol: Shared structs and constants
