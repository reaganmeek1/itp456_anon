// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GroupChat {
    address public owner;
    struct Group {
        
        string name;
        uint256 minBalance;
        uint256 maxBalance;
        address[] members;
        
    }

    //groups private to keep anon
    mapping(uint256 => Group) private groups;
    uint256 public nextGroupId;

    // Event emitted when new group is created
    event GroupCreated(uint256 indexed groupId, string name, uint256 minBalance, uint256 maxBalance);

    // Event emitted when user joins a group
    event UserJoinedGroup(uint256 indexed groupId, address user);

    constructor(){
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    // create a new group
    //only owner contract can create new groups
    function createGroup(string memory name, uint256 minBalance, uint256 maxBalance) public onlyOwner {
        require(bytes(name).length > 0 && bytes(name).length < 100, "Invalid group name");
        require(minBalance <= maxBalance, "Minimum balance must be less than or equal to maximum balance");

        Group storage newGroup = groups[nextGroupId];
        newGroup.name = name;
        newGroup.minBalance = minBalance;
        newGroup.maxBalance = maxBalance;

        emit GroupCreated(nextGroupId, name, minBalance, maxBalance);
        nextGroupId++;
    }

    // Fxn for a user to join group
    // adjusted min and max balances so that users can include gas prices in their wallet balance and get into gc
    function joinGroup(uint256 groupId) public {
        require(groupId < nextGroupId, "Group does not exist");
        Group storage group = groups[groupId];

        uint256 adjustedMin = group.minBalance - tx.gasprice;
        uint256 adjustedMax = group.maxBalance + tx.gasprice;
        uint256 userBalance = address(msg.sender).balance;
        require(userBalance >= adjustedMin && userBalance <= adjustedMax, 
                "Your balance does not meet the group's requirements");

        group.members.push(msg.sender);
        emit UserJoinedGroup(groupId, msg.sender);
    }

    // Get group info, only Owner
    function getGroup(uint256 groupId) public view onlyOwner returns (string memory, uint256, uint256, address[] memory) {
        require(groupId < nextGroupId, "Group does not exist");
        Group storage group = groups[groupId];
        return (group.name, group.minBalance, group.maxBalance, group.members);
    }
}
