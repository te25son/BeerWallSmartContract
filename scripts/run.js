const main = async () => {
    const [owner, randomPerson] = await hre.ethers.getSigners();
    // Compile the contract.
    const beerContractFactory = await hre.ethers.getContractFactory("BeerWall");

    // Deploy the contract.
    const beerContract = await beerContractFactory.deploy();
    
    // Wait for the contract to be deployed and picked up by (test) miners.
    await beerContract.deployed();
    console.log("Contract deployed to: ", beerContract.address);
    console.log("Contract deployed by: ", owner.address);

    let beerCount;
    beerCount = await beerContract.getTotalBeers();

    let topGiver;
    topGiver = await beerContract.getTopBeerGiverAndAmount();

    let topTaker;
    topTaker = await beerContract.getTopBeerTakerAndAmount();

    let contractBalance = await hre.ethers.provider.getBalance(beerContract.address);
    console.log(
      "Contract balance: ",
      hre.ethers.utils.formatEther(contractBalance)
    );

    let beerTransaction = await beerContract.takeBeer();
    let receipt = await beerTransaction.wait();
    //console.log(receipt.events?.filter((e) => { return e.event }));

    contractBalance = await hre.ethers.provider.getBalance(beerContract.address);
    console.log(
      "Contract balance: ",
      hre.ethers.utils.formatEther(contractBalance)
    );

    beerCount = await beerContract.getTotalBeers();

    beerTransaction = await beerContract.connect(randomPerson).giveBeer("Have a beer on me!");
    await beerTransaction.wait();

    beerCount = await beerContract.getTotalBeers();

    beerTransaction = await beerContract.connect(randomPerson).giveBeer("Have another beer on me!");
    await beerTransaction.wait();

    beerCount = await beerContract.connect(randomPerson).getTotalBeers();
    topGiver = await beerContract.getTopBeerGiverAndAmount();
    topTaker = await beerContract.getTopBeerTakerAndAmount();

    beerTransaction = await beerContract.connect(randomPerson).takeBeer();
    receipt = await beerTransaction.wait();
    //console.log(receipt.events?.filter((e) => { return e.event == "BeerTaken"}));

    topGiver = await beerContract.getTopBeerGiverAndAmount();
    topTaker = await beerContract.getTopBeerTakerAndAmount();

    beerTransaction = await beerContract.connect(randomPerson).takeBeer();
    await beerTransaction.wait();

    topGiver = await beerContract.getTopBeerGiverAndAmount();
    topTaker = await beerContract.getTopBeerTakerAndAmount();

    beerResults = await beerContract.getResultsOfAddress(owner.address);
    await beerTransaction.wait();

    beerResults = await beerContract.getResultsOfAddress(randomPerson.address);
    await beerTransaction.wait();

    let beers = await beerContract.getBeers();
    console.log(beers);
}


const runMain = async () => {
    try {
      await main();
      process.exit(0);
    } catch (error) {
      console.log(error);
      process.exit(1);
    }
  };
  
  runMain();