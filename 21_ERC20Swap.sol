// SPDX-License-Identifier:MIT

pragma solidity >= 0.4.0 < 0.9.0;

// What this smart contract do ?
// - 2 tokens can be swapped 
// - decided by the users for the exchange price of both the token

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

contract ERC20Swap{
    IERC20 public token1;
    address public owner1;
    IERC20 public token2;
    address public owner2;

    constructor(address _token1, address _owner1, address _token2, address _owner2) {
        token1 = IERC20(_token1);
        owner1 = _owner1;
        token2 = IERC20(_token2);
        owner2 = _owner2;
    }

    function _safeTransferFrom(IERC20 token, address sender, address recepient, uint amount) private{
        bool sent = token.transferFrom(sender,recepient,amount);
        require(sent,"Transaction failed to execute");
    }

    function swap(uint amount1, uint amount2) public {
        require(msg.sender == owner1 || msg.sender == owner2, "Not authorized");
        require(token1.allowance(owner1,address(this)) >= amount1, "token 1 allowance is too low to spend");
        require(token2.allowance(owner2,address(this)) >= amount2, "token 2 allowance is too low to spend");
        _safeTransferFrom(token1,owner1,owner2,amount1);
        _safeTransferFrom(token2,owner2,owner1,amount2);
    }   

}

// 10000000000000000000
// 20000000000000000000