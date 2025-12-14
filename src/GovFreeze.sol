// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "./MockVotesToken.sol";

/// @notice Zero-Block Governance Freeze: Voting power reads from the previous block snapshot
contract GovFreeze {
    MockVotesToken public token;
    uint256 public constant FREEZE_BLOCKS = 1; // Freeze for 1 block

    mapping(uint256 => uint256) public yesVotes;
    mapping(uint256 => uint256) public noVotes;

    event Voted(uint256 proposalId, address voter, bool support, uint256 power);

    constructor(MockVotesToken _token) {
        token = _token;
    }

    function votingPower(address voter) public view returns (uint256) {
        // Key: Use historical snapshots (previous block), temporary balances in the same transaction/block will not be counted
        return token.getPastVotes(voter, block.number - FREEZE_BLOCKS);
    }

    function vote(uint256 proposalId, bool support) external {
        uint256 power = votingPower(msg.sender);
        require(power > 0, "no voting power in snapshot");
        if (support) yesVotes[proposalId] += power;
        else noVotes[proposalId] += power;

        emit Voted(proposalId, msg.sender, support, power);
    }
}
