# Solidity Practice Contracts

A learning repository featuring Solidity smart contracts written while studying development on EVM-compatible blockchains. Each contract is accompanied by tests.

Stack: [Hardhat 3](https://hardhat.org/), [viem](https://viem.sh/), Solidity `^0.8.24`/`^0.8.34`, [OpenZeppelin Contracts](https://www.openzeppelin.com/contracts).

## Installation

```bash
npm install
```

## Running Tests

```bash
npx hardhat test
```

---

## Contracts

### `Counter.sol`

A basic tutorial contract for practicing Solidity fundamentals: state variables, events, custom errors, access modifiers, and internal helper functions.

**Functions:**
- `inc()` / `incBy(uint by)` — increments the counter by 1 or by a custom amount; accessible to everyone
- `double()` — multiplies the current counter value by 2
- `isEven()` — returns `true`/`false` depending on whether the current value is even (`view`, free call)
- `max` / `min` (public state variables) — automatically track the highest and lowest values the counter has ever reached, updated internally after every state-changing call via a shared `_updateMinMax()` helper

**Shows:** the difference between a transaction (writes to the blockchain, costs gas) and a read call (`view`, free); modular arithmetic (`%`) for parity checks; the DRY principle in Solidity — extracting repeated logic into an `internal` helper function reused across multiple state-changing functions; using `type(uint256).max` to safely initialize a "running minimum" tracker in the constructor.

---

### `MyToken.sol`

An ERC-20 token based on [OpenZeppelin](https://www.openzeppelin.com/contracts), with a cap on the maximum supply.

**Parameters:** name `MyToken`, ticker `MTK`, `MAX_SUPPLY = 1,000,000 MTK`. Upon deployment, the owner is immediately credited with 100,000 MTK.

**Functions:**
- `mint(address to, uint256 amount)` — mints new tokens; only the owner can do this; cannot exceed `MAX_SUPPLY`
- `burn(uint256 amount)` — burns the caller's own tokens; available to any holder
- Inherits the entire standard ERC-20 interface: `transfer`, `approve`, `transferFrom`, `balanceOf`, etc.

**Highlights:** inheritance from audit-verified libraries instead of writing the standard from scratch; the `Ownable` pattern; issuance limits on top of the standard ERC-20.

---

### `TokenVesting.sol`

A vesting contract for `MyToken` tokens for a single beneficiary, with a cliff period.

**Logic:**
- Upon deployment, a fixed amount of tokens is locked into the contract for a specific address (`beneficiary`)
- Until the end of the cliff period (90 days), the tokens are not available for withdrawal
- After the cliff period, the tokens are unlocked linearly, in proportion to the elapsed time, until the full `vestingDuration` (1 year)

**Demonstrates:** working with `block.timestamp` for time-based logic; linear vesting calculations; a typical pattern used in the tokenomics of real-world projects (the team and investors receive tokens gradually rather than all at once).

---

## Tests

The tests are located in `test/` and are written using `node:test` + `viem` (Hardhat 3's built-in test runner). Each contract is covered by tests that check:
- the correctness of the initial state after deployment
- access permissions (what happens if a function is called by someone other than the owner)
- edge cases (exceeding limits, attempting to withdraw before the time limit expires, running totals like `max`/`min` staying consistent across multiple calls, etc.)

```bash
npx hardhat test
```

## Disclaimer

These contracts are written for educational purposes, have not undergone a professional security audit, and are not intended for deployment on mainnet with real assets without independent verification.
