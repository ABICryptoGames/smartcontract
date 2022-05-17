// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * test token for replace busd
 */
contract TTToken is Ownable, ERC20 {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     * 
     */
    constructor() ERC20("Test Token", "TTToken") {
        ERC20._mint(msg.sender, 25 * 10**24);
    }

    function mint(address _to, uint256 _amount) external onlyOwner {
        _mint(_to, _amount);
    }

    function burnFrom(address account, uint256 amount) external onlyOwner {
        require(account != address(0), "burn from 0");
        _burn(account, amount);
    }
}
