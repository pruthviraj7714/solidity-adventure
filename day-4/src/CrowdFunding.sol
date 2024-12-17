// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract CrowdFunding {
    struct Campaign {
        uint256 id;
        string title;
        uint256 goal;
        address owner;
        uint256 collected;
        mapping(address => uint256) donars;
        address[] donarAddresses;
        uint256 deadline;
    }

    mapping(uint256 => Campaign) public campaigns;

    event CampaignCreated(
        uint256 indexed id,
        string indexed title,
        address indexed owner,
        uint256 goal,
        uint256 deadline
    );
    event DonationMade(
        uint256 indexed id,
        address indexed donar,
        uint256 amount
    );
    event RefundClaimed(
        uint256 indexed id,
        address indexed donar,
        uint256 amount
    );
    event FundsWithdrawn(
        uint256 indexed id,
        address indexed owner,
        uint256 amount
    );
    modifier onlyCampaignOwner(uint256 campaignId) {
        require(
            campaigns[campaignId].owner == msg.sender,
            "You are not authorized owner to withdraw"
        );
        _;
    }

    function createCampaign(
        string memory _title,
        uint256 _goal,
        uint256 _deadline
    ) external {
        require(
            _deadline > block.timestamp,
            "Deadline should be of the future"
        );
        uint256 id = uint256(
            keccak256(
                abi.encodePacked(block.timestamp, block.prevrandao, msg.sender)
            )
        );
        campaigns[id].id = id;
        campaigns[id].title = _title;
        campaigns[id].goal = _goal;
        campaigns[id].deadline = _deadline;
        campaigns[id].owner = msg.sender;
        campaigns[id].collected = 0;

        emit CampaignCreated(id, _title, msg.sender, _goal, _deadline);
    }

    function withdrawCampaignDonation(
        uint256 _id
    ) external onlyCampaignOwner(_id) {
        require(
            campaigns[_id].collected == campaigns[_id].goal,
            "The goal is not met!"
        );
        require(
            campaigns[_id].deadline < block.timestamp,
            "The deadline is not passed!"
        );
        uint256 amount = campaigns[_id].collected;
        campaigns[_id].collected = 0;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Withdrawal transfer failed");
        emit FundsWithdrawn(_id, msg.sender, amount);
    }

    function donateToCampaign(uint256 _id) external payable {
        require(
            block.timestamp < campaigns[_id].deadline,
            "The deadline has passed!"
        );
        require(msg.value > 0 ether, "The amount should be greater than 0 wei");
        campaigns[_id].collected += msg.value;
        if (campaigns[_id].donars[msg.sender] == 0) {
            campaigns[_id].donarAddresses.push(msg.sender);
        }
        campaigns[_id].donars[msg.sender] += msg.value;
        emit DonationMade(_id, msg.sender, campaigns[_id].donars[msg.sender]);
    }

    function claimRefund(uint256 _id) external {
        require(
            campaigns[_id].deadline < block.timestamp,
            "The deadline is not passed!"
        );
        require(
            campaigns[_id].goal > campaigns[_id].collected,
            "The goal is already met, you can't claim refund"
        );
        uint256 amount = campaigns[_id].donars[msg.sender];
        require(amount > 0, "You have no donations to claim as a refund");
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Refund transfer failed");

        campaigns[_id].donars[msg.sender] = 0;
        campaigns[_id].collected -= amount;
        emit RefundClaimed(_id, msg.sender, amount);
    }

    function getCollectedAmountOfCampaign(
        uint256 _id
    ) external view returns (uint256) {
        return campaigns[_id].collected;
    }

    function getDeadlineAmountOfCampaign(
        uint256 _id
    ) external view returns (uint256) {
        return campaigns[_id].deadline;
    }
}
