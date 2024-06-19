import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import hre from "hardhat";

describe("AdAuction", function () {
  async function deployAdAuctionFixture() {
    const TotalSupply = 1_000_000_000_000;

    const Moi = await hre.ethers.getContractFactory("Moi");
    const moi = await Moi.deploy(TotalSupply);

    const AdAuction = await hre.ethers.getContractFactory("AdAuction");
    const adAuction = await AdAuction.deploy(moi.getAddress());

    return { adAuction };
  }

  describe("Selector", function () {
    it("Should success to deploy", async function () {
      const { adAuction } = await loadFixture(deployAdAuctionFixture);
      expect(adAuction.getAddress()).to.not.be.undefined;
    });
  });
});
