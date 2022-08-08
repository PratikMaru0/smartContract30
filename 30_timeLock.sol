// SPDX-License-Identifier: MIT

pragma solidity >= 0.4.0 < 0.9.0;

// What this smart contract do ? 
// Transaction is proposed 
// First It will be queued so that no malicious transaction can be executed. Queue timing will be depend on the time mentioned in the smart contract
// After queued time elapsed transaction can be executed or canceled before elapsed time. 

contract TimeLock{

    address public owner;
    mapping(bytes32 => bool) public queued;
    uint public constant MIN_Delay = 10 seconds;
    uint public constant MAX_Delay = 1000 seconds;
    uint public constant GRACE_PERIOD = 1000;

    event Queue(bytes32 indexed txId, address target, uint value, string func, bytes data, uint timestamp);
    event Execute(bytes32 indexed txId, address target, uint value, string func, bytes data, uint timestamp);
    event Cancel(bytes32 indexed txId);

    constructor(){
        owner = msg.sender;
    }

    receive() external payable{
    }

    modifier onlyOwner(){
        require(msg.sender == owner , "Only owner can execute");    
        _;
    }

    function getTxId(address _target, uint _value, string calldata _func, bytes calldata _data, uint _timestamp) public pure returns(bytes32 TxId){
        return keccak256(abi.encode(_target, _value, _func, _data, _timestamp));
    }

    function queue(address _target, uint _value, string calldata _func, bytes calldata _data, uint _timestamp) external onlyOwner {

        bytes32 txId = getTxId(_target, _value, _func, _data, _timestamp);        
        require(queued[txId] == false,"Already in queue");
        require(!((_timestamp < block.timestamp + MIN_Delay) || (_timestamp > block.timestamp + MAX_Delay)),"Timestamp is not in range. ");
        queued[txId] = true;
        emit Queue(txId, _target, _value, _func, _data, _timestamp);
    }

    function execute(address _target, uint _value, string calldata _func, bytes calldata _data, uint _timestamp) external payable onlyOwner returns(bytes memory){
        bytes32 txId = getTxId(_target, _value, _func, _data, _timestamp);
        require(queued[txId] == true,"Transaction is not in queue");
        require(block.timestamp > _timestamp,"Sorry transaction cannot be executed before the time of the execution.");
        require(block.timestamp < _timestamp + GRACE_PERIOD,"Timestamp expired error");
        queued[txId] = false;
        bytes memory data;
        
        if(bytes(_func).length > 0 ){
            data = abi.encodePacked(bytes4(keccak256(bytes(_func))), _data);
        }
        else{
            data = _data;
        }
        (bool ok, bytes memory res) = _target.call{value:_value}(data);
        (ok,"Transaction failed");
        emit Execute(txId, _target, _value, _func, _data, _timestamp);
        return res;
    }

    function cancel(bytes32 _txId) external onlyOwner{
        require(queued[_txId],"Transaction is not queued.");       
        queued[_txId] = false;
        emit Cancel(_txId);
    }
}

contract testTimeLock{

    address public timeLock;
    
    constructor(address _timeLock) {
        timeLock = _timeLock;
    }

    function test() view external{
        require(msg.sender == timeLock,"Not timelock contract.");
    }

    function getTimeStamp() public view returns(uint) {
        return (block.timestamp + 100);
    }

}