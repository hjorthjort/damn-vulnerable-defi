# Finding 1

## Description

The flash loan relies on ether balance without checking that the balances accounting is respected. So it is possible to use the funds from a flash loan to return the money to the pool with a deposit. This means the total number of deposits exceed the balance held in the pool. An attacker can simply make a deposit with their flash loan, which would be treated as the loan having been repaid.

## Recommendation

Use `nonReentrant` to ensure there is no reentrancy on the pool during a flash loan.

Another solution would be to have the pool enforce the invariant that total deposits are at most equal to total balance, by tracking total balances. This solution also allows any extra ether sent to the pool, via mining or self-destruct, to be extracted via flash loan.
