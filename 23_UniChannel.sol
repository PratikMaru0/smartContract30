// FIXME: Testing Failed

// SPDX-License-Identifier: MIT

pragma solidity >= 0.4.0 < 0.9.0;

// Must watch :- yt video (Channel name :- Samrt contract programmar + Verify signature )

// What this smart contract do ?
// Uni-directional Payment Channel ????
// - Alice deploys the contract, funding it with some Ether.
// - Alice authorizes a payment by signing a message (off chain) and sends the signature to Bob.
// - Bob claims his payment by presenting the signed message to the smart contract.
// - If Bob does not claim his payment, Alice get her Ether back after the contract expires
// This is called a uni-directional payment channel since the payment can go only in a single direction from Alice to Bob.

// Must visit :- https://solidity-by-example.org/app/uni-directional-payment-channel

// This is really good smart contract go to know many things.  

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.5/contracts/utils/cryptography/ECDSA.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.5/contracts/security/ReentrancyGuard.sol";

contract UniDirectionalPaymentChannel is ReentrancyGuard{
    using ECDSA for bytes32;            // FIXME:

    address payable public sender;      // Alice
    address payable public receiver;    // Bob

    uint private constant DURATION = 7 days;
    uint public expiresAt;

    // Here we are making constructor payable so that while deploying we can send ETH to contract 
    constructor(address payable _receiver) payable{
        require(_receiver != address(0),"Receiver can not be zero address");
        sender = payable(msg.sender);
        receiver = _receiver;
        expiresAt = block.timestamp + DURATION;
    }

    // here we are generating the hash using data ( ie :- address of this contract and amount)
    function _getHash(uint _amount) private view returns(bytes32){
        // Note :- sign with address of thid contract to protect against replay attack on the other contracts FIXME:
        return keccak256(abi.encodePacked(address(this),_amount));
    } 

    // function to getHash that is generated using _getHash function.
    function getHash(uint _amount) external view returns(bytes32) {
        return _getHash(_amount);
    }

    //  Function to get the Eth signed hash
    function _getEthSignedHash(uint _amount) private view returns(bytes32){
        return _getHash(_amount).toEthSignedMessageHash();   
        // About .toEthSignedMessageHash() :- so this is the part of the openzeppelin contract that we imported (1st contract imported) 
        // It Returns an Ethereum Signed Message, created from a `hash`. This produces hash corresponding to the one signed with the
        // https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]. JSON-RPC method as part of EIP-191.
    }

    // function to get the hash and display ETH signed hash.
    function getEthSignedHash(uint _amount) external view returns(bytes32){
        return _getEthSignedHash(_amount);
    }

    // function to verify the sign. 
    function _verify(uint _amount,bytes memory _sig) private view returns(bool){
        return _getEthSignedHash(_amount).recover(_sig) == sender;
        // About recover function its part of the openZeppelin smar tcontract that we imported (1 st imported contract) 
        // Returns the address that signed a hashed message (`hash`) with `signature`. This address can then be used for verification purposes.
    }

    // Function for verification purposes.
    function verify(uint _amount,bytes memory _sig) external view returns(bool){
        return _verify(_amount,_sig);
    } 

    // function that can be called by only receiver to recieve ETH. 
    function close(uint _amount,bytes memory _sig) external nonReentrant{                //  Prevents a contract from calling itself, directly or indirectly
        require(msg.sender == receiver, "Only receiver can call this function");
        require(_verify(_amount,_sig),"invalid signature");
        require(block.timestamp < expiresAt,"Sorry contract is expired!");

        (bool sent,) = receiver.call{value:_amount}("");
        require(sent,"Transaction is unsucessfull");
        selfdestruct(sender);
    }
    
    // Function to stop / cancel the contract.
    function cancel() external{
        require(msg.sender == sender, "Only sender can call this function");
        require(block.timestamp >= expiresAt,"Sorry contract is expired!");
        selfdestruct(sender);
    }
    
}