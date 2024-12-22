// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Lock {
    struct LockInfo {
        uint256 amount;
        uint256 unlockTime;
    }

    mapping(address => LockInfo) public locks;
    event FundsLocked(address indexed user, uint256 amount, uint256 unlockTime);
    event FundsWithdrawn(address indexed user, uint256 amount);

    function lockFunds(uint256 _lockTime) external payable {
        require(msg.value > 0, "Your amount should be greater than 0");
        require(_lockTime > 0, "Lock time should be greater than 0");
        require(
            locks[msg.sender].amount == 0,
            "You already have tokens locked"
        );
        uint256 unlockTime = block.timestamp + _lockTime;
        locks[msg.sender] = LockInfo({
            amount: msg.value,
            unlockTime: unlockTime
        });
        emit FundsLocked(msg.sender, msg.value, unlockTime);
    }

    function withdrawFunds() external {
        LockInfo storage lockInfo = locks[msg.sender];
        require(lockInfo.amount != 0, "There is no amount to withdraw");
        require(
            lockInfo.unlockTime > block.timestamp,
            "The funds can't be withdrawn now"
        );
        uint256 amount = lockInfo.amount;
        lockInfo.amount = 0;
        payable(msg.sender).transfer(amount);
        emit FundsWithdrawn(msg.sender, amount);
    }

    function timeLeft() external view returns (uint256) {
        if (locks[msg.sender].unlockTime <= block.timestamp) {
            return 0;
        }
        return locks[msg.sender].unlockTime - block.timestamp;
    }
}
