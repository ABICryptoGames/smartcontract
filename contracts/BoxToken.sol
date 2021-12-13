// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./access/Ownable.sol";
import "./token/ERC1155/extensions/ERC1155Supply.sol";
import "./utils/Strings.sol";


contract BoxToken is Ownable, ERC1155Supply {
    using Strings for uint256;

    string private _baseURI;
    address private _operator; // controlling game logic

    constructor() ERC1155("") {
        // init base uri
        // todo: change to actual url
        _baseURI = "/";

        _operator = msg.sender;
    }

    modifier onlyOperator() {
        require(msg.sender == _operator, "Caller is not operator");
        _;
    }

    function name() public pure returns (string memory) {
        return "BoxToken";
    }

    function symbol() public pure returns (string memory) {
        return "BXT";
    }

    function setOperator(address addr) external onlyOwner {
        _operator = addr;
    }

    function setBaseURI(string memory uri) external onlyOwner {
        _baseURI = uri;
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {
        return string(abi.encodePacked(_baseURI, tokenId.toString()));
    }

    /**
     * @dev mint `amount` of token from its `typeId` and `slot` to `account`
     * require operator contract
     */
    function mint(
        address account,
        uint256 tokenId,
        uint256 amount
    ) external onlyOperator {
        _mint(account, tokenId, amount, "");
    }

    /**
     * @dev mint batch of `tokenIds` with its `amounts` to `account`
     * require operator contract
     */
    function mintBatch(
        address account,
        uint256[] memory tokenIds,
        uint256[] memory amounts
    ) external onlyOperator {
        _mintBatch(account, tokenIds, amounts, "");
    }

    /**
     * @dev burn `amount` of token from its `typeId` and `slot` from `account`
     * require operator contract
     */
    function burn(
        address account,
        uint256 tokenId,
        uint256 amount
    ) external onlyOperator {
        _burn(account, tokenId, amount);
    }

    /**
     * @dev burn batch of `tokenIds` with its `amounts` to `account`
     * require operator contract
     */
    function burnBatch(
        address account,
        uint256[] memory tokenIds,
        uint256[] memory amounts
    ) external onlyOperator {
        _burnBatch(account, tokenIds, amounts);
    }
}