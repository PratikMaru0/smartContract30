// SPDX-License-Identifier: MIT

pragma solidity >= 0.4.0 < 0.9.0;

// What this smart contract do :- 
// -  create  a ERC1155 token standard , that enable batch mint and batch transfer 
// - Multi token standard for NFT and tokens
// - Using Openzepplin library

// Whats ERC1155
// Link :- https://eips.ethereum.org/EIPS/eip-1155

// ERC-1155 is a token standard that enables the efficient transfer of fungible and non-fungible tokens in a single transaction.

// Its used in Gaming and other products also. 

// Link :- https://decrypt.co/resources/what-is-erc-1155-ethereums-flexible-token-standard


import "@openzeppelin/contracts@4.7.0/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts@4.7.0/access/Ownable.sol";

contract Kryptic is ERC1155, Ownable {

    uint16[] supplies = [50,100,150];
    uint16[] minted = [0,0,0];
    uint256[] rates = [0.05 ether, 0.1 ether, 0.025 ether];

    constructor() ERC1155("https://api.mysite.com/tokens/{id}") {}

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function mint(uint256 id, uint16 amount) public payable {
        require(id <= supplies.length,"Token Doesnt Exists");
        require(id != 0,"Token doesnt exists");
        uint256 index = id -1;
        require(minted[index] + amount <= supplies[index],"Not enough supply.");
        require(msg.value >= amount * rates[index],"Not enough ether sent");
        _mint(msg.sender, id, amount,"");
        minted[index] += amount;
    }

    function withdraw() public onlyOwner{
        require(address(this).balance > 0,"Balance is zero");
        address payable owner = payable(msg.sender);
        owner.transfer(address(this).balance);
    }
}