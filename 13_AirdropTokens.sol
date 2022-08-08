// TODO: FIXME:
// For General underatanding. Not tested yet. Have to test this.  

// SPDX-License-Identifier: MIT

pragma solidity >= 0.4.0. < 0.9.0;

// Creating interface for each token, we want to do airdrop from.
interface IERC20{
    function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);
}

interface IERC721{
    function safeTransferFrom(address from, address to, uint256 token) external;
}

interface IERC1155{
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;
}

// This is a contract that can drop airdrops token, NFT to a set of user.
contract airdropTokensOrNFT{
    function bulkAirdropERC20(IERC20 _token, address[] calldata _to, uint256[] calldata _value) public{
        require(_to.length == _value.length, "Receivers and amounts are different length");    
        for(uint256 i=0;i<_to.length;i++){
            _token.transferFrom(msg.sender,_to[i],_value[i]);
        }
    }
    function bulkAirdropERC721(IERC721 _token, address[] calldata _to, uint256[] calldata _value) public{
        require(_to.length == _value.length, "Receivers and amounts are different length");    
        for(uint256 i=0;i<_to.length;i++){
            _token.safeTransferFrom(msg.sender,_to[i],_value[i]);
        }
    }
    function bulkAirdropERC1155(IERC1155 _token, address[] calldata _to, uint256[] calldata _id, uint256[] calldata _amount) public{
        require(_to.length == _id.length, "Receivers and amounts are different length");    
        for(uint256 i=0;i<_to.length;i++){
            _token.safeTransferFrom(msg.sender, _to[i], _id[i], _amount[i], "");
        }
    }
}