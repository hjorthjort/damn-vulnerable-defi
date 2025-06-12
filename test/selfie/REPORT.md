# Finding 1

## Description

SimpleGovernance only checks the current voting power of the caller using `getVotes` when queuing an action. Because votes are based on the current balance, an attacker can borrow tokens from `SelfiePool` in a flash loan, self‑delegate and queue a malicious action within the same transaction. After returning the tokens the attacker keeps no voting power, yet the governance action remains queued and can be executed after the delay. Using this trick the attacker can call `emergencyExit` and drain the pool.

## Recommendation

Use time-based snapshots for voting power (e.g. `getPastVotes`) or require tokens to be locked or delegated before the action delay starts, preventing flash loans from affecting governance decisions.
