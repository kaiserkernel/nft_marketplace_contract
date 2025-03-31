// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTCollection is ERC721URIStorage, Ownable {
    uint256 private _tokenIds;
    string private _baseTokenURI;

    // Deployer Info
    address private immutable deployerAddress;
    uint256 private immutable deployerRoyalty;

    // Collection Metadata
    string public metadataURI;

    // Mapping to store the original creator of each NFT
    mapping(uint256 => address) private _tokenCreators;

    // Price mapping for each tokenId (fixed price or auction starting bid)
    mapping(uint256 => uint256) private _tokenPrices;

    // Royalty mapping for each tokenId
    mapping(uint256 => uint256) private _tokenRoyalties; // Royalty percentage for each tokenId

    // Auction-related mappings
    mapping(uint256 => address) private _tokenHighestBidder;
    mapping(uint256 => uint256) private _tokenHighestBid;
    mapping(uint256 => uint256) private _auctionEndTime;

    // Mapping to store currency as a string per NFT
    mapping(uint256 => string) private _tokenCurrency;

    event NFTMinted(
        address indexed owner,
        uint256 indexed tokenId,
        string tokenURI,
        uint256 royalty,
        address collectionAddress,
        string currency
    );
    event NFTPriceSet(uint256 indexed tokenId, uint256 price);
    event NFTSold(
        address indexed buyer,
        uint256 indexed tokenId,
        uint256 price
    );
    event AuctionStarted(
        uint256 indexed tokenId,
        uint256 startingBid,
        uint256 auctionEndTime
    );
    event NewBidPlaced(
        address indexed bidder,
        uint256 indexed tokenId,
        uint256 bidAmount
    );
    event AuctionEnded(
        address indexed winner,
        uint256 indexed tokenId,
        uint256 winningBid
    );

    constructor(
        string memory name,
        string memory symbol,
        string memory _metadataURI,
        address creator,
        address _deployerAddress,
        uint256 _deployerRoyalty
    ) ERC721(name, symbol) Ownable(creator) {
        metadataURI = _metadataURI;
        deployerAddress = _deployerAddress;
        deployerRoyalty = _deployerRoyalty;
    }

    function mintNFT(
        address recipient,
        string memory tokenURI,
        uint256 royaltyPercentage,
        string memory currency // Accepting string input for currency
    ) public onlyOwner {
        // Validate currency
        require(
            keccak256(abi.encodePacked(currency)) ==
                keccak256(abi.encodePacked("BNB")) ||
                keccak256(abi.encodePacked(currency)) ==
                keccak256(abi.encodePacked("ETH")) ||
                keccak256(abi.encodePacked(currency)) ==
                keccak256(abi.encodePacked("tBNB")),
            "Invalid currency"
        );

        uint256 tokenId = ++_tokenIds; // Store the current tokenId first

        _mint(recipient, tokenId);
        _setTokenURI(tokenId, tokenURI);

        // Store the original creator of the NFT
        _tokenCreators[tokenId] = recipient;

        // Set royalty percentage for this specific NFT
        _tokenRoyalties[tokenId] = royaltyPercentage;

        _tokenCurrency[tokenId] = currency;

        require(
            ownerOf(tokenId) == recipient,
            "Minting failed, owner mismatch"
        );

        emit NFTMinted(
            recipient,
            tokenId,
            tokenURI,
            royaltyPercentage,
            address(this),
            currency
        );
    }

    function setTokenPrice(uint256 tokenId, uint256 price) public {
        require(ownerOf(tokenId) != address(0), "Token does not exist");
        require(
            ownerOf(tokenId) == msg.sender,
            "You are not owner of this NFT"
        );
        require(
            _tokenHighestBidder[tokenId] == address(0),
            "This NFT is on auction"
        );

        _tokenPrices[tokenId] = price;
        emit NFTPriceSet(tokenId, price);
    }

    function buyNFT(uint256 tokenId, string memory currency) public payable {
        uint256 price = _tokenPrices[tokenId];
        require(price > 0, "NFT is not for sale");
        require(msg.value == price, "Incorrect payment amount");

        address owner = ownerOf(tokenId);
        require(msg.sender != owner, "You already own this NFT");

        // Ensure the currency matches the NFT's original currency
        require(
            keccak256(abi.encodePacked(_tokenCurrency[tokenId])) ==
                keccak256(abi.encodePacked(currency)),
            "Invalid currency for this NFT"
        );

        address creator = _tokenCreators[tokenId];

        uint256 royaltyAmount = (price * _tokenRoyalties[tokenId]) / 100;
        uint256 deployerRoyaltyAmount = (price * deployerRoyalty) / 100000;
        uint256 sellerAmount = price - royaltyAmount - deployerRoyaltyAmount;

        require(
            sellerAmount > 0,
            "Money transferred to owner should be greater than zero"
        );

        // Transfer royalty to the creator (contract owner)
        _transferFund(payable(creator), royaltyAmount);

        // Transfer the remaining amount to the current NFT owner
        _transferFund(payable(owner), sellerAmount);

        // Transfer NFT to the buyer
        _transfer(owner, msg.sender, tokenId);

        // Emit event for transaction
        emit NFTSold(msg.sender, tokenId, price);

        // Optionally clear the price after sale
        delete _tokenPrices[tokenId];
    }

    function startAuction(
        uint256 tokenId,
        uint256 startingBid,
        uint256 auctionDuration
    ) public {
        require(ownerOf(tokenId) != address(0), "Token does not exist");
        require(
            msg.sender == ownerOf(tokenId),
            "You are not owner of this NFT"
        );
        require(
            _tokenHighestBidder[tokenId] == address(0),
            "Auction already started"
        );

        _tokenPrices[tokenId] = startingBid;
        _auctionEndTime[tokenId] = block.timestamp + auctionDuration;
        emit AuctionStarted(tokenId, startingBid, _auctionEndTime[tokenId]);
    }

    function placeBid(uint256 tokenId, string memory currency) public payable {
        require(ownerOf(tokenId) != address(0), "Token does not exist");
        require(msg.sender != ownerOf(tokenId), "You can't bid you own NFT");
        require(_auctionEndTime[tokenId] > 0, "NFT is not on auction");
        require(
            block.timestamp < _auctionEndTime[tokenId],
            "Auction has ended"
        );

        // Ensure the currency matches the NFT's original currency
        require(
            keccak256(abi.encodePacked(_tokenCurrency[tokenId])) ==
                keccak256(abi.encodePacked(currency)),
            "Invalid currency for this NFT"
        );

        if (_tokenHighestBidder[tokenId] == address(0)) {
            // First bid: Ensure it meets or exceeds starting bid
            require(
                msg.value >= _tokenPrices[tokenId],
                "Bid must be at least the starting price"
            );
        } else {
            // Subsequent bids: Must be higher than the current highest bid
            require(msg.value > _tokenHighestBid[tokenId], "Bid too low");

            // Refund the previous highest bidder
            address previousBidder = _tokenHighestBidder[tokenId];
            uint256 previousBid = _tokenHighestBid[tokenId];

            if (previousBidder != address(0)) {
                _transferFund(payable(previousBidder), previousBid);
            }
        }

        // Update highest bid
        _tokenHighestBidder[tokenId] = msg.sender;
        _tokenHighestBid[tokenId] = msg.value;

        emit NewBidPlaced(msg.sender, tokenId, msg.value);
    }

    function endAuction(uint256 tokenId) public returns (address, uint256) {
        require(ownerOf(tokenId) != address(0), "Token does not exist");
        require(
            block.timestamp >= _auctionEndTime[tokenId],
            "Auction not ended yet"
        );
        require(
            msg.sender == ownerOf(tokenId),
            "Only the owner can end the auction"
        );
        // require(_tokenHighestBidder[tokenId] != address(0), "No bids placed");

        address winner = _tokenHighestBidder[tokenId];
        uint256 winningBid = _tokenHighestBid[tokenId];

        if (winner != address(0)) {
            // Transfer royalty
            uint256 royaltyAmount = (winningBid * _tokenRoyalties[tokenId]) /
                100000;
            uint256 deployerRoyaltyAmount = (winningBid * deployerRoyalty) /
                100000;

            // Transfer the remaining amount to the current owner
            uint256 sellerAmount = winningBid -
                royaltyAmount -
                deployerRoyaltyAmount;

            require(
                sellerAmount > 0,
                "Money transferred to owner should be greater than zero"
            );

            _transferFund(payable(_tokenCreators[tokenId]), royaltyAmount);
            _transferFund(payable(ownerOf(tokenId)), sellerAmount);

            // Transfer the NFT to the winner
            _transfer(ownerOf(tokenId), winner, tokenId);
        }

        emit AuctionEnded(winner, tokenId, winningBid);

        // Clear auction data
        delete _tokenPrices[tokenId];
        delete _auctionEndTime[tokenId];
        delete _tokenHighestBidder[tokenId];
        delete _tokenHighestBid[tokenId];

        return (winner, winningBid);
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

    function getTokenOwner(uint256 tokenId) public view returns (address) {
        return ownerOf(tokenId);
    }

    function _transferFund(address payable to, uint256 amount) internal {
        if (amount == 0) {
            return;
        }
        require(to != address(0), "Error, cannot transfer to address(0)");

        (bool transferSent, ) = to.call{value: amount}("");
        require(transferSent, "Error, failed to send fund");
    }
}
