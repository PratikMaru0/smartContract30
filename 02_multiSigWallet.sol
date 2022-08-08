// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

// What this smart contract do :- 
// - Owned by multiple owners
// - Can Submit , Approve and confirm Tx by any owner 
// - Check the Transactions and confirmations

// Define MultiSigWallet :- MultiSig wallets use multiple private keys, and 
// therefore multiple Signatures required to validate the transactions and transfer
// funds, allowing for unanimous decision making and thus providing increased security.
// If used properly, they allow for many useful applications, ehich make crypto
// assets more attractive to investors, and therefore, they are a much safer
// and more credible alternative to crypto fund management.

contract multiSigWallet{

    // Multiple owners for a single wallet.
    // Submit a transaction by one owner.
    // Approve and revoke approval of pending tranactions by others
    // Anyone can execute a transaction after enough owners has approved.

    event Deposit(address indexed sender, uint amount, uint balance);
    event Submit(address indexed owner, uint indexed txIndex, address indexed to, uint value, bytes data);
    event Confirm(address indexed owner, uint indexed txIndex);
    event Revoke(address indexed owner, uint indexed txIndex);
    event Execute(address indexed owner, uint indexed txIndex);

    struct Transaction{
        address to;
        uint value;
        bytes data;
        bool executed;
        uint numConfirmations;
    }

    address[] public owners;
    mapping(address=>bool) public isOwner;
    uint public required;   // no of approval required.

    Transaction[] public transactions;

    mapping(uint => mapping(address=>bool)) public isConfirmed;

    // modifier to check that only Owner can call function.
    modifier onlyOwner(){
        require(isOwner[msg.sender],"not owner");
        _;
    }

    // modifier to check transaction exists or not.
    modifier txExists(uint _txIndex){
        require(_txIndex < transactions.length,"tx does not exists");
        _;
    }

    // modifier to check transaction is executed or not.
    modifier notExecuted(uint _txIndex){
        require(!transactions[_txIndex].executed,"tx already executed");
        _;
    }

    // modifier  to check owner confirmed or not
    modifier notConfirmed(uint _txIndex){
        require(!isConfirmed[_txIndex][msg.sender],"tx already confirmed");    
        _;
    }

    constructor(address[] memory _owners, uint _required){
        require(_owners.length>0,"Owners Required");
        require(_required > 0 && _required <= _owners.length,"Invalid required owners");

        for(uint i=0;i<_owners.length;i++){
            address owner = _owners[i];
            require(owner != address(0),"Invalid Owner");
            require(!isOwner[owner] , "Owner is not unique");
            isOwner[owner] = true;
            owners.push(owner);
        }
        required = _required;    // _required == minimal approval.
    }

    // using receive() function so that we can accept the Ether in the contract
    receive() external payable{
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    // Function to submit new transactions.
    function submitTransaction(address _to, uint _value, bytes memory _data) public onlyOwner{
        uint txIndex = transactions.length;

        transactions.push(
            Transaction({
                to: _to,
                value: _value,
                data: _data,
                executed: false,
                numConfirmations: 0  
            })
        );
        emit Submit(msg.sender, txIndex, _to, _value, _data);
    }

    // Function to vote for transactions
    function confirmTransaction(uint _txIndex) external onlyOwner txExists(_txIndex) notConfirmed(_txIndex) notExecuted(_txIndex){
        Transaction storage transaction = transactions[_txIndex];
          transaction.numConfirmations += 1 ;
          isConfirmed[_txIndex][msg.sender] = true ;

          emit Confirm(msg.sender, _txIndex) ;
    }

    // function to execute transaction
    function executeTransaction(uint _txIndex) public onlyOwner txExists(_txIndex) notExecuted(_txIndex){
        Transaction storage transaction = transactions[_txIndex];
        require(transaction.numConfirmations >= required,"Cannot Execute");
        transaction.executed = true;
        emit Execute(msg.sender,_txIndex);
    }

    // revoke function to revoke the approval (Note: It will execute only when transaction is not executed)
    function revokeConfirmation(uint _txIndex) public onlyOwner txExists(_txIndex) notExecuted(_txIndex){
        Transaction storage transaction = transactions[_txIndex];
        require(isConfirmed[_txIndex][msg.sender],"tx not confirmed");
        transaction.numConfirmations -= 1;
        isConfirmed[_txIndex][msg.sender] = false;

        emit Revoke(msg.sender,_txIndex);
    }

    // getTransaction function to get the transaction details 
    function getTransaction(uint _txIndex) public view returns(
        address to,
        uint value,
        bytes memory data,
        bool executed,
        uint numConfirmations
    ){
        Transaction storage transaction = transactions[_txIndex];

        return(
            transaction.to,
            transaction.value,
            transaction.data,
            transaction.executed,
            transaction.numConfirmations   
        );
    }
} 
// Completed.