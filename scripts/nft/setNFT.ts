import { ethers } from "hardhat";
import { sendTxn } from "../helper";

async function main() {
  const [executor] = await ethers.getSigners();
  console.log(`Setting NFTs with the account: ${executor.address}`);

  const multiNFT = await ethers.getContractAt(
    "GMeowFiMultiNFT",
    "0xD5769BD2B7064c35991dD099c084C7e6195DC5de"
  );
  await sendTxn(
    multiNFT.setNFT(
      0,
      "Meow Chronicles",
      "GMeowFi-MC",
      "ipfs://QmafnHKaBLRkahmDEmLzp3fUUXojKe6FKEWgFGSZk2EbXL",
      100000
    ),
    "setNFT Chronicles"
  );
  await sendTxn(
    multiNFT.setNFT(
      1,
      "GMeowFi Lottery Ticket",
      "GMeowFi-LT",
      "ipfs://QmRCzMV9AKZrW89qhi8a65HZXPY45uQBGBWEGZXEHUeUSd",
      ethers.MaxUint256
    ),
    "setNFT Lottery Ticket"
  );
  await sendTxn(
    multiNFT.setNFT(
      2,
      "GMeowFi Fun Claw",
      "GMeowFi-FC",
      "ipfs://Qmd2wcgL6Lmrzbb8fjHeycFYJgHrWRp7ZbJBFxkTxQb52k",
      ethers.MaxUint256
    ),
    "setNFT Fun Claw"
  );
  await sendTxn(
    multiNFT.setNFT(
      3,
      "GMeowFi Joy Claw",
      "GMeowFi-JC",
      "ipfs://QmUdMaPUZJwpdvbUj6XKyCmJEgJHy8gsam7HiD9QxMpB23",
      ethers.MaxUint256
    ),
    "setNFT Joy Claw"
  );
  await sendTxn(
    multiNFT.setNFT(
      4,
      "GMeowFi Sip Claw",
      "GMeowFi-SC",
      "ipfs://QmQRvMrKE8irJR5qbbDtJ2rcyomMwLkyUyoejtG81pg2tB",
      ethers.MaxUint256
    ),
    "setNFT Sip Claw"
  );
  await sendTxn(
    multiNFT.setNFT(
      5,
      "GMeowFi Sweat Claw",
      "GMeowFi-SWC",
      "ipfs://Qmb7qQYm6hUdX8q5t6zjUuykKiyXqvGQVbcogdhNje8EjM",
      ethers.MaxUint256
    ),
    "setNFT Sweat Claw"
  );
  await sendTxn(
    multiNFT.setNFT(
      6,
      "GMeowFi Treasure Claw",
      "GMeowFi-TC",
      "ipfs://QmUDqVWsztunK6s3mhftsjMwcgMut6YZGtCRMR1ykTdPgU",
      ethers.MaxUint256
    ),
    "setNFT Treasure Claw"
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
