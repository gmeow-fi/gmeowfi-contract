import { ethers } from "hardhat";
import { deployContract, sendTxn } from "../helper";
import { XGM } from "../../typechain-types";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(`Deploying contracts with the account: ${deployer.address}`);

  const xgm = await deployContract<XGM>("XGM", [], "XGM", {});
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
