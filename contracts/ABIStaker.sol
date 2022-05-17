// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";


interface IABIMarket {
    function increaseTicket(
        address[] memory tokenAddrs,
        uint256[] memory tokenIds,
        address[] memory userAddrs,
        uint256[] memory amounts
    ) external;
}


contract ABIStaker is OwnableUpgradeable, ReentrancyGuardUpgradeable {
    struct StakingPool {
        uint256 openTimestamp; // timestamp when staking available open
        uint256 closeTimestamp; // timestamp when staking available close
        uint256 timeRequire; // require time for staking
        uint256 amountRequire; // require amount token for staking
        uint256 rewardAmount; // amount of reward for staking
        address ticketToken; // address of token that ticket need to buy
        uint256 ticketTokenId; // tokenid of whitelist reward
        uint256 ticketAmount; // amount of ticket reward
        uint256 lockTime; // how long token must be locked
    }

    struct StakingData {
        uint256 amount; // amount of staking token
        uint256 rewardAmount; // amount of total reward
        uint256 startTimestamp; // start time when user staked
        uint256 lockTime; // how long token must be locked
        uint256 timeRequire; // require time for staking
        address ticketToken; // address of token that ticket need to buy
        uint256 ticketTokenId; // tokenid of whitelist reward
        uint256 ticketAmount; // amount of ticket reward
    }

    StakingPool[] public stakingPools; // available staking pool
    mapping(address => StakingData[]) public stakingData; // staking data of user

    IERC20 private abitContract;
    IABIMarket private marketContract;

    address public _devwallet; // wallet to withdraw
    uint256 public keepToken; // amount reward and staked token will distribute when unstake

    event Stake(address indexed user, uint256 amount);
    event Unstake(address indexed user, uint256 amount);

    // constructor(address abitAddr, address marketArrd) {
    //     abitContract = IERC20(abitAddr);
    //     marketContract = IABIMarket(marketArrd);

    //     _devwallet = owner();

    //     // set init staking pools
    //     // for (uint256 i = 0; i < _openTimestamps.length; i++) {
    //     //     StakingPool sp = StakingPool(
    //     //         _openTimestamps[i], // openTimestamp
    //     //         _closeTimestamps[i], // closeTimestamp
    //     //         _timeRequires[i], // timeRequire
    //     //         _amountRequires[i], // amountRequire
    //     //         _rewardAmounts[i], // rewardAmount
    //     //         _whitelistTokenIds[i], // whitelistTokenId
    //     //         _whitelistAmounts[i], // whitelistAmount
    //     //         _lockTimes[i], // lockTime
    //     //     );
    //     //     stakingPools.push(sp);
    //     // }
    // }

    function initialize(address abitAddr, address marketArrd) external initializer {
        __Ownable_init();
        __ReentrancyGuard_init();

        _devwallet = owner();

        abitContract = IERC20(abitAddr);
        marketContract = IABIMarket(marketArrd);

        // set init staking pools
        // for (uint256 i = 0; i < _openTimestamps.length; i++) {
        //     StakingPool sp = StakingPool(
        //         _openTimestamps[i], // openTimestamp
        //         _closeTimestamps[i], // closeTimestamp
        //         _timeRequires[i], // timeRequire
        //         _amountRequires[i], // amountRequire
        //         _rewardAmounts[i], // rewardAmount
        //         _whitelistTokenIds[i], // whitelistTokenId
        //         _whitelistAmounts[i], // whitelistAmount
        //         _lockTimes[i], // lockTime
        //     );
        //     stakingPools.push(sp);
        // }
    }

    function setStakingPools(
        uint256[] memory _openTimestamps,
        uint256[] memory _closeTimestamps,
        uint256[] memory _timeRequires,
        uint256[] memory _amountRequires,
        uint256[] memory _rewardAmounts,
        address[] memory _ticketTokens,
        uint256[] memory _ticketTokenIds,
        uint256[] memory _ticketAmounts,
        uint256[] memory _lockTimes
    ) external onlyOwner {
        delete stakingPools;

        for (uint256 i = 0; i < _openTimestamps.length; i++) {
            StakingPool memory  sp = StakingPool(
                _openTimestamps[i], // openTimestamp
                _closeTimestamps[i], // closeTimestamp
                _timeRequires[i], // timeRequire
                _amountRequires[i], // amountRequire
                _rewardAmounts[i], // rewardAmount
                _ticketTokens[i], // ticketToken
                _ticketTokenIds[i], // ticketTokenId
                _ticketAmounts[i], // ticketAmount
                _lockTimes[i] // lockTime
            );
            stakingPools.push(sp);
        }
    }

    function updateStakingPool(
        uint256[] memory _indexs, 
        uint256[] memory _openTimestamps,
        uint256[] memory _closeTimestamps,
        uint256[] memory _timeRequires,
        uint256[] memory _amountRequires,
        uint256[] memory _rewardAmounts,
        address[] memory _ticketTokens,
        uint256[] memory _ticketTokenIds,
        uint256[] memory _ticketAmounts,
        uint256[] memory _lockTimes
    ) external onlyOwner {
        for (uint256 i = 0; i < _indexs.length; i++) {
            if (_indexs[i] < stakingPools.length) {
                stakingPools[_indexs[i]].openTimestamp = _openTimestamps[i];
                stakingPools[_indexs[i]].closeTimestamp = _closeTimestamps[i];
                stakingPools[_indexs[i]].timeRequire = _timeRequires[i];
                stakingPools[_indexs[i]].amountRequire = _amountRequires[i];
                stakingPools[_indexs[i]].rewardAmount = _rewardAmounts[i];
                stakingPools[_indexs[i]].ticketToken = _ticketTokens[i];
                stakingPools[_indexs[i]].ticketTokenId = _ticketTokenIds[i];
                stakingPools[_indexs[i]].ticketAmount = _ticketAmounts[i];
                stakingPools[_indexs[i]].lockTime = _lockTimes[i];
            }
        }
    }

    function getABITAddress() external view returns (address) {
        return address(abitContract);
    }
    
    function setABITAddress(address addr) external onlyOwner {
        abitContract = IERC20(addr);
    }

    function getMarketAddress() external view returns (address) {
        return address(marketContract);
    }

    function setMarketAddress(address addr) external onlyOwner {
        marketContract = IABIMarket(addr);
    }

    function setDevwallet(address addr) external onlyOwner {
        _devwallet = addr;
    }

    function getStakingPools() external view returns (StakingPool[] memory) {
        return stakingPools;
    }

    function getStakingDatas(address addr) external view returns (StakingData[] memory) {
        return stakingData[addr];
    }

    function withdrawToken() external onlyOwner {
        uint256 balance = abitContract.balanceOf(address(this));
        require(keepToken < balance, "not enough balance to withdraw");
        abitContract.transfer(_devwallet, balance - keepToken);
    }

    function stake(
        uint256 _openTimestamp,
        uint256 _closeTimestamp,
        uint256 _timeRequire,
        uint256 _amountRequire,
        uint256 _rewardAmount,
        address _ticketToken,
        uint256 _ticketTokenId,
        uint256 _ticketAmount,
        uint256 _lockTime
    ) external nonReentrant {
        for (uint256 i = 0; i < stakingPools.length; i++) {
            if (
                stakingPools[i].openTimestamp == _openTimestamp
                && stakingPools[i].closeTimestamp == _closeTimestamp
                && stakingPools[i].timeRequire == _timeRequire
                && stakingPools[i].amountRequire == _amountRequire
                && stakingPools[i].rewardAmount == _rewardAmount
                && stakingPools[i].ticketToken == _ticketToken
                && stakingPools[i].ticketTokenId == _ticketTokenId
                && stakingPools[i].ticketAmount == _ticketAmount
                && stakingPools[i].lockTime == _lockTime
            ) {
                _stake(stakingPools[i]);
                return;
            }
        }

        revert("pool is not exists");
    }

    function stake(uint256 poolIndex) external nonReentrant {
        require(poolIndex < stakingPools.length, "pool is not exists");
        _stake(stakingPools[poolIndex]);
    }


    /**
     * Stake token of sender from pool they choose
     * Need approve for amount of staking token
     * Transfer amount of staking token to contract to lock it
     */
    function _stake(StakingPool memory _stakingPool) internal {
        require(
            block.timestamp > _stakingPool.openTimestamp && block.timestamp < _stakingPool.closeTimestamp,
            "not in staking time"
        );

        // require(abitContract.balanceOf(msg.sender) >= _stakingPool.amountRequire, "not enough ABI token");
        // require(
        //     abitContract.allowance(msg.sender, address(this)) >= _stakingPool.amountRequire,
        //     "should allow me transfer amount token require for staking"
        // );

        StakingData memory sData = StakingData(
            _stakingPool.amountRequire, // amount
            _stakingPool.rewardAmount, // rewardAmount
            block.timestamp, // startTimestamp
            _stakingPool.lockTime, // lockTime
            _stakingPool.timeRequire, // timeRequire
            _stakingPool.ticketToken, // ticketToken
            _stakingPool.ticketTokenId, // ticketTokenId
            _stakingPool.ticketAmount // ticketAmount
        );

        require(sData.rewardAmount + keepToken <= abitContract.balanceOf(address(this)), "out of reward");

        abitContract.transferFrom(msg.sender, address(this), _stakingPool.amountRequire); // transfer to lock staking token

        keepToken = keepToken + _stakingPool.rewardAmount + _stakingPool.amountRequire; // update keep for check reward and not withdraw
        stakingData[msg.sender].push(sData);

        emit Stake(msg.sender, _stakingPool.amountRequire);
    }

    /**
     * Claim reward for user
     * Transfer ABI Token reward and staked amount
     */
    function unstake(uint256 _index) external nonReentrant {
        require(_index < stakingData[msg.sender].length, "staking data not exists");

        StakingData storage sData = stakingData[msg.sender][_index];

        require(block.timestamp >= sData.startTimestamp + sData.lockTime, "still in lock time");
        require(sData.rewardAmount > 0, "already unstaked");

        uint256 totalABITAmount = sData.amount;
        if (block.timestamp >= sData.startTimestamp + sData.timeRequire) {
            // add reward when pass require time
            totalABITAmount = sData.amount + sData.rewardAmount;
        }

        abitContract.transfer(msg.sender, totalABITAmount);
        keepToken = keepToken - sData.amount - sData.rewardAmount; // no keep staking and reward amount any more
        sData.rewardAmount = 0;

        // update whitelist ticket reward
        if (sData.ticketAmount > 0) {
            address[] memory tokenAddrs = new address[](1);
            tokenAddrs[0] = sData.ticketToken;
            
            uint256[] memory tokenIds = new uint256[](1);
            tokenIds[0] = sData.ticketTokenId;

            address[] memory userAddrs = new address[](1);
            userAddrs[0] = msg.sender;

            uint256[] memory amounts = new uint256[](1);
            amounts[0] = sData.ticketAmount;

            marketContract.increaseTicket(tokenAddrs, tokenIds, userAddrs, amounts);
        }

        emit Unstake(msg.sender, totalABITAmount);
    }
}
