// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;
import "./GMeowfiBoxTypeV1.sol";
// import "../../interfaces/IGMeowFiBoxStorage.sol";

contract GMeowFiBoxStorageV1 is IGMeowFiBoxStorageV1 {
    mapping(BoxType => uint256[]) public boxRewardsThreshold;
    mapping(BoxType => BoxReward[]) public boxRewards;

    constructor() {
        // Set up box rewards threshold for each box type
        // Fun

        boxRewardsThreshold[BoxType.Fun].push(15000);
        boxRewardsThreshold[BoxType.Fun].push(33000);
        boxRewardsThreshold[BoxType.Fun].push(63000);
        boxRewardsThreshold[BoxType.Fun].push(64500);
        boxRewardsThreshold[BoxType.Fun].push(67000);
        boxRewardsThreshold[BoxType.Fun].push(79000);
        boxRewardsThreshold[BoxType.Fun].push(134000);
        boxRewardsThreshold[BoxType.Fun].push(214000);
        boxRewardsThreshold[BoxType.Fun].push(314000);
        boxRewardsThreshold[BoxType.Fun].push(434000);
        boxRewardsThreshold[BoxType.Fun].push(534000);
        boxRewardsThreshold[BoxType.Fun].push(609000);

        boxRewards[BoxType.Fun].push(
            BoxReward({availableNFT: true, ethAmount: 0, xGMAmount: 0})
        );
        boxRewards[BoxType.Fun].push(
            BoxReward({availableNFT: false, ethAmount: 0, xGMAmount: 20 ether})
        );
        boxRewards[BoxType.Fun].push(
            BoxReward({availableNFT: false, ethAmount: 0, xGMAmount: 10 ether})
        );
        boxRewards[BoxType.Fun].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.005 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Fun].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.0035 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Fun].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.0025 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Fun].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.0015 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Fun].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.0005 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Fun].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.0004 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Fun].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.0002 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Fun].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.0001 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Fun].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.00005 ether,
                xGMAmount: 0
            })
        );

        // Joy

        boxRewardsThreshold[BoxType.Joy].push(15000);
        boxRewardsThreshold[BoxType.Joy].push(24000);
        boxRewardsThreshold[BoxType.Joy].push(42000);
        boxRewardsThreshold[BoxType.Joy].push(72000);
        boxRewardsThreshold[BoxType.Joy].push(72500);
        boxRewardsThreshold[BoxType.Joy].push(73500);
        boxRewardsThreshold[BoxType.Joy].push(75500);
        boxRewardsThreshold[BoxType.Joy].push(77500);
        boxRewardsThreshold[BoxType.Joy].push(87500);
        boxRewardsThreshold[BoxType.Joy].push(137500);
        boxRewardsThreshold[BoxType.Joy].push(237500);
        boxRewardsThreshold[BoxType.Joy].push(287500);
        boxRewardsThreshold[BoxType.Joy].push(387500);
        boxRewardsThreshold[BoxType.Joy].push(487500);
        boxRewardsThreshold[BoxType.Joy].push(537500);
        boxRewardsThreshold[BoxType.Joy].push(547500);

        boxRewards[BoxType.Joy].push(
            BoxReward({availableNFT: true, ethAmount: 0, xGMAmount: 0})
        );
        boxRewards[BoxType.Joy].push(
            BoxReward({availableNFT: false, ethAmount: 0, xGMAmount: 50 ether})
        );
        boxRewards[BoxType.Joy].push(
            BoxReward({availableNFT: false, ethAmount: 0, xGMAmount: 30 ether})
        );
        boxRewards[BoxType.Joy].push(
            BoxReward({availableNFT: false, ethAmount: 0, xGMAmount: 10 ether})
        );

        boxRewards[BoxType.Joy].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.05 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Joy].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.025 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Joy].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.01 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Joy].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.005 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Joy].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.0035 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Joy].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.0025 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Joy].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.0015 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Joy].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.0005 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Joy].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.0004 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Joy].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.0002 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Joy].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.0001 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Joy].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.00005 ether,
                xGMAmount: 0
            })
        );
        // Sip

        boxRewardsThreshold[BoxType.Sip].push(15000);
        boxRewardsThreshold[BoxType.Sip].push(19500);
        boxRewardsThreshold[BoxType.Sip].push(28500);
        boxRewardsThreshold[BoxType.Sip].push(46500);
        boxRewardsThreshold[BoxType.Sip].push(76500);
        boxRewardsThreshold[BoxType.Sip].push(76625);
        boxRewardsThreshold[BoxType.Sip].push(76875);
        boxRewardsThreshold[BoxType.Sip].push(77375);
        boxRewardsThreshold[BoxType.Sip].push(78375);
        boxRewardsThreshold[BoxType.Sip].push(83375);
        boxRewardsThreshold[BoxType.Sip].push(93375);
        boxRewardsThreshold[BoxType.Sip].push(123375);
        boxRewardsThreshold[BoxType.Sip].push(198375);
        boxRewardsThreshold[BoxType.Sip].push(273375);
        boxRewardsThreshold[BoxType.Sip].push(323375);
        boxRewardsThreshold[BoxType.Sip].push(348375);
        boxRewardsThreshold[BoxType.Sip].push(358375);
        boxRewardsThreshold[BoxType.Sip].push(363375);

        boxRewards[BoxType.Sip].push(
            BoxReward({availableNFT: true, ethAmount: 0, xGMAmount: 0})
        );
        boxRewards[BoxType.Sip].push(
            BoxReward({availableNFT: false, ethAmount: 0, xGMAmount: 100 ether})
        );
        boxRewards[BoxType.Sip].push(
            BoxReward({availableNFT: false, ethAmount: 0, xGMAmount: 50 ether})
        );
        boxRewards[BoxType.Sip].push(
            BoxReward({availableNFT: false, ethAmount: 0, xGMAmount: 30 ether})
        );
        boxRewards[BoxType.Sip].push(
            BoxReward({availableNFT: false, ethAmount: 0, xGMAmount: 10 ether})
        );

        boxRewards[BoxType.Sip].push(
            BoxReward({availableNFT: false, ethAmount: 0.1 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Sip].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.05 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Sip].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.025 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Sip].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.01 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Sip].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.005 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Sip].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.0035 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Sip].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.0025 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Sip].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.0015 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Sip].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.0005 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Sip].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.0004 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Sip].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.0002 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Sip].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.0001 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Sip].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.00005 ether,
                xGMAmount: 0
            })
        );
        // Sweat

        boxRewardsThreshold[BoxType.Sweat].push(15000);
        boxRewardsThreshold[BoxType.Sweat].push(19500);
        boxRewardsThreshold[BoxType.Sweat].push(28500);
        boxRewardsThreshold[BoxType.Sweat].push(46500);
        boxRewardsThreshold[BoxType.Sweat].push(76500);
        boxRewardsThreshold[BoxType.Sweat].push(76600);
        boxRewardsThreshold[BoxType.Sweat].push(76850);
        boxRewardsThreshold[BoxType.Sweat].push(77350);
        boxRewardsThreshold[BoxType.Sweat].push(78350);
        boxRewardsThreshold[BoxType.Sweat].push(80850);
        boxRewardsThreshold[BoxType.Sweat].push(95850);
        boxRewardsThreshold[BoxType.Sweat].push(135850);
        boxRewardsThreshold[BoxType.Sweat].push(195850);
        boxRewardsThreshold[BoxType.Sweat].push(295850);
        boxRewardsThreshold[BoxType.Sweat].push(375850);
        boxRewardsThreshold[BoxType.Sweat].push(435850);
        boxRewardsThreshold[BoxType.Sweat].push(475850);
        boxRewardsThreshold[BoxType.Sweat].push(495850);
        boxRewardsThreshold[BoxType.Sweat].push(505850);

        boxRewards[BoxType.Sweat].push(
            BoxReward({availableNFT: true, ethAmount: 0, xGMAmount: 0})
        );
        boxRewards[BoxType.Sweat].push(
            BoxReward({availableNFT: false, ethAmount: 0, xGMAmount: 100 ether})
        );
        boxRewards[BoxType.Sweat].push(
            BoxReward({availableNFT: false, ethAmount: 0, xGMAmount: 50 ether})
        );
        boxRewards[BoxType.Sweat].push(
            BoxReward({availableNFT: false, ethAmount: 0, xGMAmount: 30 ether})
        );
        boxRewards[BoxType.Sweat].push(
            BoxReward({availableNFT: false, ethAmount: 0, xGMAmount: 10 ether})
        );

        boxRewards[BoxType.Sweat].push(
            BoxReward({availableNFT: false, ethAmount: 0.2 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Sweat].push(
            BoxReward({availableNFT: false, ethAmount: 0.1 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Sweat].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.05 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Sweat].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.025 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Sweat].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.01 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Sweat].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.005 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Sweat].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.0035 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Sweat].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.0025 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Sweat].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.0015 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Sweat].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.0005 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Sweat].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.0004 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Sweat].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.0002 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Sweat].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.0001 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Sweat].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.00005 ether,
                xGMAmount: 0
            })
        );

        // Treasure

        boxRewardsThreshold[BoxType.Treasure].push(15000);
        boxRewardsThreshold[BoxType.Treasure].push(19500);
        boxRewardsThreshold[BoxType.Treasure].push(28500);
        boxRewardsThreshold[BoxType.Treasure].push(46500);
        boxRewardsThreshold[BoxType.Treasure].push(76500);
        boxRewardsThreshold[BoxType.Treasure].push(76550);
        boxRewardsThreshold[BoxType.Treasure].push(76650);
        boxRewardsThreshold[BoxType.Treasure].push(76900);
        boxRewardsThreshold[BoxType.Treasure].push(77400);
        boxRewardsThreshold[BoxType.Treasure].push(78400);
        boxRewardsThreshold[BoxType.Treasure].push(80900);
        boxRewardsThreshold[BoxType.Treasure].push(90900);
        boxRewardsThreshold[BoxType.Treasure].push(130900);
        boxRewardsThreshold[BoxType.Treasure].push(210900);
        boxRewardsThreshold[BoxType.Treasure].push(280900);
        boxRewardsThreshold[BoxType.Treasure].push(335900);
        boxRewardsThreshold[BoxType.Treasure].push(370900);
        boxRewardsThreshold[BoxType.Treasure].push(390900);
        boxRewardsThreshold[BoxType.Treasure].push(400900);
        boxRewardsThreshold[BoxType.Treasure].push(405900);

        boxRewards[BoxType.Treasure].push(
            BoxReward({availableNFT: true, ethAmount: 0, xGMAmount: 0})
        );
        boxRewards[BoxType.Treasure].push(
            BoxReward({availableNFT: false, ethAmount: 0, xGMAmount: 100 ether})
        );
        boxRewards[BoxType.Treasure].push(
            BoxReward({availableNFT: false, ethAmount: 0, xGMAmount: 50 ether})
        );
        boxRewards[BoxType.Treasure].push(
            BoxReward({availableNFT: false, ethAmount: 0, xGMAmount: 30 ether})
        );
        boxRewards[BoxType.Treasure].push(
            BoxReward({availableNFT: false, ethAmount: 0, xGMAmount: 10 ether})
        );

        boxRewards[BoxType.Treasure].push(
            BoxReward({availableNFT: false, ethAmount: 0.3 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Treasure].push(
            BoxReward({availableNFT: false, ethAmount: 0.2 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Treasure].push(
            BoxReward({availableNFT: false, ethAmount: 0.1 ether, xGMAmount: 0})
        );
        boxRewards[BoxType.Treasure].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.05 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Treasure].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.025 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Treasure].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.01 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Treasure].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.005 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Treasure].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.0035 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Treasure].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.0025 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Treasure].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.0015 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Treasure].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.0005 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Treasure].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.0004 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Treasure].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.0002 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Treasure].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.0001 ether,
                xGMAmount: 0
            })
        );
        boxRewards[BoxType.Treasure].push(
            BoxReward({
                availableNFT: false,
                ethAmount: 0.00005 ether,
                xGMAmount: 0
            })
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
