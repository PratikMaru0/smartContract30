// SPDX-License-Identifier: MIT

pragma solidity >= 0.4.0 < 0.9.0;

// What this smart contract do ?
// - Allows user who owns a certain tokens or a NFT
// - then can participate in voting and governance decision

// interface INFT{
//     function balanceOf(address owner) external view returns(uint256);
//     function tokenOfOwnerByIndex(address owner, uint index) external view returns(uint256);
// }

// What this actually do ?
// This DAO bounds the entry for all those who have the DAO nft, they
// can create and vote on proposals it is similar to voting but we just
// added the nft ownership functionality that restricts them to vote 
// only if they are part of DAO.

// Lets deep dive into this ?????

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.4/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.4/contracts/utils/Counters.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.4/contracts/access/Ownable.sol";

contract INFT is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("NFT-Example", "NEX") {}

    function mintNft(address receiver, string memory tokenURI) external onlyOwner returns (uint256) {
        _tokenIds.increment();

        uint256 newNftTokenId = _tokenIds.current();
        _mint(receiver, newNftTokenId);
        _setTokenURI(newNftTokenId, tokenURI);

        return newNftTokenId;
    }
}

contract DAO{
    INFT nft;

    // user defined data type (Struct) for proposal.
    struct Proposal {
    string proposal_;
    uint deadline;  // timestamp untill which this proposal is active
    uint yayVotes;    // total number of yes votes 
    uint nayVotes;    // total number of no votes
    bool executed;
    uint id;
    mapping(uint => mapping(address => bool)) voters;   // a mapping to check whether the voter is already voted or not. (One address can vote only once).
}

    mapping(uint256 => Proposal) public proposals;
    uint256 public numProposals=0;
    address public owner;

    // Here payable constructor means we can transfer some amount of 
    // ETH to the contract while deploying the contract.
    constructor(address _nft) payable{
        nft = INFT(_nft);
        owner = msg.sender;
    }

    modifier nftHolderOnly(){
        require(nft.balanceOf(msg.sender) > 0, "NOT A DAO MEMBER");
        _;
    }

    modifier active(uint proposalIndex){
        require(block.timestamp < proposals[proposalIndex].deadline,"Deadline exceeded");
        _;
    }

    modifier inactiveProposal(uint proposalIndex) {
        require(proposals[proposalIndex].deadline <= block.timestamp,"Deadline is not Exceeded");
        require(proposals[proposalIndex].executed == false,"Proposal is already executed");
        _;
    }

    modifier onlyOwner(){
        require(msg.sender == owner,"Only owner can call this function");
        _;
    }

    // function to get the contract balance. 
    function getBalance() public view returns(uint){
        return address(this).balance;
    }

    // Function to create proposal
    function createProposal(string memory _proposal) external returns(uint){
        Proposal storage proposal = proposals[numProposals];
        proposal.proposal_ = _proposal;
        proposal.deadline = block.timestamp + 3 minutes;   // for testing purpose time taken is very less. 
        proposal.id++;
        numProposals++;
        return numProposals - 1;
    }

    enum Vote {
        YAY, // YAY = 0
        NAY // NAY = 1
    }

    // Only nft owner can vote for the proposals.
    function vote(uint _id, Vote voteYN) external active(_id) nftHolderOnly{
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

    // function to execute the proposal The DAO has voted on by checking the votes.
    function executeProposal(uint256 _id) external nftHolderOnly inactiveProposal(_id){
        Proposal storage proposal = proposals[_id];
        if(proposal.yayVotes > proposal.nayVotes){
            proposal.executed = true;
        }
        else{
            proposal.executed = false;
        }
    }

    // Function to get the votes of the particular proposal.
    function getVotes(uint _id) view external returns(uint,uint){
        Proposal storage proposal = proposals[_id];
        uint _yayVotes = proposal.yayVotes;
        uint _nayVotes = proposal.nayVotes;
        return (_yayVotes, _nayVotes);
    }

    // function to withdraw the ether out of the contract 
    function withdraw() external onlyOwner{
        address payable _owner = payable(msg.sender);       
        uint amount = address(this).balance;
        _owner.transfer(amount);
    }    


    // below functions allow the contract to accept ETH deposits directly  
    // from a wallet without calling a function 
    receive() external payable{}
    fallback() external payable{}


}