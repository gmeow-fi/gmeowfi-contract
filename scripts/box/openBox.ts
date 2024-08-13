import { ethers } from "hardhat";
import { deployContract, sendTxn } from "../helper";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(`Executing with the account: ${deployer.address}`);

  const gMeowFiBox = await ethers.getContractAt(
    "GMeowFiBoxV1",
    "0xa790a1aa213A03b4ba783B96795A0E4e7336189a"
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

  const weth = await ethers.getContractAt(
    "IWETH",
    "0x4200000000000000000000000000000000000006"
  );
  await sendTxn(weth.deposit({ value: ethers.parseEther("2") }), "deposit");

  await sendTxn(
    weth.transfer(await gMeowFiBox.getAddress(), ethers.parseEther("2")),
    "transfer"
  );

  // await sendTxn(
  //   multiNFT.mintBatch(
  //     deployer.address,
  //     [1, 2, 3, 4, 5, 6],
  //     [200, 200, 200, 200, 200, 200],
  //     "0x"
  //   ),
  //   "mintBatch"
  // );

  // await sendTxn(
  //   multiNFT.setApprovalForAll(await gMeowFiBox.getAddress(), true),
  //   "setApprovalForAll"
  // );

  // for (let i = 0; i < 5; i++) {
  //   await sendTxn(
  //     gMeowFiBox.openBox(100, i, 1, false, {
  //       value: await gMeowFiBox.txFees(i),
  //       gasLimit: 10000000,
  //     }),
  //     `openBox ${i}`
  //   );
  // }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
