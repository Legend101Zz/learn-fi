// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract LearnFiContent is Ownable {
    struct Content {
        address creator;
        string contentHash;  // IPFS hash
        uint256 timestamp;
        uint256 contentType; // 0: video, 1: post
        string[] tags;
        uint256 engagementScore;
    }
    
    mapping(uint256 => Content) public contents;
    mapping(address => uint256[]) public creatorContent;
    uint256 private _contentCounter;
    
    event ContentCreated(uint256 indexed contentId, address indexed creator, string contentHash);
    event ContentEngaged(uint256 indexed contentId, address indexed user, uint256 score);
    
    constructor() Ownable(msg.sender) {}
    
    function createContent(
        string memory contentHash,
        uint256 contentType,
        string[] memory tags
    ) external returns (uint256) {
        uint256 contentId = _contentCounter++;
        
        contents[contentId] = Content({
            creator: msg.sender,
            contentHash: contentHash,
            timestamp: block.timestamp,
            contentType: contentType,
            tags: tags,
            engagementScore: 0
        });
        
        creatorContent[msg.sender].push(contentId);
        
        emit ContentCreated(contentId, msg.sender, contentHash);
        return contentId;
    }
    
    function engageWithContent(uint256 contentId, uint256 score) external {
        require(contents[contentId].timestamp != 0, "Content does not exist");
        contents[contentId].engagementScore += score;
        emit ContentEngaged(contentId, msg.sender, score);
    }
    
    function getCreatorContent(address creator) external view returns (uint256[] memory) {
        return creatorContent[creator];
    }
}