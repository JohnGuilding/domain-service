const main = async () => {
    const [owner, hacker] = await hre.ethers.getSigners();
    const domainServiceContractFactory = await hre.ethers.getContractFactory("DomainService");
    const domainServiceContract = await domainServiceContractFactory.deploy('gm');
    await domainServiceContract.deployed();
    console.log('Contract deployed to: ', domainServiceContract.address);

    // Let's be extra generous with our payment (we're paying more than required)
    let txn = await domainServiceContract.register("test",  {value: hre.ethers.utils.parseEther('1234')});
    await txn.wait();

    // How much money is in here?
    const balance = await hre.ethers.provider.getBalance(domainServiceContract.address);
    console.log("Contract balance:", hre.ethers.utils.formatEther(balance));

    // Try grab the funds (as the hacker)
    try {
        txn = await domainServiceContract.connect(hacker).withdraw();
        await txn.wait();
    } catch(error){
        console.log("Could not rob contract");
    }

    // Look in their wallet so we can compare later
    let ownerBalance = await hre.ethers.provider.getBalance(owner.address);
    console.log("Balance of owner before withdrawal:", hre.ethers.utils.formatEther(ownerBalance));

    // The owner still controls their money
    txn = await domainServiceContract.connect(owner).withdraw();
    await txn.wait();
    
    // Fetch balance of contract & owner
    const contractBalance = await hre.ethers.provider.getBalance(domainServiceContract.address);
    ownerBalance = await hre.ethers.provider.getBalance(owner.address);

    console.log("Contract balance after withdrawal:", hre.ethers.utils.formatEther(contractBalance));
    console.log("Balance of owner after withdrawal:", hre.ethers.utils.formatEther(ownerBalance));

    const allNames = await domainServiceContract.getAllNames();
    console.log(allNames);
}

const runMain = async () => {
    try {
        await main();
        process.exit(0);
    } catch (error) {
        console.log(error);
        process.exit(1);
    }
}

runMain();