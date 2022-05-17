const ABIProxyAdmin = artifacts.require("ABIProxyAdmin")

module.exports = function(deployer, network) {
    return
    deployer.deploy(ABIProxyAdmin)
};
