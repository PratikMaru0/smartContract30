// SPDX-License-Identifier: MIT

pragma solidity 0.7.0;

// NOTE: This contract is really awesome. One of my favorite Smart Contract! ??

// What this smart contract do :- 
// - Seller can deploy and this auction lasts for a time period
// - Participants can bid and the highest bidder wins 
// - Remaining can withdraw and highest one becomes owner of NFT

// For testing purpose.
// interface IERC721{
//     function safeTransferFrom(address from, address to, uint tokenId) external ;
//     function transferFrom(address from, address to, uint tokenId) external;
// }

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.4/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.4/contracts/utils/Counters.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.4/contracts/access/Ownable.sol";

contract NftExample is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("NFT-Example", "NEX") {}

    function mintNft(address receiver, string memory tokenURI) external onlyOwner returns (uint256) {
        _tokenIds.increment();

        uint256 newNftTokenId = _tokenIds.current();
        _mint(receiver, newNftTokenId);
        _setTokenURI(newNftTokenId, tokenURI);

        return newNftTokenId;
    }
}

contract englishAuction{

    // Creating Events
    event Start(string message);
    event Bid(address indexed sender, uint amount);
    event Withdraw(address indexed bidder, uint amount);
    event End(address winner, uint amount);

    // Initializing the NFT contract
    IERC721 public immutable nft;
    uint public immutable nftId;

    address payable public seller;   // making seller payable so that it can withdraw payment
    uint public endAt;
    bool public started;
    bool public ended;

    address public highestBidder;
    uint public highestBid;
    mapping(address=>uint) public bids;  // keeping track of the bid placed.

    constructor(address _nft, uint _nftId, uint _startingBid){
        nft = IERC721(_nft);
        nftId = _nftId;

        seller = payable(msg.sender);
        highestBid = _startingBid;
    }

    // function to start the auction 
    function start() external  {
        require(started == false,"Started");        
        require(msg.sender == seller,"Not a seller");

        started = true;
        // endAt = block.timestamp + 7 days;
        endAt = block.timestamp + 120 seconds;
        nft.transferFrom(msg.sender,address(this),nftId);
        emit Start("Auction is started.....");
    }

    // function called by the bidder for creating the highest bit.
    function bid() external payable{
        require(started,"Not started");
        require(block.timestamp < endAt, "Sorry Auction is ended");
        require(msg.value > highestBid,"Bidding value must be greater than the current highest bid value"); 

        if(highestBidder != address(0)){
            bids[highestBidder] += highestBid;  // FIXME:
        }

        highestBidder = msg.sender;
        highestBid = msg.value;
        emit Bid(msg.sender,msg.value);
    }

    function withdraw() external{
        uint bal = bids[msg.sender];
        bids[msg.sender] = 0;
        payable(msg.sender).transfer(bal);  // transfering the amount. 
        emit Withdraw(msg.sender,bal);
    }

    // 6111309

    function end() external{
        require(started,"Not started");
        require(block.timestamp >= endAt,"Still sometime is left to end this auction");
        require(!ended,"Ended");    

        ended = true;
        if(highestBidder != address(0)){
            nft.safeTransferFrom(address(this),highestBidder,nftId);
            seller.transfer(highestBid);  // here we are transfering the amount (Highest bid) to the seller.
        }
        else{
            nft.transferFrom(address(this),seller,nftId);
        }
        emit End(highestBidder,highestBid);
    }
}