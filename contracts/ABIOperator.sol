// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

interface IBoxToken {
    function burn(address account, uint256 tokenId, uint256 amount) external;
}

interface IAbiMarket {
    function owner() external returns (address);
    function ownerSell(address tokenAddr, uint256 tokenId, address currency, uint256 price, uint256 amount) external;
}

interface IERC20MintBurnable {
    function mint(address _to, uint256 _amount) external;
    function burnFrom (address account, uint256 amount) external;
}

interface IERC721MintBurnable {
    function mint(address to, uint256 _tokenId) external;
    function burn(uint256 tokenId) external;
}

interface IERC1155MintBurnable {
    function mint(address account, uint256 tokenId, uint256 amount) external;
    function mintBatch(address account, uint256[] memory tokenIds, uint256[] memory amounts) external;
    function burn(address account, uint256 tokenId, uint256 amount) external;
    function burnBatch(address account, uint256[] memory tokenIds, uint256[] memory amounts) external;
}

/**
 * Operator to tracking method is call from our services
 */
contract ABIOperator is OwnableUpgradeable, ReentrancyGuardUpgradeable, ERC1155Holder {
    address public devwallet;
    address public busd;
    address public abit;
    address public gart;
    address public boxt;
    address public stone;

    mapping(address => bool) public depositeds;

    mapping(address => uint256) public tokenStandards; // token address => standard (0 = None, 1 = NF-ERC20, 2 = NFT-ERC721, 3 = MIX-ERC1155)

    event DepositPublicSale(address indexed from, uint256 amount);
    event SendClaim(address indexed tokenAddress, uint256 indexed tokenId, address[] froms, address[] tos, uint256[] amounts);
    event SendSwap(address indexed tokenAddress, uint256 indexed tokenId, address[] froms, address[] tos, uint256[] amounts);
    event BurnSwap(address indexed tokenAddress, address from, uint256 amount);
    event TransferSwap(address indexed tokenAddress, address from, uint256 amount);
    event OpenBox(address indexed tokenAddress, uint256 tokenId, address user, uint256 amount);

    function initialize(
        address _devwallet,
        address _busd,
        address _abit,
        address _gart,
        address _boxt,
        address _stone
    ) external initializer {
        __Ownable_init();
        __ReentrancyGuard_init();

        devwallet = _devwallet;
        busd = _busd;
        abit = _abit;
        gart = _gart;
        boxt = _boxt;
        stone = _stone;
    }

    function depositPublicSale(uint256 amount) external nonReentrant {
        require(!depositeds[msg.sender], "Already deposit");
        IERC20(busd).transferFrom(msg.sender, devwallet, amount);
        depositeds[msg.sender] = true;
        emit DepositPublicSale(msg.sender, amount);
    }

    function openGARBox(uint256 tokenId) external nonReentrant {
        IBoxToken box = IBoxToken(boxt);
        box.burn(msg.sender, tokenId, 1);
        emit OpenBox(boxt, tokenId, msg.sender, 1);
    }

    function setDevwallet(address addr) external onlyOwner {
        devwallet = addr;
    }

    function setBusd(address addr) external onlyOwner {
        busd = addr;
    }

    function setAbit(address addr) external onlyOwner {
        abit = addr;
    }

    function setGart(address addr) external onlyOwner {
        gart = addr;
    }

    function setBoxt(address addr) external onlyOwner {
        boxt = addr;
    }

    function setStone(address addr) external onlyOwner {
        stone = addr;
    }

    function manyShipMint(address ship, address market, uint256[] memory shipIds) external onlyOwner {
        IAbiMarket marketContract = IAbiMarket(market);
        address marketOwner = marketContract.owner();
        IERC721MintBurnable shipTokenContract = IERC721MintBurnable(ship);

        for (uint256 i = 0; i < shipIds.length; i++) {
            shipTokenContract.mint(marketOwner, shipIds[i]);
        }
    }

    function manyShipSale(address ship, address market, uint256[] memory shipIds, uint256[] memory prices) external onlyOwner {
        IAbiMarket marketContract = IAbiMarket(market);

        for (uint256 i = 0; i < shipIds.length; i++) {
            marketContract.ownerSell(ship, shipIds[i], abit, prices[i], 1);
        }
    }

    function setTokenStandards(address[] memory tokens, uint256[] memory standards) external onlyOwner {
        for (uint256 i = 0; i < tokens.length; i++) {
            tokenStandards[tokens[i]] = standards[i];
        }
    }

    function _transferToken(address tokenAddr, uint256 tokenId, address from, address to, uint256 amount) internal {
        if (tokenStandards[tokenAddr] == 1) {
            IERC20(tokenAddr).transferFrom(from, to, amount);
        } else if (tokenStandards[tokenAddr] == 2) {
            IERC721(tokenAddr).transferFrom(from, to, tokenId);
        } else if (tokenStandards[tokenAddr] == 3) {
            IERC1155(tokenAddr).safeTransferFrom(from, to, tokenId, amount, "");
        } else {
            revert("no token standard");
        }
    }

    function _burnToken(address tokenAddr, uint256 tokenId, address from, uint256 amount) internal {
        if (tokenStandards[tokenAddr] == 1) {
            IERC20MintBurnable(tokenAddr).burnFrom(from, amount);
        } else if (tokenStandards[tokenAddr] == 2) {
            IERC721MintBurnable(tokenAddr).burn(tokenId);
        } else if (tokenStandards[tokenAddr] == 3) {
            IERC1155MintBurnable(tokenAddr).burn(from, tokenId, amount);
        } else {
            revert("no token standard");
        }
    }

    function sendToken(
        address tokenAddress,
        uint256 tokenId,
        address[] memory froms,
        address[] memory tos,
        uint256[] memory amounts
    ) external onlyOwner {
        for (uint256 i = 0; i < froms.length; i++) {
            _transferToken(tokenAddress, tokenId, froms[i], tos[i], amounts[i]);
        }
    }

    function sendClaimToken(
        address tokenAddress,
        uint256 tokenId,
        address[] memory froms,
        address[] memory tos,
        uint256[] memory amounts
    ) external onlyOwner {
        for (uint256 i = 0; i < froms.length; i++) {
            _transferToken(tokenAddress, tokenId, froms[i], tos[i], amounts[i]);
        }
        emit SendClaim(tokenAddress, tokenId, froms, tos, amounts);
    }

    function sendSwapToken(
        address tokenAddress,
        uint256 tokenId,
        address[] memory froms,
        address[] memory tos,
        uint256[] memory amounts
    ) external onlyOwner {
        for (uint256 i = 0; i < froms.length; i++) {
            _transferToken(tokenAddress, tokenId, froms[i], tos[i], amounts[i]);
        }
        emit SendSwap(tokenAddress, tokenId, froms, tos, amounts);
    }

    function burnTokenToSwap(address tokenAddress, uint256 tokenId, uint256 amount) external nonReentrant {
        _burnToken(tokenAddress, tokenId, msg.sender, amount);
        emit BurnSwap(tokenAddress, msg.sender, amount);
    }

    function transferTokenToSwap(address tokenAddress, uint256 tokenId, uint256 amount) external nonReentrant {
        _transferToken(tokenAddress, tokenId, msg.sender, devwallet, amount);
        emit TransferSwap(tokenAddress, msg.sender, amount);
    }
}
