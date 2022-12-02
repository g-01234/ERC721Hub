require("@nomicfoundation/hardhat-toolbox");
require("hardhat-gas-reporter");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.17",
    settings: { optimizer: { enabled: false, runs: 200 } },
  },
  gasReporter: {
    enabled: true,
  },
};
