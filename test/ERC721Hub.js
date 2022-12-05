const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");

require("hardhat-gas-reporter");

describe("Hub", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function basicDeployment() {
    // Contracts are deployed using the first signer/account by default
    const [deployer, addr1, addr2] = await ethers.getSigners();

    // Deploy Sample Hub
    const Hub = await ethers.getContractFactory("SampleERC721Hub");
    const hub = await Hub.deploy("SampleHub", "SHUB");
    await hub.deployed();

    // Mint two spokes, one to deployer one to addr1
    let makeSpoke = await hub.mintWithEth({
      value: ethers.utils.parseUnits(".02", "ether"),
    });
    await makeSpoke.wait();
    makeSpoke = await hub.connect(addr1).mintWithEth({
      value: ethers.utils.parseUnits(".02", "ether"),
    });
    await makeSpoke.wait();

    // Get deployed spokes
    const spoke1Address = await hub.spokes(1);
    const spoke1 = await ethers.getContractAt("Spoke", spoke1Address);

    const spoke2Address = await hub.spokes(2);
    const spoke2 = await ethers.getContractAt("Spoke", spoke2Address);

    console.log("hub: ", hub.address);
    console.log("spoke1: ", spoke1.address);
    console.log("spoke2: ", spoke1.address);
    console.log("deployer: ", deployer.address);
    console.log("addr1: ", addr1.address);
    console.log("addr2: ", addr2.address);
    return { hub, spoke1, spoke2, deployer, addr1, addr2 };
  }

  describe("Deployment", function () {
    it("Should deploy a Hub and two Spokes", async function () {
      const { hub, spoke1, spoke2, deployer, addr1 } = await loadFixture(
        basicDeployment
      );

      expect(await hub.ownerOf(1)).to.be.equal(deployer.address);
      expect(await hub.ownerOf(2)).to.be.equal(addr1.address);

      expect(await spoke1.owner()).to.be.equal(deployer.address);
      expect(await spoke2.owner()).to.be.equal(addr1.address);
    });
  });

  describe("Transfers", function () {
    it("Should allow an owner to transfer their tokens from hub", async function () {
      const { hub, spoke1, deployer, addr1, addr2 } = await loadFixture(
        basicDeployment
      );
      expect(await hub.ownerOf(1)).to.be.equal(deployer.address);

      let tx = await hub.transferFrom(deployer.address, addr1.address, 1);
      await tx.wait();
      expect(await hub.ownerOf(1)).to.be.equal(addr1.address);
      expect(await spoke1.owner()).to.be.equal(addr1.address);
      expect(await hub.balanceOf(addr1.address)).to.be.equal(2);

      tx = await hub
        .connect(addr1)
        .transferFrom(addr1.address, addr2.address, 1);
      expect(await hub.balanceOf(addr1.address)).to.be.equal(1);
    });

    it("Should not allow non-owner/approved to transfer token", async function () {
      const { hub, deployer, addr1, addr2 } = await loadFixture(
        basicDeployment
      );

      await expect(
        hub.connect(addr1).transferFrom(addr1.address, addr2.address, 1)
      ).to.be.reverted;

      let tx = await hub.transferFrom(deployer.address, addr1.address, 1);
      await tx.wait();

      await expect(hub.transferFrom(deployer.address, addr1.address, 1)).to.be
        .reverted;
    });

    it("Should allow approved users to transfer tokens", async function () {
      const { hub, spoke1, spoke2, deployer, addr1, addr2 } = await loadFixture(
        basicDeployment
      );

      // setApprovalForAll() on hub
      let tx = await hub.setApprovalForAll(addr1.address, true);
      await tx.wait();

      tx = await hub
        .connect(addr1)
        .transferFrom(deployer.address, addr2.address, 1);
      await tx.wait();

      expect(await hub.ownerOf(1)).to.be.equal(addr2.address);
      expect(await spoke1.owner()).to.be.equal(addr2.address);

      // approve() on hub
      tx = await hub.connect(addr1).approve(addr2.address, 2);
      await tx.wait();
      tx = await hub
        .connect(addr2)
        .transferFrom(addr1.address, deployer.address, 2);
      await tx.wait();

      expect(await hub.ownerOf(2)).to.be.equal(deployer.address);
      expect(await spoke2.owner()).to.be.equal(deployer.address);
    });
  });
});
