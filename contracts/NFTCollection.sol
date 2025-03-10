// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTCollection is ERC721URIStorage, Ownable {
    uint256 private _tokenIds;
    string private _baseTokenURI;

    // Collection Metadata
    string public metadataURI;

    event NFTMinted(address indexed owner, uint256 indexed tokenId, string tokenURI);

    constructor(
        string memory name,
        string memory symbol,
        string memory _metadataURI,
        address creator
    ) ERC721(name, symbol) Ownable(creator) {
        metadataURI = _metadataURI;
    }

    function mintNFT(address recipient, string memory tokenURI) public onlyOwner {
        uint256 tokenId = _tokenIds++;
        _mint(recipient, tokenId);
        _setTokenURI(tokenId, tokenURI);
        emit NFTMinted(recipient, tokenId, tokenURI);
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }
}
