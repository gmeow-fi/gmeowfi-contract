import { ethers } from "hardhat";
import { deployContract, sendTxn } from "../helper";
import {
  GMeowFiBox,
  GMeowFiBoxStorage,
  GMeowFiEntropy,
} from "../../typechain-types";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(`Deploying contracts with the account: ${deployer.address}`);
  const xGM = await ethers.getContractAt(
    "TestToken",
    "0x77f753D9bD8346F5c8ae0015d7cC84b266422694"
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
  const gmeowFiNFT = await ethers.getContractAt(
    "GmeowFiNFT",
    "0x9Ac9b5f0a9D5c2DA141a43f778b6aDb66638fd33"
  );
  const boxStorage = await deployContract<GMeowFiBoxStorage>(
    "GMeowFiBoxStorage",
    [],
    "GMeowFiBoxStorage",
    {}
  );
  const entropy = await deployContract<GMeowFiEntropy>(
    "GMeowFiEntropy",
    [ethers.ZeroAddress, ethers.ZeroHash],
    "GMeowFiEntropy",
    {}
  );
  const gMeowFiBox = await deployContract<GMeowFiBox>(
    "GMeowFiBox",
    [
      await multiNFT.getAddress(),
      await gmeowFiNFT.getAddress(),
      await boxStorage.getAddress(),
      await paw.getAddress(),
      await xGM.getAddress(),
      await usde.getAddress(),
      await entropy.getAddress(),
      await deployer.getAddress(), // entropy provider
      await deployer.getAddress(), // admin
      ethers.ZeroAddress, // lottery - not deployed yet
    ],
    "GMeowFiBox",
    {}
  );

  await sendTxn(
    entropy.setWhitelist(await gMeowFiBox.getAddress(), true),
    "setWhitelist"
  );
  await sendTxn(
    multiNFT.grantRole(
      await multiNFT.MINTER_ROLE(),
      await gMeowFiBox.getAddress()
    ),
    "grantRole MINTER"
  );

  await sendTxn(
    paw.transfer(
      await gMeowFiBox.getAddress(),
      await paw.balanceOf(await deployer.getAddress())
    ),
    "transfer PAW"
  );
  await sendTxn(
    xGM.transfer(await gMeowFiBox.getAddress(), ethers.parseEther("10000")),
    "transfer xGM"
  );
  
  // for (let i = 0; i < 5; i++) {
  //   await sendTxn(
  //     gmeowFiNFT.safeMint(await gMeowFiBox.getAddress()),
  //     "safeMint GmeowFiNFT"
  //   );
  // }
  // for (let i = 1; i <= 6; i++) {
  //   await sendTxn(
  //     multiNFT.mint(await deployer.getAddress(), i, 100, "0x"),
  //     "multiNFT mint"
  //   );
  // }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
