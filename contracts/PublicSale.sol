// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./core/VestingCore.sol";

contract PublicSale is VestingCore {
    uint256 public onListingAvailableRatio = 25;
    uint256 public cliffTime = 0 days;
    uint256 public vestingTime = 360 days;
    uint256 public vestingLoopTime = 30 days;
    uint256 public vestingAvailableRatio = 25;

    mapping(address => uint256) public whitelist;
    mapping(address => uint256) public claimed;

    constructor (
        address _abi,
        address _devwallet, 
        address[] memory addrs,
        uint256[] memory amounts
    ) VestingCore(_abi, _devwallet) {
        // set whitelist
        setWhitelist(addrs, amounts);
    }

    function setOnListingAvailableRatio(uint256 ratio) external onlyOwner {
        onListingAvailableRatio = ratio;
    }

    function setCliffTime(uint256 time) external onlyOwner {
        cliffTime = time;
    }

    function setVestingTime(uint256 time) external onlyOwner {
        vestingTime = time;
    }

    function setVestingLoopTime(uint256 time) external onlyOwner {
        vestingLoopTime = time;
    }

    function setVestingAvailableRatio(uint256 ratio) external onlyOwner {
        vestingAvailableRatio = ratio;
    }

    function setWhitelist(address[] memory addrs, uint256[] memory amounts) public onlyOwner {
        for (uint8 i = 0; i < addrs.length; i++) {
            whitelist[addrs[i]] = amounts[i];
        }
    }

    function getEndTimestamp() public view returns (
        uint256 cliffEndTimestamp,
        uint256 vestingFinishTimestamp
    ) {
        return getEndTimestamp(
            publicSaleTimestamp + cliffTime,                // _cliffEndTimestamp
            publicSaleTimestamp + cliffTime + vestingTime,  // _vestingFinishTimestamp
            tgeTimestamp + cliffTime,                       // _tgeCliffEndTimestamp
            tgeTimestamp + cliffTime + vestingTime          // _tgeVestingFinishTimestamp
        );
    }

    function claimAvailable() external view returns (uint256) {
        return claimAvailable(msg.sender);
    }

    function claimAvailable(address addr) public view returns (uint256) {
        (uint256 cliffEndTimestamp, uint256 vestingFinishTimestamp) = getEndTimestamp();

        return _claimAvailable(
            whitelist[addr],                                                // whitelistAmount
            claimed[addr],                                                  // claimedAmount
            whitelist[addr] * onListingAvailableRatio / 10**ratioDecimal,   // listingAmount
            cliffEndTimestamp,                                              // cliffEndTimestamp
            vestingFinishTimestamp,                                         // vestingFinishTimestamp
            vestingLoopTime,                                                // vestingLoopTime
            vestingTime / vestingLoopTime,                                  // vestingTotalLoop
            vestingAvailableRatio                                           // claimRatio
        );
    }

    function claim(uint256 amount) external {
        (uint256 cliffEndTimestamp, uint256 vestingFinishTimestamp) = getEndTimestamp();

        uint256 claimedAmount = _claim(
            amount,                                                             // amount
            whitelist[msg.sender],                                              // whitelistAmount
            claimed[msg.sender],                                                // claimedAmount
            whitelist[msg.sender] * onListingAvailableRatio / 10**ratioDecimal, // listingAmount
            cliffEndTimestamp,                                                  // cliffEndTimestamp
            vestingFinishTimestamp,                                             // vestingFinishTimestamp
            vestingLoopTime,                                                    // vestingLoopTime
            vestingTime / vestingLoopTime,                                      // vestingTotalLoop
            vestingAvailableRatio                                               // claimRatio
        );

        claimed[msg.sender] = claimed[msg.sender] + claimedAmount;
    }

    function nextTimeClaim() external view returns (uint256) {
        (uint256 cliffEndTimestamp, uint256 vestingFinishTimestamp) = getEndTimestamp();

        return _nextTimeClaim(
            cliffEndTimestamp,      // cliffEndTimestamp
            vestingFinishTimestamp, // vestingFinishTimestamp
            vestingLoopTime         // vestingLoopTime
        );
    }

    function testBlockTime() external view returns (uint256) {
        return block.timestamp;
    }

    function testTotalRatio() external view returns (uint256) {
        return 10**ratioDecimal;
    }
}
