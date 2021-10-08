// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

/**
 * @title Utility Library
 * @dev Utility
 */
library Utility {
    function random(uint256 maxAmount) public view returns (uint) {
        // sha3 and now have been deprecated
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, maxAmount)));
        // convert hash to integer
        // players is an array of entrants
    }
}