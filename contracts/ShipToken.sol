// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./access/Ownable.sol";
import "./token/ERC721/IERC721.sol";
import "./token/ERC721/extensions/ERC721Enumerable.sol";
import "./utils/Strings.sol";


contract ShipToken is Ownable, IERC721, ERC721Enumerable {
    using Strings for uint256;

    string public _baseTokenURI; // base url for gen token uri
    mapping(address => bool) public operators; // operator for mint and transfer

    constructor() ERC721("ShipToken", "GARS") {
        // init base uri
        // todo: change to product url
        _baseTokenURI = "";

        // todo: change to product operator
        operators[msg.sender] = true;
    }

    modifier onlyOperator {
        require(operators[msg.sender], "ShipToken: Caller is not operator");
        _;
    }

    function setOperator(address addr, bool isOperator) external onlyOwner {
        operators[addr] = isOperator;
    }

    function setBaseURI(string memory uri) external onlyOwner {
        _baseTokenURI = uri;
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    /**
     * @dev See {IERC721-transferFrom}.
     * only operator can do transfer.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override(IERC721, ERC721) onlyOperator {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override(IERC721, ERC721) onlyOperator {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public override(IERC721, ERC721) onlyOperator {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev mint `tokenId` to address
     * require operator
     */
    function mint(address to, uint256 _tokenId) external onlyOperator {
        _mint(to, _tokenId);
    }

    function burn(uint256 tokenId) external {
        address owner = ERC721.ownerOf(tokenId);
        require(
            msg.sender == owner
                || msg.sender == ERC721.getApproved(tokenId)
                || ERC721.isApprovedForAll(owner, msg.sender),
            "ShipToken: Require owner or approval of token"
        );

        _burn(tokenId);
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
