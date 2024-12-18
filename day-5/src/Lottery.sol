// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Lottery {
    address public owner;
    address[] participants;
    bool isOpen = false;
    mapping(address => uint256) lotteryFundsBook;
    uint256 totalCollectedAmount;

    event LotteryOpened();
    event LotteryClosed();
    event LotteryWinnerDeclared(address indexed winner, uint256 amount);
    event LotteryParticipation(address indexed participant, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not authorized owner");
        _;
    }

    function modifyLotteryActivationStatus(
        bool _activationStatus
    ) external onlyOwner {
        require(
            _activationStatus != isOpen,
            "Lottery is already in the desired state"
        );
        isOpen = _activationStatus;
        if (isOpen) {
            emit LotteryOpened();
        } else {
            emit LotteryClosed();
        }
    }

    function participateInLottery() external payable {
        require(isOpen, "Lottery is currently deactive");
        require(
            msg.value == 0.01 ether,
            "Participation requires exactly 0.01 ether"
        );
        require(
            lotteryFundsBook[msg.sender] == 0,
            "You have already joined the lottery"
        );
        lotteryFundsBook[msg.sender] = msg.value;
        participants.push(msg.sender);
        totalCollectedAmount += msg.value;
        emit LotteryParticipation(msg.sender, msg.value);
    }

   
    function pickAndDistributeLotteryToOwner() external onlyOwner {
        require(!isOpen, "Lottery is still open you can't distribute");
        require(
            participants.length > 0,
            "No one yet participated in the lottery"
        );

        address winner = participants[
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        block.prevrandao,
                        msg.sender
                    )
                )
            ) % participants.length
        ];

        (bool success, ) = winner.call{value: totalCollectedAmount}("");
        require(success, "Transfer to winner failed");

        emit LotteryWinnerDeclared(winner, totalCollectedAmount);

        for (uint256 i = 0; i < participants.length; i++) {
            delete lotteryFundsBook[participants[i]];
        }

        delete participants;
        totalCollectedAmount = 0;
    }

     function resetLottery() external onlyOwner {
        for (uint256 i = 0; i < participants.length; i++) {
            delete lotteryFundsBook[participants[i]];
        }
        delete participants;
        isOpen = false;
        totalCollectedAmount = 0;
    }

}
