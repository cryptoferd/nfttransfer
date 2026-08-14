# EVM NFT Bulk Transfer

v10 includes transfer diagnostics for ERC-721 helper troubleshooting.


## v11 — Ethereum Mainnet helper

- Ethereum Mainnet (1): `0x1D4671d55C894d2a166a0aDc9720faBb76f5FfB1`
- Base (8453): `0x1d4f7624139d337A31cf08DB065Ec7F4Bd698C22`
- Robinhood Chain (4663): `0x19466Dd578cAB78BfcC3f776531598c1473d32ab`


## v12 — Robinhood RPC throttling and fallback

The collection checker is now rate-limit aware.

On Robinhood Chain (4663), the checker defaults to:
- 5 concurrent `ownerOf()` reads per batch
- 250 ms delay between batches
- exponential retry backoff on HTTP 429 / rate-limit errors
- retry delays of roughly 0.5s, 1s, 2s, 4s, up to 8s
- automatic fallback to the connected wallet provider when the direct read RPC is blocked by CORS or fails to fetch

The Stop Check button remains cooperative: it stops after the current in-flight batch finishes and preserves holdings already found.

For other chains, the default remains 20 reads per batch with no artificial delay unless the user changes the batch-size field.


## v13 — nonexistent ERC-721 token handling

Some ERC-721 collections have gaps, burned token IDs, reserved ranges, or IDs that were never minted. Calling `ownerOf()` on those IDs is expected to revert.

v13 explicitly recognizes and skips common nonexistent-token custom errors:

- `0xdf2d9b42` — ERC721A `OwnerQueryForNonexistentToken()`
- `0x7e273289` — OpenZeppelin v5 `ERC721NonexistentToken(uint256)`

These reverts are now treated as a normal "token does not exist" result inside the checker rather than a failed batch or RPC error.
