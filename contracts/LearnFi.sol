// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract LearnFiContent is Ownable, ReentrancyGuard {
    struct Content {
        address creator;
        string contentHash;  // IPFS hash
        uint256 timestamp;
        uint256 contentType; // 0: video, 1: post
        string[] tags;
        uint256 engagementScore;
        bool isActive;
    }
    
    mapping(uint256 => Content) public contents;
    mapping(address => uint256[]) public creatorContent;
    mapping(address => uint256) public userEngagementPoints;
    uint256 private _contentCounter;
    
    event ContentCreated(uint256 indexed contentId, address indexed creator, string contentHash);
    event ContentEngaged(uint256 indexed contentId, address indexed user, uint256 score);
    event ContentToggled(uint256 indexed contentId, bool isActive);
    event PointsAwarded(address indexed user, uint256 points);
    
    constructor() Ownable(msg.sender) {}
    
    function createContent(
        string memory contentHash,
        uint256 contentType,
        string[] memory tags
    ) external returns (uint256) {
        require(bytes(contentHash).length > 0, "Content hash cannot be empty");
        require(tags.length > 0, "Must provide at least one tag");
        
        uint256 contentId = _contentCounter++;
        
        contents[contentId] = Content({
            creator: msg.sender,
            contentHash: contentHash,
            timestamp: block.timestamp,
            contentType: contentType,
            tags: tags,
            engagementScore: 0,
            isActive: true
        });
        
        creatorContent[msg.sender].push(contentId);
        
        emit ContentCreated(contentId, msg.sender, contentHash);
        return contentId;
    }
    
    function engageWithContent(uint256 contentId, uint256 score) external nonReentrant {
        Content storage content = contents[contentId];
        require(content.timestamp != 0, "Content does not exist");
        require(content.isActive, "Content is not active");
        require(score > 0 && score <= 5, "Score must be between 1 and 5");
        require(content.creator != msg.sender, "Cannot engage with own content");
        
        content.engagementScore += score;
        
        // Award points to the user who engaged
        uint256 points = score * 10; // 10 points per engagement score
        userEngagementPoints[msg.sender] += points;
        
        emit ContentEngaged(contentId, msg.sender, score);
        emit PointsAwarded(msg.sender, points);
    }
    
    function toggleContentStatus(uint256 contentId) external {
        require(msg.sender == contents[contentId].creator || owner() == msg.sender, "Not authorized");
        require(contents[contentId].timestamp != 0, "Content does not exist");
        
        contents[contentId].isActive = !contents[contentId].isActive;
        emit ContentToggled(contentId, contents[contentId].isActive);
    }
    
    function getCreatorContent(address creator) external view returns (uint256[] memory) {
        return creatorContent[creator];
    }
    
    function getUserPoints(address user) external view returns (uint256) {
        return userEngagementPoints[user];
    }
    
    function getContentsByTag(string memory tag) external view returns (uint256[] memory) {
        uint256[] memory result = new uint256[](_contentCounter);
        uint256 count = 0;
        
        for (uint256 i = 0; i < _contentCounter; i++) {
            if (contents[i].isActive) {
                for (uint256 j = 0; j < contents[i].tags.length; j++) {
                    if (keccak256(bytes(contents[i].tags[j])) == keccak256(bytes(tag))) {
                        result[count] = i;
                        count++;
                        break;
                    }
                }
            }
        }
        
        // Resize array to actual count
        assembly {
            mstore(result, count)
        }
        
        return result;
    }
}