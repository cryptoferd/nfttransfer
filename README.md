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


## v15 — ERC-1155 live-balance transfer fix

Fixes `TypeError: Cannot convert undefined to a BigInt` in ERC-1155 transfers.

Before ERC-1155 preflight or transfer, v15 now:
1. re-reads all selected token balances directly from the collection
2. prefers `balanceOfBatch()` and falls back to individual `balanceOf()` calls
3. repairs missing/stale `balance` values in the UI holding objects
4. defaults a missing send amount to the current live balance
5. caps requested amounts to the current live balance
6. deselects/removes token IDs whose live balance is zero
7. only then builds `safeBatchTransferFrom()`

This makes the transfer path independent of incomplete/stale discovery metadata.


## v16 — disconnect + wallet provider chooser

v16 adds EIP-6963 multi-wallet discovery and app-side disconnect support.

New behavior:
- detects multiple installed EVM wallet providers when they support EIP-6963
- shows a Wallet provider dropdown
- lets the user explicitly choose Rabby, MetaMask, Coinbase Wallet, etc.
- falls back to legacy `window.ethereum` when needed
- adds a Disconnect button
- changing the provider while connected first clears the app's current wallet state
- wallet batch capability detection uses the selected provider instead of global `window.ethereum`

Note: injected-wallet standards do not define a universal RPC that forcibly disconnects the browser extension account. The Disconnect button clears the application's connection/session state and lets the user choose another provider; the extension itself may still remember site permission.
