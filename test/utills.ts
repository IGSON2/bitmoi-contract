import { expect } from "chai";
import hre from "hardhat";

export async function deployContracts() {
  const [owner] = await hre.ethers.getSigners();
  const TotalSupply: bigint = hre.ethers.WeiPerEther * 100_000_000_000n;

  const Moi = await hre.ethers.getContractFactory("Moi");
  const moi = await Moi.deploy(TotalSupply);
  expect(await moi.totalSupply()).to.equal(TotalSupply);

  const Vault = await hre.ethers.getContractFactory("Vault");
  const vault = await Vault.connect(owner).deploy(await moi.getAddress());

  const AdAuction = await hre.ethers.getContractFactory("AdAuction");
  const adAuction = await AdAuction.deploy(await vault.getAddress());

  await expect(vault.connect(owner).setAdAuction(await adAuction.getAddress()))
    .not.to.be.reverted;

  return { moi, vault, adAuction };
}

export async function createAdSpot() {
  const signers = await hre.ethers.getSigners();
  const { moi, vault, adAuction } = await deployContracts();
  await expect(adAuction.connect(signers[0]).createAdSpot("spot1")).not.to.be
    .reverted;

  expect(await adAuction._adSpots(0)).to.equal("spot1");

  for (let i = 1; i <= 10; i++) {
    await expect(
      moi
        .connect(signers[0])
        .transfer(signers[i], hre.ethers.WeiPerEther * 10_000n)
    ).not.to.be.reverted;
  }

  await expect(vault.connect(signers[0]).newRound()).not.to.be.reverted;

  return { moi, vault, adAuction };
}
