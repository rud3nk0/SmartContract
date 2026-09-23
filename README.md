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

A basic tutorial contract for practicing Solidity fundamentals: state variables, events, custom errors, and access modifiers.

**Functions:**
- `increment()` / `decrement()` — increments or decrements the counter; accessible to everyone
- `reset()` — resets the counter to 0; accessible only to the contract owner (`onlyOwner` modifier)
- `getCount()` — reads the current value (`view`, free call)

**Shows:** the difference between a transaction (writes to the blockchain, costs gas) and a read call (`view`, free); the access control pattern using `modifier` and `custom error`.
### `MyToken.sol`

An ERC-20 token based on [OpenZeppelin](https://www.openzeppelin.com/contracts), with a cap on the maximum supply.

**Parameters:** name `MyToken`, ticker `MTK`, `MAX_SUPPLY = 1,000,000 MTK`. Upon deployment, the owner is immediately credited with 100,000 MTK.

**Functions:**
- `mint(address to, uint256 amount)` — mints new tokens; only the owner can do this; cannot exceed `MAX_SUPPLY`
- `burn(uint256 amount)` — burns the owner’s own tokens; available to any holder
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

The tests are located in `test/` and are written using `node:test` + `viem` (Hardhat 3’s built-in test runner). Each contract is covered by tests that check:
- the correctness of the initial state after deployment
- access permissions (what happens if a function is called by someone other than the owner)
- edge cases (exceeding limits, attempting to withdraw before the time limit expires, etc.)

```bash
npx hardhat test
```

## Disclaimer

These contracts are written for educational purposes, have not undergone a professional security audit, and are not intended for deployment on mainnet with real assets without independent verification.
