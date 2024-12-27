// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract MultiSigWallet {
    uint256 requiredApprovals;   
    address[] owners;

    struct Transaction {
        uint id;
        address recipientAddress;
        uint256 amount;
        uint256 approvalCount;
        bool executionStatus;
    }

    event TransactionCreated(uint256 indexed transactionId, uint256 amount, address recipientAddress);
    event TransactionApproved(uint256 indexed transactionId, address indexed approver);
    event TransactionExectuted(uint256 indexed transactionId, uint256 amount, address recipientAddress);

    mapping(uint256 => mapping(address => bool)) public isApprovedOwner;
    mapping(address => bool) public isOwner;
    Transaction[] public txns;

    modifier onlyOwner() {
        require(isOwner[msg.sender], "You are not authorized owner");
        _;
    }

    constructor(address[] memory addresses , uint256 _requiredApprovals) {
        owners = addresses; 
        for(uint256 i = 0; i < addresses.length; i++) {
             require(addresses[i] != address(0), "Invalid owner address");
            require(!isOwner[addresses[i]], "Duplicate owner");
            isOwner[addresses[i]] = true;
            owners.push(addresses[i]);
        }
        requiredApprovals = _requiredApprovals;
    }

    receive() external payable {}

    function createTransaction(address _recipientAddress, uint256 _amount) external onlyOwner {
        txns.push(Transaction(txns.length, _recipientAddress, _amount, 0, false));
        emit TransactionCreated(txns.length - 1, _amount, _recipientAddress);
    }

    function approveTx(uint256 _transactionId) external onlyOwner {
        Transaction storage txn = txns[_transactionId];
        require(!isApprovedOwner[txn.id][msg.sender], "You already Approved this transaction");
        txn.approvalCount+= 1;
        isApprovedOwner[txn.id][msg.sender] = true;
        emit TransactionApproved(_transactionId, msg.sender);
    }

    function executeTx(uint256 _transactionId) external onlyOwner {
        Transaction storage txn = txns[_transactionId];
        require(txn.approvalCount >= requiredApprovals, "Transaction don't have enough approvals");
        require(!txn.executionStatus, "Transaction is Already executed!");
        require(address(this).balance >= txn.amount, "Insufficient contract balance");
        payable(txn.recipientAddress).transfer(txn.amount);
        txn.executionStatus = true;
        emit TransactionExectuted(_transactionId, txn.amount, txn.recipientAddress);
    }

}
