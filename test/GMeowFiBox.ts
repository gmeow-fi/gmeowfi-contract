import { ethers } from "hardhat";
import {
  GMeowFiBox,
  GMeowFiBoxStorage,
  GMeowFiEntropy,
  GMeowFiMultiNFT,
  GmeowFiNFT,
  PAWToken,
  TestToken,
} from "../typechain-types";
import { Signer } from "ethers";
import { sendTxn } from "../scripts/helper";

describe("GMeowFiBox", function () {
  let deployer: Signer;
  let xGM: TestToken,
    usde: TestToken,
    paw: PAWToken,
    multiNFT: GMeowFiMultiNFT,
    gmeowFiNFT: GmeowFiNFT,
    boxStorage: GMeowFiBoxStorage,
    entropy: GMeowFiEntropy,
    gMeowFiBox: GMeowFiBox;

  before(async function () {
    [deployer] = await ethers.getSigners();
    xGM = await ethers.deployContract("TestToken", [
      "xGM",
      "xGM",
      1000000000,
      18,
    ]);
    usde = await ethers.deployContract("TestToken", [
      "USDE",
      "USDE",
      1000000000,
      18,
    ]);
    paw = await ethers.deployContract("PAWToken", [
      await usde.getAddress(),
      await deployer.getAddress(),
      await usde.decimals(),
    ]);
    multiNFT = await ethers.deployContract("GMeowFiMultiNFT", []);
    for (let i = 1; i <= 6; i++) {
      await multiNFT.setNFT(
        i,
        `GMeowFi NFT ${i}`,
        `GMeowFi-NFT-${i}`,
        `https://gmeowfi.com/api/nft/${i}/`,
        ethers.MaxUint256
      );
    }
    gmeowFiNFT = await ethers.deployContract("GmeowFiNFT", [
      "ipfs://QmaqJqrksoERsG4aGEFyp1GTarpV2zrcqyubDA3qW7XSJV",
      100000,
    ]);
    boxStorage = await ethers.deployContract("GMeowFiBoxStorage", []);
    entropy = await ethers.deployContract("GMeowFiEntropy", [
      ethers.ZeroAddress,
      ethers.ZeroHash,
    ]);
    gMeowFiBox = await ethers.deployContract("GMeowFiBox", [
      await multiNFT.getAddress(),
      await gmeowFiNFT.getAddress(),
      await boxStorage.getAddress(),
      await paw.getAddress(),
      await xGM.getAddress(),
      await usde.getAddress(),
      await entropy.getAddress(),
      await deployer.getAddress(),
      await deployer.getAddress(),
      ethers.ZeroAddress,
    ]);

    await entropy.setWhitelist(await gMeowFiBox.getAddress(), true);

    await paw.approve(await gMeowFiBox.getAddress(), ethers.MaxUint256);
    await usde.approve(await gMeowFiBox.getAddress(), ethers.MaxUint256);
    await multiNFT.setApprovalForAll(await gMeowFiBox.getAddress(), true);

    await multiNFT.grantRole(
      await multiNFT.MINTER_ROLE(),
      await gMeowFiBox.getAddress()
    );

    for (let i = 1; i <= 6; i++) {
      await multiNFT.mint(await deployer.getAddress(), i, 100, "0x");
    }

    await usde.approve(await paw.getAddress(), ethers.MaxUint256);
    await paw.deposit(ethers.parseEther("100000"));

    await paw.transfer(
      await gMeowFiBox.getAddress(),
      ethers.parseEther("10000")
    );

    await xGM.transfer(
      await gMeowFiBox.getAddress(),
      ethers.parseEther("10000")
    );

    for (let i = 0; i <= 6; i++) {
      await gmeowFiNFT.safeMint(await gMeowFiBox.getAddress());
    }
  });

  it("open box", async function () {
    for (let i = 0; i < 5; i++) {
      await sendTxn(
        gMeowFiBox.openBox(1, i, 0, false, {
          value: await gMeowFiBox.txFees(i),
        }),
        `openBox ${i}`
      );
      await sendTxn(
        gMeowFiBox.openBox(1, i, 1, false, {
          value: await gMeowFiBox.txFees(i),
        }),
        `openBox ${i}`
      );
      await sendTxn(
        gMeowFiBox.openBox(1, i, 2, false, {
          value: await gMeowFiBox.txFees(i),
        }),
        `openBox ${i}`
      );
    }
  });
});
