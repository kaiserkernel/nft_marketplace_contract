// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./NFTCollection.sol";

contract NFTFactory is Ownable {
    uint256 private deployerRoyalty = 2250;
    // address private immutable deployerAddress;

    event CollectionCreated(
        address indexed owner,
        address indexed collectionAddress,
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

    // CollectionInfo[] public collections;
    mapping(address => CollectionInfo) public collections;
    address[] private collectionAddresses;

    constructor() Ownable(msg.sender) {}

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
            owner(), // Owner from Ownable
            deployerRoyalty
        );

        collections[address(newCollection)] = CollectionInfo({
            owner: msg.sender,
            collectionAddress: address(newCollection),
            name: name,
            symbol: symbol,
            metadataURI: metadataURI,
            deployerRoyalty: deployerRoyalty
        });

        collectionAddresses.push(address(newCollection));

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
        uint256 length = collectionAddresses.length;
        CollectionInfo[] memory result = new CollectionInfo[](length);

        for (uint256 index = 0; index < length; index++) {
            result[index] = collections[collectionAddresses[index]];
        }
        return result;
    }

    function getCollectionCount() external view returns (uint256) {
        return collectionAddresses.length;
    }

    function setDeployerRoyalty(uint256 royalty) external onlyOwner {
        require(royalty < 50, "Royalty for contract should be less than 50%");
        deployerRoyalty = royalty;
    }
}
