// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./core/VestingCore.sol";

contract Presale is VestingCore {

    /**
     * seed storage
     */

    uint256 public seedOnListingAvailableRatio = 5;
    uint256 public seedCliffTime = 180 days;
    uint256 public seedVestingTime = 360 days;
    uint256 public seedVestingLoopTime = 30 days;

    mapping(address => uint256) public seedWhitelist;
    mapping(address => uint256) public seedClaimed;

    /**
     * private storage
     */

    uint256 public privateOnListingAvailableRatio = 10;
    uint256 public privateCliffTime = 180 days;
    uint256 public privateVestingTime = 36 days;
    uint256 public privateVestingLoopTime = 30 days;

    mapping(address => uint256) public privateWhitelist;
    mapping(address => uint256) public privateClaimed;

    /**
     * constructor make init abi address, devwallet addres and whitelist data
     * VestingCore(_abi, _devwallet)
     * array of seed address and array of seed amount, those length must be matched
     * array of private address and array of amount, those length must be matched
     */
    constructor (
        address _abi,
        address _devwallet, 
        address[] memory seedAddrs,
        uint256[] memory seedAmounts,
        address[] memory privateAddrs,
        uint256[] memory privateAmounts
    ) VestingCore(_abi, _devwallet) {
        // set whitelist
        setSeedWhitelist(seedAddrs, seedAmounts);
        setPrivateWhitelist(privateAddrs, privateAmounts);
    }

    /**
     * seed function
     */

    function setSeedOnListingAvailableRatio(uint256 ratio) external onlyOwner {
        seedOnListingAvailableRatio = ratio;
    }

    function setSeedCliffTime(uint256 time) external onlyOwner {
        seedCliffTime = time;
    }

    function setSeedVestingTime(uint256 time) external onlyOwner {
        seedVestingTime = time;
    }

    function setSeedVestingLoopTime(uint256 time) external onlyOwner {
        seedVestingLoopTime = time;
    }

    function setSeedWhitelist(address[] memory addrs, uint256[] memory amounts) public onlyOwner {
        for (uint8 i = 0; i < addrs.length; i++) {
            seedWhitelist[addrs[i]] = amounts[i];
        }
    }

    function getSeedEndTimestamp() public view returns (uint256 cliffEndTimestamp, uint256 vestingFinishTimestamp) {
        return getEndTimestamp(
            publicSaleTimestamp + seedCliffTime,                    // _cliffEndTimestamp
            publicSaleTimestamp + seedCliffTime + seedVestingTime,  // _vestingFinishTimestamp
            tgeTimestamp + seedCliffTime,                           // _tgeCliffEndTimestamp
            tgeTimestamp + seedCliffTime + seedVestingTime          // _tgeVestingFinishTimestamp
        );
    }

    function seedClaimAvailable() external view returns (uint256) {
        return seedClaimAvailable(msg.sender);
    }

    function seedClaimAvailable(address addr) public view returns (uint256) {
        (uint256 cliffEndTimestamp, uint256 vestingFinishTimestamp) = getSeedEndTimestamp();

        return _claimAvailable(
            seedWhitelist[addr],                                                    // whitelistAmount
            seedClaimed[addr],                                                      // claimedAmount
            seedWhitelist[addr] * seedOnListingAvailableRatio / 10**ratioDecimal,   // listingAmount
            cliffEndTimestamp,                                                      // cliffEndTimestamp
            vestingFinishTimestamp,                                                 // vestingFinishTimestamp
            seedVestingLoopTime,                                                    // vestingLoopTime
            seedVestingTime / seedVestingLoopTime,                                  // vestingTotalLoop
            10**ratioDecimal - seedOnListingAvailableRatio                          // claimRatio
        );
    }

    function seedClaim(uint256 amount) external {
        (uint256 cliffEndTimestamp, uint256 vestingFinishTimestamp) = getSeedEndTimestamp();

        uint256 claimedAmount = _claim(
            amount,                                                                     // amount
            seedWhitelist[msg.sender],                                                  // whitelistAmount
            seedClaimed[msg.sender],                                                    // claimedAmount
            seedWhitelist[msg.sender] * seedOnListingAvailableRatio / 10**ratioDecimal, // listingAmount
            cliffEndTimestamp,                                                          // cliffEndTimestamp
            vestingFinishTimestamp,                                                     // vestingFinishTimestamp
            seedVestingLoopTime,                                                        // vestingLoopTime
            seedVestingTime / seedVestingLoopTime,                                      // vestingTotalLoop
            10**ratioDecimal - seedOnListingAvailableRatio                              // claimRatio
        );

        seedClaimed[msg.sender] = seedClaimed[msg.sender] + claimedAmount;
    }

    function seedNextTimeClaim() external view returns (uint256) {
        (uint256 cliffEndTimestamp, uint256 vestingFinishTimestamp) = getSeedEndTimestamp();

        return _nextTimeClaim(
            cliffEndTimestamp,      // cliffEndTimestamp
            vestingFinishTimestamp, // vestingFinishTimestamp
            seedVestingLoopTime     // vestingLoopTime
        );
    }

    /**
     * private function
     */

    function setPrivateOnListingAvailableRatio(uint256 ratio) external onlyOwner {
        privateOnListingAvailableRatio = ratio;
    }

    function setPrivateCliffTime(uint256 time) external onlyOwner {
        privateCliffTime = time;
    }

    function setPrivateVestingTime(uint256 time) external onlyOwner {
        privateVestingTime = time;
    }

    function setPrivateVestingLoopTime(uint256 time) external onlyOwner {
        privateVestingLoopTime = time;
    }

    function setPrivateWhitelist(address[] memory addrs, uint256[] memory amounts) public onlyOwner {
        for (uint8 i = 0; i < addrs.length; i++) {
            privateWhitelist[addrs[i]] = amounts[i];
        }
    }

    function getPrivateEndTimestamp() public view returns (uint256 cliffEndTimestamp, uint256 vestingFinishTimestamp) {
        return getEndTimestamp(
            publicSaleTimestamp + privateCliffTime,                         // _cliffEndTimestamp
            publicSaleTimestamp + privateCliffTime + privateVestingTime,    // _vestingFinishTimestamp
            tgeTimestamp + privateCliffTime,                                // _tgeCliffEndTimestamp
            tgeTimestamp + privateCliffTime + privateVestingTime            // _tgeVestingFinishTimestamp
        );
    }

    function privateClaimAvailable() external view returns (uint256) {
        return privateClaimAvailable(msg.sender);
    }

    function privateClaimAvailable(address addr) public view returns (uint256) {
        (uint256 cliffEndTimestamp, uint256 vestingFinishTimestamp) = getPrivateEndTimestamp();

        return _claimAvailable(
            privateWhitelist[addr],                                                     // whitelistAmount
            privateClaimed[addr],                                                       // claimedAmount
            privateWhitelist[addr] * privateOnListingAvailableRatio / 10**ratioDecimal, // listingAmount
            cliffEndTimestamp,                                                          // cliffEndTimestamp
            vestingFinishTimestamp,                                                     // vestingFinishTimestamp
            privateVestingLoopTime,                                                     // vestingLoopTime
            privateVestingTime / privateVestingLoopTime,                                // vestingTotalLoop
            10**ratioDecimal - privateOnListingAvailableRatio                           // claimRatio
        );
    }

    function privateClaim(uint256 amount) external {
        (uint256 cliffEndTimestamp, uint256 vestingFinishTimestamp) = getPrivateEndTimestamp();

        uint256 claimedAmount = _claim(
            amount,                                                                             // amount
            privateWhitelist[msg.sender],                                                       // whitelistAmount
            privateClaimed[msg.sender],                                                         // claimedAmount
            privateWhitelist[msg.sender] * privateOnListingAvailableRatio / 10**ratioDecimal,   // listingAmount
            cliffEndTimestamp,                                                                  // cliffEndTimestamp
            vestingFinishTimestamp,                                                             // vestingFinishTimestamp
            privateVestingLoopTime,                                                             // vestingLoopTime
            privateVestingTime / privateVestingLoopTime,                                        // vestingTotalLoop
            10**ratioDecimal - privateOnListingAvailableRatio                                   // claimRatio
        );

        privateClaimed[msg.sender] = privateClaimed[msg.sender] + claimedAmount;
    }

    function privateNextTimeClaim() external view returns (uint256) {
        (uint256 cliffEndTimestamp, uint256 vestingFinishTimestamp) = getPrivateEndTimestamp();

        return _nextTimeClaim(
            cliffEndTimestamp,      // cliffEndTimestamp
            vestingFinishTimestamp, // vestingFinishTimestamp
            privateVestingLoopTime  // vestingLoopTime
        );
    }

    /**
     * test function
     */

    function testBlockTime() external view returns (uint256) {
        return block.timestamp;
    }

    function testTotalRatio() external view returns (uint256) {
        return 10**ratioDecimal;
    }
}
