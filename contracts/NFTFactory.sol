// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./NFTCollection.sol";

contract NFTFactory {
    uint256 private deployerRoyalty = 2250;
    address private immutable deployerAddress;

    event CollectionCreated(
        address indexed owner,
        address collectionAddress,
        string name,
        string symbol,
        string metadataURI
    );

    struct CollectionInfo {
        address owner;
        address collectionAddress;
        string name;
        string symbol;
        string metadataURI;
        uint256 deployerRoyalty;
    }

    CollectionInfo[] public collections;

    constructor() {
        deployerAddress = msg.sender; // Store deployer's address at contract deployment
    }

    function createCollection(
        string memory name,
        string memory symbol,
        string memory metadataURI
    ) external {
        NFTCollection newCollection = new NFTCollection(
            name,
            symbol,
            metadataURI,
            msg.sender,
            deployerAddress,
            deployerRoyalty
        );

        collections.push(
            CollectionInfo({
                owner: msg.sender,
                collectionAddress: address(newCollection),
                name: name,
                symbol: symbol,
                metadataURI: metadataURI,
                deployerRoyalty: deployerRoyalty
            })
        );

        emit CollectionCreated(
            msg.sender,
            address(newCollection),
            name,
            symbol,
            metadataURI
        );
    }

    function getAllCollections()
        external
        view
        returns (CollectionInfo[] memory)
    {
        return collections;
    }

    function getCollectionCount() external view returns (uint256) {
        return collections.length;
    }

    function setDeployerRoyalty(uint256 royalty) external {
        require(
            deployerAddress == msg.sender,
            "Only deployer can set contract royalty"
        );
        require(royalty < 50, "Royalty for contract should be less than 50%");
        deployerRoyalty = royalty;
    }
}
