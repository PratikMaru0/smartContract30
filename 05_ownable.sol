// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

// What this smart contract do.
// - the owner can be set who is deploying 
// - can not be changed
// - Check function if the user is owner or not 
// - the ownership can be transferred by calling a function

contract ownable{

    address public owner;

    event OwnershipTransferred(address indexed previousOwner,address indexed newOwner);

    constructor(){
        owner = msg.sender;
    }

    // modifier for owner check
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }

    // function to check current Owner
    function currentOwner() public view returns(address){
        return owner;
    }

    // Function to transfer the ownership of the contract to another address by the current owner
    function transferOwnership(address newOwner) public onlyOwner{
        require(newOwner != address(0) && newOwner != owner, "The new owner address is not valid");
        owner = newOwner;
        emit OwnershipTransferred(msg.sender,owner);
    }

    // Function to leave the contract without owner, therefore disabling all the functions
    // that require onlyOwner
    function renounceOwnership() public virtual onlyOwner{
        // selfdestruct(payable(owner));    // for testing purposes.
        owner = address(0);
    }
}