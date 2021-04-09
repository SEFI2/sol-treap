pragma solidity 0.8.3;

import "hardhat/console.sol";

library TreapLib {
  struct Node {
    int value;
    int size;
    int sum;
    int min;
    int max;

    int priority;

    int leftNodeId;
    int rightNodeId;
  }
  int private constant NULL = 0;

  struct Treap {
    int rootId;

    mapping (int => int) nodeIdToIndex;
    int nodeIdCounter;
    Node[] nodes;
  }

  function init(Treap storage self)
    public
  {
    self.rootId = 1;
    self.nodeIdCounter = 2;
 
    self.nodeIdToIndex[self.rootId] = NULL;

    self.nodes.push(Node({
      value: 0,
      min: 0,
      max: 0,
      sum: 0,
      size: 0,
      leftNodeId: 0,
      rightNodeId: 0,
      priority: 0
    }));
  }

  function length(Treap storage self) 
    public
    view
    returns (int)
  {
    int curIndex = self.nodeIdToIndex[self.rootId];
    if (curIndex == 0) {
      return 0;
    }

    Node storage root = self.nodes[uint(curIndex)];
    return root.size;
  }

  function traverseAndShow(Treap storage self, int curNodeId)
    public
    view
  {
    int curIndex = self.nodeIdToIndex[curNodeId];
    console.log("Traverse");
    console.log("curIndex: '%d', curNodeId: '%d'", uint(curIndex), uint(curNodeId));
    if (curIndex == NULL) {
      return;
    }

    Node memory node = self.nodes[uint(curIndex)];
    
    console.log("leftNodeId: '%d', rightNodeId: '%d'", uint(node.leftNodeId), uint(node.rightNodeId));
    console.log("");
    traverseAndShow(self, node.leftNodeId);
    console.log("Node Value: '%d'", uint(node.value));
    traverseAndShow(self, node.rightNodeId);
  }

  function _getValue(Treap storage self, int curNodeId)
    internal
    view
    returns (int)
  {

  }

  function get(Treap storage self, int index)
    internal
    returns (int)
  {
    int rootId = self.rootId;
    int leftId = self.nodeIdCounter ++;
    int rightId = self.nodeIdCounter ++;
    int midId = self.nodeIdCounter ++;
    
    _split(self, rootId, leftId, rightId, index - 1, 0);
    _split(self, rightId, midId, rightId, index + 1, 0);

    int val = _getValue(self, midId);    
    console.log("val: %d", uint(val));
    console.log("size: %d", uint(_getSize(self, val)));
    _merge(self, leftId, leftId, midId);
    _merge(self, rootId, leftId, rightId);
    return val;
  }

  function insert(Treap storage self, int index, int data)
    internal
    returns (bool)
  {      
    int nodeId = self.nodeIdCounter ++;
    int nodeIndex = int(self.nodes.length);
    self.nodeIdToIndex[nodeId] = nodeIndex;
    
    self.nodes.push(Node({
      value: data,
      min: data,
      max: data,
      sum: data,
      size: 1,
      leftNodeId: self.nodeIdCounter ++,
      rightNodeId: self.nodeIdCounter ++,
      priority: _random(self)
    }));
    
    int rootId = self.rootId;
    int leftId = self.nodeIdCounter ++;
    int rightId = self.nodeIdCounter ++;
    console.log("Insert");
    console.log("rootId: '%d'", uint(rootId));
    console.log("nodeId: '%d'", uint(nodeId));
    console.log("leftId: '%d'", uint(leftId));
    console.log("rightId: '%d'", uint(rightId));
    console.log("");
    
    _split(self, rootId, leftId, rightId, index - 1, 0);
    _merge(self, leftId, leftId, nodeId);
    _merge(self, rootId, leftId, rightId);
    return true;
  }

  function _getSize(Treap storage self, int curNodeId) 
    private
    view
    returns (int) 
  {
    int curIndex = self.nodeIdToIndex[curNodeId];
    if (curIndex == NULL) {
      return 0;
    }
    return self.nodes[uint(curIndex)].size;
  }

  function _update(Treap storage self, int curNodeId)
    private
  {
    int curIndex = self.nodeIdToIndex[curNodeId];
    if (curIndex == NULL) {
      return;
    }

    Node storage current = self.nodes[uint(curIndex)];
    current.size = 1;
    current.size += _getSize(self, current.leftNodeId);
    current.size += _getSize(self, current.rightNodeId);
  }

  function _merge(Treap storage self, int curNodeId, int leftNodeId, int rightNodeId)
    private
    returns (bool)
  {
    int leftIndex = self.nodeIdToIndex[leftNodeId];
    int rightIndex = self.nodeIdToIndex[rightNodeId];
    if (leftIndex == NULL && rightIndex == NULL) {
      return true;
    }

    if (leftIndex == NULL) { 
      self.nodeIdToIndex[curNodeId] = self.nodeIdToIndex[rightNodeId];
      console.log("Left is NULL");
      console.log("");
      return true;
    }
    
    if (rightIndex == NULL) {
      self.nodeIdToIndex[curNodeId] = self.nodeIdToIndex[leftNodeId];
      console.log("Right is NULL");
      console.log("");
      return true;
    }

    console.log("Merge:");
    console.log("curNodeId: '%d'", uint(curNodeId));
    console.log("leftNodeId: '%d'", uint(leftNodeId));
    console.log("rightNodeId: '%d'", uint(rightNodeId));
    console.log("leftIndex: '%d'", uint(leftIndex));
    console.log("rightIndex: '%d'", uint(rightIndex));
    console.log("");
    
    Node memory left = self.nodes[uint(leftIndex)];
    Node memory right = self.nodes[uint(rightIndex)];
    
    if (left.size == 0 || right.size == 0) {
      console.log("Very strange :(");
      return false;
    }
    
    if (left.priority < right.priority) {
      _merge(self, right.leftNodeId, leftNodeId, right.leftNodeId);
      self.nodeIdToIndex[curNodeId] = self.nodeIdToIndex[rightNodeId];
    } else {
      _merge(self, left.rightNodeId, left.rightNodeId, rightNodeId);
      self.nodeIdToIndex[curNodeId] = self.nodeIdToIndex[leftNodeId];
    }

    _update(self, curNodeId);
    return true;
  }



  function _split(Treap storage self, int curNodeId, int leftNodeId, int rightNodeId, int index, int add)
    private
    returns (bool)
  {

    int curIndex = self.nodeIdToIndex[curNodeId];
    if (curIndex == NULL) {
      self.nodeIdToIndex[leftNodeId] = self.nodeIdToIndex[rightNodeId] = NULL;
      return true;
    }
    
    console.log("Split");
    console.log("curIndex: '%d'", uint(curIndex));
    console.log("curNodeId: '%d'", uint(curNodeId));
    console.log("leftNodeId: '%d'", uint(leftNodeId));
    console.log("rightNodeId: '%d'", uint(rightNodeId));
    console.log("");
  
    Node memory current = self.nodes[uint(curIndex)];
    if (current.size == 0) {
      console.log("Something strange...");
      return false;
    }

    int accIndex = add + _getSize(self, current.leftNodeId);
    if (accIndex <= index) {
      _split(self, current.rightNodeId, current.rightNodeId, rightNodeId, index, accIndex + 1);
      self.nodeIdToIndex[leftNodeId] = self.nodeIdToIndex[curNodeId];
    } else {
      _split(self, current.leftNodeId, leftNodeId, current.leftNodeId, index, add);
      self.nodeIdToIndex[rightNodeId] = self.nodeIdToIndex[curNodeId];
    }
  
    _update(self, curNodeId);
    return true;
  }
  
  function _random(Treap storage self) view private returns (int) {
    return int(uint(
      keccak256(
        abi.encodePacked(
            self.nodeIdCounter,
            self.rootId,
            msg.sender,
            block.timestamp,
            block.difficulty
        )
      )
    ));
  }
}
