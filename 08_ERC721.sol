// // What this smart contract do :- 
// // ERC721 ???
// // - A ERC721 Token with a mint method 
// // - Openzepplin library used

// // TOKEN - A Deeper Explanation 
// // 1). A token is a representation of something in the blockchain 
// // 2). This something can be money, time, services, share in the company, a virtual pet, anything.
// // 3). By representing things as tokens, we can allow smart contracts to interact with them, exchange them, create or destroy them.

// // ERC721 is non-fungible. 
// // Whats non-fungible ?
// // -> Non-fungible goods are unique and distinct, like collectibles, digital paintings, etc. Which can not be exchanged with the same items. For eg :- House in 
// // a hiranandani complex is not equal to a house in the marine lines. We cannot exchange it. Becoz both posses uniqueness. But in case of money (notes) we can exchange
// // 100 rupees notes with 50+50 (2 notes). This means money is fungible. 

// // There were no rules of how to write smart contracts. So industry developed variety of standards (EIPs or ERCs) for documenting how contracts can interoperate with other contracts.
// // ERC20 :- a widespread token standard for fungible assets.
// // ERC721 :- a defacto solution for non-fungible tokens, often used for collectibles and games. 

// // NOTE: Every ERC721 compliant contract must implement the ERC721 and ERC165 interfaces.

// // Required interface of an ERC721 compliant contract.

// // FUNCTIONS :-
// // balanceOf(owner)
// // ownerOf(tokenId)
// // safeTransferFrom(from, to, tokenId, data)
// // safeTransferFrom(from, to, tokenId)
// // transferFrom(from, to, tokenId)
// // approve(to, tokenId)
// // setApprovalForAll(operator, _approved)
// // getApproved(tokenId)
// // isApprovedForAll(owner, operator)
// // supportsInterface(interfaceId)   ----ERC165

// // EVENTS :- 
// // Transfer(from, to, tokenId)
// // Approval(owner, approved, tokenId)
// // ApprovalForAll(owner, operator, approved)

// // Link for more information :- https://eips.ethereum.org/EIPS/eip-721#simple-summary

// // Most useful thing Link :- https://docs.openzeppelin.com/contracts/4.x/wizard

// // SPDX-License-Identifier: MIT 

pragma solidity >=0.4.0 < 0.8.15;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract MyNFT is  ERC721URIStorage , Ownable {

    // We can use library as below in the contract 
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    constructor() ERC721("Kryptonite Token","KTC"){

    }

    // Here are writing logic to mint NFT 
    // Here onlyOwner means only owner can call this function to mint the NFT (We have seen this in CryptoZombies. I hope you remembered 
    function mintNFT(address recipient,string memory tokenURI) public onlyOwner returns(uint256){
        // We'll increment the token Id so that we wont get same number again and again. 
        // Its mandatory step 
        _tokenIds.increment();        

        uint256 newItemId = _tokenIds.current();
        
        // recipient is the address of the nft reciever and newItemId is the ID that we'll give to Image so that we can make our NFT
        _mint(recipient,newItemId);

        // tokenURI is the URL of the Image that we kept on the server and newItemId toh pata hi hai.
        _setTokenURI(newItemId, tokenURI);

        return newItemId;   
    }
}