import { ethers } from "hardhat";
import { deployContract, sendTxn } from "../helper";
import { GMeowFiMultiNFTStaking } from "../../typechain-types";
import { send } from "process";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(`Deploying NFTs with the account: ${deployer.address}`);

  const multiNFT = await ethers.getContractAt(
    "GMeowFiMultiNFT",
    "0x87A4f586aea0C47a1f615a13F9b6acfFCF59452B"
  );
  const xGM = await ethers.getContractAt(
    "XGM",
    "0x77f753D9bD8346F5c8ae0015d7cC84b266422694"
  );
  const totalReward = ethers.parseEther("10000");
  const startTime =
    (await ethers.provider.getBlock("latest"))?.timestamp!! + 60;
  const endTime = startTime + 60 * 60 * 24 * 30;
  const lockTime = 60 * 60;
  const rewardClawDivisor = 100;
  const rewardClawPeriod = 60 * 60;

  const multiNFTStake = await deployContract<GMeowFiMultiNFTStaking>(
    "GMeowFiMultiNFTStaking",
    [
      await multiNFT.getAddress(),
      await xGM.getAddress(),
      await multiNFT.getAddress(),
      totalReward,
      startTime,
      endTime,
      lockTime,
      rewardClawDivisor,
      rewardClawPeriod,
    ],
    "GMeowFiMultiNFTStaking",
    null
  );
  await sendTxn(multiNFTStake.setNFTIds([0], true), "setNFTIds chronicles");
  //   await sendTxn(
  //     xGM.setWhitelistTransfer(await multiNFTStake.getAddress(), true),
  //     "setWhitelistTransfer"
  //   );
  await sendTxn(
    xGM.transfer(await multiNFTStake.getAddress(), totalReward),
    "transfer reward token"
  );
  await sendTxn(
    multiNFT.mint(
      await multiNFTStake.getAddress(),
      await multiNFTStake.REWARD_CLAW_ID(),
      100,
      "0x"
    ),
    "mint reward claw"
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
