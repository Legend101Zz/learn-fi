import { expect } from "chai";
import { ethers } from "hardhat";
import { LearnFiContent } from "../typechain-types";
import { SignerWithAddress } from "@nomicfoundation/hardhat-ethers/signers";

describe("LearnFiContent", function () {
  console.log("Content created successfully");
  console.log("Tracking creator's content...");
  console.log("Engaging with content...");
  console.log("Content does not exist");
  let learnFiContent: LearnFiContent;
  let owner: SignerWithAddress;
  let creator: SignerWithAddress;
  let user: SignerWithAddress;

  beforeEach(async function () {
    [owner, creator, user] = await ethers.getSigners();

    const LearnFiContent = await ethers.getContractFactory("LearnFiContent");
    learnFiContent = await LearnFiContent.deploy();
  });

  describe("Content Creation", function () {
    it("Should create new content", async function () {
      const contentHash = "QmTest123";
      const contentType = 0; // video
      const tags = ["education", "crypto"];

      await learnFiContent
        .connect(creator)
        .createContent(contentHash, contentType, tags);

      const content = await learnFiContent.contents(0);
      expect(content.creator).to.equal(creator.address);
      expect(content.contentHash).to.equal(contentHash);
      expect(content.contentType).to.equal(contentType);
    });

    it("Should track creator's content", async function () {
      await learnFiContent
        .connect(creator)
        .createContent("QmTest123", 0, ["test"]);

      const creatorContent = await learnFiContent.getCreatorContent(
        creator.address
      );
      expect(creatorContent.length).to.equal(1);
    });
  });

  describe("Content Engagement", function () {
    beforeEach(async function () {
      await learnFiContent
        .connect(creator)
        .createContent("QmTest123", 0, ["test"]);
    });

    it("Should allow users to engage with content", async function () {
      await learnFiContent.connect(user).engageWithContent(0, 1);
      const content = await learnFiContent.contents(0);
      expect(content.engagementScore).to.equal(1);
    });

    it("Should fail when engaging with non-existent content", async function () {
      await expect(
        learnFiContent.connect(user).engageWithContent(999, 1)
      ).to.be.revertedWith("Content does not exist");
    });
  });
});
