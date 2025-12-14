// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "./MockVotesToken.sol";

/// @notice No freeze: Directly use the current balance as voting power (vulnerable to manipulation by instantaneous balances in the same transaction)
contract GovNoFreeze {
    
    MockVotesToken public token;

    mapping(uint256 => uint256) public yesVotes;
    mapping(uint256 => uint256) public noVotes;

    // Record who voted on which proposal, whether they supported or opposed, and how many votes were used
    event Voted(uint256 proposalId, address voter, bool support, uint256 power);

    constructor(MockVotesToken _token) {
        token = _token;
    }

    function votingPower(address voter) public view returns (uint256) {
        return token.balanceOf(voter); // Key vulnerability: current balance
    }

    function vote(uint256 proposalId, bool support) external {
        uint256 power = votingPower(msg.sender);
        require(power > 0, "no voting power");
        if (support) yesVotes[proposalId] += power;
        else noVotes[proposalId] += power;

        emit Voted(proposalId, msg.sender, support, power);
    }

}
