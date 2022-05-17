const ABIMarket = artifacts.require("ABIMarket")
const ABIProxyAdmin = artifacts.require("ABIProxyAdmin")
const MarketProxy = artifacts.require("MarketProxy")
const ABIToken = artifacts.require("ABIToken")
const BoxToken = artifacts.require("BoxToken")
const ShipToken = artifacts.require("ShipToken");

module.exports = function(deployer, network) {
    return
    // deploy(deployer, network)
    // upgrade(deployer, network)
};

const deploy = function(deployer, network) {
    let tokens = [ShipToken.address, BoxToken.address]
    let standards = [2, 3]
    let commissions = [3, 3]
    let currencies = [ABIToken.address]
    let _ticketTokens = [
        BoxToken.address,
        BoxToken.address,
        BoxToken.address,
    ]
    let _ticketRequireTokens = []
    let _ticketRequireAmounts = []

    const adminAddress = ABIProxyAdmin.address

    if (network === 'development' || network === 'local') {
        _ticketRequireTokens = [
            0,
            1,
            2,
        ]
        _ticketRequireAmounts = [
            1,
            5,
            5,
        ]

    } else if (network === 'testnet') {
        _ticketRequireTokens = [
            0,
            1,
            2,
        ]
        _ticketRequireAmounts = [
            1,
            5,
            5,
        ]

    } else if (network === 'mainnet') {
        _ticketRequireTokens = [
            0,
            1,
            2,
        ]
        _ticketRequireAmounts = [
            1,
            5,
            5,
        ]

    } else {
        console.log(`Not support network ${network}`)
        return
    }

    deployer.deploy(ABIMarket).then(() => {
        return ABIMarket.deployed()
    }).then((marketContract) => {
        const initData = marketContract.contract.methods.initialize(
            tokens,
            standards,
            commissions,
            currencies,
            _ticketTokens,
            _ticketRequireTokens,
            _ticketRequireAmounts,
        ).encodeABI()

        return deployer.deploy(MarketProxy, ABIMarket.address, adminAddress, initData)
    }).then(() => {
        console.log(`deploy netword ${network}`)
        console.log('ABIProxyAdmin', adminAddress)
        console.log('MarketProxy', MarketProxy.address)
        console.log('ABIMarket', ABIMarket.address)
    })
}

const upgrade = function(deployer, network) {
    const adminAddress = ABIProxyAdmin.address
    const proxyAddress = MarketProxy.address

    deployer.deploy(ABIMarket).then(() => {
        return ABIMarket.deployed()
    }).then((marketContract) => {
        return ABIProxyAdmin.at(adminAddress).then((proxyAdmin) => {
            return proxyAdmin.upgrade(proxyAddress, marketContract.address).then(() => {
                return proxyAdmin.getProxyImplementation(proxyAddress).then((res) => {
                    console.log('implement to', res)
                })
            })
        })
    })
}
