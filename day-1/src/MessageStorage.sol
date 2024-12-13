// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract MessageStorage {
    string public message;
    address public lastMessageUpdatedUser;
    uint public messageCount;
    address private owner;

    event MessageUpdated(address indexed msgUpdatedUser, string message);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not authorized owner");
        _;
    }

    function setMessage(string memory _msg) public {
        require(bytes(_msg).length > 0, "Message shouldn't be empty");
        message = _msg;
        messageCount++;
        lastMessageUpdatedUser = msg.sender;
        emit MessageUpdated(msg.sender, _msg);
    }

    function getMessage() public view returns(string memory) {
        return message;
    }

    function getMessageCount() public view returns(uint) {
        return messageCount;
    }

    function resetMessage() public onlyOwner {
        message = "";
    }

}
