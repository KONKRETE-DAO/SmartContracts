import * as dotenv from "dotenv";

import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import "solidity-coverage";
import "@openzeppelin/hardhat-upgrades";
import { HardhatUserConfig, task } from "hardhat/config";
dotenv.config();

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

const config: HardhatUserConfig = {
  solidity: "0.8.14",
  networks: {
    // polygon: {
    //   url: process.env.POLYGON_URL,
    //   accounts:
    //     [process.env.OWNER_KEY!, process.env.BUYER_KEY!]
    // },
    mumbai: {
      url: process.env.MUMBAI_URL!,
      accounts: [process.env.PKEY!, process.env.BUYER_KEY!],
    },
    tbsc: {
      url: process.env.TBSC_URL!,
      accounts: [process.env.PKEY!, process.env.BUYER_KEY!],
    },
    // mainnet: {
    //   url: process.env.MAINNET_URL,
    //   accounts:
    //     [process.env.OWNER_KEY!, process.env.BUYER_KEY!]
    // },
  },
  etherscan: {
    apiKey: process.env.BSC_API_KEY,
  },
  // gasReporter: {
  //   enabled: true,
  //   currency: "USD",
  //   gasPriceApi : "https://api.etherscan.io/api?module=proxy&action=eth_gasPrice",
  // },
  // },
};

export default config;
