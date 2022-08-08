// SPDX-License-Identifier: MIT

pragma solidity >= 0.4.0 < 0.9.0;

// What this smart contract do. 
// Vauld  (Smart contract name)
// user can deposit money
// it will mint some share 
// vault generate some yield
// User can withdraw the shares with the increased amount

// TODO: Must visit to know more about vault :- https://medium.datadriveninvestor.com/how-do-crypto-vaults-work-c8609853ad90
// TODO: Must watch :- Youtube video (Channel name :- Smart contract programmer ) video name :- Vault Math DeFi . 

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

contract vault{
    IERC20 public token;
    uint public totalSupply;   // total Supply. 
    mapping(address => uint) public balanceOf;    // share per user

    constructor(address _token) {
        token = IERC20(_token);
    }

    function mint(address _to, uint shares) public {
        totalSupply += shares;
        balanceOf[_to] += shares;
    }

    function burn(address _from, uint shares) public {
        totalSupply -= shares;
        balanceOf[_from] -= shares;
    }

    function deposit(uint _amount) external {
        uint shares;
        if(totalSupply == 0){
            shares = _amount;
        }
        else{
            shares = (_amount*totalSupply) / token.balanceOf(address(this));  // For formula :- watch yt video recommended above. 
        }

        mint(msg.sender,shares);
        token.transferFrom(msg.sender,address(this),_amount);
    }

    function withdraw(uint _shares) external {
        uint amount = (_shares*token.balanceOf(address(this)))/ totalSupply ;  // For formula :- watch yt video recommended above.
        burn(msg.sender,_shares) ;
        token.transfer(msg.sender, amount) ;
    } 

}