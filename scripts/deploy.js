const main = async () => {
    const domainServiceContractFactory = await hre.ethers.getContractFactory('DomainService');
    const domainServiceContract = await domainServiceContractFactory.deploy('gm');
    await domainServiceContract.deployed();
    console.log('Contract deployed to:', domainServiceContract.address);

    let txn = await domainServiceContract.register('letsgo', {value: hre.ethers.utils.parseEther('0.1')});
    await txn.wait();
    console.log('Minted domain for letsgo.gm');

    txn = await domainServiceContract.setRecord('letsgo', 'Let\'s go');
    await txn.wait();
    console.log('Set the record for letsgo.gm');

    const address = await domainServiceContract.getAddress('letsgo');
    console.log('Owner of domain letsgo:', address);

    const balance = await hre.ethers.provider.getBalance(domainServiceContract.address);
    console.log('Contract balance:', hre.ethers.utils.formatEther(balance));

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