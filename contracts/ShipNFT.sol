// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./access/Ownable.sol";
import "./token/ERC721/extensions/ERC721Enumerable.sol";
import "./utils/Strings.sol";


contract ShipNFT is Ownable, ERC721Enumerable {
    using Strings for uint256;

    string public _baseTokenURI; // base url for gen token uri
    address private _operator; // operator for controlling game logic

    constructor() ERC721("ShipNFT", "GARS") {
        // init base uri
        // todo: change to product url
        _baseTokenURI = "";

        _operator = msg.sender;
    }

    modifier onlyOperator {
        require(msg.sender == _operator, "ShipNFT: Caller is not operator");
        _;
    }

    function setOperator(address addr) public onlyOwner {
        _operator = addr;
    }

    function setBaseURI(string memory uri) public onlyOwner {
        _baseTokenURI = uri;
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    function mint(address to, uint256 _tokenId) public onlyOperator {
        _mint(to, _tokenId);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(ERC721._exists(tokenId), "URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return string(abi.encodePacked(baseURI, tokenId.toString()));
    }

    function allTokenOf() public view returns (uint256[] memory) {
        return allTokenOf(msg.sender);
    }

    function allTokenOf(address addr) public view returns (uint256[] memory) {
        uint256 numOfTokens = balanceOf(addr);
        uint256[] memory tokens = new uint256[](numOfTokens);

        for (uint256 i = 0; i < numOfTokens; i++) {
            tokens[i] = ERC721Enumerable.tokenOfOwnerByIndex(addr, i);
        }

        return tokens;
    }
}
