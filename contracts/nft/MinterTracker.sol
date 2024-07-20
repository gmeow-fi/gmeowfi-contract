// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./GMeowFiNFTMinter.sol";

contract MinterTracker {
    struct MintedCount {
        address user;
        uint256 count;
    }
    function getMintedCount(
        address _minter,
        address[] memory _users
    ) public view returns (MintedCount[] memory) {
        MintedCount[] memory mintedCounts = new MintedCount[](_users.length);
        for (uint256 i = 0; i < _users.length; i++) {
            mintedCounts[i] = MintedCount({
                user: _users[i],
                count: GMeowFiNFTMinter(_minter).mintedCount(_users[i])
            });
        }
        return mintedCounts;
    }
}
