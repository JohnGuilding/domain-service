const main = async () => {
    const domainServiceContractFactory = await hre.ethers.getContractFactory('DomainService');
    const domainServiceContract = await domainServiceContractFactory.deploy('gm');
    await domainServiceContract.deployed();
    console.log('Contract deployed to:', domainServiceContract.address);

    let txn = await domainServiceContract.register('letsgo', {value: hre.ethers.utils.parseEther('0.1')});
    await txn.wait();
    console.log('Minted domain for letsgo.gm');

    txn = await domainServiceContract.setDomainMetadata(
        'letsgo',
        'Let\'s go',
        'jwguilding@gmail.com',
        'solleio',
        'https://twitter.com/stablekwon/status/1464897977793728514',
        );
    await txn.wait();
    console.log('Set metadata for domain');

    const metadata = await domainServiceContract.getDomainMetadata('letsgo');
    console.log('Metadata: ', metadata);
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