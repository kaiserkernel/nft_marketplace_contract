// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./NFTCollection.sol";

contract NFTFactory {
    event CollectionCreated(
        address indexed owner,
        address collectionAddress,
        string name,
        string symbol,
        string description,
        string image,
        string avatar,
        uint256 royalty
    );

    function createCollection(
        string memory name,
        string memory symbol,
        string memory description,
        string memory image,
        string memory avatar,
        uint256 royalty
    ) external {
        NFTCollection newCollection = new NFTCollection(
            name,
            symbol,
            description,
            image,
            avatar,
            royalty,
            msg.sender
        );

        emit CollectionCreated(msg.sender, address(newCollection), name, symbol, description, image, avatar, royalty);
    }
}