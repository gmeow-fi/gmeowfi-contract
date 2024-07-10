import { deployContract, sendTxn } from "../helper";
import { ethers } from "hardhat";
import params from "../params/faucetParams";
import { Faucet } from "../../typechain-types";

async function main() {
  const [deployer] = await ethers.getSigners();

  const faucet = await deployContract<Faucet>(
    "Faucet",
    [params[0], params[1]],
    "deployFaucet",
    {}
  );

  for (const tokenConfig of params[0] as {
    token: string;
    faucetAmount: bigint;
  }[]) {
    const token = await ethers.getContractAt("ERC20", tokenConfig.token);
    await sendTxn(
      token.transfer(
        await faucet.getAddress(),
        tokenConfig.faucetAmount * BigInt(10000)
      ),
      "transfer"
    );
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
