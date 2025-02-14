// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract EscrowContract {
    enum TaskStatus { PENDING, COMPLETED, DISPUTED }

    struct Escrow {
        address buyer;
        address seller;
        uint256 amount;
        uint256 deadline;
        uint256 depositedAmount;
        TaskStatus status;
    }

    mapping(uint => Escrow) public escrows;
    uint public currEscrowIndex = 0;

    event EscrowCreated(uint index, address buyer, address seller, uint256 amount);
    event EscrowDeposited(uint index, address buyer, uint256 amount);
    event EscrowCompleted(uint index, address seller, uint256 amount);
    event EscrowRefunded(uint index, address buyer, uint256 amount);
    event EscrowDisputed(uint index, address buyer, address seller, uint256 amount);

    function createEscrow(address _buyer, address _seller, uint256 _amount, uint256 _deadline) public {
        escrows[currEscrowIndex] = Escrow({
            buyer: _buyer,
            seller: _seller,
            amount: _amount,
            deadline: _deadline,
            depositedAmount: 0,
            status: TaskStatus.PENDING
        });

        emit EscrowCreated(currEscrowIndex, _buyer, _seller, _amount);
        currEscrowIndex++;
    }

    function depositFunds(uint index) public payable {
        Escrow storage currEscrow = escrows[index];

        require(msg.sender == currEscrow.buyer, "Only buyer can deposit funds");
        require(msg.value == currEscrow.amount, "Deposit must match escrow amount");
        require(currEscrow.depositedAmount == 0, "Funds already deposited");

        currEscrow.depositedAmount = msg.value;

        emit EscrowDeposited(index, msg.sender, msg.value);
    }

    function markTaskDone(uint index) public {
        Escrow storage currEscrow = escrows[index];

        require(msg.sender == currEscrow.seller, "Only seller can mark task as done");
        require(block.timestamp <= currEscrow.deadline, "Deadline has passed");
        require(currEscrow.status == TaskStatus.PENDING, "Escrow is not pending");

        currEscrow.status = TaskStatus.COMPLETED;
    }

    function confirmDelivery(uint index) public {
        Escrow storage currEscrow = escrows[index];

        require(msg.sender == currEscrow.buyer, "Only buyer can confirm delivery");
        require(currEscrow.status == TaskStatus.COMPLETED, "Task must be marked completed");
        require(currEscrow.depositedAmount > 0, "No funds to release");

        uint256 amountToTransfer = currEscrow.depositedAmount;
        currEscrow.depositedAmount = 0;
        currEscrow.status = TaskStatus.DISPUTED; 

        payable(currEscrow.seller).transfer(amountToTransfer);
        emit EscrowCompleted(index, currEscrow.seller, amountToTransfer);
    }

    function requestRefund(uint index) public {
        Escrow storage currEscrow = escrows[index];

        require(msg.sender == currEscrow.buyer, "Only buyer can request a refund");
        require(currEscrow.status == TaskStatus.PENDING, "Escrow must be pending");
        require(block.timestamp > currEscrow.deadline, "Deadline not yet passed");
        require(currEscrow.depositedAmount > 0, "No funds to refund");

        uint256 refundAmount = currEscrow.depositedAmount;
        currEscrow.depositedAmount = 0;
        currEscrow.status = TaskStatus.DISPUTED; 

        payable(currEscrow.buyer).transfer(refundAmount);
        emit EscrowRefunded(index, currEscrow.buyer, refundAmount);
    }
}
