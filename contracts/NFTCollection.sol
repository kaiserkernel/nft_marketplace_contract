// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTCollection is ERC721URIStorage, Ownable {
    uint256 private _tokenIds;
    string private _baseTokenURI;

    // Collection Metadata
    string public collectionDescription;
    string public collectionImage;
    string public collectionAvatar;
    uint256 public royaltyPercentage; // In basis points (e.g., 500 = 5%)

    event NFTMinted(address indexed owner, uint256 indexed tokenId, string tokenURI);

    constructor(
        string memory name,
        string memory symbol,
        string memory description,
        string memory image,
        string memory avatar,
        uint256 royalty,
        address creator
    ) ERC721(name, symbol) Ownable(creator) {
        collectionDescription = description;
        collectionImage = image;
        collectionAvatar = avatar;
        royaltyPercentage = royalty;
    }

    function mintNFT(address recipient, string memory tokenURI) public {
        uint256 tokenId = _tokenIds++;
        _mint(recipient, tokenId);
        _setTokenURI(tokenId, tokenURI);
        emit NFTMinted(recipient, tokenId, tokenURI);
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }
}
