import { PAWToken } from "../../typechain-types";
import { deployContract, sendTxn } from "../helper";
import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(`Deploying contracts with the account: ${deployer.address}`);

  const usdt = await ethers.getContractAt(
    "ERC20",
    "0x2b533475875b518144c2Cf8558d799BC6FB11716"
  );
  const paw = await deployContract<PAWToken>(
    "PAWToken",
    [
      await usdt.getAddress(),
      await deployer.getAddress(),
      await usdt.decimals(),
    ],
    "PAWToken",
    {}
  );
  await sendTxn(
    usdt.approve(await paw.getAddress(), ethers.MaxUint256),
    "approve"
  );
  await sendTxn(
    paw.deposit(BigInt("10000") * (await usdt.decimals())),
    "deposit"
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
