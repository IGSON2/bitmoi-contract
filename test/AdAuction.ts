import hre from "hardhat";
import { expect } from "chai";
import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { createAdSpot, deployContracts } from "./utills";

const amount = hre.ethers.WeiPerEther * 100n;
const adSpot = "spot1";

describe("AdAuction", function () {
  it("Should success to modify ad spots", async function () {
    const [owner] = await hre.ethers.getSigners();
    const { adAuction } = await loadFixture(deployContracts);
    expect(await adAuction.connect(owner).createAdSpot("spot1")).not.to.be
      .reverted;

    expect(await adAuction._adSpots(0)).to.equal("spot1");

    expect(await adAuction.connect(owner).createAdSpot("spot2")).not.to.be
      .reverted;

    expect(await adAuction._adSpots(1)).to.equal("spot2");

    expect(await adAuction.connect(owner).deleteAdSpot("spot1")).not.to.be
      .reverted;

    expect(await adAuction._adSpots(0)).to.equal("spot2");
  });

  it("Should success to bid", async function () {
    const [owner, bidder] = await hre.ethers.getSigners();
    const { moi, adAuction, vault } = await loadFixture(createAdSpot);
    const round = await vault._round();
    expect(round).to.equal(1);

    ///////////////////////////////////////////////////////////////////////////// Submit bid
    let tx = adAuction.connect(bidder).submitBid(adSpot, amount);
    await expect(tx).not.to.be.reverted;
    await expect(tx)
      .to.emit(vault, "Submitted")
      .withArgs(round, adSpot, bidder.address, amount);
    expect(
      await vault.connect(bidder)._biddingsBySpot(round, adSpot, bidder.address)
    ).to.equal(amount);

    ///////////////////////////////////////////////////////////////////////////// Decrease bid
    const decreaseAmount = hre.ethers.WeiPerEther * 50n;
    tx = adAuction.connect(bidder).decreaseBid(adSpot, decreaseAmount);
    await expect(tx).not.to.be.reverted;
    await expect(tx)
      .to.emit(vault, "Decreased")
      .withArgs(round, adSpot, bidder.address, decreaseAmount);
    expect(
      await vault.connect(bidder)._biddingsBySpot(round, adSpot, bidder.address)
    ).to.equal(amount - decreaseAmount);

    ///////////////////////////////////////////////////////////////////////////// Encrease bid
    const encreaseAmount = hre.ethers.WeiPerEther * 30n;
    tx = adAuction.connect(bidder).encreaseBid(adSpot, encreaseAmount);
    await expect(tx).not.to.be.reverted;
    await expect(tx)
      .to.emit(vault, "Encreased")
      .withArgs(round, adSpot, bidder.address, encreaseAmount);
    expect(
      await vault.connect(bidder)._biddingsBySpot(round, adSpot, bidder.address)
    ).to.equal(amount - decreaseAmount + encreaseAmount);

    ///////////////////////////////////////////////////////////////////////////// Cancel bid
    tx = adAuction.connect(bidder).cancelBid(adSpot);
    await expect(tx).not.to.be.reverted;
    await expect(tx)
      .to.emit(vault, "Canceled")
      .withArgs(round, adSpot, bidder.address);
    expect(
      await vault.connect(bidder)._biddingsBySpot(round, adSpot, bidder.address)
    ).to.equal(0);
  });
});
