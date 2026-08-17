# EVM NFT Bulk Transfer

v10 includes transfer diagnostics for ERC-721 helper troubleshooting.


## v11 — ERC-1155 auto-discovery

ERC-1155 holdings are now discovered automatically by scanning only the selected collection contract's `TransferSingle` and `TransferBatch` events involving the connected wallet. Candidate token IDs are then verified with `balanceOfBatch()` so only current non-zero balances are shown.

This is contract-scoped discovery, not a scan of unrelated contracts or general blockchain activity. Manual token IDs remain available as a fallback.


## v12 — automatic RPC failover

ERC-1155 contract-scoped log discovery now rotates through available providers automatically.

Priority:
1. user-supplied Read-only RPC override
2. configured/default read provider
3. connected wallet provider
4. known public fallbacks for the connected chain

Ethereum mainnet public fallbacks:
- PublicNode Ethereum
- Cloudflare Ethereum Gateway

Base public fallbacks:
- Base official public RPC
- PublicNode Base

The UI displays the read provider that most recently succeeded. If a provider returns 401/403, CORS/fetch failures, RPC errors, or refuses `eth_getLogs`, the app tries the next provider before shrinking the block window or giving up.

## v13 — Wallet Batch

Adds EIP-5792 capability detection with `wallet_getCapabilities`, an optional Wallet Batch transfer mode using `wallet_sendCalls`, and status lookup through `wallet_getCallsStatus`. Wallet Batch remains disabled when the connected wallet does not advertise support.


## v14 — Robinhood browser RPC fix

Robinhood Chain (4663) no longer uses `https://rpc.mainnet.chain.robinhood.com`
as a direct browser-side JSON-RPC endpoint.

Why:
- direct requests from GitHub Pages can be rejected by the endpoint's CORS response
- the public endpoint can return HTTP 429 under application-style request volume

New behavior on Robinhood Chain:
1. connected wallet provider is the default read provider
2. the Robinhood public endpoint is removed from automatic browser fallback
3. a user-supplied Read-only RPC override still works
4. the UI suggests an Alchemy Robinhood endpoint format when an external RPC is desired

Transactions are still signed only by the connected wallet.
