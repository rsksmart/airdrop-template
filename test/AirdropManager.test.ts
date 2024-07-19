import { expect } from "chai";
import { ethers } from "hardhat";

describe("AirdropManager", function () {
  let admin: any;
  let user1: any;
  let user2: any;
  let airdropManager: any;
  let customAirdrop: any;
  let myToken: any;

  before(async function () {
    [admin, user1, user2] = await ethers.getSigners();

    myToken = await ethers.deployContract("MyToken", [admin.address], { signer: admin });
    await myToken.waitForDeployment();
    console.log("MyToken deployed at", await myToken.getAddress());

    const name = "Custom Airdrop";
    const tokenId = 1;
    const totalAirdropAmount = ethers.parseUnits("100", 18);
    const claimAmount = ethers.parseUnits("1", 18);
    const expirationDate = Math.floor(Date.now() / 1000) + 86400; // 1 day from now

    customAirdrop = await ethers.deployContract("CustomAirdrop1155", [
      name,
      admin.address,
      await myToken.getAddress(),
      tokenId,
      totalAirdropAmount,
      claimAmount,
      expirationDate
    ], { signer: admin });
    await customAirdrop.waitForDeployment();
    console.log("CustomAirdrop deployed at", await customAirdrop.getAddress());

    
    airdropManager = await ethers.deployContract("AirdropManager", [[admin.address]], { signer: admin });
    await airdropManager.waitForDeployment(); 
    console.log("AirdropManager deployed at", await airdropManager.getAddress());

    
    await customAirdrop.transferOwnership(await airdropManager.getAddress());
  });

  it("should add an airdrop successfully", async function () {
    await airdropManager.addAirdrop(await customAirdrop.getAddress());
    const airdrops = await airdropManager.getAirdrops();
    expect(airdrops).to.include(await customAirdrop.getAddress());
  });

  it("should not allow a non-admin to allow addresses", async function () {
    await expect(airdropManager.connect(user1).allowAddress(await customAirdrop.getAddress(), user1.address)).to.be.reverted;
  });

  it("should allow an admin to allow addresses", async function () {
    await airdropManager.allowAddress(await customAirdrop.getAddress(), user1.address);
    const isAllowed = await airdropManager.isAllowed(await customAirdrop.getAddress(), user1.address);
    expect(isAllowed).to.be.true;
  });

  it("should allow a user to claim airdrop after being allowed", async function () {
    
    await myToken.mint(await customAirdrop.getAddress(), 1, ethers.parseUnits("100", 18), "0x");

    
    const airdropBalance = await myToken.balanceOf(await customAirdrop.getAddress(), 1);
    expect(airdropBalance.toString()).to.equal(ethers.parseUnits("100", 18).toString());

    
    await airdropManager.claim(await customAirdrop.getAddress(), user1.address);

    
    const userBalance = await myToken.balanceOf(user1.address, 1);
    expect(userBalance.toString()).to.equal(ethers.parseUnits("1", 18).toString()); 
  });

  it("should fail to claim airdrop if user is not allowed", async function () {
    await expect(airdropManager.claim(await customAirdrop.getAddress(), user2.address)).to.be.revertedWith("Address not allowed to claim this airdrop");
  });

  it("should fail to claim airdrop if expired", async function () {
    
    await ethers.provider.send("evm_increaseTime", [86400 + 1]); // 1 day + 1 second
    await ethers.provider.send("evm_mine", []);

    await expect(airdropManager.claim(await customAirdrop.getAddress(), user1.address)).to.be.revertedWith("Airdrop already expired.");
  });
});
