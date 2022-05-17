const ABIOperator = artifacts.require("ABIOperator")
const ABIProxyAdmin = artifacts.require("ABIProxyAdmin")
const OperatorProxy = artifacts.require("OperatorProxy")
const ABIToken = artifacts.require("ABIToken")
const GARToken = artifacts.require("GARToken")
const BoxToken = artifacts.require("BoxToken")
const StoneToken = artifacts.require("StoneToken")

module.exports = function (deployer, network, accounts) {
    return
    // deploy(deployer, network, accounts)
    // upgrade(deployer, network)
}

const deploy = function (deployer, network, accounts) {
    let _devwallet, _busd, _abit, _gart, _boxt, _stone
    _devwallet = accounts[0]
    if (network === 'development' || network === 'local') {
        _busd = ABIToken.address
        _abit = ABIToken.address
        _gart = GARToken.address
        _boxt = BoxToken.address
        _stone = StoneToken.address
    } else if (network === 'testnet') {
        _busd = ABIToken.address
        _abit = ABIToken.address
        _gart = GARToken.address
        _boxt = BoxToken.address
        _stone = StoneToken.address
    } else if (network === 'mainnet') {
        _devwallet = 
        _busd = 
        _abit = ABIToken.address
        _gart = GARToken.address
        _boxt = BoxToken.address
        _stone = StoneToken.address
    } else {
        console.log(`Not support network ${network}`)
        return
    }

    const adminAddress = ABIProxyAdmin.address

    deployer.deploy(ABIOperator).then(() => {
        // not need to redeploy can use admin address
        // return deployer.deploy(ABIProxyAdmin)
    }).then(() => {
        return ABIOperator.deployed()
    }).then((operatorContract) => {
        const initData = operatorContract.contract.methods.initialize(
            _devwallet,
            _busd,
            _abit,
            _gart,
            _boxt,
            _stone,
        ).encodeABI()

        return deployer.deploy(OperatorProxy, ABIOperator.address, adminAddress, initData)
    }).then(() => {
        return ABIOperator.at(OperatorProxy.address).then((operator) => {
            const devAddr = operator.devwallet()
            const abitAddr = operator.abit()
            return Promise.all([devAddr, abitAddr])
        }).then((res) => {
            console.log(`deploy netword ${network}`)
            console.log('dev + abit?', res.map(r => r.toString()))
            console.log('ABIProxyAdmin', adminAddress)
            console.log('OperatorProxy', OperatorProxy.address)
            console.log('ABIOperator', ABIOperator.address)
        })
    })
}

const upgrade = function (deployer, network) {
    const proxyAdminAddress = ABIProxyAdmin.address
    const proxyContractAddress = OperatorProxy.address
    console.log('admin', proxyAdminAddress)
    console.log('proxy', proxyContractAddress)

    deployer.deploy(ABIOperator).then(() => {
        return ABIOperator.deployed()
    }).then((operatorContract) => {
        return ABIProxyAdmin.at(proxyAdminAddress).then((proxyAdmin) => {
            return proxyAdmin.upgrade(proxyContractAddress, operatorContract.address).then(() => {
                return proxyAdmin.getProxyImplementation(proxyContractAddress).then((res) => {
                    console.log('implement to', res)
                })
            })
        })
    })
}