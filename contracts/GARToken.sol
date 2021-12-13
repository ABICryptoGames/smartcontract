// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./access/Ownable.sol";
import "./token/ERC20/ERC20.sol";


contract GARToken is Ownable, ERC20 {
    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     * 
     * name = "Galaxy Attack Revolution", symbol = "GAR"
     */
    constructor() ERC20("Galaxy Attack Revolution", "GAR") {
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

        _approve(account, msg.sender, allowance(account, msg.sender) - amount);
        _burn(account, amount);
    }
}
