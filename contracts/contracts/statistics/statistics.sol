// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Statistics {
    address ETHERNAUT_ADDRESS;

    struct LevelInstance {
        address instance;
        bool isCompleted;
        uint256 timeCreated;
        uint256 timeCompleted;
        uint256[] timeSubmitted;
    }
    mapping(address => mapping(address => LevelInstance)) playerStats;
    mapping(address => bool) public playerExists;
    address[] players;

    struct Level {
        uint256 noOfInstancesCreated;
        uint256 noOfInstancesSubmitted_Success;
        uint256 noOfInstancesSubmitted_Fail;
    }
    mapping(address => Level) public levelStats;
    address[] public levels;

    function initate(address _ethernautAddress) public {
        ETHERNAUT_ADDRESS = _ethernautAddress;
    }

    function createNewInstance(address instance, address level, address user) onlyEthernaut levelExistsCheck(level) external {
        if(playerExists[user] == false) {
            players.push(user);
            playerExists[user] = true;
        }
        require(playerStats[user][level].instance == address(0), "Level already created");
        playerStats[user][level] = LevelInstance(instance, false, block.timestamp, 0, new uint256[](0));
        levelStats[level].noOfInstancesCreated++;
    }

    function submitSuccess(address level, address user) onlyEthernaut levelExistsCheck(level) playerExistsCheck(user) external {
        require(playerStats[user][level].instance != address(0), "Level not created");
        require(playerStats[user][level].isCompleted == false, "Level already completed");

        playerStats[user][level].timeSubmitted.push(block.timestamp);
        
        playerStats[user][level].timeCompleted = block.timestamp;
        playerStats[user][level].isCompleted = true;

        levelStats[level].noOfInstancesSubmitted_Success++;
    }

    function submitFailure(address level, address user) onlyEthernaut levelExistsCheck(level) playerExistsCheck(user) external {
        require(playerStats[user][level].instance != address(0), "Level not created");
        require(playerStats[user][level].isCompleted == false, "Level already completed");

        playerStats[user][level].timeSubmitted.push(block.timestamp);

        levelStats[level].noOfInstancesSubmitted_Fail++;
    }

    function saveNewLevel(address level) onlyEthernaut external {
        require(doesLevelExist(level) == false, "Level already exists");
        levels.push(level);
    }

    function getNoOfLevelsCompleted(address player) playerExistsCheck(player) public view returns(uint256) {
        uint256 noOfLevelsCompleted = 0;
        for(uint256 i = 0; i < levels.length; i++) {
            if(playerStats[player][levels[i]].isCompleted) {
                noOfLevelsCompleted++;
            }
        }
        return noOfLevelsCompleted;
    }

    function isLevelSolved(address player, address level) playerExistsCheck(player) levelExistsCheck(level) public view returns(bool) {
        return playerStats[player][level].isCompleted;
    }

    function getTimeElapsedSinceCompletionOfLevel(address player, address level) playerExistsCheck(player) levelExistsCheck(level) public view returns(uint256) {
        require(playerStats[player][level].isCompleted, "Level not completed");
        return block.timestamp - playerStats[player][level].timeCompleted;
    }

    function getPercentageOfLevelsSolved(address player) playerExistsCheck(player) public view returns(uint256) {
        return (getNoOfLevelsCompleted(player) * 100) / levels.length;
    }

    function getTotalNoOfInstancesCreated() public view returns(uint256) {
        uint256 totalNoOfLevelInstancesCreated = 0;
        for(uint256 i = 0; i < levels.length; i++) {
            totalNoOfLevelInstancesCreated += levelStats[levels[i]].noOfInstancesCreated;
        }
        return totalNoOfLevelInstancesCreated;
    }

    function getTotalNoOfInstancesSolved() public view returns(uint256) {
        uint256 totalNoOfLevelInstancesSolved = 0;
        for(uint256 i = 0; i < levels.length; i++) {
            totalNoOfLevelInstancesSolved += levelStats[levels[i]].noOfInstancesSubmitted_Success;
        }
        return totalNoOfLevelInstancesSolved;
    }

    function getTotalNoOfPlayers() public view returns(uint256) {
        return players.length;
    }

    function doesLevelExist(address level) private view returns(bool) {
        for(uint256 i = 0; i < levels.length; i++) {
            if(levels[i] == level) {
                return true;
            }
        }
        return false;
    }

    modifier levelExistsCheck(address level) {
        require(doesLevelExist(level), "Invalid level factory address");
        _;
    }

    modifier playerExistsCheck(address player) {
        require(playerExists[player], "Invalid player address");
        _;
    }

    modifier onlyEthernaut() {
        require(msg.sender == ETHERNAUT_ADDRESS, "Only Ethernaut can call this function");
        _;
    }
}