import { ethers } from "hardhat";
import { deployContract, sendTxn } from "../helper";
import {
  GMeowFiBox,
  GMeowFiBoxStorage,
  GMeowFiBoxStorageV1,
  GMeowFiBoxV1,
  GMeowFiEntropy,
} from "../../typechain-types";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(`Deploying contracts with the account: ${deployer.address}`);
  const xGM = await ethers.getContractAt(
    "XGM",
    "0x91041fdaf58254aba28dAd32F548D4A466FE0E65"
  );
  const weth = await ethers.getContractAt(
    "IWETH",
    "0x4200000000000000000000000000000000000006"
  );
  const multiNFT = await ethers.getContractAt(
    "GMeowFiMultiNFT",
    "0xD5769BD2B7064c35991dD099c084C7e6195DC5de"
  );

  // const boxStorage = await deployContract<GMeowFiBoxStorageV1>(
  //   "GMeowFiBoxStorageV1",
  //   [],
  //   "GMeowFiBoxStorageV1",
  //   {}
  // );
  const boxStorage = await ethers.getContractAt(
    "GMeowFiBoxStorageV1",
    "0x6bbd17B910cF5576b4E9FFF2140A4F3Ea6a3C991"
  );
  // const entropy = await deployContract<GMeowFiEntropy>(
  //   "GMeowFiEntropy",
  //   [ethers.ZeroAddress, ethers.ZeroHash],
  //   "GMeowFiEntropy",
  //   {}
  // );
  const entropy = await ethers.getContractAt(
    "GMeowFiEntropy",
    "0x7fC42883AFe5B9Bdf315164862f2E12b16906f98"
  );
  // const gMeowFiBox = await deployContract<GMeowFiBoxV1>(
  //   "GMeowFiBoxV1",
  //   [
  //     await multiNFT.getAddress(),
  //     await boxStorage.getAddress(),
  //     await xGM.getAddress(),
  //     await weth.getAddress(),
  //     await entropy.getAddress(),
  //     await deployer.getAddress(), // entropy provider
  //     await deployer.getAddress(), // admin
  //   ],
  //   "GMeowFiBoxV1",
  //   {}
  // );

  const gMeowFiBox = await ethers.getContractAt(
    "GMeowFiBoxV1",
    "0x9091712FE15D07C36cf350D4A61a864E96549e25"
  );

  // await sendTxn(
  //   entropy.setWhitelist(await gMeowFiBox.getAddress(), true),
  //   "setWhitelist"
  // );
  // await sendTxn(
  //   multiNFT.grantRole(
  //     await multiNFT.MINTER_ROLE(),
  //     await gMeowFiBox.getAddress()
  //   ),
  //   "grantRole MINTER"
  // );
  // await sendTxn(
  //   xGM.setWhitelistTransfer(await gMeowFiBox.getAddress(), true),
  //   "setWhitelistTransfer"
  // );
  await sendTxn(
    xGM.distribute(deployer.address, ethers.parseEther("1000")),
    "distribute"
  );
  await sendTxn(
    xGM.transfer(await gMeowFiBox.getAddress(), ethers.parseEther("1000")),
    "transfer xGM"
  );

  await sendTxn(
    multiNFT.mint(
      await gMeowFiBox.getAddress(),
      await gMeowFiBox.MEOW_CHRONICLES_ID(),
      100,
      "0x"
    ),
    "multiNFT mint"
  );
  await sendTxn(weth.deposit({ value: ethers.parseEther("0.02") }), "deposit");
  await sendTxn(
    weth.transfer(await gMeowFiBox.getAddress(), ethers.parseEther("0.02")),
    "transfer"
  );
  await sendTxn(
    multiNFT.mintBatch(
      await deployer.getAddress(),
      [1, 2, 3, 4, 5, 6],
      [5, 5, 5, 5, 5, 5],
      "0x"
    ),
    "multiNFT mint"
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
