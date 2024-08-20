## Repos in Repo.Trade

In the context of Repo.Trade, a repo (repository) represents a project or codebase that can receive contributions and have its own token economy.

### Key Characteristics of Repos

- Each repo belongs to a namespace
- Repos have an auction period for initial contributions
- After the auction, repos enter a swapping state where tokens can be traded

### Repo State Structure

The repo state, defined in `programs/repotrade/src/states/repo.rs`, includes:

````rust
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

 * name: The repo's name
 * namespace_index: Index of the namespace it belongs to
 * owner: Public key of the repo owner
 * status: Current state of the repo (Pending, Auction, or Swapping)
 * auction: Details about the auction phase
 * usdc_reserve and token_reserve: Liquidity pools for swapping
 * Fee-related fields for tracking balances and claims

## Example from Unit Test

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
````

In this example:

- A new repo named "solana-labs/solana" is created
- The repo is associated with a specific namespace
- The current timestamp is used to set the start time for the auction
- An admin account initializes the repo

Repos in Repo.Trade serve as the central entity for managing project-specific token economies, facilitating contributions, and enabling token swaps after the initial auction period.

## Repo Statuses in Repo.Trade

Repos in Repo.Trade go through different statuses as they progress. These statuses determine what actions can be taken with the repo at any given time.

### Repo Status Enum

The repo status is defined in `programs/repotrade/src/states/repo.rs`:

```rust
pub enum RepoStatus {
    Pending,
    Auction,
    Swapping,
}
```

### Status Progression

1 Pending: Initial state when a repo is first created (Note: This state might be removed in future versions)
2 Auction: The contribution period where users can contribute USDC
3 Swapping: After the auction ends, the repo enters the swapping state where tokens can be traded

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

### Impact of Status on Repo Actions

- During the Auction status:

  - Users can contribute USDC to the repo
  - Tokens cannot be claimed or swapped yet

- During the Swapping status:
  - Contributions are no longer accepted
  - Users can claim their tokens based on their contributions
  - Tokens can be swapped with USDC

Understanding these statuses and transitions is crucial for users to know when they can contribute, claim tokens, or start trading.
