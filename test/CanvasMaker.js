const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const fs = require("fs");

require("hardhat-gas-reporter");

describe("CanvasMaker", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function basicDeployment() {
    // Contracts are deployed using the first signer/account by default
    const [deployer, addr1, addr2] = await ethers.getSigners();

    const CanvasMaker = await ethers.getContractFactory("CanvasMaker");
    const canvasMaker = await CanvasMaker.deploy();
    await canvasMaker.deployed();

    const makeCanvas = await canvasMaker.mintWithEth({
      value: ethers.utils.parseUnits(".02", "ether"),
    });
    await makeCanvas.wait();
    const canvasAddress = await canvasMaker.canvases(1);
    const canvas = await ethers.getContractAt("Canvas", canvasAddress);
    console.log("CanvasMaker: ", canvasMaker.address);
    console.log("Canvas: ", canvas.address);
    console.log("Deployer: ", deployer.address);
    console.log("addr1: ", addr1.address);
    console.log("addr2: ", addr2.address);
    return { canvasMaker, canvas, deployer, addr1, addr2 };
  }

  describe("Deployment", function () {
    it("Should deploy a CanvasMaker and two Canvases", async function () {
      const { canvasMaker, deployer } = await loadFixture(basicDeployment);
      expect(await canvasMaker.ownerOf(1)).to.be.equal(deployer.address);
    });

    // Fork mainnet and test WL collections
  });

  describe("Image Creation", function () {
    it("Should create a test image", async function () {
      const { canvas, deployer } = await loadFixture(basicDeployment);

      let pixels = [];
      for (let i = 0; i < 2304; i++) {
        pixels.push(parseInt(Math.random() * 255));
      }

      let tx = await canvas.setPixelsAss(pixels);

      tx.wait();

      let test = await canvas.getPixelFromCoords(23, 23);
      console.log(test);

      pixels = [];
      for (let i = 0; i < 2304; i++) {
        pixels.push(parseInt(Math.random() * 255));
      }

      tx = await canvas.setPixelsAss2(pixels);
      tx.wait();

      test = await canvas.getPixelFromCoords(23, 23);
      console.log(test);

      let svg = await canvas.generateSvg();
      // console.log(svg);
      fs.writeFile("./test.svg", svg, (err) => {
        if (err) {
          console.error(err);
        }
      });

      // // console.log(ethers.utils.hexlify([1, 2, 3, 4]));
      // const arr = ethers.utils.solidityPack(
      //   ["uint8", "uint8", "uint8", "uint8"],
      //   [1, 2, 3, 4]
      // );
      // console.log(arr);
    });
  });
});
