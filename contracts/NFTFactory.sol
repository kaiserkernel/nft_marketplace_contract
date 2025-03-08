// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./NFTCollection.sol";

contract NFTFactory {
    event CollectionCreated(
        address indexed owner,
        address collectionAddress,
        string name,
        string symbol,
        string metadataURI,
    );

    struct CollectionInfo {
        address owner;
        address collectionAddress;
        string name;
        string symbol;
        string metadataURI;
    }

    CollectionInfo[] public collections;

    function createCollection(
        string memory name,
        string memory symbol,
        string memory metadataURI,
    ) external {
        NFTCollection newCollection = new NFTCollection(
            name,
            symbol,
            metadataURI,
            msg.sender
        );

        collections.push(CollectionInfo({
            owner: msg.sender,
            collectionAddress: address(newCollection),
            name: name,
            symbol: symbol,
            metadataURI: metadataURI
        }));

        emit CollectionCreated(msg.sender, address(newCollection), name, symbol, metadataURI);
    }

    function getAllCollections() external view returns (CollectionInfo[] memory) {
        return collections;
    }

    function getCollectionCount() external view returns (uint256) {
        return collections.length;
    }
}