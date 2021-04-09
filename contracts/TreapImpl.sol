pragma solidity 0.8.3;

import "hardhat/console.sol";

import "./TreapLib.sol";

contract TreapImpl {
  using TreapLib for TreapLib.Treap;
  TreapLib.Treap private _treap;

  constructor() {
    _treap.init();
  }

  function push(int value)
    public
    returns (bool)
  {
    int length = _treap.length();
    return _treap.insert(length, value);
  }

  function insert(int index, int value)
    public
    returns (bool)
  {
    return _treap.insert(index, value);
  }

  function remove(int index, int value)
    public
    returns (bool)
  {
    return _treap.insert(index, value);
  }


  function show()
    public
    view
  {
    _treap.traverseAndShow(_treap.rootId);
  }
}