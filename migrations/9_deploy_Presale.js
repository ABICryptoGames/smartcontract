const Presale = artifacts.require("Presale");
const ABIToken = artifacts.require("ABIToken");

module.exports = function(deployer, network, accounts) {
    return
    let _abi, _devwallet, seedAddrs, seedAmounts, privateAddrs, privateAmounts
    _abi = ABIToken.address
    _devwallet = accounts[0]

    if (network === 'development' || network === 'local') {
        seedAddrs = [
            '0xac45520086d645bf10684f1b70e697cadb7660e9',
            '0x54b7c60cc5c71b9724655655d39b28bac629f6c2',
        ]
        seedAmounts = [
            1000,
            100,
        ]
        privateAddrs = [
            '0xac45520086d645bf10684f1b70e697cadb7660e9',
            '0x54b7c60cc5c71b9724655655d39b28bac629f6c2',
        ]
        privateAmounts = [
            2000,
            200,
        ]
    } else if (network === 'testnet') {
        seedAddrs = [
            '0xac45520086d645bf10684f1b70e697cadb7660e9',
            '0x54b7c60cc5c71b9724655655d39b28bac629f6c2',
        ]
        seedAmounts = [
            1000,
            100,
        ]
        privateAddrs = [
            '0xac45520086d645bf10684f1b70e697cadb7660e9',
            '0x54b7c60cc5c71b9724655655d39b28bac629f6c2',
        ]
        privateAmounts = [
            2000,
            200,
        ]
    } else if (network === 'mainnet') {
        seedAddrs = [
        ]
        seedAmounts = [
        ]
        privateAddrs = [
        ]
        privateAmounts = [
        ]
    } else {
        console.log(`Not support deploy at network ${network}`)
        return
    }

    deployer.deploy(
        Presale,
        _abi,
        _devwallet,
        seedAddrs,
        seedAmounts,
        privateAddrs,
        privateAmounts,
    );
};