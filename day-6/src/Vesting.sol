// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Vesting {
    struct Beneficiary {
        uint256 tokensAllocated;
        uint256 startTime;
        uint256 duration;
        uint256 tokensReleased;
    }
    address public owner;

    mapping(address => Beneficiary) public beneficiaries;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not authorized owner");
        _;
    }

    function addBenificary(
        address _user,
        uint256 _token,
        uint256 _startTime,
        uint256 _duration
    ) external onlyOwner {
        beneficiaries[_user] = Beneficiary({
            tokensAllocated: _token,
            startTime: _startTime,
            duration: _duration,
            tokensReleased: 0
        });
    }

    function calculateVestedAmount(
        address _user
    ) public view onlyOwner returns (uint256) {
        Beneficiary storage beneficiary = beneficiaries[_user];

        if (beneficiary.tokensAllocated == 0) {
            return 0;
        }

        if (block.timestamp < beneficiary.startTime) {
            return 0;
        }

        uint256 timeElapsed = block.timestamp - beneficiary.startTime;

        if (timeElapsed > beneficiary.duration) {
            return beneficiary.tokensAllocated;
        }

        uint256 vestedAmount = (beneficiary.tokensAllocated * timeElapsed) /
            beneficiary.duration;

        return vestedAmount;
    }

    function claimTokens() external {
        Beneficiary storage beneficiary = beneficiaries[msg.sender];

        require(
            beneficiaries[msg.sender].tokensAllocated > 0,
            "No tokens allocated for you!"
        );

        uint256 vestedAmount = calculateVestedAmount(msg.sender);

        uint256 claimableAmount = vestedAmount - beneficiary.tokensReleased;

        require(claimableAmount > 0, "No tokens available to claim");

        beneficiary.tokensReleased += vestedAmount;
        
        payable(msg.sender).transfer(claimableAmount);
    }
}
