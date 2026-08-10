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
