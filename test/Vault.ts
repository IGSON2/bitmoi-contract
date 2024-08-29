import hre from "hardhat";
import { expect } from "chai";
import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { createAdSpot } from "./utills";

const amount = hre.ethers.WeiPerEther * 100n;
const adSpot = "spot1";

describe("Vault", function () {
  it("Should success to finalize", async function () {
    const [owner, bidder] = await hre.ethers.getSigners();
    const { moi, adAuction, vault } = await loadFixture(createAdSpot);
    let round = await vault._round();
    expect(round).to.equal(1);

    await expect(adAuction.connect(bidder).submitBid(adSpot, amount)).not.to.be
      .reverted;

    await expect(moi.connect(bidder).approve(await vault.getAddress(), amount))
      .not.to.be.reverted;

    let tx = vault
      .connect(owner)
      .finalizeBidPayment(round, adSpot, bidder.address);
    await expect(tx).not.to.be.reverted;
    await expect(tx)
      .to.emit(vault, "Finalized")
      .withArgs(round, adSpot, bidder.address);

    expect(await moi.balanceOf(await vault.getAddress())).to.equal(amount);
    expect(await moi.allowance(bidder.address, vault.getAddress())).to.equal(0);

    tx = vault.connect(owner).finalizeBidPayment(round, adSpot, bidder.address);
    await expect(tx).to.be.revertedWith("Already finalized");

    tx = vault.connect(owner).newRound();
    await expect(tx).not.to.be.reverted;
    round = await vault._round();
    expect(round).to.equal(2);
  });
});
