require("@nomicfoundation/hardhat-toolbox");

const { privateKey } = require('./secrets.json');

module.exports = {
  solidity: "0.8.18",

  networks: {
    ottochain: {
      url: 'http://34.69.4.240:8545',
      chainId: 9100,
      accounts: [privateKey],
      gas: 2100000,
      gasPrice: 2000000000      
    },
  }
};
