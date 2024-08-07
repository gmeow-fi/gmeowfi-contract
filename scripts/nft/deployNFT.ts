import { GMeowFiNFTMinter, GmeowFiNFT } from "../../typechain-types";
import { deployContract, sendTxn } from "../helper";
import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(`Deploying contracts with the account: ${deployer.address}`);

  // const gmeowFiNFT = await deployContract<GmeowFiNFT>(
  //   "GmeowFiNFT",
  //   ["ipfs://QmaqJqrksoERsG4aGEFyp1GTarpV2zrcqyubDA3qW7XSJV", 100000],
  //   "GmeowFiNFT",
  //   {}
  // );
  const gmeowFiNFT = await ethers.getContractAt(
    "GmeowFiNFT",
    "0x9Ac9b5f0a9D5c2DA141a43f778b6aDb66638fd33"
  );
  const gmeowFiNFTMinter = await deployContract<GMeowFiNFTMinter>(
    "GMeowFiNFTMinter",
    [await deployer.getAddress(), await gmeowFiNFT.getAddress()],
    "GMeowFiNFTMinter",
    {}
  );
  await sendTxn(
    gmeowFiNFT.grantRole(
      await gmeowFiNFT.MINTER_ROLE(),
      await gmeowFiNFTMinter.getAddress()
    ),
    "grantRole"
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
