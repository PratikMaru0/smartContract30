// FIXME: Testing is LEFT.

// SPDX-License-Identifier: MIT

pragma solidity >= 0.4.0 < 0.9.0;
pragma experimental ABIEncoderV2;

// Bi-Directional Payment ??????
// What this smart contract do :- 
// -Bi-directional payment channels allow participants Alice and Bob to repeatedly transfer Ether off-chain.
// -Payments can go both ways, Alice pays Bob and Bob pays Alice

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.5/contracts/utils/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.5/contracts/utils/cryptography/ECDSA.sol";

contract biDirectional{
    using SafeMath for uint;
    using ECDSA for bytes32;

    event ChallengeExit(address indexed sender, uint nonce);
    event Withdraw(address indexed to, uint amount);

    address payable[2] public users;  // storing address of the alice and bob 
    mapping(address=>bool) public isUser;   // checking whether the address is user or not.
    mapping(address=>uint) public balances;  // keeping track of the balances 

    uint public challengePeriod;  
    uint public expiresAt;
    uint public nonce;

    modifier checkBalances(uint[2] memory _balances){
        require(address(this).balance >= _balances[0].add(_balances[1]),"Balance of contract must be >= to the total balance of the users");
        _;
    }

    constructor(address payable[2] memory _users, uint[2] memory _balances, uint _expiresAt, uint _challengePeriod) payable checkBalances(_balances) {
        require(_expiresAt > block.timestamp, "Expiration must be > now");
        require(_challengePeriod > 0, "Challenge period must be > 0");

        for (uint i = 0; i < _users.length; i++) {
            address payable user = _users[i];

            require(!isUser[user], "user must be unique");
            users[i] = user;
            isUser[user] = true;

            balances[user] = _balances[i];
        }

        expiresAt = _expiresAt;
        challengePeriod = _challengePeriod;
    }

    function verify(bytes[2] memory _signatures, address _contract, address[2] memory _signers, uint[2] memory _balances, uint _nonce) public pure returns(bool){
        for(uint i=0;i<_signatures.length;i++){
            bool valid = _signers[i] == keccak256(abi.encodePacked(_contract, _balances, _nonce)).toEthSignedMessageHash().recover(_signatures[i]);
            if(!valid){
                return false;
            }
        }
        return true;
    }

    modifier checkSignatures(bytes[2] memory _signatures, uint[2] memory _balances, uint _nonce){
        address[2] memory signers;
        for(uint i=0;i<users.length;i++){
            signers[i] = users[i];
        }   

        require(verify(_signatures, address(this), signers, _balances, _nonce),"Invalid Signatures");
        _;
    }

    modifier onlyUser(){
        require(isUser[msg.sender],"Not a user");
        _;
    }

    function challengeExit(uint[2] memory _balances, uint _nonce, bytes[2] memory _signatures) public onlyUser checkSignatures(_signatures,_balances,_nonce) checkBalances(_balances){
        require(block.timestamp < expiresAt, "Challenge period is Expired");
        require(_nonce > nonce, "Nonce must be greater than the current nonce");

        for(uint i=0;i<_balances.length;i++){
            balances[users[i]] = _balances[i];
        }

        nonce = _nonce;
        expiresAt = block.timestamp.add(challengePeriod);
        emit ChallengeExit(msg.sender,nonce);
    }

    function withdraw() public onlyUser{
        require(block.timestamp >= expiresAt,"Challenge period has not expired at");
        uint amount = balances[msg.sender];
        balances[msg.sender] = 0;
        (bool sent, ) = msg.sender.call{value:amount}("");
        require(sent,"Failed to send ether");
        emit Withdraw(msg.sender,amount);
    }
}