import { ethers } from "hardhat";
import { deployContract, sendTxn } from "../helper";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(`Executing with the account: ${deployer.address}`);

  const gMeowFiBox = await ethers.getContractAt(
    "GMeowFiBox",
    "0xFd7C4f40C65307c0176Cb7F32EC916afeb090211"
  );

  const usde = await ethers.getContractAt(
    "TestToken",
    "0xF9755e4aDcdc81Aa982fc74b7Ae00aa17246Bc9d"
  );
  const paw = await ethers.getContractAt(
    "PAWToken",
    "0xB9B4F9354B4e66021A01a1E339827b729ADDDbCA"
  );
  const multiNFT = await ethers.getContractAt(
    "GMeowFiMultiNFT",
    "0x87A4f586aea0C47a1f615a13F9b6acfFCF59452B"
  );

  // await sendTxn(
  //   paw.deposit(BigInt("10000") * (await usde.decimals())),
  //   "paw deposit"
  // );
  // await sendTxn(
  //   usde.approve(await gmeowFiBox.getAddress(), ethers.MaxUint256),
  //   "usde approve"
  // );
  // await sendTxn(
  //   paw.approve(await gmeowFiBox.getAddress(), ethers.MaxUint256),
  //   "paw approve"
  // );
  // await sendTxn(
  //   multiNFT.setApprovalForAll(await gmeowFiBox.getAddress(), true),
  //   "multiNFT setApprovalForAll"
  // );
  await sendTxn(
    multiNFT.mintBatch(
      "0x04a4c59A13F4eDC0990f4E153841C4251021aed8",
      [1, 2, 3, 4, 5, 6],
      [10, 10, 10, 10, 10, 10],
      "0x"
    ),
    "mintBatch"
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
