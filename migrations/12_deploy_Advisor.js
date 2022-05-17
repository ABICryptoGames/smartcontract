const AdvisorClaim = artifacts.require("AdvisorClaim");
const ABIToken = artifacts.require("ABIToken");

module.exports = function(deployer, network, accounts) {
    return
    let _abi, _devwallet, addrs, amounts
    _abi = ABIToken.address
    _devwallet = accounts[0]

    if (network === 'development' || network === 'local') {
        addrs = [
            '0xac45520086d645bf10684f1b70e697cadb7660e9',
            '0x54b7c60cc5c71b9724655655d39b28bac629f6c2',
        ]
        amounts = [
            3000,
            300,
        ]
    } else if (network === 'testnet') {
        addrs = [
            '0xac45520086d645bf10684f1b70e697cadb7660e9',
            '0x54b7c60cc5c71b9724655655d39b28bac629f6c2',
        ]
        amounts = [
            3000,
            300,
        ]
    } else if (network === 'mainnet') {
        addrs = [
        ]
        amounts = [
        ]
    } else {
        console.log(`Not support deploy at network ${network}`)
        return
    }

    deployer.deploy(
        AdvisorClaim,
        _abi,
        _devwallet,
        addrs,
        amounts,
    );
}
