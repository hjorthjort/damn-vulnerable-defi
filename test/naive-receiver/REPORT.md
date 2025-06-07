# Finding 1

## Description

`multicall()` slices up the `msg.data` bytes, so it's not safe to rely on `msg.data` having the shape that the forwarder intends.

It is well known that using Multicall can be dangerous because of the context -- e.g. `msg.value`,`msg.sender` -- being the same throughout each separate `delegatecall` under the `multicall()`. In this instance, since there is authorization logic relying on `msg.data`, namely `_msgSender()` in the pool, is possible to have the `msg.sender` bet the trusted forwarder, but the calldata not have the standard shape, where the `Request` signer is appended at the end of `msg.data`.

By calling `multicall()` with an address of our choice appended to the end of each bytes array, we can trigger calls from an arbitrary `_msgSender()`.

## Recommendation

The basic forwarder is not safe to use in conjunction with Multicall.

For a somewhat janky solution, you could have the trusted forwarder set a state variable `currentCaller`, that is valid for the duration of the external call, which any contract using the the trusted forwarder would pull the current address from. This does not rely on any specific handling of the calldata.

# Finding 2

## Description

The example fee receiver doesn't properly protect against unauthorized flash loans.

When a flash loan is sent to it, it will always accept it as long as it's from the right pool (and for the correct token), regardless of where it was initiated. It will then pay the fee. Since the fee is 1 WETH and the contract holds 10 WETH, creating 10 flash loans will drain the receiver.

## Recommendation

Check the `initiator` field of the `onFlashLoan` function, and only accept whitelisted initiators. One sensible way to do this could be to add a function in the receiver which initiates the flash loans, and only accept `address(this)` as initiator. The function could charge 1 WETH from the caller, and return any surplus to the caller, so that the balance is kept.
