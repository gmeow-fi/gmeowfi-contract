// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

enum PaymentToken {
    // USD,
    // PAW,
    ETH,
    CLAW
}

enum BoxType {
    Fun,
    Joy,
    Sip,
    Sweat,
    Treasure
}
struct BoxReward {
    uint256 xGMAmount;
    uint256 ethAmount;
    bool availableNFT;
}

struct TotalReward {
    uint256 totalXGM;
    uint256 totalETH;
    uint256 totalNFT;
}

struct RequestRandom {
    address user;
    BoxType boxType;
    uint256 amount;
    uint64 sequenceNumber;
}

interface IGMeowFiBoxStorageV1 {
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
