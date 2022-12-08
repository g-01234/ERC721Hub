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

    // Mint 100 spokes, one to deployer rest to addr1
    let spokes = [];
    let makeSpoke = await hub.mintWithEth({
      value: ethers.utils.parseUnits(".02", "ether"),
    });
    await makeSpoke.wait();
    let spokeAddress = await hub.spokes(1);
    let spoke = await ethers.getContractAt("CanvasSpoke", spokeAddress);

    spokes.push(spoke);

    for (let i = 2; i < 20; i++) {
      makeSpoke = await hub.connect(addr1).mintWithEth({
        value: ethers.utils.parseUnits(".02", "ether"),
      });
      await makeSpoke.wait();

      spokeAddress = await hub.spokes(i);
      spoke = await ethers.getContractAt("CanvasSpoke", spokeAddress);

      spokes.push(spoke);
    }

    console.log("hub: ", hub.address);
    console.log("deployer: ", deployer.address);
    console.log("renderer: ", renderer.address);
    console.log("spokes0: ", spokes[0].address);
    console.log("addr1: ", addr1.address);
    console.log("addr2: ", addr2.address);
    console.log("num spokes: ", spokes.length);
    return { hub, spokes, renderer, deployer, addr1, addr2 };
  }

  describe("Image Creation", function () {
    it("Should get tokenURIs", async function () {
      const { hub } = await loadFixture(basicDeployment);
      expect(await hub.tokenURI(1)).to.not.equal("");
    });

    it("Should allow setting pixels", async function () {
      const { hub, spokes, renderer, addr1 } = await loadFixture(
        basicDeployment
      );

      let pixels = [];
      for (let i = 0; i < 1024; i++) {
        pixels.push(parseInt(Math.random() * 255));
      }

      let tx = await spokes[0].setPixels(pixels);
      await tx.wait();

      let svg = await spokes[0].renderSVG();

      fs.writeFile(`./output/svgRand.svg`, svg, (err) => {
        if (err) {
          console.error(err);
        }
      });
    });

    it("Should create some test images", async function () {
      const { spokes } = await loadFixture(basicDeployment);

      let svg;
      for (let i = 0; i < 3; i++) {
        svg = await spokes[i].renderSVG();

        fs.writeFile(`./output/svg${i}.svg`, svg, (err) => {
          if (err) {
            console.error(err);
          }
        });
        console.log(`Done writing svg${i}.svg`);
      }
    });
  });
});
