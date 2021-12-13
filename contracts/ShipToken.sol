// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./access/Ownable.sol";
import "./token/ERC721/extensions/ERC721Enumerable.sol";
import "./utils/Strings.sol";


contract ShipToken is Ownable, ERC721Enumerable {
    using Strings for uint256;

    string public _baseTokenURI; // base url for gen token uri
    address public _operator; // operator for controlling game logic

    constructor() ERC721("ShipToken", "GARS") {
        // init base uri
        // todo: change to product url
        _baseTokenURI = "";

        // todo: change to product operator
        _operator = msg.sender;
    }

    modifier onlyOperator {
        require(msg.sender == _operator, "ShipToken: Caller is not operator");
        _;
    }

    function setOperator(address addr) external onlyOwner {
        _operator = addr;
    }

    function setBaseURI(string memory uri) external onlyOwner {
        _baseTokenURI = uri;
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    /**
     * @dev mint `tokenId` to address
     * require operator
     */
    function mint(address to, uint256 _tokenId) external onlyOperator {
        _mint(to, _tokenId);
    }

    /**
     * @dev get uri of `tokenId`
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(ERC721._exists(tokenId), "URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return string(abi.encodePacked(baseURI, tokenId.toString()));
    }

    /**
     * @dev get allTokenOf sender
     */
    function allTokenOf() public view returns (uint256[] memory) {
        return allTokenOf(msg.sender);
    }

    /**
     * @dev get list token owned by address
     */
    function allTokenOf(address addr) public view returns (uint256[] memory) {
        uint256 numOfTokens = balanceOf(addr);
        uint256[] memory tokens = new uint256[](numOfTokens);

        for (uint256 i = 0; i < numOfTokens; i++) {
            tokens[i] = ERC721Enumerable.tokenOfOwnerByIndex(addr, i);
        }

        return tokens;
    }
}
