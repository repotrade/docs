# The flow

```mermaid
flowchart TD
 A[Namespace] -->|initialize_repo| B(Repo)
 B -->|initialize_auction| C(Auction)
 C -->|initialize_mint| D(Mint)
 D -->|initialize_swap| E(Swap)
```
