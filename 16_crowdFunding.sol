// SPDX-License-Identifier: MIT

pragma solidity >= 0.6.2;

// What this smart contract do ?
// - A campaign is created with the target , 
// - User can pledge , give tokens for campaign
// - When target reaches , campaign closes and the creator can claim the amount
// - If campaign is not completed , user can withdraw the pledge

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SimpleToken is ERC20 {
    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) public ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
    }
}

contract crowdFunding{

    event Launch(uint id, address indexed creator , uint goal, uint startAt, uint endAt);
    event Cancel(uint id);
    event Pledge(uint indexed id, address indexed caller, uint amount);
    event Unpledge(uint indexed id, address indexed caller, uint amount);
    event Claim(uint id);
    event Refund(uint indexed id, address indexed caller, uint amount);

    struct Campaign{
        address creator;
        uint goal;
        uint pledged;
        uint startAt;
        uint endAt;
        bool claimed;
    }

    IERC20 public immutable token;
    uint public count; 
    mapping(uint => Campaign) public campaigns;
    mapping(uint => mapping(address => uint) ) public plegedAmount;

    constructor(address _token){
        token = IERC20(_token);
    }

    function launch(uint _goal, uint _startAt, uint _endAt) external {
        require(_startAt >= block.timestamp,"Start at < now");
        require(_endAt >= _startAt , "EndAt < StartAt");
        require(_endAt <= block.timestamp + 90 days, "endAt > max duration");

        count += 1;
        campaigns[count] = Campaign({
            creator : msg.sender,
            goal : _goal,
            pledged : 0,
            startAt : _startAt,
            endAt : _endAt,
            claimed : false
        });
        emit Launch(count, msg.sender, _goal, _startAt, _endAt);
    }

    function cancel(uint _id) external {
        Campaign memory campaign = campaigns[_id];
        require(msg.sender == campaign.creator, "Not a campaign creator. Only creator can call this function");
        require(block.timestamp < campaign.startAt,"Started");
        delete campaigns[_id];
        emit Cancel(_id);
    }

    function pledge(uint _id, uint _amount) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp >= campaign.startAt,"Not started yet");
        require(block.timestamp <= campaign.endAt,"Campaign Ended");   
        campaign.pledged += _amount;
        plegedAmount[_id][msg.sender] += _amount;
        token.transferFrom(msg.sender,address(this),_amount);
        emit Pledge(_id,msg.sender,_amount);
    }

    function unpledge(uint _id, uint _amount) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp <= campaign.endAt,"Campaign Ended");
        campaign.pledged -= _amount;
        plegedAmount[_id][msg.sender] -= _amount;
        token.transfer(msg.sender,_amount);
        emit Unpledge(_id,msg.sender,_amount);

    }

    function claim(uint _id) external {
        Campaign storage campaign = campaigns[_id];
        require(msg.sender == campaign.creator,"Not a creator");
        require(block.timestamp > campaign.endAt,"Campaign Not Ended Yet");
        require(campaign.pledged >= campaign.goal,"Pledged < Goal");
        require(!campaign.claimed,"Claimed");
        campaign.claimed = true;
        token.transfer(msg.sender,campaign.pledged);
        emit Claim(_id);
    }

    function refund(uint _id) external{
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp > campaign.endAt,"Campaign Not Ended Yet");
        require(campaign.pledged < campaign.goal,"Pledged < Goal");
        uint bal = plegedAmount[_id][msg.sender];
        plegedAmount[_id][msg.sender] = 0;
        token.transfer(msg.sender,bal);
        emit Refund(_id,msg.sender, bal);
    }
}