// SPDX-License-Identifier: MIT

pragma solidity >= 0.4.0 < 0.9.0;

// What this ERC721 NFT collection ??? contract do ? 
// - Make a contract to make a NFT collection of 10 NFTs 
// - To mint & transfer these tokens
// - withdraw function for owner

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/access/Ownable.sol";

// ERC721Enumerable :- The interface defines the following view functions: totalSupply() : The function returns the total number of NFTs issued by the contract that are not burned.

contract NFTCollection is ERC721Enumerable, Ownable {
    
    string _baseTokenURI;
    uint256 public _price = 0.01 ether;   // price of a NFT.
    bool public _paused;
    uint256 public maxTokenIds = 10;    // maximum amount of NFT can be minted
    uint256 public tokenIds;

    modifier onlyWhenNotPaused{
        require(!_paused,"Contract currently paused");
        _;
    }

    constructor(string memory baseURI) ERC721("CryptZombie","CRZ"){
        _baseTokenURI = baseURI;
    }

    function mint() public payable onlyWhenNotPaused {
        require(tokenIds < maxTokenIds,"Exceed maximum supply");
        require(msg.value >= _price,"ETH transfer amount is less than actual price.");
        tokenIds += 1;
        _safeMint(msg.sender, tokenIds);
    }

    // _baseURI overides the Openzeppelin's ERC721 implementation 
    // which by default returned an empty string for the baseURI
    function _baseURI() internal view virtual override returns(string memory){
        return _baseTokenURI;
    }

    // function to pause or unpause the contract. 
    function setPaused(bool value) public onlyOwner{
        _paused = value;
    }

    function withdraw() public onlyOwner  {
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) =  _owner.call{value: amount}(""); 
        require(sent, "Failed to send Ether");
    }

    // function to receive ether.
    receive() external payable{
    }

    // function is called when msg.data is not empty.
    fallback() external payable{
    }
    
}