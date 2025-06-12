# Finding 1

## Description

The governance vote mechanism is naive. It allows any holder at any time to create an action, as long as they have the requsite balance at the time of creating it. By flash loaning the tokens in the pool, an account can momentarily hold the requisite number of tokens, delegate them to himself, and create a governance action.

Note that it may be hard to pull this attack off in practice. The governance action will be created two days before it can be executed, giving plenty of time to exit the pool for large holders. Even so, it is unlikely that all the funds will be pulled in time, depending on how large the protocol is and how many holders stay up to date with the goings on.

## Recommendation

Alternatively, use `getPastVotes()` instead of `getVotes()`. Use the most recent block. This prevents users from having their votes counted via flash loan, becuase their votes will always be reset at the end of the transaction, during the transfer of funds back.