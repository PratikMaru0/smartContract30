// SPDX-License-Identifier: MIT
pragma solidity >= 0.4.0 < 0.9.0;

// what this smart contract do :- 
// Dutch Auction??
// - Seller can deploy and this auction lasts for a time period
// -  Price of NFT decreases , participants can buy by depositing a greater price 
// - Auction ends when a buyer buys NFT

// For testing purpose.
// interface IERC721{
//     function transferFrom(address _from, address _to, uint _nftId) external;
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

contract dutchAuction{

    uint private constant duration = 7 days;
    IERC721 public immutable nft;   
    uint public immutable nftId;
    address payable public immutable seller;
    uint public immutable startingPrice;
    uint public immutable startAt;
    uint public immutable expiresAt;
    uint public immutable discountRate;

    event sold(address buyer, uint price);

    constructor(uint _startingPrice,uint _discountRate, address _nft, uint _nftId){
        seller = payable(msg.sender);
        startingPrice = _startingPrice;
        discountRate = _discountRate;
        startAt = block.timestamp;
        expiresAt = block.timestamp + duration;

        require(_startingPrice >= _discountRate * duration,"Starting price < discount");

        nft = IERC721(_nft);
        nftId = _nftId;
    }

    function getPrice() public view returns(uint){
        uint timeElapsed = block.timestamp - startAt;
        uint discount = discountRate * timeElapsed;
        return startingPrice - discount;
    }

    function buy() external payable{
        require(block.timestamp < expiresAt ,"Aution is Ended");
        uint price = getPrice();
        require(msg.value >= price,"ETH < price");
        nft.transferFrom(seller,msg.sender,nftId);
        uint refund = msg.value - price;
        if(refund > 0){
            payable(msg.sender).transfer(refund);
        }
        emit sold(msg.sender, msg.value);
        selfdestruct(seller);   // this will send all the remaining eth to the seller.
    }  
}