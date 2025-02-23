import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-ethers";
import * as dotenv from "dotenv";

dotenv.config();

// Make sure to keep your private key secure
const PRIVATE_KEY =
  process.env.PRIVATE_KEY ||
  "0000000000000000000000000000000000000000000000000000000000000000";

const config: HardhatUserConfig = {
  solidity: "0.8.20",
  networks: {
    hardhat: {
      chainId: 31337,
    },
    sonic: {
      url: "https://rpc.soniclabs.com",
      chainId: 146,
      accounts: [PRIVATE_KEY],
    },
    sonicTestnet: {
      url: "https://rpc.blaze.soniclabs.com",
      chainId: 57054,
      accounts: [PRIVATE_KEY],
    },
  },
  etherscan: {
    apiKey: {
      sonic: process.env.SONICSCAN_API_KEY || "",
      sonicTestnet: process.env.SONICSCAN_TESTNET_API_KEY || "",
    },
    customChains: [
      {
        network: "sonic",
        chainId: 146,
        urls: {
          apiURL: "https://api.sonicscan.org/api",
          browserURL: "https://sonicscan.org",
        },
      },
      {
        network: "sonicTestnet",
        chainId: 57054,
        urls: {
          apiURL: "https://api-testnet.sonicscan.org/api",
          browserURL: "https://testnet.sonicscan.org",
        },
      },
    ],
  },
};

export default config;
