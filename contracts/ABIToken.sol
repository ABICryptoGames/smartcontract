// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./access/Ownable.sol";
import "./utils/math/SafeMath.sol";
import "./token/ERC20/ERC20.sol";
import "./token/ERC20/utils/SafeERC20.sol";


contract ABIToken is Ownable, ERC20 {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public mainwallet; // keep not distribute token
    address public devwallet; // keep token use for game play
    address public partnerwallet; // keep token will distribute for partner
    address public miningwallet; // keep token use for staking, framing
    address public eventwallet; // keep token for event game

    uint256 public constant MINT_INTERVAL = 365 days; // time interval from each mint
    uint256 public immutable MINT_START; // time start when mint action is allowed

    uint256 public lastMint; // time of the lastest mint
    uint256 public constant MINT_AMOUNT = 50 * 10**24; // 50,000,000

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     * 
     * name = "ABI Token", symbol = "ABIT"
     */
    constructor() ERC20("ABI Token", "ABIT") {
        // set init wallet to deploy address
        // todo: change to real address

        mainwallet = msg.sender;
        ERC20._mint(mainwallet, 270 * 10**24); // 270,000,000

        devwallet = msg.sender;
        ERC20._mint(devwallet, 210 * 10**24); // 210,000,000

        partnerwallet = msg.sender;
        ERC20._mint(partnerwallet, 220 * 10**24); // 220,000,000

        miningwallet = msg.sender;
        ERC20._mint(miningwallet, 200 * 10**24); // 200,000,000

        eventwallet = msg.sender;
        ERC20._mint(eventwallet, 100 * 10*24); // 100,000,000

        MINT_START = block.timestamp.add(5 * 365 days); // 5 years after deployed
    }

    /**
     * @dev Set mainwallet
     * require owner
     */
    function setMainwallet(address addr) external onlyOwner {
        if (mainwallet != address(0) && balanceOf(mainwallet) > 0) {
            ERC20._transfer(mainwallet, addr, balanceOf(mainwallet));
        }
        mainwallet = addr;
    }

    /**
     * @dev Set devwallet
     * require owner
     */
    function setDevwallet(address addr) external onlyOwner {
        if (devwallet != address(0) && balanceOf(devwallet) > 0) {
            ERC20._transfer(devwallet, addr, balanceOf(devwallet));
        }
        devwallet = addr;
    }

    /**
     * @dev Set partnerwallet
     * require owner
     */
    function setPartnerwallet(address addr) external onlyOwner {
        if (partnerwallet != address(0) && balanceOf(partnerwallet) > 0) {
            ERC20._transfer(partnerwallet, addr, balanceOf(partnerwallet));
        }
        partnerwallet = addr;
    }

    /**
     * @dev Set miningwallet
     * require owner
     */
    function setMiningwallet(address addr) external onlyOwner {
        if (miningwallet != address(0) && balanceOf(miningwallet) > 0) {
            ERC20._transfer(miningwallet, addr, balanceOf(miningwallet));
        }
        miningwallet = addr;
    }

    /**
     * @dev Set eventwallet
     * require owner
     */
    function setEventwallet(address addr) external onlyOwner {
        if (eventwallet != address(0) && balanceOf(eventwallet) > 0) {
            ERC20._transfer(eventwallet, addr, balanceOf(eventwallet));
        }
        eventwallet = addr;
    }
}
