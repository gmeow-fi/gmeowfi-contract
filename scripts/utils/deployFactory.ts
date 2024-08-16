import { ethers } from "hardhat";
import { deployContract, sendTxn } from "../helper";
import { DeployerFactory } from "../../typechain-types";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(`Deploying contracts with the account: ${deployer.address}`);

  const deployerFactory = await deployContract<DeployerFactory>(
    "DeployerFactory",
    [],
    "DeployerFactory",
    {}
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
