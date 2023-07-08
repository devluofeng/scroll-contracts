const { ethers } = require("hardhat");

module.exports = async ({getNamedAccounts, deployments, network}) => {
    const {deploy} = deployments;
    const {deployer, owner} = await getNamedAccounts();
    const oracle = await deploy('DummyOracle', {
        from: deployer, 
        args:[160000000000],
        log:true
    })

    await deploy('StablePriceOracle', {
        from: deployer, 
        args:[oracle.address,[20294266869609]],
        log:true
    })
    

}

module.exports.tags = ['oracles'];
module.exports.dependencies = ['registry']