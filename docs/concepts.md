---
hide:
  - navigation
  - toc
---

## Repository Flow

This document outlines the complete process flow for a repository on repo.trade, from submission to trading.
***
### Discovery Phase

The first step in the repo.trade process is repository discovery:

1. A repository is created on GitHub
2. The repository is submitted to repo.trade
3. Community members "like" the repository to indicate interest
4. Repositories reaching enough likes qualify for tokenization
***
### Verification Phase

Once a repository qualifies:

1. Repository ownership is verified
2. Token parameters are configured
3. Auction settings are established
***
### Auction Phase

The 14-day auction process:

1. Daily auctions distribute tokens proportionally to contributors
2. 35.7M tokens are auctioned each day (2.5% of total supply)
3. Minimum threshold must be met for auction success
4. If successful, tokens are generated; if not, contributors are refunded
***
### Trading Phase

After successful auction:

1. Tokens are distributed to community, owner, and reserves
2. Trading begins on the automated market maker (AMM)
3. Trading fees are distributed to repository owners and protocol
4. Secondary market activity continues indefinitely
***
### Benefits

This flow creates several advantages:

* Fair token distribution
* Sustainable funding for developers
* Community alignment around projects
* Market-based valuation of repositories
* Ongoing revenue through trading fees
***
## Namespaces in RepoTrade

Namespaces in RepoTrade are used to group and organize repositories. They serve as a way to categorize and manage repos within a specific domain or organization.

!!! info

    Namespaces are managed by repo.trade. So far, the only supported namespace is denoted to `github`. Fees can vary.
***
### Key Features of Namespaces

- Each namespace has a unique name and URI
- Namespaces are associated with an authority (owner)
- They include a swap fee setting (in basis points)
***
### Example from Unit Test

In the `repotrade.ts` test file, we can see how a namespace is created:

```typescript
const NAMESPACE_NAME = "github.com/";
const tx = await program.methods
  .initializeNamespace(NAMESPACE_NAME, "https://github.com/", 30) // 30 bps = 0.3% fee
  .accounts({
    state: statePda,
    namespace: namespacePda,
    authority: ADMIN_SIGNER.publicKey,
    mint: testUsdcMint,
    systemProgram: SystemProgram.programId,
  })
  .signers([ADMIN_SIGNER])
  .rpc();
```

In this example:

- The namespace name is set to "github.com/"
- The URI is set to "https://github.com/"
- A swap fee of 30 basis points (0.3%) is established
- An admin account is set as the authority

Namespaces provide a structured way to organize repos, making it easier for users to navigate and interact with related projects on the RepoTrade platform.
***
## Repos in Repo.Trade

In the context of Repo.Trade, a repo (repository) represents a project or codebase that can receive contributions and have its own token economy.
***
### Key Characteristics of Repos

- Each repo belongs to a namespace
- Repos have an auction period for initial contributions
- After the auction, repos enter a swapping state where tokens can be traded
***
### Repo State Structure

The repo state, defined in `programs/repotrade/src/states/repo.rs`, includes:

```rust
pub struct Repo {
    pub name: String,
    pub namespace_index: u32,
    pub owner: Pubkey,
    pub status: RepoStatus,
    pub auction: Auction,
    pub usdc_reserve: u64,
    pub token_reserve: u64,
    pub owner_fee_balance: u64,
    pub protocol_fee_balance: u64,
    pub owner_fee_claimed: u64,
    pub protocol_fee_claimed: u64,
    pub padding: [u64; 8],
}
```

Key components:

- name: The repo's name
- namespace_index: Index of the namespace it belongs to
- owner: Public key of the repo owner
- status: Current state of the repo (Pending, Auction, or Swapping)
- auction: Details about the auction phase
- usdc_reserve and token_reserve: Liquidity pools for swapping
- Fee-related fields for tracking balances and claims
***
### Example from Unit Test

In the repotrade.ts test file, we can see how a repo is created:

```typescript
const REPO_NAME = "solana-labs/solana";
const now = Math.floor(Date.now() / 1000);
const tx = await program.methods
  .initializeRepo(new anchor.BN(now), REPO_NAME)
  .accounts({
    repo: repoPda,
    namespace: namespacePda,
    payer: ADMIN_SIGNER.publicKey,
    systemProgram: SystemProgram.programId,
  })
  .signers([ADMIN_SIGNER])
  .rpc();
```

In this example:

- A new repo named "solana-labs/solana" is created
- The repo is associated with a specific namespace
- The current timestamp is used to set the start time for the auction
- An admin account initializes the repo

Repos in Repo.Trade serve as the central entity for managing project-specific token economies, facilitating contributions, and enabling token swaps after the initial auction period.
***
## Repo Statuses in Repo.Trade

Repos in Repo.Trade go through different statuses as they progress. These statuses determine what actions can be taken with the repo at any given time.
***
### Repo Status Enum

The repo status is defined in `programs/repotrade/src/states/repo.rs`:

```rust
pub enum RepoStatus {
    Pending,
    Auction,
    Swapping,
}
```
***
### Status Progression

1. Pending: Initial state when a repo is first created (Note: This state might be removed in future versions)
2. Auction: The contribution period where users can contribute USDC
3. Swapping: After the auction ends, the repo enters the swapping state where tokens can be traded
***
### State Transitions

#### Pending to Auction

This transition happens automatically when the repo is initialized. In the unit tests, we see this when a repo is created:

```typescript
const tx = await program.methods
  .initializeRepo(new anchor.BN(now), REPO_NAME)
  .accounts({
    repo: repoPda,
    namespace: namespacePda,
    payer: ADMIN_SIGNER.publicKey,
    systemProgram: SystemProgram.programId,
  })
  .signers([ADMIN_SIGNER])
  .rpc();

const repoAccount = await program.account.repo.fetch(repoPda);
expect(repoAccount.status.toString()).to.equal(RepoStates.Auction.toString());
```

#### Auction to Swapping

This transition occurs when tokens are claimed after the auction period. In the unit tests, we see this transition when claiming tokens:

```typescript
await program.methods
  .claimTokens()
  .accounts({
    repo: repoPda,
    angel: angelPda,
    namespace: namespacePda,
    tokenMint: repoMintPda,
    angelTokenAccount: await splToken.getAssociatedTokenAddress(
      repoMintPda,
      wallet.publicKey,
    ),
    repoTokenVault: repoTokenVaultPda,
    payer: wallet.publicKey,
    tokenProgram: TOKEN_PROGRAM_ID,
    associatedTokenProgram: ASSOCIATED_TOKEN_PROGRAM_ID,
    systemProgram: SystemProgram.programId,
  })
  .signers([payer])
  .rpc();

const repoAccount = await program.account.repo.fetch(repoPda);
expect(repoAccount.status.toString()).to.equal(RepoStates.Swapping.toString());
```
***
### Impact of Status on Repo Actions

- During the Auction status:
  - Users can contribute USDC to the repo
  - Tokens cannot be claimed or swapped yet

- During the Swapping status:
  - Contributions are no longer accepted
  - Users can claim their tokens based on their contributions
  - Tokens can be swapped with USDC

Understanding these statuses and transitions is crucial for users to know when they can contribute, claim tokens, or start trading.
***
## Rewards

The purpose of repo.trade is to provide a stream of funding to software developers that implement popular open source software.
***
### Fee Distribution

50/50 Split

The fees collected on Repo.Trade are divided equally between two parties:

1. Protocol Fees: 50% of the fees go to the Repo.Trade protocol.
2. Owner Fees: 50% of the fees go to the verified owner of the repository.

This equal distribution ensures that:

- The protocol can sustain and improve its services.
- Repository owners are incentivized to participate and maintain their projects.
***
### Owner Verification

To claim owner fees, repository owners must go through a verification process:

1. Owners need to authenticate through GitHub.
2. This process verifies their ownership of the repository.
3. Only after successful verification can owners claim their share of the fees.
***
### Fee Accumulation and Claiming

- Owner fees accumulate in the repository's account.
- Verified owners can claim these fees periodically and at any time.
- Unclaimed fees remain in the repository's account until claimed.
- As long as a repository has no owner, the owner rewards will continue to accumulate
***
### Importance of Verification

The verification process through GitHub serves several purposes:

- Ensures that fees are distributed to legitimate repository owners.
- Prevents unauthorized claims on repository fees.
- Maintains the integrity and trust in the Repo.Trade ecosystem.

!!! warning

    Currently only **personal** accounts can verify their repositories.
    Organizational repositories will be supported in a future update.
***
## Swaps in Repo.Trade

Swaps in Repo.Trade allow users to exchange USDC for repo tokens and vice versa. This feature becomes available once a repo enters the Swapping state after its initial auction period.
***
### How Swaps Work

1. Users can swap USDC for repo tokens or repo tokens for USDC.
2. The swap rate is determined by the current reserves of USDC and repo tokens.
3. Each swap incurs a fee, set by the namespace.
***
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

Swaps incur a fee, which is set at the namespace level.
This fee is applied to each swap, contributing to the liquidity and sustainability of the system.
***
### Conclusion

Swaps are a crucial feature in Repo.Trade, allowing users to trade between USDC and repo tokens. The constant product formula ensures fair pricing, while fees contribute to the ecosystem's sustainability. Understanding how swaps work is essential for users looking to participate in the token economy of various repos.