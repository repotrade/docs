## Namespaces in RepoTrade

Namespaces in RepoTrade are used to group and organize repositories. They serve as a way to categorize and manage repos within a specific domain or
organization.

!!! info

    Namespaces are managed by repo.trade. So far, the only supported namespace is denoted to `github`. Fees can vary.

### Key Features of Namespaces

- Each namespace has a unique name and URI
- Namespaces are associated with an authority (owner)
- They include a swap fee setting (in basis points)

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


In this example:

* The namespace name is set to "github.com/"
* The URI is set to "https://github.com/"
* A swap fee of 30 basis points (0.3%) is established
* An admin account is set as the authority

Namespaces provide a structured way to organize repos, making it easier for users to navigate and interact with related projects on the RepoTrade platform.


```
