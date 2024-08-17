import { ethers } from "hardhat";
import { deployContract, sendTxn } from "../helper";
import { Mutex } from "async-mutex";

let count = 0;
const mutex = new Mutex();

async function calculateAddress(suffixs: string[]) {
  const factoryAddress = "0x2F045F8784C45604bcbE96550EB728Ba1d330a17";
  const ContractFactory = await ethers.getContractFactory("PAWToken");
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
    let found = false;
    for (const suffix of suffixs) {
      if (address.endsWith(suffix)) {
        console.log(`Found address: ${address}, salt: ${salt}`);
        found = true;
        break;
      }
    }
    if (found) {
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
  const suffixs = [
    "11111",
    "22222",
    "33333",
    "44444",
    "55555",
    "66666",
    "77777",
    "88888",
    "99999",
    "00000",
    "aaaaa",
    "bbbbb",
    "ccccc",
    "ddddd",
    "eeeee",
    "fffff",
  ];
  const promises = Array.from({ length: numOfProcess }, (_, i) =>
    calculateAddress(suffixs)
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
