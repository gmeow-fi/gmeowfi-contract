import { ethers } from "hardhat";
import { deployContract, sendTxn } from "../helper";
import { Mutex } from "async-mutex";

let count = 0;
const mutex = new Mutex();

async function calculateAddress(suffix: string) {
  const factoryAddress = "0xAb38aa4A581351416a92815cf4697D4f58c4fdc6";
  const ContractFactory = await ethers.getContractFactory("GM");
  while (true) {
    const salt = genRandomSalt();
    const hash = ethers.keccak256(
      ethers.solidityPacked(
        ["bytes1", "address", "uint256", "bytes32"],
        [
          "0xff",
          factoryAddress,
          salt,
          ethers.keccak256(ContractFactory.bytecode),
        ]
      )
    );
    const address = "0x" + hash.slice(26);
    if (address.endsWith(suffix)) {
      console.log(`Found address: ${address}, salt: ${salt}`);
      break;
    }
    const release = await mutex.acquire();
    count++;
    if (count % 100000 === 0) {
      console.log(`Total checked: ${count}\n====================`);
    }
    release();
  }
}

function genRandomSalt() {
  const salt = ethers.randomBytes(32);
  const saltBigNumber = ethers.toBigInt(salt);
  return saltBigNumber;
}

async function main() {
  const numOfProcess = 200;
  const suffix = "888888";
  const promises = Array.from({ length: numOfProcess }, (_, i) =>
    calculateAddress(suffix)
  );
  try {
    await Promise.race(promises);
    console.log(`Gotcha! Total checked: ${count}`);
  } catch (e) {
    console.log(e);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
