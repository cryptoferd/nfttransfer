# EVM NFT Bulk Transfer

A static, client-side tool for transferring selected NFTs from a connected EVM wallet to another wallet.

## What it supports

- Any injected EVM wallet/provider (MetaMask, Rabby, Coinbase Wallet, etc.)
- Any EVM chain that your wallet can connect to
- ERC-721 collections
  - Auto-loads holdings when the collection implements ERC-721 Enumerable
  - Otherwise reconstructs candidate holdings by scanning `Transfer` events and verifies each with `ownerOf`
  - Manual token-ID fallback
  - Direct transfer mode: one wallet transaction per NFT
  - Optional `BatchNFTSender` helper: one batch transfer transaction after operator approval
- ERC-1155 collections
  - Reconstructs token IDs from `TransferSingle` / `TransferBatch` events
  - Manual token-ID fallback
  - Uses native `safeBatchTransferFrom` for one-transaction batch transfers

## Run it

Because the page imports ethers.js as an ES module, serve the folder over HTTP instead of double-clicking `index.html`.

### Python

```bash
cd evm-nft-bulk-transfer
python -m http.server 8080
```

Then open:

```text
http://localhost:8080
```

### Node

Any simple static server also works, for example:

```bash
npx serve .
```

## Typical use

1. Select the desired EVM network in your wallet.
2. Open the page and click **Connect Wallet**.
3. Paste the collection contract address.
4. Click **Detect & Load Holdings**.
5. Select the NFTs you want to send.
6. Paste the destination wallet.
7. Click **Preflight Selected**.
8. Test with one low-value NFT first.
9. Click **Transfer Selected**.

## ERC-721 batch helper

ERC-721 itself does not include a standard batch-transfer function. The included `BatchNFTSender.sol` is a deliberately minimal helper.

To use it:

1. Open `BatchNFTSender.sol` in Remix or your normal Solidity deployment workflow.
2. Compile with Solidity 0.8.24 or compatible 0.8.x compiler.
3. Deploy it on the EVM chain you plan to use.
4. Put the deployed address into the web app.
5. Click **Verify Helper**.
6. Click **Approve Helper**. This calls `setApprovalForAll(helper, true)` on the collection.
7. Preflight and batch-transfer the selected ERC-721s.
8. After finishing, consider revoking the helper's operator approval directly on the collection contract or through a reputable approval-management interface.

### Important

`setApprovalForAll` grants the helper operator permission over *all* NFTs you own in that collection until revoked. Deploy or independently verify the helper yourself. Never use an unknown helper address.

The included helper is intentionally constrained:
- no owner/admin
- no arbitrary calls
- no delegatecall
- no token withdrawal function
- transfers only from `msg.sender`
- fixed `MAGIC()` identifier checked by the UI

## Event-scan limitations

Not every ERC-721 contract implements the optional enumerable extension, so the app can scan historical token transfer events.

Generic RPC providers often limit how many blocks can be queried in a single `eth_getLogs` request. The app automatically reduces the chunk size when a query fails, but a full scan from block 0 can still be slow on older chains.

For old collections:
- set **Event scan start block** near the collection's deployment block, if known
- use the manual token-ID loader if you already know the IDs
- use an RPC endpoint/wallet provider that permits historical log queries

ERC-1155 has no standard owner-enumeration function, so event scanning or manual IDs are required.

## Security

- The app never asks for a seed phrase or private key.
- All signing occurs through the connected wallet.
- The destination address and network should be checked before signing.
- Transfers are irreversible.
- Custom NFTs can add pause, allowlist, soulbound, royalty, or other transfer restrictions that can cause a standard transfer to revert.
- Always test with one NFT first on valuable collections.

## Files

- `index.html` — complete static application
- `BatchNFTSender.sol` — optional minimal ERC-721 batch helper contract
- `README.md` — this guide


## GitHub-ready additions

- NFT thumbnails and metadata names
- ERC-721 tokenURI and ERC-1155 uri support
- IPFS / Arweave URL normalization
- Known-chain names including Robinhood Chain
- Safer helper approval with revocation button
- Configurable ERC-721 batch gas ceiling
- Shareable collection URL state
- Strong final network/collection/recipient confirmation

## GitHub Pages

Put these files in the repository root. In GitHub open **Settings → Pages**, choose **Deploy from a branch**, select `main` and `/(root)`, then save.


## v2 RPC / error-handling update

This version separates read operations from transaction signing.

- Wallet provider: used for account access and transaction signing.
- Read provider: used for `eth_call`, bytecode checks, block reads, and historical `eth_getLogs`.
- A read-only RPC override can be entered in the UI.
- Robinhood Chain automatically tries `https://rpc.mainnet.chain.robinhood.com`.
- If an automatic read RPC fails, the app falls back to the wallet's provider.
- If a user-supplied read RPC fails, the app reports the error instead of silently falling back.
- Ethers "could not coalesce error" wrappers are unpacked when possible to show the underlying RPC error.
- Technical error details can be expanded from the UI.

For collections that require historical event scanning, an archive-capable RPC may be necessary.


## v4 — contract-by-contract discovery

Historical blockchain event scanning has been removed from the normal holdings-discovery workflow.

### ERC-721 discovery order

1. Detect ERC-721 with ERC-165 / behavior checks.
2. Call `balanceOf(wallet)`.
3. If `tokenOfOwnerByIndex(wallet, index)` is supported, enumerate only the connected wallet's holdings directly from the collection contract.
4. If owner enumeration is not supported, call `ownerOf(tokenId)` across a configurable token-ID range for that collection only.
5. If IDs are sparse or unusual, use the Manual token IDs box.

If `totalSupply()` is available, the UI can derive a default end of the token range. Users can override the start/end range when a collection starts at 1, has reserved IDs, gaps, or other non-standard behavior.

### ERC-1155

ERC-1155 does not define a standard method to enumerate every token ID owned by a wallet. v4 therefore does not scan historical logs. Use the Manual token IDs input; the app verifies each ID against the selected collection contract using `balanceOf(wallet, id)`.

This keeps the tool RPC-friendly and avoids archive-node requirements.


## v5 — built-in helper deployments

The app now auto-fills these `BatchNFTSender` deployments based on the connected chain:

- Robinhood Chain (4663): `0x19466Dd578cAB78BfcC3f776531598c1473d32ab`
- Base (8453): `0x1d4f7624139d337A31cf08DB065Ec7F4Bd698C22`

The UI still requires **Verify Helper** before enabling approval, and the helper field remains editable for other chains or future deployments.


## v6 — stoppable ownership checks

Large non-enumerable ERC-721 collections can require many `ownerOf()` contract calls.

v6 adds a **Stop Check** button:

- available only while a token-range ownership check is running
- finishes the currently executing batch of contract reads
- stops before beginning the next batch
- keeps all owned token IDs found so far
- leaves partial holdings visible and selectable
- reports how many IDs were checked and how many owned tokens were found

This is cooperative cancellation; already-sent RPC calls cannot be forcibly aborted, so stopping takes effect immediately after the current batch completes.


## v7 — Select Max

v7 adds **Select Max** for ERC-721 helper-mode transfers.

The button:

1. reads the latest block's gas limit
2. applies the configurable block safety percentage (default 90%)
3. compares that value with the app's configured `Maximum gas units per batch`
4. uses the lower value as the effective gas ceiling
5. estimates the real `batchTransferERC721(...)` transaction
6. binary-searches for the largest number of loaded NFTs that should fit in one transaction
7. selects exactly that many NFTs

Requirements:
- destination wallet must be entered
- batch helper must be verified
- helper must already be approved for the collection

The helper approval requirement is necessary because `estimateGas` executes the actual call as a simulation; without approval, the underlying ERC-721 transfers would revert.

For ERC-1155, Select Max currently selects all loaded token IDs and asks the user to run Preflight Selected, because ERC-1155 uses its native `safeBatchTransferFrom`.


## v8 — destination presets

v8 adds three one-click destination presets while preserving the fully editable custom-address field:

- `0x000000000000000000000000000000000000FE2D`
- `0x000000000000000000000000000000000000dEaD`
- `0x0000000000000000000000000000000000000000`

The zero address is displayed as a preset for convenience/reference, but transfer/preflight is intentionally blocked when it is selected. Standard ERC-721/ERC-1155 safe transfers reject the zero address, and the deployed `BatchNFTSender` helper also explicitly rejects `address(0)`.

The `0x...dEaD` address is treated as an ordinary non-zero destination by the app.


## v9 — thumbnail / metadata fix

v9 restores the metadata enrichment function that was accidentally removed during the contract-only discovery rewrite.

After holdings are discovered, the app now:
- calls ERC-721 `tokenURI(tokenId)` or ERC-1155 `uri(tokenId)`
- fetches JSON metadata
- reads common image fields (`image`, `image_url`, `imageUrl`, `image_uri`, `imageURI`)
- renders NFT names and thumbnails incrementally
- supports `ipfs://`, `ar://`, normal HTTP(S), and `data:application/json` metadata
- shows a useful fallback status when metadata or an image fails instead of silently showing "No image"

Public metadata hosts can still block browser CORS requests. When that happens the card displays the failure state, while NFT transfer functionality remains unaffected.
