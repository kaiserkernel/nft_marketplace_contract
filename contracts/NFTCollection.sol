// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTCollection {
    struct Collection {
        string name;
        string description;
        string coverImage;
        string avatar;
        uint256 royalty; // Percentage (e.g., 5 means 5%)
        string tokenSymbol;
        address creator;
    }

    Collection[] public collections;

    event CollectionCreated(address indexed creator, string name, uint256 royalty);

    function createCollection(
        string memory name,
        string memory description,
        string memory coverImage,
        string memory avatar,
        uint256 royalty,
        string memory tokenSymbol
    ) external {
        require(royalty <= 10, "Royalty cannot exceed 10%");

        collections.push(Collection(name, description, coverImage, avatar, royalty, tokenSymbol, msg.sender));
        
        emit CollectionCreated(msg.sender, name, royalty);
    }

    function getCollections() external view returns (Collection[] memory) {
        return collections;
    }
}
