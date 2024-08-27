import { ethers } from "hardhat";
import { sendTxn, deployContract } from "../helper";
import { GMeowFiBoxStorageV1 } from "../../typechain-types";

async function main() {
  const [executor] = await ethers.getSigners();
  const box = await ethers.getContractAt(
    "GMeowFiBoxV1",
    "0x9091712FE15D07C36cf350D4A61a864E96549e25"
  );
  const boxStorage = await deployContract<GMeowFiBoxStorageV1>(
    "GMeowFiBoxStorageV1",
    [],
    "GMeowFiBoxStorageV1",
    null
  );

  await sendTxn(
    box.setGMeowFiBoxStorage(await boxStorage.getAddress()),
    "box.setGMeowFiBoxStorage"
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
