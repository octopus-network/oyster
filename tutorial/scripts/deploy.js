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