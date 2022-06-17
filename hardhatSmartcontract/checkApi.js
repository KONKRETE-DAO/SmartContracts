// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
require('dotenv').config()
const axios = require('axios');
const req = 'https://api-testnet.polygonscan.com/api?module=logs&action=getLogs&fromBlock=5000000&toBlock=6000000&address=0x0000000000000000000000000000000000001010&topic0=0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef&apikey='
// const url= req + process.env.POLYGONSCAN_API_KEY

// const url = `https://api-testnet.polygonscan.com/api?module=logs&action=getLogs&fromBlock=26742278&toBlock=6000000&address=0x59EF7a197c23c3a1882a510C4CCa83A6eA1c5d2d&topic0=0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef&topic0_1_opr=and&topic1=0x0000000000000000000000000000000000000000000000000000000000000000&apikey=${process.env.POLYGONSCAN_API_KEY}`

const url = 'https://api-testnet.polygonscan.com/api?module=logs&action=getLogs&fromBlock=5000000&toBlock=6000000&address=0x0000000000000000000000000000000000001010&topic0=0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef&apikey=GSMV18I6X6XEJQ5A4AQDNFQH75458GKSQ1'

const getting = async () => {

  let res = await axios
  .get(url)

  console.log(await axios
  .get(url));
}
getting().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
