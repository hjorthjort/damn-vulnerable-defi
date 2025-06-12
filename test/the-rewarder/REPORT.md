# Finding 1

## Description

A user can take away the rewards for everyone, using a single claim, by performing a claim with the same `Claim` structure repeated. If Alice can claim X DVT tokens, she can make an array, length N, with the same claim for X tokens, and the take `N * X` tokens.

## Recommendation

Simplify the claiming logic. A user is only supposed to make one claim per token per transaction. The first `if`-case is sufficient, and no bit fiddling is necessary: just set whether or not a user has already made their claim for a specific token and batch. Make sure you identify each possible claim uniqely. Assuming the Merkle trees only ever contains one address once, you can safely mark a user as having claimed with the tuple `(msg.sender, token, batchNumber)`.

# Finding 2

## Description

The `createDistribution()` function is unprotected. It should only be available to the owner to avoid someone maliciously creating distributions and causing DoS.