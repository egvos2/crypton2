const main = async () => {
  // gets info of the account used to deploy
  const [deployer] = await hre.ethers.getSigners();
  const accountBalance = await deployer.getBalance();

  console.log('Deploying contract with account: ', deployer.address);
  console.log('Account balance: ', accountBalance.toString());

  // read contract file
  const ballotContractFactory = await hre.ethers.getContractFactory(
    'Ballot'
  );
  // triggers deployment
  const ballotContract = await ballotContractFactory.deploy({});

  // wait for deployment to finish
  await ballotContract.deployed();

  console.log('Ballot contract address: ', ballotContract.address);
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
};

runMain();
