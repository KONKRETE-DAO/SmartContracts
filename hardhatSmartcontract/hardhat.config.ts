import * as dotenv from "dotenv";

import { HardhatUserConfig, task } from "hardhat/config";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import "solidity-coverage";

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
  solidity: "0.8.13",
  networks: {
    polygon: {
      url: process.env.POLYGON_URL,
      accounts:
        [process.env.OWNER_KEY!, process.env.BUYER_KEY!]
    },
    mumbai: {
      url: process.env.MUMBAI_URL,
      accounts:
        [process.env.OWNER_KEY!, process.env.BUYER_KEY!]
    },
    mainnet: {
      url: process.env.MAINNET_URL,
      accounts:
        [process.env.OWNER_KEY!, process.env.BUYER_KEY!]
    },

  },
  // gasReporter: {
  //   enabled: true,
  //   currency: "USD",
  //   gasPriceApi : "https://api.etherscan.io/api?module=proxy&action=eth_gasPrice", 
  // },
  etherscan: {
    apiKey: {
      mainnet : process.env.ETHERSCAN_API_KEY!,
      goerli : process.env.ETHERSCAN_API_KEY!,
      rinkeby : process.env.ETHERSCAN_API_KEY!,
      polygon : process.env.POLYGONSCAN_API_KEY!,
      polygonMumbai : process.env.POLYGONSCAN_API_KEY!,
    }
  },
};

export default config;