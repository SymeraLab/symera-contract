const {
    time,
    loadFixture,
  } = require("@nomicfoundation/hardhat-network-helpers");
  const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
  const { expect } = require("chai");
  
  const communityMultisig = '0x37bAFb55BC02056c5fD891DFa503ee84a97d89bF'
  const teamMultisig = '0x040353E9d057689b77DF275c07FFe1A46b98a4a6'
  const wEthERC20 = '0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6';
  const wstEthERC20 = '0x6320cd32aa674d2898a68ec82e869385fc5f7e2f';
  const rETHERC20 = '0x178e141a0e3b34152f73ff610437a7bf9b83267a';
  const tsETHERC20 = '0x';
  describe("SymeraSlotManager", function () {
    
    async function deployTokenFixture() {
      // Get the ContractFactory and Signers here.
      const SymeraSlotManager = await ethers.getContractFactory("SymeraSlotManager");
      const SymeraSlotBase = await ethers.getContractFactory("SymeraSlotBase");
      const PauserRegistry = await ethers.getContractFactory("PauserRegistry");
      const [owner, addr1, addr2] = await ethers.getSigners();
  
      // To deploy our contract, we just have to call Token.deploy() and await
      // for it to be deployed(), which happens onces its transaction has been
      // mined.
      const pauserRegistryToken = await PauserRegistry.deploy(teamMultisig,communityMultisig);
      
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
  