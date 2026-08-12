# EVM NFT Bulk Transfer

v10 includes transfer diagnostics for ERC-721 helper troubleshooting.


## v11 — ERC-1155 auto-discovery

ERC-1155 holdings are now discovered automatically by scanning only the selected collection contract's `TransferSingle` and `TransferBatch` events involving the connected wallet. Candidate token IDs are then verified with `balanceOfBatch()` so only current non-zero balances are shown.

This is contract-scoped discovery, not a scan of unrelated contracts or general blockchain activity. Manual token IDs remain available as a fallback.
