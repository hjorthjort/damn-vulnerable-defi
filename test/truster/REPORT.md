# Fidning 1

## Description

The Truster can be made to perform any contract call thorugh the flash loans. In particular, it can be made to call the DVT, which is the source of its funds, and make an approval. An approval doesn't immediately drain tokens so it will not be detected at the end of the flash loan call that something is amiss. Letting the contract make any call the borrower specifies is a dangerous pattern, and discouraged, as it makes the Truster into a zombie that can do the caller's bidding.

## Recommendation

Use the standard ERC3156 approach of calling only `onFlashLoan()` on a given address, and requiring it returns `keccak256("ERC3156FlashBorrower.onFlashLoan")`. This means that only a specific function signature can be called.