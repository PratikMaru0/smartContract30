// SPDX-License-Identifier: MIT

pragma solidity >= 0.4.0 < 0.9.0;

// What this smart contract do ? 
// Subscription service ??
// - A Subscription service is started
// -  Payment can be deducted after a period of 30 days , and anyone can trigger it 
// - Payment is done from a particular ERC20 token , and approval needs to be given by payee

// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/IERC20.sol" ;

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
        _totalSupply = 1000;
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

contract subscriptionPlan{
    myERC20 token;
    address public owner;
    address public merchant;
    uint256 public frequency;   // here frequenct means time (valid till) fro eg :- 7 days valid 
    uint256 public amount;

    struct Subscription{
        address subscriber;
        uint start;
        uint nextPayment;
    }

    mapping(address=>Subscription) public subscriptions;

    event subscriptionCreated(address subscriber, uint date);
    event subscriptionCancelled(address subscriber,uint date);
    event paymentSent(address from, address to, uint amount, uint date);

    // Constructor to take all the details needed for a subscription plan
    constructor(address _token, address _merchant, uint _amount, uint _frequency){
        token = myERC20(_token);
        owner = msg.sender;
        require(_merchant != address(0),"Address can not be null address");
        merchant = _merchant;
        require(_amount != 0, "Amount cannot be zero");
        amount = _amount;
        require(_frequency != 0,"Frequency can not be zero");
        frequency = _frequency;
    }

    // Function to subscribe a service
    function subscribe() external{
        token.transferFrom(msg.sender, merchant, amount);
        emit paymentSent(msg.sender, merchant,amount,block.timestamp);
        subscriptions[msg.sender] = Subscription(msg.sender,block.timestamp,block.timestamp+frequency);
        emit subscriptionCreated(msg.sender,block.timestamp);
    }

    // Function to cancel the subscription 
    function cancel() external {
        Subscription storage subscription = subscriptions[msg.sender];
        require(subscription.subscriber != address(0),"This subscription does not exists");
        delete subscriptions[msg.sender];
        emit subscriptionCancelled(msg.sender,block.timestamp);
    }
 
    // Function to  renew the subscription after the period of expiration of the current subscription.
    function renew(address subscriber) external {
        Subscription storage subscription = subscriptions[subscriber];
        require(subscription.subscriber != address(0),"The Subscription does not exists.");
        require(block.timestamp > subscription.nextPayment,"Subscription is not ended yet.");
        token.transferFrom(subscriber,merchant,amount);
        emit paymentSent(subscriber,merchant,amount,block.timestamp);
        subscription.nextPayment += frequency;
    }

}