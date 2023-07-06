async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(`Deploying contract with the account: ${deployer.address}`);    
  const tokenContract = await ethers.deployContract('OttoToken');
  const deployedAddress = await tokenContract.getAddress();
  console.log(`Deployed contract to the address: ${deployedAddress}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});