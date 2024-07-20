// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;
import {BoxType, BoxReward} from "./GMeowfiBoxType.sol";
import "../interfaces/IGMeowFiBoxStorage.sol";

contract GMeowFiBoxStorage is IGMeowFiBoxStorage {
    mapping(BoxType => uint256[]) public boxRewardsThreshold;
    mapping(BoxType => BoxReward[]) public boxRewards;

    constructor() {
        // Set up box rewards threshold for each box type
        // Fun

        boxRewardsThreshold[BoxType.Fun].push(125);
        boxRewardsThreshold[BoxType.Fun].push(18125);
        boxRewardsThreshold[BoxType.Fun].push(48125);
        boxRewardsThreshold[BoxType.Fun].push(49625);
        boxRewardsThreshold[BoxType.Fun].push(52125);
        boxRewardsThreshold[BoxType.Fun].push(64125);
        boxRewardsThreshold[BoxType.Fun].push(119125);
        boxRewardsThreshold[BoxType.Fun].push(199125);
        boxRewardsThreshold[BoxType.Fun].push(299125);
        boxRewardsThreshold[BoxType.Fun].push(419125);
        boxRewardsThreshold[BoxType.Fun].push(519125);
        boxRewardsThreshold[BoxType.Fun].push(594125);

        boxRewards[BoxType.Fun].push(
            BoxReward({availableNFT: true, usdAmount: 0, xGMAmount: 0})
        );
        boxRewards[BoxType.Fun].push(
            BoxReward({availableNFT: false, usdAmount: 0, xGMAmount: 20 ether})
        );
        boxRewards[BoxType.Fun].push(
            BoxReward({availableNFT: false, usdAmount: 0, xGMAmount: 10 ether})
        );
        boxRewards[BoxType.Fun].push(
            BoxReward({availableNFT: false, usdAmount: 10 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Fun].push(
            BoxReward({availableNFT: false, usdAmount: 7 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Fun].push(
            BoxReward({availableNFT: false, usdAmount: 5 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Fun].push(
            BoxReward({availableNFT: false, usdAmount: 3 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Fun].push(
            BoxReward({availableNFT: false, usdAmount: 1 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Fun].push(
            BoxReward({availableNFT: false, usdAmount: 0.8 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Fun].push(
            BoxReward({availableNFT: false, usdAmount: 0.4 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Fun].push(
            BoxReward({availableNFT: false, usdAmount: 0.2 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Fun].push(
            BoxReward({availableNFT: false, usdAmount: 0.1 ether, xGMAmount: 0})
        );

        // Joy

        boxRewardsThreshold[BoxType.Joy].push(125);
        boxRewardsThreshold[BoxType.Joy].push(9125);
        boxRewardsThreshold[BoxType.Joy].push(27125);
        boxRewardsThreshold[BoxType.Joy].push(57125);
        boxRewardsThreshold[BoxType.Joy].push(57625);
        boxRewardsThreshold[BoxType.Joy].push(58625);
        boxRewardsThreshold[BoxType.Joy].push(60625);
        boxRewardsThreshold[BoxType.Joy].push(62625);
        boxRewardsThreshold[BoxType.Joy].push(72625);
        boxRewardsThreshold[BoxType.Joy].push(122625);
        boxRewardsThreshold[BoxType.Joy].push(222625);
        boxRewardsThreshold[BoxType.Joy].push(272625);
        boxRewardsThreshold[BoxType.Joy].push(372625);
        boxRewardsThreshold[BoxType.Joy].push(472625);
        boxRewardsThreshold[BoxType.Joy].push(522625);
        boxRewardsThreshold[BoxType.Joy].push(532625);

        boxRewards[BoxType.Joy].push(
            BoxReward({availableNFT: true, usdAmount: 0, xGMAmount: 0})
        );
        boxRewards[BoxType.Joy].push(
            BoxReward({availableNFT: false, usdAmount: 0, xGMAmount: 50 ether})
        );
        boxRewards[BoxType.Joy].push(
            BoxReward({availableNFT: false, usdAmount: 0, xGMAmount: 30 ether})
        );
        boxRewards[BoxType.Joy].push(
            BoxReward({availableNFT: false, usdAmount: 0, xGMAmount: 10 ether})
        );
        boxRewards[BoxType.Joy].push(
            BoxReward({availableNFT: false, usdAmount: 100 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Joy].push(
            BoxReward({availableNFT: false, usdAmount: 50 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Joy].push(
            BoxReward({availableNFT: false, usdAmount: 20 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Joy].push(
            BoxReward({availableNFT: false, usdAmount: 10 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Joy].push(
            BoxReward({availableNFT: false, usdAmount: 8 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Joy].push(
            BoxReward({availableNFT: false, usdAmount: 4 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Joy].push(
            BoxReward({availableNFT: false, usdAmount: 2 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Joy].push(
            BoxReward({availableNFT: false, usdAmount: 1 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Joy].push(
            BoxReward({availableNFT: false, usdAmount: 0.8 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Joy].push(
            BoxReward({availableNFT: false, usdAmount: 0.4 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Joy].push(
            BoxReward({availableNFT: false, usdAmount: 0.2 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Joy].push(
            BoxReward({availableNFT: false, usdAmount: 0.1 ether, xGMAmount: 0})
        );
        // Sip

        boxRewardsThreshold[BoxType.Sip].push(125);
        boxRewardsThreshold[BoxType.Sip].push(4625);
        boxRewardsThreshold[BoxType.Sip].push(13625);
        boxRewardsThreshold[BoxType.Sip].push(31625);
        boxRewardsThreshold[BoxType.Sip].push(61625);
        boxRewardsThreshold[BoxType.Sip].push(61750);
        boxRewardsThreshold[BoxType.Sip].push(62000);
        boxRewardsThreshold[BoxType.Sip].push(62500);
        boxRewardsThreshold[BoxType.Sip].push(63500);
        boxRewardsThreshold[BoxType.Sip].push(68500);
        boxRewardsThreshold[BoxType.Sip].push(78500);
        boxRewardsThreshold[BoxType.Sip].push(108500);
        boxRewardsThreshold[BoxType.Sip].push(183500);
        boxRewardsThreshold[BoxType.Sip].push(258500);
        boxRewardsThreshold[BoxType.Sip].push(308500);
        boxRewardsThreshold[BoxType.Sip].push(333500);
        boxRewardsThreshold[BoxType.Sip].push(343500);
        boxRewardsThreshold[BoxType.Sip].push(348500);

        boxRewards[BoxType.Sip].push(
            BoxReward({availableNFT: true, usdAmount: 0, xGMAmount: 0})
        );
        boxRewards[BoxType.Sip].push(
            BoxReward({availableNFT: false, usdAmount: 0, xGMAmount: 1 ether})
        );
        boxRewards[BoxType.Sip].push(
            BoxReward({availableNFT: false, usdAmount: 0, xGMAmount: 0.5 ether})
        );
        boxRewards[BoxType.Sip].push(
            BoxReward({availableNFT: false, usdAmount: 0, xGMAmount: 0.3 ether})
        );
        boxRewards[BoxType.Sip].push(
            BoxReward({availableNFT: false, usdAmount: 0, xGMAmount: 0.1 ether})
        );
        boxRewards[BoxType.Sip].push(
            BoxReward({availableNFT: false, usdAmount: 200 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Sip].push(
            BoxReward({availableNFT: false, usdAmount: 100 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Sip].push(
            BoxReward({availableNFT: false, usdAmount: 50 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Sip].push(
            BoxReward({availableNFT: false, usdAmount: 20 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Sip].push(
            BoxReward({availableNFT: false, usdAmount: 10 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Sip].push(
            BoxReward({availableNFT: false, usdAmount: 7 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Sip].push(
            BoxReward({availableNFT: false, usdAmount: 5 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Sip].push(
            BoxReward({availableNFT: false, usdAmount: 3 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Sip].push(
            BoxReward({availableNFT: false, usdAmount: 1 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Sip].push(
            BoxReward({availableNFT: false, usdAmount: 0.8 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Sip].push(
            BoxReward({availableNFT: false, usdAmount: 0.6 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Sip].push(
            BoxReward({availableNFT: false, usdAmount: 0.2 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Sip].push(
            BoxReward({availableNFT: false, usdAmount: 0.1 ether, xGMAmount: 0})
        );
        // Sweat

        boxRewardsThreshold[BoxType.Sweat].push(125);
        boxRewardsThreshold[BoxType.Sweat].push(4625);
        boxRewardsThreshold[BoxType.Sweat].push(13625);
        boxRewardsThreshold[BoxType.Sweat].push(31625);
        boxRewardsThreshold[BoxType.Sweat].push(61625);
        boxRewardsThreshold[BoxType.Sweat].push(61725);
        boxRewardsThreshold[BoxType.Sweat].push(61975);
        boxRewardsThreshold[BoxType.Sweat].push(62475);
        boxRewardsThreshold[BoxType.Sweat].push(63475);
        boxRewardsThreshold[BoxType.Sweat].push(65975);
        boxRewardsThreshold[BoxType.Sweat].push(80975);
        boxRewardsThreshold[BoxType.Sweat].push(120975);
        boxRewardsThreshold[BoxType.Sweat].push(180975);
        boxRewardsThreshold[BoxType.Sweat].push(280975);
        boxRewardsThreshold[BoxType.Sweat].push(360975);
        boxRewardsThreshold[BoxType.Sweat].push(420975);
        boxRewardsThreshold[BoxType.Sweat].push(460975);
        boxRewardsThreshold[BoxType.Sweat].push(480975);
        boxRewardsThreshold[BoxType.Sweat].push(490975);

        boxRewards[BoxType.Sweat].push(
            BoxReward({availableNFT: true, usdAmount: 0, xGMAmount: 0})
        );
        boxRewards[BoxType.Sweat].push(
            BoxReward({availableNFT: false, usdAmount: 0, xGMAmount: 1 ether})
        );
        boxRewards[BoxType.Sweat].push(
            BoxReward({availableNFT: false, usdAmount: 0, xGMAmount: 0.5 ether})
        );
        boxRewards[BoxType.Sweat].push(
            BoxReward({availableNFT: false, usdAmount: 0, xGMAmount: 0.3 ether})
        );
        boxRewards[BoxType.Sweat].push(
            BoxReward({availableNFT: false, usdAmount: 0, xGMAmount: 0.1 ether})
        );
        boxRewards[BoxType.Sweat].push(
            BoxReward({availableNFT: false, usdAmount: 400 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Sweat].push(
            BoxReward({availableNFT: false, usdAmount: 200 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Sweat].push(
            BoxReward({availableNFT: false, usdAmount: 100 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Sweat].push(
            BoxReward({availableNFT: false, usdAmount: 50 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Sweat].push(
            BoxReward({availableNFT: false, usdAmount: 20 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Sweat].push(
            BoxReward({availableNFT: false, usdAmount: 10 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Sweat].push(
            BoxReward({availableNFT: false, usdAmount: 7 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Sweat].push(
            BoxReward({availableNFT: false, usdAmount: 5 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Sweat].push(
            BoxReward({availableNFT: false, usdAmount: 3 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Sweat].push(
            BoxReward({availableNFT: false, usdAmount: 1 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Sweat].push(
            BoxReward({availableNFT: false, usdAmount: 0.8 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Sweat].push(
            BoxReward({availableNFT: false, usdAmount: 0.4 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Sweat].push(
            BoxReward({availableNFT: false, usdAmount: 0.2 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Sweat].push(
            BoxReward({availableNFT: false, usdAmount: 0.1 ether, xGMAmount: 0})
        );

        // Treasure

        boxRewardsThreshold[BoxType.Treasure].push(125);
        boxRewardsThreshold[BoxType.Treasure].push(4625);
        boxRewardsThreshold[BoxType.Treasure].push(13625);
        boxRewardsThreshold[BoxType.Treasure].push(31625);
        boxRewardsThreshold[BoxType.Treasure].push(61625);
        boxRewardsThreshold[BoxType.Treasure].push(61675);
        boxRewardsThreshold[BoxType.Treasure].push(61775);
        boxRewardsThreshold[BoxType.Treasure].push(62025);
        boxRewardsThreshold[BoxType.Treasure].push(62525);
        boxRewardsThreshold[BoxType.Treasure].push(63525);
        boxRewardsThreshold[BoxType.Treasure].push(66025);
        boxRewardsThreshold[BoxType.Treasure].push(76025);
        boxRewardsThreshold[BoxType.Treasure].push(116025);
        boxRewardsThreshold[BoxType.Treasure].push(196025);
        boxRewardsThreshold[BoxType.Treasure].push(266025);
        boxRewardsThreshold[BoxType.Treasure].push(321025);
        boxRewardsThreshold[BoxType.Treasure].push(356025);
        boxRewardsThreshold[BoxType.Treasure].push(376025);
        boxRewardsThreshold[BoxType.Treasure].push(386025);
        boxRewardsThreshold[BoxType.Treasure].push(391025);

        boxRewards[BoxType.Treasure].push(
            BoxReward({availableNFT: true, usdAmount: 0, xGMAmount: 0})
        );
        boxRewards[BoxType.Treasure].push(
            BoxReward({availableNFT: false, usdAmount: 0, xGMAmount: 1 ether})
        );
        boxRewards[BoxType.Treasure].push(
            BoxReward({availableNFT: false, usdAmount: 0, xGMAmount: 0.5 ether})
        );
        boxRewards[BoxType.Treasure].push(
            BoxReward({availableNFT: false, usdAmount: 0, xGMAmount: 0.3 ether})
        );
        boxRewards[BoxType.Treasure].push(
            BoxReward({availableNFT: false, usdAmount: 0, xGMAmount: 0.1 ether})
        );
        boxRewards[BoxType.Treasure].push(
            BoxReward({availableNFT: false, usdAmount: 600 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Treasure].push(
            BoxReward({availableNFT: false, usdAmount: 400 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Treasure].push(
            BoxReward({availableNFT: false, usdAmount: 200 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Treasure].push(
            BoxReward({availableNFT: false, usdAmount: 100 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Treasure].push(
            BoxReward({availableNFT: false, usdAmount: 50 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Treasure].push(
            BoxReward({availableNFT: false, usdAmount: 20 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Treasure].push(
            BoxReward({availableNFT: false, usdAmount: 10 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Treasure].push(
            BoxReward({availableNFT: false, usdAmount: 7 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Treasure].push(
            BoxReward({availableNFT: false, usdAmount: 5 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Treasure].push(
            BoxReward({availableNFT: false, usdAmount: 3 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Treasure].push(
            BoxReward({availableNFT: false, usdAmount: 1 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Treasure].push(
            BoxReward({availableNFT: false, usdAmount: 0.8 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Treasure].push(
            BoxReward({availableNFT: false, usdAmount: 0.4 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Treasure].push(
            BoxReward({availableNFT: false, usdAmount: 0.2 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Treasure].push(
            BoxReward({availableNFT: false, usdAmount: 0.1 ether, xGMAmount: 0})
        );
    }

    function getRewardByRandomNumber(
        BoxType boxType,
        uint256 random
    ) external view returns (BoxReward memory) {
        BoxReward memory reward;
        for (uint256 i = 0; i < boxRewardsThreshold[boxType].length; i++) {
            if (random < boxRewardsThreshold[boxType][i]) {
                reward = boxRewards[boxType][i];
                break;
            }
        }
        return reward;
    }

    function getRandomThreshold(
        BoxType boxType
    ) external view returns (uint256) {
        return
            boxRewardsThreshold[boxType][
                boxRewardsThreshold[boxType].length - 1
            ];
    }

    function getBoxReward(
        BoxType boxType,
        uint256 index
    ) external view returns (BoxReward memory) {
        return boxRewards[boxType][index];
    }
}
