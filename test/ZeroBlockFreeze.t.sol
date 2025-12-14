// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {MockVotesToken} from "../src/MockVotesToken.sol";
import {GovNoFreeze} from "../src/GovNoFreeze.sol";
import {GovFreeze} from "../src/GovFreeze.sol";
import {FlashMint} from "../src/FlashMint.sol";
import {Attacker} from "../src/Attacker.sol";


contract ZeroBlockFreezeTest is Test {
    MockVotesToken token;
    GovNoFreeze govNoFreeze;
    GovFreeze govFreeze;
    FlashMint flash;
    Attacker attacker;

    function setUp() public {
        token = new MockVotesToken();
        govNoFreeze = new GovNoFreeze(token);
        govFreeze = new GovFreeze(token);
        flash = new FlashMint(token);
        attacker = new Attacker(govNoFreeze, govFreeze);

        // Give the attacker contract some normal balance (small amount), e.g., 1 
        token.mint(address(attacker), 1 );

        // Mine a block to ensure this 1 unit becomes a historical state visible in the "previous block snapshot"
        vm.roll(block.number + 1);
    }

    function test_AttackSucceedsWithoutFreeze() public {
        uint256 proposalId = 1;
        uint256 flashAmount = 1_000_000 ;

        bytes memory data = abi.encodeWithSignature(
            "attackVoteNoFreeze(uint256)",
            proposalId
        );


        flash.flashMint(address(attacker), flashAmount, data);

        // No freeze: Voting power reads the current balance, so flashAmount will be counted
        assertEq(govNoFreeze.yesVotes(proposalId), flashAmount + 1 );
    }

    function test_AttackCountsOnlySnapshotWithZeroBlockFreeze() public {
    uint256 proposalId = 2;
    uint256 flashAmount = 1_000_000 ;

    // Proof: There is indeed 1 unit voting power in the previous block snapshot
    uint256 snapPower = token.getPastVotes(address(attacker), block.number - 1);
    assertEq(snapPower, 1 );

    bytes memory data = abi.encodeWithSignature(
        "attackVoteFreeze(uint256)",
        proposalId
    );

    uint256 beforeBal = token.balanceOf(address(attacker));
    // 
    flash.flashMint(address(attacker), flashAmount, data);

    uint256 afterBal = token.balanceOf(address(attacker));
    assertEq(beforeBal, afterBal); // Flash balance rollback, this assertion passes indicating flash mint was burned after the transaction ended
    // Key: Check if only the 1 ether from the previous block snapshot is counted; the current block flashAmount is not included
    assertEq(govFreeze.yesVotes(proposalId), 1 );
    assertTrue(govFreeze.yesVotes(proposalId) < flashAmount);

    emit log_named_uint("previouse snapshot power", snapPower);
    emit log_named_uint("counted yesVotes", govFreeze.yesVotes(proposalId));
    emit log_named_uint("flash amount", flashAmount);   
}

}
