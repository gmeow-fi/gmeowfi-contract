import { ethers } from "hardhat";
import {
  GMeowFiMultiNFT,
  GMeowFiMultiNFTStaking,
  TestToken,
} from "../typechain-types";
import { Signer } from "ethers";
import { deployMultiNFTForTest } from "./utils";

describe("GMeowFiMultiNFT", function () {
  let multiNFT: GMeowFiMultiNFT, multiNFTStaking: GMeowFiMultiNFTStaking;
  let rewardToken: TestToken;
  let deployer: Signer, user1: Signer, user2: Signer;
  let startTime: number, endTime: number;
  let totalReward: bigint,
    lockDuration: number,
    rewardClawDivisor = 100,
    rewardClawPeriod = 1000;

  beforeEach(async function () {
    [deployer, user1, user2] = await ethers.getSigners();
    rewardToken = await ethers.deployContract("TestToken", [
      "TestToken",
      "TT",
      1000000000,
      18,
    ]);

    multiNFT = await deployMultiNFTForTest();

    startTime = (await ethers.provider.getBlock("latest"))?.timestamp!! + 100;
    endTime = startTime + 10000;
    totalReward = ethers.parseEther("1000");
    lockDuration = 1000;

    multiNFTStaking = await ethers.deployContract("GMeowFiMultiNFTStaking", [
      await multiNFT.getAddress(),
      await rewardToken.getAddress(),
      await multiNFT.getAddress(),
      totalReward,
      startTime,
      endTime,
      lockDuration,
      rewardClawDivisor,
      rewardClawPeriod,
    ]);
    multiNFTStaking.setNFTIds([0], true);
    // await multiNFT.mint(await user1.getAddress(), multiNFTStaking.
    await rewardToken.transfer(await multiNFTStaking.getAddress(), totalReward);
    await multiNFT.safeTransferFrom(
      await deployer.getAddress(),
      await multiNFTStaking.getAddress(),
      await multiNFTStaking.REWARD_CLAW_ID(),
      100,
      "0x"
    );
  });

  it("should be able to stake", async function () {});
});
