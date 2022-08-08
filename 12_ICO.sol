// SPDX-License-Identifier: MIT

pragma solidity >= 0.4.0 < 0.9.0;

// ICO :-
// An initial coin offering (ICO) is the cryptocurrency industry's
// equivalent to an initial public offering (IPO). A company seeking 
// to raise money to create coin, app, or service can launch an ICO
// as a way to raise funds. Interested investors can buy into an 
// initial coin offering to receive a new cryptocurrency token issued 
// by the company. This token may have some utility related to the 
// product or service that the company is offering, or it may just 
// represent a stake in the company or project. Its not regulated.

// So anyone can create an ICO ? 
// 1). First you need Whitepaper :- need to mention Marketing plan, What 
// problem the coin solves, How the coin is different, code mechanics of the
// coin, Developer fees, wallets, and future spending plans, Long term goals
// 2). Second, you'll need to market it :- do advertisement on crypto platforms,
// join groups etc. 
// 3). Sell your coin on a platform :- There are platforms that allows you to
// do ICO. Where anyone can buy coin. The idea of buying coins is to allow
// investors early access to the cheaper price then hpefully once the coin
// launces price will increase which means investors can sell the coins for
// profit.

// Cons :- Risks involved.
// 1). There are many ICOs who collects the money and never developed the project.
// 2). After launching ICO price fails of the token/coin.

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/access/Ownable.sol";

interface INFT{
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns(uint256 tokenId);
    function balanceOf(address owner) external view returns(uint256 balance);
}

// A user whitelisted can mint the tokens.

contract MyToken is ERC20 , Ownable {
    uint256 public constant tokenPrice = 0.001 ether;  // fixed price of the token
    // Each NFT would give the user 10 tokens. 
    // 1 token = 10 ** 18 (Smallest denomination possible).
    // Means 10^(-18) == 1 balance
    // Simply Owning 1 full token is equal to owning (10^18) tokens when you account for the decimal places.
    uint public constant tokensPerNFT = 10 * (10 ** 18);
    uint public constant maxTotalSupply = 1000 * (10**18);

    INFT NFT; // NFT contract instance.
    mapping(uint256=>bool) public tokenIdsClaimed;
    constructor(address _nft) ERC20("MedicoCrypt","MCY"){
        NFT = INFT(_nft);
    }

    // mint tokens
    function mint(uint256 amount) public payable{
        uint256 _requiredAmount = tokenPrice * amount;
        require(msg.value >= _requiredAmount,"Insufficient fud transfer");
        uint256 amountWithDecimals = amount * 10**18;   
        require((totalSupply() + amountWithDecimals) <= maxTotalSupply, "Exceeds the max total supply available");
        _mint(msg.sender, amountWithDecimals); // calling internal function
    }
    
    // to claim tokens if user owns NFT.
    function claim() public payable{
        address sender = msg.sender;
        uint balance = NFT.balanceOf(sender); // get the number of NFTs held by a given address.
        require(balance > 0,"You don't own any NFT's");  // revert the trxns if the balance is 0
        uint amount;   
        for(uint256 i=0;i<balance;i++){
            uint256 tokenId = NFT.tokenOfOwnerByIndex(sender,i);
            if(!tokenIdsClaimed[tokenId]){
                amount += 1;
                tokenIdsClaimed[tokenId] = true;
            }

        }
        require(amount > 0, "You have already claimed all the tokens");
        _mint(msg.sender,amount*tokensPerNFT); 
    }

    receive() external payable{
    }

    fallback() external payable {
    }
}