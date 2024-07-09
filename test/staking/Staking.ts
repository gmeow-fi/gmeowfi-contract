import { ethers } from "hardhat";
import {
  ERC20,
  StakingFactory,
  StakingInitializable,
  TestToken,
} from "../../typechain-types";
import { Signer } from "ethers";
import { expect } from "chai";

describe("Staking", function () {
  let stakingFactory: StakingFactory, stakingPool: StakingInitializable;
  let stakeToken: TestToken, rewardToken: TestToken;
  let deployer: Signer, user1: Signer, user2: Signer;

  beforeEach(async function () {
    [deployer, user1, user2] = await ethers.getSigners();
    stakingFactory = await ethers.deployContract("StakingFactory", []);
    stakeToken = await ethers.deployContract("TestToken", [
      "Stake Token",
      "STK",
      1000000000,
      18,
    ]);
    rewardToken = await ethers.deployContract("TestToken", [
      "Reward Token",
      "RWD",
      1000000000,
      18,
    ]);

    await rewardToken.approve(
      await stakingFactory.getAddress(),
      ethers.MaxUint256
    );

    await stakeToken.transfer(
      await user1.getAddress(),
      ethers.parseEther("100000")
    );

    await stakeToken.transfer(
      await user2.getAddress(),
      ethers.parseEther("100000")
    );
  });

  it("calculate pool address correct", async function () {
    const startTime =
      (await ethers.provider.getBlock("latest"))?.timestamp!! + 100;
    const endTime = startTime + 86400;

    await stakingFactory.deployPool(
      await stakeToken.getAddress(),
      await rewardToken.getAddress(),
      ethers.parseEther("1"),
      startTime,
      endTime,
      0,
      10000,
      1000,
      5000,
      await deployer.getAddress()
    );

    const pool = await stakingFactory.getPoolInfo(0);
    const poolAddressCalculated = await stakingFactory.calculatePoolAddress(
      await stakeToken.getAddress(),
      await rewardToken.getAddress(),
      ethers.parseEther("1"),
      startTime,
      endTime,
      0,
      10000,
      1000,
      5000,
      await deployer.getAddress()
    );
    expect(pool._poolAddress).to.be.equal(poolAddressCalculated);
  });

  it("interact with locked pool correctly", async function () {
    const startTime =
      (await ethers.provider.getBlock("latest"))?.timestamp!! + 100;
    const endTime = startTime + 86400;

    await stakingFactory.deployPool(
      await stakeToken.getAddress(),
      await rewardToken.getAddress(),
      ethers.parseEther("1"),
      startTime,
      endTime,
      0,
      10000,
      1000,
      5000,
      await deployer.getAddress()
    );

    stakingPool = await ethers.getContractAt(
      "StakingInitializable",
      await stakingFactory.calculatePoolAddress(
        await stakeToken.getAddress(),
        await rewardToken.getAddress(),
        ethers.parseEther("1"),
        startTime,
        endTime,
        0,
        10000,
        1000,
        5000,
        await deployer.getAddress()
      )
    );

    await stakeToken
      .connect(user1)
      .approve(await stakingPool.getAddress(), ethers.MaxUint256);

    await stakingPool
      .connect(user1)
      .createDeposit(ethers.parseEther("100"), 1000);

    await stakingPool
      .connect(user1)
      .createDeposit(ethers.parseEther("100"), 5000);

    await increaseTime(10000);

    await stakingPool.connect(user1).extendDeposit(0, 5000);
    await stakingPool.connect(user1).extendDeposit(1, 5000);

    await increaseTime(1000);
    await stakingPool.connect(user1).addToDeposit(0, ethers.parseEther("100"));
    await stakingPool.connect(user1).addToDeposit(1, ethers.parseEther("100"));

    await increaseTime(10000);

    await stakingPool.connect(user1).withdraw(0);
    await stakingPool.connect(user1).withdraw(1);
  });

  it("interact with unlocked pool correctly", async function () {
    const startTime =
      (await ethers.provider.getBlock("latest"))?.timestamp!! + 100;
    const endTime = startTime + 86400;

    await stakingFactory.deployPool(
      await stakeToken.getAddress(),
      await rewardToken.getAddress(),
      ethers.parseEther("1"),
      startTime,
      endTime,
      0,
      10000,
      1000,
      5000,
      await deployer.getAddress()
    );

    stakingPool = await ethers.getContractAt(
      "StakingInitializable",
      await stakingFactory.calculatePoolAddress(
        await stakeToken.getAddress(),
        await rewardToken.getAddress(),
        ethers.parseEther("1"),
        startTime,
        endTime,
        0,
        0,
        0,
        0,
        await deployer.getAddress()
      )
    );

    await stakeToken
      .connect(user1)
      .approve(await stakingPool.getAddress(), ethers.MaxUint256);

    await stakingPool
      .connect(user1)
      .createDeposit(ethers.parseEther("100"), 1000);

    await stakingPool
      .connect(user1)
      .createDeposit(ethers.parseEther("100"), 5000);

    await increaseTime(10000);

    await stakingPool.connect(user1).extendDeposit(0, 5000);
    await stakingPool.connect(user1).extendDeposit(1, 5000);

    await increaseTime(1000);
    await stakingPool.connect(user1).addToDeposit(0, ethers.parseEther("100"));
    await stakingPool.connect(user1).addToDeposit(1, ethers.parseEther("100"));

    await increaseTime(10000);

    await stakingPool.connect(user1).withdraw(0);
    await stakingPool.connect(user1).withdraw(1);
  });
});

async function increaseTime(time: number) {
  await ethers.provider.send("evm_increaseTime", [time]);
  await ethers.provider.send("evm_mine", []);
}
