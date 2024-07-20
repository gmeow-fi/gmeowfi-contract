// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

enum PaymentToken {
    USD,
    PAW,
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
    uint256 usdAmount;
    bool availableNFT;
}

struct TotalReward {
    uint256 totalXGM;
    uint256 totalUSD;
    uint256 totalNFT;
}

struct RequestRandom {
    address user;
    BoxType boxType;
    uint256 amount;
    uint64 sequenceNumber;
}
