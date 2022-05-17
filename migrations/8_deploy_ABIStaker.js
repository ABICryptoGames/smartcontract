const ABIStaker = artifacts.require("ABIStaker");
const ABIProxyAdmin = artifacts.require("ABIProxyAdmin")
const StakerProxy = artifacts.require("StakerProxy")
const ABIToken = artifacts.require("ABIToken")
const MarketProxy = artifacts.require("MarketProxy")

module.exports = function(deployer, network) {
    return
    // deploy(deployer, network)
    // upgrade(deployer, network)
};

const deploy = function(deployer, network) {
    let abit = ABIToken.address
    let market = MarketProxy.address

    let proxyAdminAddress = ABIProxyAdmin.address

    if (network === 'development' || network === 'local') {

    } else if (network === 'testnet') {

    } else if (network === 'mainnet') {

    } else {
        console.log(`Not support network ${network}`)
        return
    }


    deployer.deploy(ABIStaker).then(() => ABIStaker.deployed()).then((stakerContract) => {
        const initData = stakerContract.contract.methods.initialize(abit, market).encodeABI()
        return deployer.deploy(StakerProxy, ABIStaker.address, proxyAdminAddress, initData)
    }).then(() => {
        console.log('ABIProxyAdmin', proxyAdminAddress)
        console.log('StakerProxy', StakerProxy.address)
        console.log('ABIStaker', ABIStaker.address)
    })
}

const upgrade = function(deployer, network) {
    const proxyAdminAddress = ABIProxyAdmin.address
    const proxyContractAddress = StakerProxy.address

    deployer.deploy(ABIStaker).then(() => ABIStaker.deployed()).then((stakerContract) => {
        return ABIProxyAdmin.at(proxyAdminAddress).then((adminContract) => {
            return adminContract.upgrade(proxyContractAddress, stakerContract.address).then(() => {
                return adminContract.getProxyImplementation(proxyContractAddress).then((res) => {
                    console.log('proxy', proxyContractAddress)
                    console.log('implement to', res)
                })
            })
        })
    })
}
