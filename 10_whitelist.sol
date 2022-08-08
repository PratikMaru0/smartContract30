// SPDX-License-Identifier: GPL-3.0

pragma solidity >= 0.4.0 < 0.9.0;

// What this smart contract do ? :- 
// - Whitelisting for a token or NFT collection ??
// - To whitelist or save the add in the contract for the user
// - Should be able to fetch and check 

// What is whitelisting in Cryptocurrency ?
// -> In the blockchain and cryptocurrency space, a whitelist is a term 
// associated with Initial Coin Offering (ICO) events, or withdrawal
// addresses for exchanges. With regards to an ICO event, a whitelist
// is a list of registered and approved participants that are given
// exclusive access to contribute to an ICO or a pre-sale.
// -> Some cryptocurrency projects may offer a whitelisting phase for
//  investors that are interested in taking part in the public sale
//  of their tokens. Such Crypto project owners make use of the
//  whitelisting process to enable them to verify potential
//  token buyers and ensure they are compliant with the terms 
// of the token sale

contract whitelist{

    // Max number of whitelisted addresses allowed
    uint8 public maxWhitelistedAddress;

    // If an address is whitelisted we will set it true, bydefault its false.
    mapping(address=>bool) public whitelistedAddress;

    // keeping track of how many addresses have been whitelisted
    uint8 public numAddressWhitelisted;

    constructor(uint8 _maxWhitelistedAddress){
        maxWhitelistedAddress = _maxWhitelistedAddress;
    }

    function addAddressToWhitelist() public{
        require(!whitelistedAddress[msg.sender],"Sender has already been whitelisted");
        require(numAddressWhitelisted < maxWhitelistedAddress,"More address can't be added, Limit reached");
        whitelistedAddress[msg.sender] = true;
        numAddressWhitelisted += 1;
    }

    function checkAddress(address user)public view returns(bool){
        return whitelistedAddress[user];
    }
}