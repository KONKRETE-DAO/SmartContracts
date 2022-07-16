import * as dotenv from "dotenv";

import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import "solidity-coverage";
import "@openzeppelin/hardhat-upgrades";
import "@openzeppelin/hardhat-defender";
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
  defender: {
    apiKey: process.env.DEFENDER_TEAM_API_KEY!,
    apiSecret: process.env.DEFENDER_TEAM_API_SECRET_KEY!,
  },
  networks: {
    // polygon: {
    //   url: process.env.POLYGON_URL,
    //   accounts:
    //     [process.env.OWNER_KEY!, process.env.BUYER_KEY!]
    // },
    goerli: {
      url: process.env.GOERLI_URL!,
      accounts: [process.env.PKEY!, process.env.BUYER_KEY!],
    },
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
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
  // gasReporter: {
  //   enabled: true,
  //   currency: "USD",
  //   gasPriceApi : "https://api.etherscan.io/api?module=proxy&action=eth_gasPrice",
  // },
  // },
};

export default config;
