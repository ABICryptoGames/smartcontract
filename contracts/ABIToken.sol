// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./access/Ownable.sol";
import "./utils/math/SafeMath.sol";
import "./token/ERC20/ERC20.sol";
import "./token/ERC20/utils/SafeERC20.sol";


contract ABIToken is Ownable, ERC20 {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public mainPool; // keep not distribute token
    address public playPool; // keep token use for game play
    address public partnerPool; // keep token will distribute for partner
    address public miningPool; // keep token use for staking, framing
    address public marketingPool; // keep token for maketing and comunity

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     * 
     * name = "ABI", symbol = "ABI"
     */
    constructor() ERC20("ABI", "ABI") {
        // set init pool to deploy address
        // todo: change to product address

        mainPool = msg.sender;
        ERC20._mint(mainPool, 415 * 10**24); // 415,000,000 - 41.5%

        playPool = msg.sender;
        ERC20._mint(playPool, 210 * 10**24); // 210,000,000 - 21%

        partnerPool = msg.sender;
        ERC20._mint(partnerPool, 75 * 10**24); // 75,000,000 - 7.5%

        miningPool = msg.sender;
        ERC20._mint(miningPool, 200 * 10**24); // 200,000,000 - 20%

        marketingPool = msg.sender;
        ERC20._mint(marketingPool, 100 * 10*24); // 100,000,000 - 10%
    }

    /**
     * @dev Set mainPool
     * require owner
     */
    function setMainPool(address addr) external onlyOwner {
        if (mainPool != address(0) && balanceOf(mainPool) > 0) {
            ERC20._transfer(mainPool, addr, balanceOf(mainPool));
        }
        mainPool = addr;
    }

    /**
     * @dev Set playPool
     * require owner
     */
    function setPlayPool(address addr) external onlyOwner {
        playPool = addr;
    }

    /**
     * @dev Set partnerPool
     * require owner
     */
    function setPartnerPool(address addr) external onlyOwner {
        partnerPool = addr;
    }

    /**
     * @dev Set miningPool
     * require owner
     */
    function setMiningPool(address addr) external onlyOwner {
        miningPool = addr;
    }

    /**
     * @dev Set marketingPool
     * require owner
     */
    function setMarketingPool(address addr) external onlyOwner {
        marketingPool = addr;
    }
}
