require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-etherscan");
require("@solidstate/hardhat-bytecode-exporter");
require('hardhat-abi-exporter');
require('@openzeppelin/hardhat-upgrades');
const {
  TASK_COMPILE,
} = require('hardhat/builtin-tasks/task-names');

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});


module.exports = {
  networks: {
    goerli: {
      url: "",
      accounts: [""]
    },
    sepolia:{
      url: "",
      accounts: [""]
    }

  },
  etherscan: {
    apiKey: ""
  },
  solidity: "0.8.9"
}