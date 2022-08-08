// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

// What smart contract is doing :- 
// - Should accept Ether 
// - Owner will be able to withdraw

contract etherWallet{
    address payable public owner;

    event Deposit(address account, uint amount);
    event Withdraw(address account, uint amount);

    constructor(){
        owner = payable(msg.sender);  // payable is used to indicae that this address must be paid.       
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Caller is not a owner");
        _;
    }

    function getBalance() external view returns(uint balance){
        return address(this).balance;
    }

    function withdraw(uint amount) external onlyOwner {
        payable(msg.sender).transfer(amount);
        emit Withdraw(msg.sender,amount);
    }

    // receive() A contract can now have only one receive function that is 
    // declared with the syntax receive() external payable {…} (without the 
    // function keyword). It executes on calls to the contract with no data 
    // ( calldata ), such as calls made via send() or transfer() .
    receive() external payable{
        emit Deposit(msg.sender,msg.value);
    }

    // In Solidity, a fallback function is an external function with neither a name, 
    // parameters, or return values. It is executed in one of the following cases: 
    // If a function identifier doesn't match any of the available functions in a 
    // smart contract. If there was no data supplied along with the function call.
    fallback() external payable{}   // must make visisbility external and no arguments.

}


// More on fallback 
// 1). It is executed when a non-existenct function is called on the contract.
// 2). It is required to be marked external.
// 3). It has no name.
// 4). It has no arguments.
// 5). It can not return any thing.
// 6). It can be defined one per contract. 
// 7). If not marked payable, it will throw exception if contract receives ether.
// 8). Its main use is to directly send the ETH to contract.
