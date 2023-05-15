const {
    time,
    loadFixture,
  } = require("@nomicfoundation/hardhat-network-helpers");
  const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
  const { expect } = require("chai");
  
  describe("SymeraSlotManager", function () {
    
    async function deployTokenFixture() {
      // Get the ContractFactory and Signers here.
      const SymeraSlotManager = await ethers.getContractFactory("SymeraSlotManager");
      const SymeraSlotBase = await ethers.getContractFactory("SymeraSlotBase");
      const [owner, addr1, addr2] = await ethers.getSigners();
  
      // To deploy our contract, we just have to call Token.deploy() and await
      // for it to be deployed(), which happens onces its transaction has been
      // mined.
      const symeraSlotManagerToken = await SymeraSlotManager.deploy();
      const symeraSlotBaseToken = await SymeraSlotBase.deploy();
      await symeraSlotManagerToken.deployed();
      await symeraSlotBaseToken.deployed();
      await symeraSlotManagerToken.flipSaleState();
      // Fixtures can return anything you consider useful for your tests
      return { Token, symeraSlotManagerToken, owner, addr1, addr2 };
    }
  
    describe("Deployment", function () {
      
      it("depositIntoSlot", async function () {
        const { symeraSlotManagerToken, owner } = await loadFixture(deployTokenFixture);
        await symeraSlotManagerToken.depositIntoSlot();
        
      });
    });
  
  
    
  });
  