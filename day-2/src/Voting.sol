// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract VotingSystem {
    address owner;
    uint256 totalProposals;
    struct Proposal {
        uint256 id;
        string title;
        mapping(address => bool) hasVoted;
        bool isClosed;
        uint256 votes;
    }

    mapping(uint256 => Proposal) public proposals;

    event ProposalCreated(uint256 indexed id, string title);
    event Voted(address indexed voterAddress, uint256 proposalId);
    event ProposalClosed(uint256 indexed proposalId); 

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not authorized owner");
        _;
    }

    function startProposal(uint256 _proposalId) external onlyOwner {
        proposals[_proposalId].isClosed = false;
    }

    function closeProposal(uint256 _proposalId) external onlyOwner {
        proposals[_proposalId].isClosed = true;
        emit ProposalClosed(_proposalId);
    }

    function createProposal(string memory _title) external onlyOwner {
        uint256 id = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, msg.sender)));
        
        Proposal storage newProposal = proposals[totalProposals];
        newProposal.id = id;
        newProposal.isClosed = false;
        newProposal.title = _title;
        newProposal.votes = 0;

        totalProposals++;
        emit ProposalCreated(id, _title);
    }

    function voteProposal(uint256 id) external {
        require(
            !proposals[id].isClosed,
            "The Proposal is currently closed you can't vote now"
        );
        require(!proposals[id].hasVoted[msg.sender], "You already votes for this proposal");

        proposals[id].hasVoted[msg.sender] = true;
        proposals[id].votes++;
        emit Voted(msg.sender, id);
    }

    function getProposalWithMostVotes() public view returns(string memory title, uint256 votes) {
        uint256 maxVotes = 0;
        uint maxVotedIndex = 0;
        for(uint256 i = 0; i < totalProposals; i++) {
            if(proposals[i].votes > maxVotes) {
                maxVotes = proposals[i].votes;
                maxVotedIndex = i;
            }
        } 
        return (proposals[maxVotedIndex].title, maxVotes);       
    }
    
}
