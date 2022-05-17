// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./access/Ownable.sol";
import "./token/ERC20/ERC20.sol";
import "./token/BEP20/BEP20.sol";


contract ABIToken is BEP20 {

    address public presalePool;     // token for seed and private sale
    address public publicsalePool;  // token for public sale
    address public stakingPool;     // token use for staking, framing
    address public playPool;        // token use for game play
    address public coreteamPool;    // token for core team
    address public partnerPool;     // token will distribute for partner
    address public marketingPool;   // token for maketing and comunity
    address public advisorPool;     // token will distribute for advisor
    address public dexPool;         // token use for DEXliquidity

    address public operator; // operator addres, use for mint via bridge

    modifier onlyOperator() {
        require(msg.sender == operator);
        _;
    }

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     * 
     * name = "ABI", symbol = "ABI"
     */
    constructor() BEP20("ABI", "ABI") {
        // set init pool to deploy address
        // todo: change to product address

        presalePool     = msg.sender;
        publicsalePool  = msg.sender;
        stakingPool     = msg.sender;
        playPool        = msg.sender;
        coreteamPool    = msg.sender;
        partnerPool     = msg.sender;
        marketingPool   = msg.sender;
        advisorPool     = msg.sender;
        dexPool         = msg.sender;

        BEP20._mint(presalePool,    130 * 10**24);  // 130,000,000  -   13%
        BEP20._mint(publicsalePool, 15  * 10**24);  // 15,000,000   -   1.5%
        BEP20._mint(stakingPool,    200 * 10**24);  // 200,000,000  -   20%
        BEP20._mint(playPool,       210 * 10**24);  // 210,000,000  -   21%
        BEP20._mint(coreteamPool,   200 * 10**24);  // 200,000,000  -   20%
        BEP20._mint(partnerPool,    75  * 10**24);  // 75,000,000   -   7.5%
        BEP20._mint(marketingPool,  100 * 10**24);  // 100,000,000  -   10%
        BEP20._mint(advisorPool,    20  * 10**24);  // 20,000,000   -   2%
        BEP20._mint(dexPool,        50  * 10**24);  // 50,000,000   -   5%
    }

    function setpresalePool(address addr) external onlyOwner {
        require(addr != address(0), "can not set to address 0");
        presalePool = addr;
    }

    function setpublicsalePool(address addr) external onlyOwner {
        require(addr != address(0), "can not set to address 0");
        publicsalePool = addr;
    }

    function setstakingPool(address addr) external onlyOwner {
        require(addr != address(0), "can not set to address 0");
        stakingPool = addr;
    }

    function setplayPool(address addr) external onlyOwner {
        require(addr != address(0), "can not set to address 0");
        playPool = addr;
    }

    function setcoreteamPool(address addr) external onlyOwner {
        require(addr != address(0), "can not set to address 0");
        coreteamPool = addr;
    }

    function setpartnerPool(address addr) external onlyOwner {
        require(addr != address(0), "can not set to address 0");
        partnerPool = addr;
    }

    function setmarketingPool(address addr) external onlyOwner {
        require(addr != address(0), "can not set to address 0");
        marketingPool = addr;
    }

    function setadvisorPool(address addr) external onlyOwner {
        require(addr != address(0), "can not set to address 0");
        advisorPool = addr;
    }

    function setdexPool(address addr) external onlyOwner {
        require(addr != address(0), "can not set to address 0");
        dexPool = addr;
    }

    function mint(address account, uint256 amount) external onlyOperator {
        _mint(account, amount);
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    function burnFrom(address account, uint256 amount) external {
        require(account != address(0), "burn from 0");

        _approve(account, msg.sender, allowance(account, msg.sender) - amount);
        _burn(account, amount);
    }
}
