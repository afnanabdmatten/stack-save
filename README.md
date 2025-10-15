# stack-save

Simple STX savings vault (Clarity). Lets users lock STX for a chosen number of blocks and withdraw after the lock period.

## Contract
- File: contracts/stack-save.clar
- Provides:
  - deposit(amount: uint, lock-period: uint, block-height-contract: principal)
  - withdraw(block-height-contract: principal)
  - get-lock-info(user: principal) -> { amount, unlock-block }
  - get-total-deposits() -> uint

## Notes
- Uses a block-height trait to read the current chain height via a helper contract.
- Each account can have one active deposit. Deposits store amount and unlock-block.
- Errors:
  - u100: user already has a deposit
  - u101: invalid deposit amount
  - u102: no deposit found
  - u103: funds still locked
  - u104/u105: transfer failed

## Local checks & tests (Windows PowerShell)
- Install Clarinet (if not installed): follow Clarinet docs.
- Compile/check contracts:
  clarinet check
- Run contract tests:
  clarinet test
- Run project npm tests (if present):
  npm test

## Example usage (high-level)
- Deploy a block-height provider contract that implements `block-height-trait`.
- Pass the deployed provider principal as the `block-height-contract` argument when calling `deposit` and `withdraw`.
- Example (pseudo):
  - deposit: (contract-call? .stack-save deposit u1000 u1440 STX_BLOCK_HEIGHT_PROVIDER)
  - withdraw: (contract-call? .stack-save withdraw STX_BLOCK_HEIGHT_PROVIDER)

## License
MIT
```// filepath: c:\Users\USER\Desktop\STACKS\OCTOMBER\stack-save\README.md
# stack-save

Simple STX savings vault (Clarity). Lets users lock STX for a chosen number of blocks and withdraw after the lock period.

## Contract
- File: contracts/stack-save.clar
- Provides:
  - deposit(amount: uint, lock-period: uint, block-height-contract: principal)
  - withdraw(block-height-contract: principal)
  - get-lock-info(user: principal) -> { amount, unlock-block }
  - get-total-deposits() -> uint

## Notes
- Uses a block-height trait to read the current chain height via a helper contract.
- Each account can have one active deposit. Deposits store amount and unlock-block.
- Errors:
  - u100: user already has a deposit
  - u101: invalid deposit amount
  - u102: no deposit found
  - u103: funds still locked
  - u104/u105: transfer failed

## Local checks & tests (Windows PowerShell)
- Install Clarinet (if not installed): follow Clarinet docs.
- Compile/check contracts:
  clarinet check
- Run contract tests:
  clarinet test
- Run project npm tests (if present):
  npm test

## License
MIT
