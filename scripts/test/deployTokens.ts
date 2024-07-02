import { TestToken } from "../../typechain-types";
import { deployContract } from "../helper";
import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);
  const btc = await deployContract<TestToken>(
    "TestToken",
    ["Bitcoin", "BTC", 1000000, 8],
    "BTC",
    {}
  );
  const usdt = await deployContract<TestToken>(
    "TestToken",
    ["Tether", "USDT", 1000000000, 6],
    "USDT",
    {}
  );
  const usdc = await deployContract<TestToken>(
    "TestToken",
    ["USD Coin", "USDC", 1000000000, 6],
    "USDC",
    {}
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
