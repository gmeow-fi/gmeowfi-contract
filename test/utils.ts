import { ethers } from "hardhat";

async function deployMultiNFTForTest() {
  const multiNFT = await ethers.deployContract("GMeowFiMultiNFT", []);
  for (let i = 1; i <= 6; i++) {
    await multiNFT.setNFT(
      i,
      `GMeowFi NFT ${i}`,
      `GMeowFi-NFT-${i}`,
      `https://gmeowfi.com/api/nft/${i}/`,
      ethers.MaxUint256
    );
  }
  return multiNFT;
}

export { deployMultiNFTForTest };
