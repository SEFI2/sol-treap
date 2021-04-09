const { expect } = require("chai");

describe("TreapImpl", function() {
  it("should test treap", async function() {
    const TreapLibContract = await ethers.getContractFactory("TreapLib");
    const TreapLib = await TreapLibContract.deploy();
    await TreapLib.deployed();

    const TreapImplContract = await ethers.getContractFactory("TreapImpl", {
      libraries: {
        TreapLib: TreapLib.address
      }
    });

    const Treap = await TreapImplContract.deploy();
    
    await Treap.deployed();
    await Treap.insert(15);
  });
});
