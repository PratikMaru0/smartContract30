// SPDX-License-Identifier: MIT

pragma solidity >= 0.4.0 < 0.9.0;

// What this smart contract do ?
// - Create a pool contract that accepts deposit from lenders , who earn interest on lending
// - User  or borrower can borrow some amount of tokens (limited) , and pay back with some interest for some time period. 
// - lender can withdraw the amount later with some interest 

// This liquidity pool acts same like a traditional bank works. Like account holder make FD and get fixed amount of returns and borrowers borrow money at fixed interest cost and difference is bank's profit.

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SimpleToken is ERC20 {

    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
    }
}

contract liquidityPool{
    IERC20 token;
    uint256 totalSupply;
    uint256 lendRate = 100;
    uint256 borrowRate = 130;
    uint256 periodBorrowed;

    address public owner;

    struct amount{
        uint amount;
        uint start;
    }

    // Lenders Data
    mapping(address=>bool) lenders;
    mapping(address=>amount) lendAmount;
    mapping(address=>uint) earnedInterest;

    // Borrowers data
    mapping(address=>bool) borrowers;
    mapping(address=>amount) borrowAmount;
    mapping(address=>uint) payInterest;

    constructor(address _tokenAddress,uint _amount) payable{
        token = IERC20(_tokenAddress);
        token.transferFrom(msg.sender,address(this),_amount);
        owner = msg.sender;
    }

    // function to lend money
    function lend(uint _amount) external{
        require(_amount != 0, "Amount can no be zero");
        token.transferFrom(msg.sender,address(this),_amount);
        lendAmount[msg.sender].amount = _amount;
        lendAmount[msg.sender].start = block.timestamp;
        lenders[msg.sender] = true;
        totalSupply += _amount;
    }   

    // function to borrow money
    function borrow(uint _amount) external {
        require(_amount != 0, "Amount can not be zero");
        require(_amount <= totalSupply,"There is not enough fund in pool");
        token.transfer(msg.sender,_amount);
        borrowAmount[msg.sender].amount = _amount;
        borrowAmount[msg.sender].start = block.timestamp;
        borrowers[msg.sender] = true;
        totalSupply -= _amount;
    }

    // Function to repay the whole loan 
    function repay() external{
        require(borrowers[msg.sender] == true,"You are not a borrower");
        amount storage amount_ = borrowAmount[msg.sender];
        uint _amount = (amount_.amount + amount_.amount*((block.timestamp - amount_.start)*borrowRate*1e18)/totalSupply);
        require(_amount != 0,"Amount can not be zero");
        token.transferFrom(msg.sender,address(this),_amount);
        delete borrowAmount[msg.sender];
        borrowers[msg.sender] = false;
        totalSupply += _amount;
    }

    // function to withdraw the amount for the lender 
    function withdraw() external{
        require(lenders[msg.sender] == true, "You are not a lender");
        amount storage amount_ = lendAmount[msg.sender];
        uint _amount = (amount_.amount + amount_.amount*((block.timestamp - amount_.start)*lendRate*1e18)/totalSupply);
        require(_amount != 0,"Amount can not be zero");
        delete lendAmount[msg.sender];
        lenders[msg.sender] = false;
        totalSupply -= _amount;
        token.transfer(msg.sender,_amount);
    }

}