// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "./GovNoFreeze.sol";
import "./GovFreeze.sol";

contract Attacker {
    GovNoFreeze public govNoFreeze;
    GovFreeze public govFreeze;

    constructor(GovNoFreeze _noFreeze, GovFreeze _freeze) {
        govNoFreeze = _noFreeze;
        govFreeze = _freeze;
    }

    function attackVoteNoFreeze(uint256 proposalId) external {
        govNoFreeze.vote(proposalId, true);
    }

    function attackVoteFreeze(uint256 proposalId) external {
        govFreeze.vote(proposalId, true);
    }
}
