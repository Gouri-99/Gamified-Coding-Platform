// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GamifiedCodingPlatform {
    
    // Structs
    struct User {
        string username;
        uint256 experiencePoints;
        uint256 level;
        uint256 balance;
    }
    
    struct Challenge {
        string title;
        string description;
        uint256 reward;
        bool isActive;
    }
    
    // Mappings
    mapping(address => User) public users;
    mapping(uint256 => Challenge) public challenges;
    
    // State Variables
    uint256 public totalChallenges;
    address public owner;
    
    // Events
    event UserRegistered(address indexed user, string username);
    event ChallengeCreated(uint256 challengeId, string title, uint256 reward);
    event ChallengeCompleted(address indexed user, uint256 challengeId, uint256 reward);
    
    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    
    modifier isRegistered() {
        require(bytes(users[msg.sender].username).length > 0, "User is not registered");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    // User Registration
    function registerUser(string memory _username) public {
        require(bytes(users[msg.sender].username).length == 0, "User already registered");
        users[msg.sender] = User(_username, 0, 1, 0);
        emit UserRegistered(msg.sender, _username);
    }
    
    // Create Challenge
    function createChallenge(string memory _title, string memory _description, uint256 _reward) public onlyOwner {
        totalChallenges++;
        challenges[totalChallenges] = Challenge(_title, _description, _reward, true);
        emit ChallengeCreated(totalChallenges, _title, _reward);
    }
    
    // Complete Challenge
    function completeChallenge(uint256 _challengeId) public isRegistered {
        Challenge storage challenge = challenges[_challengeId];
        require(challenge.isActive, "Challenge is not active");
        
        users[msg.sender].experiencePoints += challenge.reward;
        users[msg.sender].balance += challenge.reward;
        users[msg.sender].level = (users[msg.sender].experiencePoints / 100) + 1;
        
        challenge.isActive = false;
        emit ChallengeCompleted(msg.sender, _challengeId, challenge.reward);
    }
    
    // Get User Details
    function getUserDetails(address _user) public view returns (string memory, uint256, uint256, uint256) {
        User memory user = users[_user];
        return (user.username, user.experiencePoints, user.level, user.balance);
    }
    
    // Withdraw Rewards
    function withdrawRewards() public isRegistered {
        uint256 amount = users[msg.sender].balance;
        require(amount > 0, "No rewards to withdraw");
        
        users[msg.sender].balance = 0;
        payable(msg.sender).transfer(amount);
    }
    
    // Fallback Function
    receive() external payable {}
}
