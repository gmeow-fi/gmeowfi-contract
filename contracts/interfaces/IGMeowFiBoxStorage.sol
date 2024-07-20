// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../box/GMeowfiBoxType.sol";

interface IGMeowFiBoxStorage {
    function getRewardByRandomNumber(
        BoxType boxType,
        uint256 random
    ) external view returns (BoxReward memory);

    function getRandomThreshold(
        BoxType boxType
    ) external view returns (uint256);

    function getBoxReward(
        BoxType boxType,
        uint256 index
    ) external view returns (BoxReward memory);
}
