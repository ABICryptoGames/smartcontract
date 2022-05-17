const StoneToken = artifacts.require("StoneToken");

module.exports = function(deployer, network) {
    return
    deployer.deploy(StoneToken)
};
