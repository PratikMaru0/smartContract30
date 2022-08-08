// Didnt understood. 

// SPDX-License-Identifier: MIT

pragma solidity >= 0.4.0 < 0.9.0;

// What this smart contract do ? 
// Merkle Proof generator & checker ??
// - should generate Merkle proof & verify it. 

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/utils/cryptography/MerkleProof.sol" ;

// Merkle tree also known as hash tree is a data structure used for data verification and synchronization. 
// It is a tree data structure where each non-leaf node is a hash of it’s child nodes. All the leaf nodes are at the same depth and are as far left as possible. 
// It maintains data integrity and uses hash functions for this purpose.

contract Merkle{
    bytes32 public merkleRoot;
    constructor(bytes32 _merkleroot){
        merkleRoot = _merkleroot;
    }

    // function to generate the merkle hash for a set of data 
    function hash(address _address, uint256 _nonce) public pure returns(bytes32){
        return keccak256(abi.encodePacked(_address,_nonce));
    }

    // verify root with the proof the user has 
    function verify(bytes32[] calldata _proof, bytes32 _hash) public view returns(bool){
        bytes32 leaf = _hash;
        return MerkleProof.verify(_proof,merkleRoot,leaf);
    }
}// Didnt understood. 

// SPDX-License-Identifier: MIT

pragma solidity >= 0.4.0 < 0.9.0;

// What this smart contract do ? 
// Merkle Proof generator & checker ??
// - should generate Merkle proof & verify it. 

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/utils/cryptography/MerkleProof.sol" ;

// Merkle tree also known as hash tree is a data structure used for data verification and synchronization. 
// It is a tree data structure where each non-leaf node is a hash of it’s child nodes. All the leaf nodes are at the same depth and are as far left as possible. 
// It maintains data integrity and uses hash functions for this purpose.

contract Merkle{
    bytes32 public merkleRoot;
    constructor(bytes32 _merkleroot){
        merkleRoot = _merkleroot;
    }

    // function to generate the merkle hash for a set of data 
    function hash(address _address, uint256 _nonce) public pure returns(bytes32){
        return keccak256(abi.encodePacked(_address,_nonce));
    }

    // verify root with the proof the user has 
    function verify(bytes32[] calldata _proof, bytes32 _hash) public view returns(bool){
        bytes32 leaf = _hash;
        return MerkleProof.verify(_proof,merkleRoot,leaf);
    }
}// Didnt understood. 

// SPDX-License-Identifier: MIT

pragma solidity >= 0.4.0 < 0.9.0;

// What this smart contract do ? 
// Merkle Proof generator & checker ??
// - should generate Merkle proof & verify it. 

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/utils/cryptography/MerkleProof.sol" ;

// Merkle tree also known as hash tree is a data structure used for data verification and synchronization. 
// It is a tree data structure where each non-leaf node is a hash of it’s child nodes. All the leaf nodes are at the same depth and are as far left as possible. 
// It maintains data integrity and uses hash functions for this purpose.

contract Merkle{
    bytes32 public merkleRoot;
    constructor(bytes32 _merkleroot){
        merkleRoot = _merkleroot;
    }

    // function to generate the merkle hash for a set of data 
    function hash(address _address, uint256 _nonce) public pure returns(bytes32){
        return keccak256(abi.encodePacked(_address,_nonce));
    }

    // verify root with the proof the user has 
    function verify(bytes32[] calldata _proof, bytes32 _hash) public view returns(bool){
        bytes32 leaf = _hash;
        return MerkleProof.verify(_proof,merkleRoot,leaf);
    }
}