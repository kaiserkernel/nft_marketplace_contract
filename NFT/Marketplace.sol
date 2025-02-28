// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./NFTMinting.sol";

contract Marketplace {
    struct Listing {
        address seller;
        address nftContract;
        uint256 tokenId;
        uint256 price;
        bool active;
    }

    Listing[] public listings;

    event NFTListed(uint256 index, address seller, uint256 price);
    event NFTSold(uint256 index, address buyer);

    function listNFT(address nftContract, uint256 tokenId, uint256 price) external {
        require(price > 0, "Price must be greater than zero");

        listings.push(Listing(msg.sender, nftContract, tokenId, price, true));
        
        emit NFTListed(listings.length - 1, msg.sender, price);
    }

    // function buyNFT(uint256 index) external payable {
    //     Listing storage listing = listings[index];
    //     require(listing.active, "Listing is not active");
    //     require(msg.value == listing.price, "Incorrect price");

    //     NFTMinting nftContract = NFTMinting(listing.nftContract);
    //     NFTMinting.NFTMetadata storage metadata = nftContract.nftMetadata(listing.tokenId);

    //     uint256 royaltyFee = (msg.value * metadata.royalty) / 100;
    //     uint256 sellerAmount = msg.value - royaltyFee;

    //     payable(listing.seller).transfer(sellerAmount);
    //     payable(metadata.collection).transfer(royaltyFee); // Collection receives royalty

    //     nftContract.safeTransferFrom(listing.seller, msg.sender, listing.tokenId);
        
    //     listing.active = false;
    //     emit NFTSold(index, msg.sender);
    // }
}
