const GARToken = artifacts.require("GARToken");

module.exports = function(deployer, network) {
    return
    if (network === 'development' || network === 'local') {

    } else if (network === 'testnet') {

    } else if (network === 'mainnet') {

    } else {
        console.log(`Not support deploy at network ${network}`)
        return
    }
    deployer.deploy(GARToken);
};
