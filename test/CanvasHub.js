const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const fs = require("fs");

require("hardhat-gas-reporter");
describe("CanvasHub", function () {
  async function basicDeployment() {
    // Contracts are deployed using the first signer/account by default
    const [deployer, addr1, addr2] = await ethers.getSigners();

    // Deploy default renderer
    const Renderer = await ethers.getContractFactory("DefaultRenderer");
    const renderer = await Renderer.deploy();
    await renderer.deployed();

    // Deploy Sample Hub
    const Hub = await ethers.getContractFactory("CanvasHub");
    const hub = await Hub.deploy("CanvasHub", "CHUB", renderer.address);
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
    const spoke1 = await ethers.getContractAt("CanvasSpoke", spoke1Address);

    const spoke2Address = await hub.spokes(2);
    const spoke2 = await ethers.getContractAt("CanvasSpoke", spoke2Address);

    console.log("hub: ", hub.address);
    console.log("spoke1: ", spoke1.address);
    console.log("spoke2: ", spoke1.address);
    console.log("deployer: ", deployer.address);
    console.log("addr1: ", addr1.address);
    console.log("addr2: ", addr2.address);
    return { hub, spoke1, spoke2, deployer, addr1, addr2 };
  }

  describe("Image Creation", function () {
    it("Should create a test image", async function () {
      const { spoke1, deployer } = await loadFixture(basicDeployment);

      let pixels = [];
      for (let i = 0; i < 2304; i++) {
        pixels.push(parseInt(Math.random() * 255));
      }

      let tx = await spoke1.setPixels(pixels);
      tx.wait();

      let svg = await spoke1.renderSVG();
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
