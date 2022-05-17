// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

abstract contract VestingCore is Ownable {
    IERC20 private abiContract;
    address public devwallet; // wallet of pool keep distribute token

    uint256 public publicSaleTimestamp = 1633159800; // 14h30 02/10/2021 todo: change to actual public sale time
    uint256 public tgeTimestamp = 1633159800; // 14h30 02/10/2021 todo: change to actual tge time

    uint256 public ratioDecimal = 2; // 10**2

    event Claim(address indexed user, uint256 balance); // emit each time user claim success

    constructor (address _abi, address _devwallet) {
        abiContract = IERC20(_abi);
        devwallet = _devwallet;
    }

    function setDevwallet(address addr) external onlyOwner {
        devwallet = addr;
    }

    function setABIAddress(address addr) external onlyOwner {
        abiContract = IERC20(addr);
    }

    function getABIAddress() external view returns (address) {
        return address(abiContract);
    }

    function setPublicSaleTimestamp(uint256 timestamp) external onlyOwner {
        publicSaleTimestamp = timestamp;
    }

    function setTgeTimestamp(uint256 timestamp) external onlyOwner {
        tgeTimestamp = timestamp;
    }

    function onVesting() public view returns (bool) {
        uint256 checktime = tgeTimestamp > publicSaleTimestamp ? tgeTimestamp : publicSaleTimestamp;
        return block.timestamp > checktime;
    }

    function getEndTimestamp(
        uint256 _cliffEndTimestamp,
        uint256 _vestingFinishTimestamp,
        uint256 _tgeCliffEndTimestamp,
        uint256 _tgeVestingFinishTimestamp
    ) public view returns (
        uint256 cliffEndTimestamp,
        uint256 vestingFinishTimestamp
    ) {
        cliffEndTimestamp = _cliffEndTimestamp;
        vestingFinishTimestamp = _vestingFinishTimestamp;

        if (tgeTimestamp > publicSaleTimestamp) {
            cliffEndTimestamp = _tgeCliffEndTimestamp;
            vestingFinishTimestamp = _tgeVestingFinishTimestamp;
        }
    }

    function _claimAvailable(
        uint256 whitelistAmount,
        uint256 claimedAmount,
        uint256 listingAmount,
        uint256 cliffEndTimestamp,
        uint256 vestingFinishTimestamp,
        uint256 vestingLoopTime,
        uint256 vestingTotalLoop,
        uint256 claimRatio
    ) internal view returns (
        uint256
    ) {
        if (!onVesting()) {
            return 0;
        }

        if (block.timestamp >= vestingFinishTimestamp) {
            return whitelistAmount - claimedAmount;

        } else if (block.timestamp >= cliffEndTimestamp) {
            uint256 claimLoop = (block.timestamp - cliffEndTimestamp) / vestingLoopTime;

            if (claimLoop == 0) return 0;

            if (claimLoop < vestingTotalLoop) {
                return whitelistAmount
                       * claimRatio
                       / vestingTotalLoop
                       / (10**ratioDecimal)
                       * claimLoop
                       + listingAmount
                       - claimedAmount;
            } else {
                return whitelistAmount - claimedAmount;
            }

        } else {
            return listingAmount - claimedAmount;
        }
    }

    function _claim(
        uint256 amount,
        uint256 whitelistAmount,
        uint256 claimedAmount,
        uint256 listingAmount,
        uint256 cliffEndTimestamp,
        uint256 vestingFinishTimestamp,
        uint256 vestingLoopTime,
        uint256 vestingTotalLoop,
        uint256 claimRatio
    ) internal returns (
        uint256
    ) {
        require(block.timestamp > publicSaleTimestamp, "public sale not start");

        uint256 availableAmount = _claimAvailable(
            whitelistAmount,
            claimedAmount,
            listingAmount,
            cliffEndTimestamp,
            vestingFinishTimestamp,
            vestingLoopTime,
            vestingTotalLoop,
            claimRatio
        );

        require(availableAmount > 0, "no token to claim");
        require(amount <= availableAmount, "claim amount exceed avalable");

        abiContract.transferFrom(devwallet, msg.sender, amount);

        emit Claim(msg.sender, amount);
        return amount;
    }

    
    function _nextTimeClaim(
        uint256 cliffEndTimestamp,
        uint256 vestingFinishTimestamp,
        uint256 vestingLoopTime
    ) internal view returns (
        uint256
    ) {
        uint256 timenow = block.timestamp;
        uint256 nextClaimTimestamp = 0;

        if (!onVesting()) {
            nextClaimTimestamp = publicSaleTimestamp;

        } else if (timenow >= vestingFinishTimestamp) {
            nextClaimTimestamp = vestingFinishTimestamp;

        } else if (timenow <= cliffEndTimestamp) {
            nextClaimTimestamp = cliffEndTimestamp + vestingLoopTime;

        } else {
            uint256 nextInterval = (timenow - cliffEndTimestamp + vestingLoopTime) / vestingLoopTime;
            nextClaimTimestamp = nextInterval * vestingLoopTime + cliffEndTimestamp;
        }

        return nextClaimTimestamp;
    }
}
