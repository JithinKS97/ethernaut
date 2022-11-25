// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract Statistics is Initializable {
    address public ethernaut;
    address[] public players;
    address[] public levels;
    uint256 private globalNoOfInstancesCreated;
    uint256 private globalNoOfInstancesCompleted;
    uint256 private globalNoOfFailedSubmissions;
    struct LevelInstance {
        address instance;
        bool isCompleted;
        uint256 timeCreated;
        uint256 timeCompleted;
        uint256[] timeSubmitted;
    }
    struct Level {
        uint256 noOfInstancesCreated;
        uint256 noOfInstancesSubmitted_Success;
        uint256 noOfSubmissions_Failed;
    }
    mapping(address => uint256) private globalNoOfLevelsCompletedByPlayer;
    mapping(address => uint256) private globalNoOfInstancesCreatedByPlayer;
    mapping(address => uint256) private globalNoOfInstancesCompletedByPlayer;
    mapping(address => uint256) private globalNoOfFailedSubmissionsByPlayer;
    mapping(address => Level) private levelStats;
    mapping(address => mapping(address => uint256)) private levelFirstInstanceCreationTime;
    mapping(address => mapping(address => uint256)) private levelFirstCompletionTime;
    mapping(address => mapping(address => LevelInstance)) private playerStats;
    mapping(address => bool) private playerExists;
    mapping(address => bool) private levelExists;
    modifier levelExistsCheck(address level) {
        require(doesLevelExist(level), "Level doesn't exist");
        _;
    }
    modifier levelDoesntExistCheck(address level) {
        require(!doesLevelExist(level), "Level already exists");
        _;
    }
    modifier playerExistsCheck(address player) {
        require(doesPlayerExist(player), "Player doesn't exist");
        _;
    }
    modifier onlyEthernaut() {
        require(
            msg.sender == ethernaut,
            "Only Ethernaut can call this function"
        );
        _;
    }

    function initialize(address _ethernautAddress) public initializer {
        ethernaut = _ethernautAddress;
    }

    // Protected functions
    function createNewInstance(
        address instance,
        address level,
        address player
    ) external onlyEthernaut levelExistsCheck(level) {
        if (!doesPlayerExist(player)) {
            players.push(player);
            playerExists[player] = true;
        }
        // If it is the first instance of the level
        if(playerStats[player][level].instance == address(0)) {
            levelFirstInstanceCreationTime[player][level] = block.timestamp;
        }
        playerStats[player][level] = LevelInstance(
            instance,
            false,
            block.timestamp,
            0,
            playerStats[player][level].timeSubmitted.length != 0
                ? playerStats[player][level].timeSubmitted
                : new uint256[](0)
        );
        levelStats[level].noOfInstancesCreated++;
        globalNoOfInstancesCreated++;
        globalNoOfInstancesCreatedByPlayer[player]++;
    }

    function submitSuccess(
        address instance,
        address level,
        address player
    ) external onlyEthernaut levelExistsCheck(level) playerExistsCheck(player) {
        require(
            playerStats[player][level].instance != address(0),
            "Instance for the level is not created"
        );
        require(
            playerStats[player][level].instance == instance,
            "Submitted instance is not the created one"
        );
        require(
            playerStats[player][level].isCompleted == false,
            "Level already completed"
        );
        // If it is the first submission in the level
        if(levelFirstCompletionTime[player][level] == 0) {
            globalNoOfLevelsCompletedByPlayer[player]++;
            levelFirstCompletionTime[player][level] = block.timestamp;
        }
        playerStats[player][level].timeSubmitted.push(block.timestamp);
        playerStats[player][level].timeCompleted = block.timestamp;
        playerStats[player][level].isCompleted = true;
        levelStats[level].noOfInstancesSubmitted_Success++;
        globalNoOfInstancesCompleted++;
        globalNoOfInstancesCompletedByPlayer[player]++;
    }

    function submitFailure(
        address instance,
        address level,
        address player
    ) external onlyEthernaut levelExistsCheck(level) playerExistsCheck(player) {
        require(
            playerStats[player][level].instance != address(0),
            "Instance for the level is not created"
        );
        require(
            playerStats[player][level].instance == instance,
            "Submitted instance is not the created one"
        );
        require(
            playerStats[player][level].isCompleted == false,
            "Level already completed"
        );
        playerStats[player][level].timeSubmitted.push(block.timestamp);
        levelStats[level].noOfSubmissions_Failed++;
        globalNoOfFailedSubmissions++;
        globalNoOfFailedSubmissionsByPlayer[player]++;
    }

    function saveNewLevel(address level)
        external
        levelDoesntExistCheck(level)
        onlyEthernaut
    {
        levelExists[level] = true;
        levels.push(level);
    }

    // Player specific metrics
    // number of levels created by player
    function getTotalNoOfLevelInstancesCreatedByPlayer(address player)
        public
        view
        playerExistsCheck(player)
        returns (uint256)
    {
        return globalNoOfInstancesCreatedByPlayer[player];
    }

    // number of levels completed by player
    function getTotalNoOfLevelInstancesCompletedByPlayer(address player)
        public
        view
        playerExistsCheck(player)
        returns (uint256)
    {
        return globalNoOfInstancesCompletedByPlayer[player];
    }

    // number of levels failed by player
    function getTotalNoOfFailedSubmissionsByPlayer(address player)
        public
        view
        playerExistsCheck(player)
        returns (uint256)
    {
        return globalNoOfFailedSubmissionsByPlayer[player];
    }

    function getTotalNoOfLevelsCompletedByPlayer(address player)
        public
        view
        playerExistsCheck(player)
        returns (uint256)
    {
        return globalNoOfLevelsCompletedByPlayer[player];
    }

    // number of failed submissions of a specific level by player (0 if player didn't play the level)
    function getTotalNoOfFailuresForLevelAndPlayer(
        address level,
        address player
    )
        public
        view
        playerExistsCheck(player)
        levelExistsCheck(level)
        returns (uint256)
    {
        return
            playerStats[player][level].instance != address(0)
                ? playerStats[player][level].timeSubmitted.length
                : 0;
    }

    // Is a specific level completed by a specific player ?
    function isLevelCompleted(address player, address level)
        public
        view
        playerExistsCheck(player)
        levelExistsCheck(level)
        returns (bool)
    {
        return playerStats[player][level].isCompleted;
    }

    // How much time a player took to complete a level (in seconds)
    function getTimeElapsedForCompletionOfLevel(address player, address level)
        public
        view
        playerExistsCheck(player)
        levelExistsCheck(level)
        returns (uint256)
    {
        require(levelFirstCompletionTime[player][level] != 0, "Level not completed");
        return
            levelFirstCompletionTime[player][level] - levelFirstInstanceCreationTime[player][level];
    }

    // Get a specific submission time per level and player
    // Useful to measure differences between submissions time
    function getSubmissionsForLevelByPlayer(
        address player,
        address level,
        uint256 index
    )
        public
        view
        playerExistsCheck(player)
        levelExistsCheck(level)
        returns (uint256)
    {
        require(
            playerStats[player][level].timeSubmitted.length >= index,
            "Index outbounded"
        );
        return playerStats[player][level].timeSubmitted[index];
    }

    // Percentage of total levels completed by player (1e18 = 100%)
    function getPercentageOfLevelsCompleted(address player)
        public
        view
        playerExistsCheck(player)
        returns (uint256)
    {
        // Changed from 100 to 1e18 otherwise when levels.length > 100 this will round to 0 always
        return
            (getTotalNoOfLevelsCompletedByPlayer(player) * 1e18) /
            levels.length;
    }

    // Game specific metrics
    function getTotalNoOfLevelInstancesCreated() public view returns (uint256) {
        return globalNoOfInstancesCreated;
    }

    function getTotalNoOfLevelInstancesCompleted() public view returns (uint256) {
        return globalNoOfInstancesCompleted;
    }

    function getTotalNoOfFailedSubmissions() public view returns (uint256) {
        return globalNoOfFailedSubmissions;
    }

    function getTotalNoOfPlayers() public view returns (uint256) {
        return players.length;
    }

    function getNoOfFailedSubmissionsForLevel(address level)
        public
        view
        levelExistsCheck(level)
        returns (uint256)
    {
        return levelStats[level].noOfSubmissions_Failed;
    }

    function getNoOfInstancesForLevel(address level)
        public
        view
        levelExistsCheck(level)
        returns (uint256)
    {
        return levelStats[level].noOfInstancesCreated;
    }

    function getNoOfCompletedSubmissionsForLevel(address level)
        public
        view
        levelExistsCheck(level)
        returns (uint256)
    {
        return levelStats[level].noOfInstancesSubmitted_Success;
    }

    // Internal functions
    function doesLevelExist(address level) public view returns (bool) {
        return levelExists[level];
    }

    function doesPlayerExist(address player) public view returns (bool) {
        return playerExists[player];
    }

    /**
     * Functions for filling data to the contract
     */

    function updatePlayers(address[] memory _players) public {
        for (uint256 i = 0; i < _players.length; i++) {
            if(!playerExists[_players[i]]) {
                playerExists[_players[i]] = true;
                players.push(_players[i]);
            }
        }
    }

    function updateGlobalData(
        uint256 _noOfAdditionalInstancesCreatedGlobally,
        uint256 _noOfAdditionalInstancesCompletedGlobally,
        uint256 _noOfAdditionalFailedSubmissionsGlobally
    ) public {
        globalNoOfInstancesCreated += _noOfAdditionalInstancesCreatedGlobally;
        globalNoOfInstancesCompleted += _noOfAdditionalInstancesCompletedGlobally;
        globalNoOfFailedSubmissions += _noOfAdditionalFailedSubmissionsGlobally;
    }

    function updateSinglePlayerData(
        address _player,
        uint256 _noOfAdditionalInstancesCreatedByPlayer,
        uint256 _noOfAdditionalInstancesCompletedByPlayer
    ) private {
        globalNoOfInstancesCreatedByPlayer[_player] += _noOfAdditionalInstancesCreatedByPlayer;
        globalNoOfInstancesCompletedByPlayer[_player] += _noOfAdditionalInstancesCompletedByPlayer;
    }

    function updateAllPlayerData(
        address[] memory _players,
        uint256[] memory _noOfAdditionalInstancesCreatedByPlayer,
        uint256[] memory _noOfAdditionalInstancesCompletedByPlayer
    ) public {
        for (uint256 i = 0; i < _players.length; i++) {
            updateSinglePlayerData(
                _players[i],
                _noOfAdditionalInstancesCreatedByPlayer[i],
                _noOfAdditionalInstancesCompletedByPlayer[i]
            );
        }
    }

    function updateSingleLevelData(
        address _level,
        uint256 _noOfAdditionalInstancesCreated,
        uint256 _noOfAdditionalInstancesCompleted
    ) private {
        levelStats[_level].noOfInstancesCreated += _noOfAdditionalInstancesCreated;
        levelStats[_level].noOfInstancesSubmitted_Success += _noOfAdditionalInstancesCompleted;
    }

    function updateAllLevelData(
        address[] memory _levels,
        uint256[] memory _noOfAdditionalInstancesCreated,
        uint256[] memory _noOfAdditionalInstancesCompleted
    ) public {
        for (uint256 i = 0; i < _levels.length; i++) {
            updateSingleLevelData(
                _levels[i],
                _noOfAdditionalInstancesCreated[i],
                _noOfAdditionalInstancesCompleted[i]
            );
        }
    }

    function updatePlayersData(
        address[] memory _players,
        address[][] memory _levels,
        address[][] memory _instances,
        bool[][] memory _isCompleted,
        uint256[][] memory _timeCompleted,
        uint256[][] memory _timeCreated,
        uint256[][] memory _timeSubmitted,
        uint256[][] memory _levelFirstCompletedTime,
        uint256[][] memory _levelFirstInstanceCreationTime
    ) public {
        for (uint256 i = 0; i < _players.length; i++) {
            updatePlayerData(
                _players[i],
                _levels[i],
                _instances[i],
                _isCompleted[i],
                _timeCompleted[i],
                _timeCreated[i],
                _timeSubmitted[i],
                _levelFirstCompletedTime[i],
                _levelFirstInstanceCreationTime[i]
            );
        }
    }

    function updatePlayerData(
        address _player,
        address[] memory _levels,
        address[] memory _instances,
        bool[] memory _isCompleted,
        uint256[] memory _timeCompleted,
        uint256[] memory _timeCreated,
        uint256[] memory _timeSubmitted,
        uint256[] memory _levelFirstCompletedTime,
        uint256[] memory _levelFirstInstanceCreationTime
    ) public {
        for(uint256 j = 0; j < _levels.length; j++) {
            if(playerStats[_player][_levels[j]].instance == address(0)) {
                playerStats[_player][_levels[j]].instance = _instances[j];
                playerStats[_player][_levels[j]].isCompleted = _isCompleted[j];
                playerStats[_player][_levels[j]].timeCompleted = _timeCompleted[j];
                playerStats[_player][_levels[j]].timeCreated = _timeCreated[j];
                if(_timeSubmitted[j] != 0) {
                    playerStats[_player][_levels[j]].timeSubmitted.push(_timeSubmitted[j]);
                }
                if(_levelFirstCompletedTime[j] != 0) {
                    levelFirstCompletionTime[_player][_levels[j]] = _levelFirstCompletedTime[j];
                }
                if(_levelFirstInstanceCreationTime[j] != 0) {
                    levelFirstInstanceCreationTime[_player][_levels[j]] = _levelFirstInstanceCreationTime[j];
                }
            }
        }
    }

    function updateLevelsCompletedByPlayer(address _player, address[] memory _levels) public {
        for(uint256 i = 0; i < _levels.length; i++) {
            if(levelFirstCompletionTime[_player][_levels[i]] == 0) {
                globalNoOfLevelsCompletedByPlayer[_player]++;
            }
        }
    }

    function updateLevelsCompletedByPlayers(address[] memory _players, address[][] memory _levels) public {
        for(uint256 i = 0; i < _players.length; i++) {
            for(uint256 j = 0; j < _levels.length; j++) {
               address[] memory levelsCompletedByPlayer = _levels[j];
               updateLevelsCompletedByPlayer(_players[i], levelsCompletedByPlayer);
            }
        }
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[45] private __gap;
}
