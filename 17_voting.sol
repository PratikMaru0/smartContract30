// SPDX-License-Identifier: GPL

pragma solidity > 0.4.0 < 0.9.0;

// What this smart contract do ? 
// - users can create proposal
// - Other users can vote yes or no , results can be fetched
// -  If the results are in majority, a action can be performed

// Lets deep dive in ????? 

contract voting{

struct Proposal {
    string proposal_;
    uint deadline;  // timestamp untill which this proposal is active
    uint yayVotes;    // total number of yes votes 
    uint nayVotes;    // total number of no votes
    bool executed;
    uint id;
    mapping(uint => mapping(address => bool)) voters;   // a mapping to check whether the voter is already voted or not. (One address can vote only once).
}

mapping(uint => Proposal) public proposals;
uint public numProposals;

modifier active(uint proposalIndex){
    require(block.timestamp < proposals[proposalIndex].deadline,"Deadline exceeded");
    _;
}

enum Vote{
    YAY,
    NAY
}

// Function to create a Proposal.
function createProposal(string memory _proposal) external returns(uint){
    Proposal storage proposal = proposals[numProposals];
    proposal.proposal_ = _proposal;
    proposal.deadline = block.timestamp + 1 days;
    proposal.id++;
    numProposals++;
    return numProposals - 1;
}

// Function to vote for the proposal
// _id = proposal id
// vote = enum (YAY / NAY )
function vote(uint _id, Vote voteYN) external active(_id){
    Proposal storage proposal = proposals[_id];
    require(proposal.voters[_id][msg.sender] == false,"Already voted");
    if(voteYN == Vote.YAY){
        proposal.yayVotes += 1;
    }
    else {
        proposal.nayVotes += 1;
    }
    proposal.voters[_id][msg.sender] = true;   
}

// Function to get the votes of the particular proposal.
function getVotes(uint _id) view external returns(uint,uint){
    Proposal storage proposal = proposals[_id];
    uint _yayVotes = proposal.yayVotes;
    uint _nayVotes = proposal.nayVotes;
    return (_yayVotes, _nayVotes);
}

}