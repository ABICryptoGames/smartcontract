// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";


contract MarketProxy is TransparentUpgradeableProxy {
    constructor (
        address _logic,
        address _admin,
        bytes memory data
    ) TransparentUpgradeableProxy(_logic, _admin, data) {

    }
}