// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "./MockVotesToken.sol";

/// @notice Simulate flash loan "instantaneous assets within the same transaction":
/// - flashMint: mint to borrower -> borrower executes callback -> must burn before the callback ends
contract FlashMint {
    MockVotesToken public token;

    constructor(MockVotesToken _token) {
        token = _token;
    }

    function flashMint(address borrower, uint256 amount, bytes calldata data) external {
        token.mint(borrower, amount);

        (bool ok, ) = borrower.call(data);
        require(ok, "borrower call failed");

        // Require the borrower to return the tokens (simulated repayment using burn here)
        token.burn(borrower, amount);
    }
}
