# Finding 1

## Description

The check on ERC4626 invariants during flash loans is too strict.

```solidity
uint256 balanceBefore = totalAssets();
if (convertToShares(totalSupply) != balanceBefore) revert InvalidBalance();
```

`convertToShares()`:

```solidity
function convertToShares(uint256 assets) public view virtual returns (uint256) {
    uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

    return supply == 0 ? assets : assets.mulDivDown(supply, totalAssets());
}
```

This calculates 

$$\frac{totalAssets() \cdot totalSupply}{totalAssets()} = totalSupply$$

Hence the check enforces that `totalSupply == totalAssets()`, which is only true
when the ERC4626 vault has not accrued any value. Making the vault accrue value
is trivial, since the `totalSupply()` function simply checks the balance of DIV tokens in the contract:

```solidity
function totalAssets() public view override nonReadReentrant returns (uint256) {
    return asset.balanceOf(address(this));
}
```

So by passing any amount of tokens to the vault, this "invariant" is violated and flash loans will fail.

## Recommendation

Remove the check altogether: it does not serve any particular purpose.

# Finding 2

## Description

There is a trivial "solution" to pass the test: just advance time to where the grace period is over. At this time the Monitor, which expects only there to be no fee, will fail its flash loan, and the test passes.

## Recommendation

When checking the solution, also check that the time stamp has not advanced beyond the end of the grace period.



