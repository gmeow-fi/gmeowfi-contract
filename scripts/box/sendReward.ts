import { ethers } from "hardhat";
import { sendTxn } from "../helper";

async function main() {
  const [executor] = await ethers.getSigners();
  console.log(`Sending reward with the account: ${executor.address}`);

  const multiNFT = await ethers.getContractAt(
    "GMeowFiMultiNFT",
    "0xD5769BD2B7064c35991dD099c084C7e6195DC5de"
  );
  const xGM = await ethers.getContractAt(
    "XGM",
    "0x91041fdaf58254aba28dAd32F548D4A466FE0E65"
  );
  const gMeowFiBox = await ethers.getContractAt(
    "GMeowFiBoxV1",
    "0x9091712FE15D07C36cf350D4A61a864E96549e25"
  );

  await sendTxn(
    multiNFT.mint(
      await gMeowFiBox.getAddress(),
      await gMeowFiBox.MEOW_CHRONICLES_ID(),
      39900,
      "0x"
    ),
    "mint chronicles to box"
  );
  await sendTxn(
    xGM.distribute(await gMeowFiBox.getAddress(), ethers.parseEther("999000")),
    "distribute xGM to box"
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
