// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IERC721Minimal {
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
}

contract BatchNFTSender {
    bytes32 public constant MAGIC = keccak256("EVM_NFT_BULK_SENDER_V1");

    error ZeroAddress();
    error EmptyBatch();

    function batchTransferERC721(
        address collection,
        address to,
        uint256[] calldata tokenIds
    ) external {
        if (collection == address(0) || to == address(0)) revert ZeroAddress();
        if (tokenIds.length == 0) revert EmptyBatch();

        for (uint256 i = 0; i < tokenIds.length; ) {
            IERC721Minimal(collection).safeTransferFrom(msg.sender, to, tokenIds[i]);
            unchecked { ++i; }
        }
    }
}
