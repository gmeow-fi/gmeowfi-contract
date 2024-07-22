import { PAWToken } from "../../typechain-types";
import { deployContract, sendTxn } from "../helper";
import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(`Deploying contracts with the account: ${deployer.address}`);

  const usde = await ethers.getContractAt(
    "ERC20",
    "0xF9755e4aDcdc81Aa982fc74b7Ae00aa17246Bc9d"
  );
  const paw = await deployContract<PAWToken>(
    "PAWToken",
    [
      await usde.getAddress(),
      await deployer.getAddress(),
      await usde.decimals(),
    ],
    "PAWToken",
    {}
  );
  await sendTxn(
    usde.approve(await paw.getAddress(), ethers.MaxUint256),
    "approve"
  );
  await sendTxn(
    paw.deposit(BigInt("10000") * (await usde.decimals())),
    "deposit"
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
