// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";


contract ABIMarket is OwnableUpgradeable, ReentrancyGuardUpgradeable, ERC1155Holder {
    address public _devwallet;
    mapping(address => bool) public operators; // operator contracts

    struct SaleOrder {
        bytes32 orderId;
        address tokenAddress;
        uint256 tokenId;
        address currency;
        uint256 price;
        address seller;
        uint256 amount;
    }

    mapping(address => bool) public whitelistToken; // token address => bool; token is allow to sale here
    mapping(address => uint256) public tokenStandards; // token address => standard (0 = None, 1 = NF-ERC20, 2 = NFT-ERC721, 3 = MIX-ERC1155)
    mapping(address => uint256) public tokenCommissions; // token address => comission; 2 decimal
    mapping(address => bool) public tokenPublicSale; // token address => bool; user is allowed to sell token here
    mapping(address => bool) public allowCurrencies; // currency allow to use

    mapping(address => mapping(uint256 => mapping(address => uint256))) public tickets; // token address => token id => user address => ticket amount
    mapping(address => mapping(uint256 => uint256)) public ticketRequire; // token address => token id => require amount
    bool public requireTicketFromOwner;

    mapping(bytes32 => SaleOrder) public saleOrdersById; // order id => sale order
    bytes32[] public saleOrderIds; // array of onsell order id
    uint256 public saleOrderIdLength;

    event Sell(
        bytes32 orderId,
        address indexed tokenAddress,
        uint256 indexed tokenId,
        address currency,
        uint256 price,
        address indexed seller,
        uint256 amount
    );
    event Buy(
        bytes32 orderId,
        address indexed tokenAddress,
        uint256 indexed tokenId,
        address currency,
        uint256 price,
        address indexed seller,
        address buyer,
        uint256 amount,
        uint256 pay
    );
    event Cancel(
        bytes32 orderId,
        address indexed tokenAddress,
        uint256 indexed tokenId,
        address currency,
        uint256 price,
        address indexed seller
    );

    function initialize(
        address[] memory tokens,
        uint256[] memory standards,
        uint256[] memory commissions,
        address[] memory currencies,
        address[] memory _ticketTokens,
        uint256[] memory _ticketRequireTokens,
        uint256[] memory _ticketRequireAmounts
    ) external initializer {
        __Ownable_init();
        __ReentrancyGuard_init();

        _devwallet = msg.sender;
        operators[msg.sender] = true;
        requireTicketFromOwner = true;

        for (uint256 i = 0; i < tokens.length; i++) {
            whitelistToken[tokens[i]] = true;
            tokenStandards[tokens[i]] = standards[i];
            tokenCommissions[tokens[i]] = commissions[i];
        }

        for (uint256 i = 0; i < currencies.length; i++) {
            allowCurrencies[currencies[i]] = true;
        }

        for (uint256 i = 0; i < _ticketTokens.length; i++) {
            ticketRequire[_ticketTokens[i]][_ticketRequireTokens[i]] = _ticketRequireAmounts[i];
        }
    }

    function setDevwallet(address addr) external onlyOwner {
        _devwallet = addr;
    }

    function setOperator(address[] memory addrs, bool[] memory isOps) external onlyOwner {
        for (uint256 i = 0; i < addrs.length; i++) {
            operators[addrs[i]] = isOps[i];
        }
    }

    function setAllowedCurrencies(address[] memory addrs, bool[] memory isAllow) external onlyOwner {
        for (uint256 i = 0; i < addrs.length; i++) {
            allowCurrencies[addrs[i]] = isAllow[i];
        }
    }

    function setTicketRequire(
        address[] memory tokenAddrs,
        uint256[] memory tokenIds,
        uint256[] memory amounts
    ) external onlyOwner {
        for (uint256 i = 0; i < tokenAddrs.length; i++) {
            ticketRequire[tokenAddrs[i]][tokenIds[i]] = amounts[i];
        }
    }

    function setTickets(
        address[] memory tokenAddrs,
        uint256[] memory tokenIds,
        address[] memory userAddrs,
        uint256[] memory amounts
    ) external onlyOwner {
        for (uint256 i = 0; i < userAddrs.length; i++) {
            tickets[tokenAddrs[i]][tokenIds[i]][userAddrs[i]] = amounts[i];
        }
    }

    function setRequireTicketFromOwner(bool isRequire) external onlyOwner {
        requireTicketFromOwner = isRequire;
    }

    function setSaleToken(
        address[] memory tokenAddrs,
        bool[] memory isWhitelist,
        uint256[] memory standards,
        uint256[] memory coms,
        bool[] memory isPublicSale
    ) external onlyOwner {
        for (uint256 i = 0; i < tokenAddrs.length; i++) {
            whitelistToken[tokenAddrs[i]] = isWhitelist[i];
            tokenStandards[tokenAddrs[i]] = standards[i];
            tokenCommissions[tokenAddrs[i]] = coms[i];
            tokenPublicSale[tokenAddrs[i]] = isPublicSale[i];
        }
    }

    function increaseTicket(
        address[] memory tokenAddrs,
        uint256[] memory tokenIds,
        address[] memory userAddrs,
        uint256[] memory amounts
    ) external {
        // only operator
        require(operators[msg.sender], "require operator");

        for (uint256 i = 0; i < tokenAddrs.length; i++) {
            tickets[tokenAddrs[i]][tokenIds[i]][userAddrs[i]] += amounts[i];
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

    function sell(
        address tokenAddr,
        uint256 tokenId,
        address currency,
        uint256 price,
        uint256 amount
    ) external nonReentrant {
        _sell(tokenAddr, tokenId, currency, price, amount, msg.sender);
    }

    function ownerSell(
        address tokenAddr,
        uint256 tokenId,
        address currency,
        uint256 price,
        uint256 amount
    ) external nonReentrant {
        require(operators[msg.sender], "require operator");
        _sell(tokenAddr, tokenId, currency, price, amount, owner());
    }

    function _sell(
        address tokenAddr,
        uint256 tokenId,
        address currency,
        uint256 price,
        uint256 amount,
        address seller
    ) internal {
        require(whitelistToken[tokenAddr], "token not in whitelist");
        require(seller == owner() || tokenPublicSale[tokenAddr], "require owner");
        require(allowCurrencies[currency], "currency not allowed");

        if (tokenStandards[tokenAddr] == 1) {
            tokenId = 0;
        }

        if (tokenStandards[tokenAddr] == 2) {
            amount = 1;
        }

        bytes32 orderId = keccak256(
            abi.encodePacked(
                block.timestamp,
                tokenAddr,
                tokenId,
                currency,
                price,
                seller
            )
        );
        SaleOrder memory sale = SaleOrder(
            orderId,
            tokenAddr,
            tokenId,
            currency,
            price,
            seller,
            amount
        );

        _transferToken(tokenAddr, tokenId, seller, address(this), amount);

        saleOrderIds.push(orderId);
        saleOrderIdLength = saleOrderIds.length;
        saleOrdersById[sale.orderId] = sale;

        emit Sell(
            sale.orderId,
            tokenAddr,
            tokenId,
            currency,
            price,
            seller,
            amount
        );
    }

    function buy(bytes32 orderId, uint256 amount, uint256 pay) external nonReentrant {
        _buy(orderId, amount, pay);
    }

    function _buy(bytes32 orderId, uint256 amount, uint256 pay) internal {
        require(orderId != 0, "not saling");

        SaleOrder memory sale = saleOrdersById[orderId];

        if (tokenStandards[sale.tokenAddress] == 2) {
            amount = 1;
        }

        uint256 totalTicketRequire = ticketRequire[sale.tokenAddress][sale.tokenId] * amount;

        if (sale.seller != owner() || !requireTicketFromOwner) {
            totalTicketRequire = 0;
        }

        require(sale.amount > 0 && sale.amount >= amount, "out of sale");
        require(pay >= sale.price * amount, "payment is not enought");
        require(
            totalTicketRequire <= tickets[sale.tokenAddress][sale.tokenId][msg.sender],
            "not enought ticket"
        );

        uint256 commissionAmount = pay * tokenCommissions[sale.tokenAddress] / 100;

        IERC20(sale.currency).transferFrom(msg.sender, sale.seller, pay - commissionAmount);
        IERC20(sale.currency).transferFrom(msg.sender, _devwallet, commissionAmount);

        _transferToken(sale.tokenAddress, sale.tokenId, address(this), msg.sender, amount);
        // _transferToken(sale.tokenAddress, sale.tokenId, sale.seller, msg.sender, amount);

        uint256 remainAmount = sale.amount - amount;

        if (remainAmount == 0) {
            removeOrderId(sale.orderId);

            delete saleOrdersById[sale.orderId];
        } else {
            saleOrdersById[sale.orderId].amount = remainAmount;
        }

        if (totalTicketRequire > 0) {
            tickets[sale.tokenAddress][sale.tokenId][msg.sender] -= totalTicketRequire;
        }

        emit Buy(
            sale.orderId,
            sale.tokenAddress,
            sale.tokenId,
            sale.currency,
            sale.price,
            sale.seller,
            msg.sender,
            amount,
            pay
        );
    }

    function ownerUpdatePrice(bytes32[] memory orderIds, uint256[] memory prices) external nonReentrant  {
        require(operators[msg.sender], "require operator");
        for (uint256 i = 0; i < orderIds.length; i++) {
            saleOrdersById[orderIds[i]].price = prices[i];
            emit Sell(
                orderIds[i],
                saleOrdersById[orderIds[i]].tokenAddress,
                saleOrdersById[orderIds[i]].tokenId,
                saleOrdersById[orderIds[i]].currency,
                saleOrdersById[orderIds[i]].price,
                saleOrdersById[orderIds[i]].seller,
                saleOrdersById[orderIds[i]].amount
            );
        }
    }

    function cancel(bytes32 orderId) external nonReentrant {
        _cancel(orderId);
    }

    function _cancel(bytes32 orderId) internal {
        require(orderId != 0, "not saling");

        SaleOrder memory sale = saleOrdersById[orderId];

        require(sale.amount > 0, "not saling");
        require(sale.seller == msg.sender, "not seller");

        _transferToken(sale.tokenAddress, sale.tokenId, address(this), sale.seller, sale.amount);

        removeOrderId(sale.orderId);

        delete saleOrdersById[sale.orderId];

        emit Cancel(sale.orderId, sale.tokenAddress, sale.tokenId, sale.currency, sale.price, msg.sender);
    }

    function removeOrderId(bytes32 orderId) internal {
        for (uint256 i = 0; i < saleOrderIds.length; i++) {
            if (saleOrderIds[i] == orderId) {
                saleOrderIds[i] = saleOrderIds[saleOrderIds.length - 1];
                saleOrderIds.pop();
                saleOrderIdLength = saleOrderIds.length;

                break;
            }
        }
    }
}
