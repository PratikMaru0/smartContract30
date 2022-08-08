// FIXME: Here we are using chainlink. So testing of this smart contract is remaining. 

// SPDX-License-Identifier: MIT

pragma solidity >=0.4.0 < 0.9.0;

// How do I get the price of ETH in USD inside my smart contract 
// We can use chainlink. 

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract chainlink{
    AggregatorV3Interface internal priceFeed;

    constructor(){
        priceFeed  = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
    }

    function getLatestPrice() public view returns(int){
        (uint80 roundID, int price, uint startedAt, uint timestamp, uint80 answeredInRound) = priceFeed.latestRoundData();

        // for ETH / USD price is scaled up by 10**8
        return price/ 1e18;
    }

}