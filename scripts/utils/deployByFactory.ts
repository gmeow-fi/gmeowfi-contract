import { ethers } from "hardhat";
import { sendTxn } from "../helper";
import { solidityPacked } from "ethers";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(`Deploying contracts with the account: ${deployer.address}`);
  const ContractFactory = await ethers.getContractFactory("PAWToken");
  const initializeData = ContractFactory.interface.encodeFunctionData(
    "initialize(address,address,uint8,address)",
    [
      "0x337610d27c682E347C9cD60BD4b3b107C9d34dDd",
      deployer.address,
      18,
      deployer.address,
    ]
  );
  const salt =
    "15174129830343841129645702496528952479856029809945774655486863593395606312211";

  const deployerFactory = await ethers.getContractAt(
    "DeployerFactory",
    "0x2F045F8784C45604bcbE96550EB728Ba1d330a17"
  );
  console.log(
    `Deploying to address: ${await deployerFactory.calculateAddress(
      ContractFactory.bytecode,
      salt
    )}`
  );
  await sendTxn(
    deployerFactory.deploy(ContractFactory.bytecode, salt, initializeData),
    "deploy"
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
