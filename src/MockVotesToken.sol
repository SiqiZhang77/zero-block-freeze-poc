// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
// The snapshot refers to the balance/vote count recorded when a block is updated
/// @notice Simplified "snapshot voting power" token:
/// - mint/burn
/// - Record a checkpoint (blockNumber -> balance) whenever the balance changes
/// - getPastVotes(addr, blockNumber) returns the most recent balance recorded <= blockNumber
contract MockVotesToken {
    string public name = "MockVotesToken";
    string public symbol = "MVT";
    uint8 public decimals = 0; // 1 token = 10^0 smallest units

    mapping(address => uint256) public balanceOf;
    uint256 public totalSupply;

    struct Checkpoint {
        uint32 fromBlock; // The block where this snapshot was recorded.
        uint224 votes; // The number of votes (equal to balance) for this address at the block
    }

    mapping(address => Checkpoint[]) internal _checkpoints; // Can only be operated within this contract

    event Transfer(address indexed from, address indexed to, uint256 amount);

    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
        totalSupply += amount;
        _writeCheckpoint(to, balanceOf[to]); // Record a snapshot, which can involve flash loans temporarily increasing the attacker's balance/votes
        emit Transfer(address(0), to, amount);
    }// Checkpoints record the block number and balance/votes whenever the balance changes.

    function burn(address from, uint256 amount) external {
        require(balanceOf[from] >= amount, "insufficient");
        balanceOf[from] -= amount;
        totalSupply -= amount;
        _writeCheckpoint(from, balanceOf[from]);
        emit Transfer(from, address(0), amount);
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "insufficient");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        _writeCheckpoint(msg.sender, balanceOf[msg.sender]);
        _writeCheckpoint(to, balanceOf[to]);
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function _writeCheckpoint(address account, uint256 newVotes) internal {
        Checkpoint[] storage ckpts = _checkpoints[account];
        uint32 b = uint32(block.number); // Retrieve the current block number

        if (ckpts.length > 0 && ckpts[ckpts.length - 1].fromBlock == b) {
            // If updated within the same block, overwrite it
            ckpts[ckpts.length - 1].votes = uint224(newVotes); // newVotes is the latest balance/votes
        } else {
            ckpts.push(Checkpoint({fromBlock: b, votes: uint224(newVotes)}));
        }
    }

    /// @notice Return the voting power (balance snapshot) of an address at a specific historical block (search target)
    // blockNumber is the historical block number to query
    function getPastVotes(address account, uint256 blockNumber) external view returns (uint256) {
        require(blockNumber < block.number, "block not yet mined"); // Can only query historical blocks, less than the current block
        Checkpoint[] storage ckpts = _checkpoints[account];
        if (ckpts.length == 0) return 0; // No historical records, return 0

        // Binary search for the last checkpoint where fromBlock <= blockNumber
        uint256 lo = 0;
        uint256 hi = ckpts.length;
        while (lo < hi) {
            uint256 mid = (lo + hi) / 2;
            if (ckpts[mid].fromBlock <= blockNumber) lo = mid + 1;
            else hi = mid;
        }
        if (hi == 0) return 0;
        return ckpts[hi - 1].votes;
    }
}
