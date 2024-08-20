## Swaps in Repo.Trade

### Overview

Swaps in Repo.Trade allow users to exchange USDC for repo tokens and vice versa. This feature becomes available once a repo enters the Swapping state after its initial auction period.

### How Swaps Work

1. Users can swap USDC for repo tokens or repo tokens for USDC.
2. The swap rate is determined by the current reserves of USDC and repo tokens.
3. Each swap incurs a fee, set by the namespace.

### Swap Mathematics

The swap mechanism uses a constant product formula, similar to many decentralized exchanges. The core function is `calculate_amount_out` in `programs/repotrade/src/math/curve.rs`:

```rust
pub fn calculate_amount_out(
amount_in_with_fee: u64,
reserve_in: u64,
reserve_out: u64,
) -> Option<u64> {
  let numerator = (amount_in_with_fee as u128).checked_mul(reserve_out as u128)?;
  let denominator = (reserve_in as u128).checked_add(amount_in_with_fee as u128)?;
  Some((numerator / denominator) as u64)
}
```

This function ensures that the product of the reserves remains constant after the swap, maintaining price equilibrium.

Here's an example of a swap from the `tests/repotrade.ts` file:

```typescript
const usdcAmount = new anchor.BN(1_000_000); // 1 USDC
await program.methods
  .swap(usdcAmount, true)
  .accounts({
    repo: repoPda,
    namespace: namespacePda,
    userAccount: userUsdcAccount,
    userTokenAccount: userTokenAccount,
    mint: testUsdcMint,
    tokenMint: repoMintPda,
    repoTokenVault: repoTokenVaultPda,
    repoVault: repoVaultPda,
    payer: wallet.publicKey,
    tokenProgram: TOKEN_PROGRAM_ID,
  })
  .rpc();
```

In this example:

- The user is swapping 1 USDC for repo tokens.
- The true parameter indicates it's a USDC to repo token swap (false would be the reverse).
- The necessary accounts are provided for the swap operation.

Swaps incur a fee, which is set at the [namespace level](./namespaces.md).
This fee is applied to each swap, contributing to the liquidity and sustainability of the system.

## Conclusion

Swaps are a crucial feature in Repo.Trade, allowing users to trade between USDC and repo tokens. The constant product formula ensures fair pricing, while fees contribute to the ecosystem's sustainability. Understanding how swaps work is essential for users looking to participate in the token economy of various repos.
