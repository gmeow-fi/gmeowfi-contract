import { ethers } from "hardhat";
import { deployContract, sendTxn } from "../helper";
import { GMeowFiMultiNFT } from "../../typechain-types";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(`Deploying contracts with the account: ${deployer.address}`);
  const multiNFT = await deployContract<GMeowFiMultiNFT>(
    "GMeowFiMultiNFT",
    [],
    "GMeowFiMultiNFT",
    {}
  );
  await sendTxn(
    multiNFT.setNFT(
      1,
      "GMeowFi Lottery Ticket",
      "GMeowFi-LT",
      "https://gmeowfi.com/api/nft/1/",
      ethers.MaxUint256
    ),
    "setNFT Lottery Ticket"
  );
  await sendTxn(
    multiNFT.setNFT(
      2,
      "GMeowFi Fun Claw",
      "GMeowFi-FC",
      "https://gmeowfi.com/api/nft/2/",
      ethers.MaxUint256
    ),
    "setNFT Fun Claw"
  );
  await sendTxn(
    multiNFT.setNFT(
      3,
      "GMeowFi Joy Claw",
      "GMeowFi-JC",
      "https://gmeowfi.com/api/nft/3/",
      ethers.MaxUint256
    ),
    "setNFT Joy Claw"
  );
  await sendTxn(
    multiNFT.setNFT(
      4,
      "GMeowFi Sip Claw",
      "GMeowFi-SC",
      "https://gmeowfi.com/api/nft/4/",
      ethers.MaxUint256
    ),
    "setNFT Sip Claw"
  );
  await sendTxn(
    multiNFT.setNFT(
      5,
      "GMeowFi Sweat Claw",
      "GMeowFi-SWC",
      "https://gmeowfi.com/api/nft/5/",
      ethers.MaxUint256
    ),
    "setNFT Sweat Claw"
  );
  await sendTxn(
    multiNFT.setNFT(
      6,
      "GMeowFi Treasure Claw",
      "GMeowFi-TC",
      "https://gmeowfi.com/api/nft/6/",
      ethers.MaxUint256
    ),
    "setNFT Treasure Claw"
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
