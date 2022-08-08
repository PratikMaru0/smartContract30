// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

// What this smart contract do.
// - User can deposit in the wallet 
// - Owner can Withdraw the amount
// - The Contract should be destroyed after withdrawal

contract piggyBank{

    address public owner;

    event Deposit(uint amount);
    event Withdraw(uint amount);

    constructor(){
        owner = payable(msg.sender);
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "You are not owner");
        _;
    }

    receive() external payable{
        emit Deposit(msg.value);
    }

    fallback() external payable{

    }

    // function to withdraw the amount that owner needs
    function withdraw(uint amount) external onlyOwner{
        payable(msg.sender).transfer(amount);
        emit Withdraw(address(this).balance);
        selfdestruct(payable(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2));
        // selfdestruct can be used to destroy 
        // and send all the eth remaining to the address mentioned, it deleted the ABI
        // associated with it, therefore no function call work there can be an attack too 
        // using selfdestruct where user can force send ether from attack contract to the
        // target contract , destructing this attack contract . more we'll see on this later
        // on.
    }

    function getBalance() public view returns(uint){
        return address(this).balance;
    }
}