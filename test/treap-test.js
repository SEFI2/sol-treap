const { expect } = require("chai");

const wait = async(sec) => {
  return new Promise((res) => {
    setTimeout(() => {
      res();
    }, sec)
  });
}

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
    await Treap.push(15);
    await Treap.push(14);
    await Treap.push(17);
    await Treap.push(11);
    await Treap.push(5);
    await Treap.insert(3, 3);

    await wait(10);
    await Treap.access(1);

    console.log((await Treap.getLastAccessed()).toString());
    expect(await Treap.getLastAccessed()).be.equal(15);
  });
});
