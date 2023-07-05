# Hardhat Tutorial

In this tutorial, we'll walk through how we can use the [Hardhat](https://hardhat.org/){target=_blank} to write, deploy a sample Solidity smart contract to OttoChain Testnet.

## Checking Prerequisites

To get started, you should have the following:

* [Node.js](https://nodejs.org/en/download){target=_blank} version 16 or newer installed.
* [VS Code](https://code.visualstudio.com/) with Nomic Foundation's [Solidity extension](https://marketplace.visualstudio.com/items?itemName=NomicFoundation.hardhat-solidity) is a recommended IDE.
* A wallet like [MetaMask](https://metamask.io/){target=_blank} installed.

## Creating a Hardhat Project

You can create a Hardhat project by completing the following steps:

1. Create a project directory
    ```
    mkdir tutorial && cd tutorial
    ```
2. Initialize the project which will create a `package.json` file
    ```
    npm init -y
    ```
3. Install Hardhat
    ```
    npm install hardhat
    ```
4. Create an empty Hardhat project
    ```
    npx hardhat
    ```     
5. A menu will appear which will allow you to create a new project or use a sample project. For this example, you can choose **Create an empty hardhat.config.js**

![Create an empty Hardhat project.](./images/npx-hardhat.png)

This will create a Hardhat config file (`hardhat.config.js`) in your project directory.

## Hardhat Configuration File

Before you can write and deploy the contract to OttoChain Testnet, you'll need to modify the Hardhat configuration file.

Then you can create a `secrets.json` file under the project directory to store the private key of the pre-funded account `test` which has some `OCT` tokens in OttoChain Testnet by running:
```
touch secrets.json
```

The below content is the private key of the pre-funded account `test` in OttoChain Testnet, you can copy and paste it into `secrets.json`.
```
afe0a1313b61191d8f9fe2b4b7e91aad98e28458799428f140a61d884dec7c59
```

Your `secrets.json` should resemble the following:
```
{
    "privateKey": "0xafe0a1313b61191d8f9fe2b4b7e91aad98e28458799428f140a61d884dec7c59"
}
```

!!! remember
Make sure to add the file to your project's `.gitignore`. Never reveal or commit your private keys inside your repositories.

When setting up the `hardhat.config.js` file, we'll need the [Hardhat Toolbox plugin](https://hardhat.org/hardhat-runner/plugins/nomicfoundation-hardhat-toolbox){target=_blank}, which conveniently bundles together the packages that we'll need later on for testing. It can be installed with the following command:
```
npm install --save-dev @nomicfoundation/hardhat-toolbox
```

Next you can take the following steps to modify the `hardhat.config.js` file and add OttoChain Testnet as a network:

1. Import the Hardhat Toolbox plugin required to interact with our contracts
2. Import the private key from the `secrets.json` file
3. Inside the `module.exports`, you need to add the OttoChain Testnet network configuration
```
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
```
You're now ready to move on to development and testing for smart contracts.

## Write an ERC-20 Token Contract

Let's write a smart contract that allows you to mint a token for a price. This smart contract relies on a couple of standard [OpenZeppelin contracts](https://docs.openzeppelin.com/contracts/4.x/) and install the library with the following command:
    ```
    npm install @openzeppelin/contracts
    ```

To get started, take the following steps:

1. Create a `contracts` directory to hold your project's smart contracts
    ```
    mkdir contracts
    ```
2. Create a new file called `MintableERC20.sol`
    ```
    touch contracts/MintableERC20.sol
    ```
3. Copy and paste the below contents into `MintableERC20.sol`
    ```
    // SPDX-License-Identifier: UNLICENSED
    pragma solidity ^0.8.18;

    import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
    import "@openzeppelin/contracts/access/Ownable.sol";

    contract MintableERC20 is ERC20, Ownable {
        constructor() ERC20("Mintable ERC 20", "MERC") {}

        uint256 public constant MAX_TO_MINT = 1000 ether;

        event PurchaseOccurred(address minter, uint256 amount);
        error MustMintOverZero();
        error MintRequestOverMax();
        error FailedToSendEtherToOwner();

        /**Purchases some of the token with native gas currency. */
        function purchaseMint() external payable {
            // Calculate amount to mint
            uint256 amountToMint = msg.value;

            // Check for no errors
            if (amountToMint == 0) revert MustMintOverZero();
            if (amountToMint + totalSupply() > MAX_TO_MINT)
                revert MintRequestOverMax();

            // Send to owner
            (bool success, ) = owner().call{value: msg.value}("");
            if (!success) revert FailedToSendEtherToOwner();

            // Mint to user
            _mint(msg.sender, amountToMint);
            emit PurchaseOccurred(msg.sender, amountToMint);
        }
    }    
    ```

## Compiling the Contract

To compile the contract you can simply run:
```
npx hardhat compile
```

![Compile your Solidity contracts with Hardhat.](./images/npx-hardhat-compile.png)

After compilation, two new folders `artifacts` and `cache` are created and hold the bytecode and metadata of the contract which are `.json` files. It’s a good idea to add these two folders to your `.gitignore`.

You've now written the smart contract! If this was for a production app, we would write tests for it, but that is out of the scope of this tutorial. Let's deploy it next.

## Deploy Smart Contracts

Hardhat is a Node project that uses the [Ethers.js](https://docs.ethers.org/v6/) library to interact with the blockchain. You can also use Ethers.js with Hardhat's tool to create scripts to do things like deploy contracts.

To deploy `MintableERC20.sol`, you can write a simple script. You can create a new directory for the script and name it `scripts`:

```
mkdir scripts
```

Then add a new file to it called `deploy.js`:

```
touch scripts/deploy.js
```

Next, you need to write your deployment script which can be done using `Ethers.js`, it comes out of the box with Hardhat, so you don't need to worry about installing it yourself.

Then please copy and paste the below contents into `deploy.js`:

```javascript
async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(`Deploying contracts with the account: ${deployer.address}`);    
  const tokenContract = await ethers.deployContract('MintableERC20');
  const deployedAddress = await tokenContract.getAddress();
  console.log(`Deployed MintableERC20 to the address: ${deployedAddress}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
```

This script first fetches the deployer which is the pre-funded account `test` and prints it. Then it uses the `deployContract` method to deploy the `MintableERC20.sol` smart contract that we wrote earlier, and then fetches the address of the contract using the contract instance and prints it. 

Let's run the script to deploy the contract on OttoChain Testnet whose JSON-RPC endpoint we defined in the `hardhat.config.js` script earlier:

```
npx hardhat run scripts/deploy.js --network ottochain
```

After a few seconds, the contract is deployed, and you should see an output that displays the token address in the terminal. Make sure to save it for use later!

![Deploy a Contract with Hardhat.](/images/npx-hardhat-deploy.jpg)

Congratulations, your contract is live on OttoChain Testnet! Save the address, as you will use it to search in the next step.

## Search Contracts on OttoChain Testnet Explorer

You can open [OttoChain Testnet Explorer](http://34.69.4.240:4000/) and search the contract with its address.

![Search the Contract with Explorer.](/images/explorer-search-contract.jpg)

## Conclusion

You can view the complete [tutorial on GitHub](https://github.com/octopus-network/oyster/tree/ottochain/tutorial).

