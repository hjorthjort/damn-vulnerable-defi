# Finding 1

## Description

A user can take away the rewards for everyone, using a single claim, by performing a claim with the same `Claim` structure repeated. If Alice can claim X DVT tokens, she can make an array, length N, with the same claim for X tokens, and the `reamining` amount for that token will be decreaded by `X * N`, even though she only receives X tokens.

See the `sabotage` test for a way to drain the `remaining`.