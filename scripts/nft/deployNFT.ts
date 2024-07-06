import { GMeowFiNFTMinter, GmeowFiNFT } from "../../typechain-types";
import { deployContract, sendTxn } from "../helper";
import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(`Deploying contracts with the account: ${deployer.address}`);
  console.log(ethers.MaxUint256);

  const gmeowFiNFT = await deployContract<GmeowFiNFT>(
    "GmeowFiNFT",
    [
      "ipfs://QmaqJqrksoERsG4aGEFyp1GTarpV2zrcqyubDA3qW7XSJV",
      ethers.MaxUint256,
    ],
    "GmeowFiNFT",
    {}
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
