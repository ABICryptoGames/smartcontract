// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./access/Ownable.sol";
import "./utils/math/SafeMath.sol";
import "./token/ERC20/ERC20.sol";
import "./token/ERC20/utils/SafeERC20.sol";

contract GARToken is Ownable, ERC20 {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     * 
     */
    constructor() ERC20("GAR Token", "GART") {
    }

    /**
     * @dev Set mint new token for address
     * require owner
     */
    function mint(address _to, uint256 _amount) external onlyOwner {
        _mint(_to, _amount);
    }

    /**
     * @dev Burn `amount` token of sender
     */
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    /**
     * @dev Burn `amount` token from `account`
     * require allowance token greater than amount
     */
    function burnFrom(address account, uint256 amount) external {
        require(account != address(0), "burn from 0");

        _approve(account, msg.sender, allowance(account, msg.sender).sub(amount));
        _burn(account, amount);
    }
}
