// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

// ERC token :- 
// ERC fullform :- Ethereum Request for Comment.  ERC is a form of proposal and its purpose is to
// define standards and practices. 
// Token :- Tokens are a type of Cryptocurrency that represents an asset or specific use 
// and reside on their blockchain.

// ERC-20 Specified Six Different Coding Functions
// 1) totalSupply() :- This function allows an instance of the contract to calculate and return the total amount of the token that exists in circulation.
//  2) balanceOf(address _owner) :- This function allows a smart contract to store and return the balance of the provided address.
//  3) allowance(address _owner, address _spender) :- returns the amount that "_spender" is still allowed to withdraw from "_owner" 
//  4) transfer(address _to, uint _value) :- This function lets the owner of the contract send a given amount of the token to another address just like a conventional cryptocurrency transaction and it also fires the transfer event. 
//  5) approve(address _spender, uint256 _value) :- When calling this function, the owner of the contract authorizes, or approves, the given address to withdraw instances of the token from the owner’s address. Successfull call must fire the approval event.
//  6) transferFrom(address _from, address _to, uint256 _value) :- This function allows a smart contract to automate the transfer process and send a given amount of the token on behalf of the owner. With this function, a contract can send a certain amount of the token to another address on your behalf, without your intervention.

// ERC-20 Specified 2 events 
// 1) transfer , 2) approve

// NOTE: A full compatible ERC20 Token must implement 6 functions and 2 events

// Abstract contracts are contractss that have at least one function without its implmentation. 
// To make a contract abstract yo have to use abstract keyword.
abstract contract ERC20_STD{

    // When we declare token we must specify :- name , symbol , decimals.
    function name() public view virtual returns(string memory);
    function symbol() public view virtual returns(string memory);
    function decimals() public view virtual returns(uint8);

    // these are the six functions that we disscused above.
    function totalSupply() public view virtual returns(uint256);
    function balanceOf(address _owner) public view virtual returns(uint256 balance);
    function transfer(address _to, uint256 _value) public virtual returns(bool success);
    function transferFrom(address _from, address _to, uint256 _value) public virtual returns(bool success);
    function approve(address _spender, uint256 _value) public virtual returns(bool success);
    function allowance(address _owner, address _spender) public view virtual returns(uint256 remaining);

    // these are two events that we discussed above.
    event Transfer(address indexed _from, address indexed _to, uint256 _value) ;
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}

contract Ownership {
    address public contractOwner;
    address public newOwner;

    event TransferOwnership(address indexed _from, address indexed _to);

    constructor(){
        contractOwner = msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender == contractOwner,"You are not an owner");
        _;
    }

    function changeOwner(address _to) public onlyOwner{
        newOwner = _to;
    }

    function acceptOwner() public {
        require(msg.sender == newOwner, "Only new owner can call it");
        emit TransferOwnership(contractOwner,newOwner);
        contractOwner = newOwner;
        newOwner = address(0);
    }
}

contract myERC20 is Ownership,ERC20_STD{

    string public _name;
    string public _symbol;
    uint8 public _decimals;
    uint256 public _totalSupply;
    address public _minter;

    mapping(address => uint256) tokenBalances;
    mapping(address => mapping(address => uint256)) allowed;

    constructor(address minter_){
        _name = "Crypto Gyan";
        _symbol = "CGC";
        _totalSupply = 100000;
        _minter = minter_;
        tokenBalances[_minter] = _totalSupply;
    }

    function name() public view override returns(string memory){
        return _name;
    }

    function symbol() public view override returns(string memory){
        return _symbol;
    }

    function decimals() public view override returns(uint8){
        return _decimals;
    }

    function totalSupply() public view override returns(uint256){
        return _totalSupply;
    }

    function balanceOf(address _owner) public view override returns(uint256 balance){
        return tokenBalances[_owner];
    }

    function transfer(address _to, uint256 _value) public override returns(bool success){
        require(tokenBalances[msg.sender] >= _value,"Insufficient balance");
        tokenBalances[msg.sender] -= _value;
        tokenBalances[_to] += _value;
        emit Transfer(msg.sender,_to,_value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public override returns(bool success){
        uint allowedBal = allowed[_from][_to];
        require(allowedBal >= _value,"Insufficient balance");
        tokenBalances[_from] -= _value;
        tokenBalances[_to] += _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public override returns(bool success){
        require(tokenBalances[msg.sender] >= _value,"Insufficient balance");
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view override returns(uint256 remaining){
        return allowed[_owner][_spender];
    }
}