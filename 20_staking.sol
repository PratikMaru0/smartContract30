// SPDX-License-Identifier: MIT

pragma solidity >= 0.4.0 < 0.9.0;

// Staking your crypto allows you to earn interest while holding onto -
// your favorite coins. Staking is fast and easy, and crypto -
// investors now have a range of platforms to choose from for -
// different coins, staking periods, and crypto interest rates.

// Thoda sa complicated hai in terms of formula. Dekh lio ache se.

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

contract Staking{
    IERC20 public rewardsToken;    //token that we'll distribute as a reward
    IERC20 public stakingToken;    // token that we'll accept to stake.

    uint public rewardRate = 100;       // rate at which reward will increase
    uint public lastUpdateTime;         // Last interaction timestamp of the contract.  
    uint public rewardPerTokenStored;   // Latest reward per token rate is stored.

    mapping(address => uint256) public rewards;                 // reward tracking of the depositors.
    mapping(address => uint256) public rewardsPerTokenPaid;     // mapping for the rewards per token paid
    mapping(address => uint256) public staked;                  // tracking the number of tokens staked by the depositors.
    uint256 public _totalSupply;                                // total supply for the staked token in the contract

    constructor(address _stakingToken, address _rewardsToken) {
        stakingToken = IERC20(_stakingToken);
        rewardsToken = IERC20(_rewardsToken);
    }

    // function to calculate the reward per token. ?
    function rewardPerToken() public view returns (uint) {
        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored + (((block.timestamp - lastUpdateTime) * rewardRate * 1e18) / _totalSupply);  // formula to calculate the reward per token.
    }

    // function to display total reward earned till date by the staker (Depositor). ?
    function earned(address account) public view returns(uint){
        return ((staked[account]* (rewardPerToken()-rewardsPerTokenPaid[account])) / 1e18) + rewards[account];
    }
  
    // modifier to update the reward per token as per the time and reward mapping , rewardsPaid mapping. 
    modifier updateReward(address account){
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;
        rewards[account] = earned(account);
        rewardsPerTokenPaid[account] = rewardPerTokenStored;
        _;
    }  
    
    // function to stake the required token. ?
    function stake(uint _amount) external updateReward(msg.sender){
        _totalSupply += _amount;
        staked[msg.sender] += _amount;
        stakingToken.transferFrom(msg.sender,address(this),_amount);
    }

    // function to withdraw the staked token with reward. This will simutaneosly update the all the tracking mappings made. ?
    function withdraw(uint _amount) external updateReward(msg.sender){
        _totalSupply -= _amount;
        staked[msg.sender] -= _amount;
        stakingToken.transfer(msg.sender,_amount);
    }    

    // function to withdraw the reward only. ?  
    function getReward() external updateReward(msg.sender){
        uint reward = rewards[msg.sender];
        rewards[msg.sender] = 0;
        rewardsToken.transfer(msg.sender, reward);
    }
}