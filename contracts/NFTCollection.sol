// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTCollection is ERC721URIStorage, Ownable {
    uint256 private _tokenIds;
    string private _baseTokenURI;

    // Collection Metadata
    string public metadataURI;

    // Mapping to store the original creator of each NFT
    mapping(uint256 => address) private _tokenCreators;

    // Price mapping for each tokenId (fixed price or auction starting bid)
    mapping(uint256 => uint256) private _tokenPrices;

    // Royalty mapping for each tokenId
    mapping(uint256 => uint256) private _tokenRoyalties;  // Royalty percentage for each tokenId

    // Auction-related mappings
    mapping(uint256 => address) private _tokenHighestBidder;
    mapping(uint256 => uint256) private _tokenHighestBid;

    // Auction start and end time
    mapping(uint256 => uint256) private _auctionEndTime;

    event NFTMinted(address indexed owner, uint256 indexed tokenId, string tokenURI, uint256 royalty, address collectionAddress);
    event NFTPriceSet(uint256 indexed tokenId, uint256 price);
    event NFTSold(address indexed buyer, uint256 indexed tokenId, uint256 price);
    event AuctionStarted(uint256 indexed tokenId, uint256 startingBid, uint256 auctionEndTime);
    event NewBidPlaced(address indexed bidder, uint256 indexed tokenId, uint256 bidAmount);
    event AuctionEnded(address indexed winner, uint256 indexed tokenId, uint256 winningBid);
    
    constructor(
        string memory name,
        string memory symbol,
        string memory _metadataURI,
        address creator
    ) ERC721(name, symbol) Ownable(creator) {
        metadataURI = _metadataURI;
    }

    function mintNFT(address recipient, string memory tokenURI, uint256 royaltyPercentage) public onlyOwner {
        uint256 tokenId = ++_tokenIds;  // Store the current tokenId first

        _mint(recipient, tokenId);
        _setTokenURI(tokenId, tokenURI);

        // Store the original creator of the NFT
        _tokenCreators[tokenId] = recipient;
        
        // Set royalty percentage for this specific NFT
        _tokenRoyalties[tokenId] = royaltyPercentage;

        emit NFTMinted(recipient, tokenId, tokenURI, royaltyPercentage, address(this));
    }

    function setTokenPrice(uint256 tokenId, uint256 price) public onlyOwner {
        require(ownerOf(tokenId) != address(0), "Token does not exist");
        _tokenPrices[tokenId] = price;
        emit NFTPriceSet(tokenId, price);
    }

    function buyNFT(uint256 tokenId) public payable{
        uint256 price = _tokenPrices[tokenId];
        require(price > 0, "NFT is not for sale");
        require(msg.value == price, "Incorrect payment amount");

        address owner = ownerOf(tokenId);
        address creator = _tokenCreators[tokenId];

        uint256 royaltyAmount = (price * _tokenRoyalties[tokenId]) / 100;
        uint256 sellerAmount = price - royaltyAmount;

        // Transfer royalty to the creator (contract owner)
        payable(creator).transfer(royaltyAmount);

        // Transfer the remaining amount to the current NFT owner
        payable(owner).transfer(sellerAmount);

        // Transfer NFT to the buyer
        _transfer(owner, msg.sender, tokenId);

        emit NFTSold(msg.sender, tokenId, price);

        // Optionally clear the price after sale
        delete _tokenPrices[tokenId];
    }

    function startAuction(uint256 tokenId, uint256 startingBid, uint256 auctionDuration) public onlyOwner {
        require(ownerOf(tokenId) != address(0), "Token does not exist");
        require(_tokenHighestBidder[tokenId] == address(0), "Auction already started");

        _tokenPrices[tokenId] = startingBid;
        _auctionEndTime[tokenId] = block.timestamp + auctionDuration;
        emit AuctionStarted(tokenId, startingBid, _auctionEndTime[tokenId]);
    }

    function placeBid(uint256 tokenId) public payable {
        require(ownerOf(tokenId) != address(0), "Token does not exist");
        require(block.timestamp < _auctionEndTime[tokenId], "Auction has ended");
        require(msg.value > _tokenHighestBid[tokenId], "Bid too low");

        // Refund the previous highest bidder if any
        address previousBidder = _tokenHighestBidder[tokenId];
        uint256 previousBid = _tokenHighestBid[tokenId];

        if (previousBidder != address(0)) {
            payable(previousBidder).transfer(previousBid);
        }

        _tokenHighestBidder[tokenId] = msg.sender;
        _tokenHighestBid[tokenId] = msg.value;
        emit NewBidPlaced(msg.sender, tokenId, msg.value);
    }

    function endAuction(uint256 tokenId) public {
        require(ownerOf(tokenId) != address(0), "Token does not exist");
        require(block.timestamp >= _auctionEndTime[tokenId], "Auction not ended yet");
        require(msg.sender == ownerOf(tokenId), "Only the owner can end the auction");
        require(_tokenHighestBidder[tokenId] != address(0), "No bids placed");

        address winner = _tokenHighestBidder[tokenId];
        uint256 winningBid = _tokenHighestBid[tokenId];

        // Transfer royalty
        uint256 royaltyAmount = (winningBid * _tokenRoyalties[tokenId]) / 100;
        payable(_tokenCreators[tokenId]).transfer(royaltyAmount);

        // Transfer the remaining amount to the current owner
        uint256 sellerAmount = winningBid - royaltyAmount;
        payable(ownerOf(tokenId)).transfer(sellerAmount);

        // Transfer the NFT to the winner
        _transfer(ownerOf(tokenId), winner, tokenId);

        emit AuctionEnded(winner, tokenId, winningBid);

        // Clear auction data
        delete _tokenPrices[tokenId];
        delete _auctionEndTime[tokenId];
        delete _tokenHighestBidder[tokenId];
        delete _tokenHighestBid[tokenId];
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    function getTokenPrice(uint256 tokenId) public view returns (uint256) {
        return _tokenPrices[tokenId];
    }

    function getRoyalty(uint256 tokenId) public view returns (uint256) {
        return _tokenRoyalties[tokenId];
    }
}
