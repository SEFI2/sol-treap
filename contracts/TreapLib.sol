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
  
  struct Treap {
    int rootId;

    mapping (int => int) nodeIdToIndex;
    int nodeIdCounter;
    Node[] nodes;
  }

  function length(Treap storage self) 
    public
    view
    returns (int)
  {
    int curIndex = self.nodeIdToIndex[self.rootId];
    Node storage root = self.nodes[uint(curIndex)];
    return root.size;
  }

  function _merge(Treap storage self, int curNodeId, int leftNodeId, int rightNodeId)
    private
    returns (bool)
  {
    int leftIndex = self.nodeIdToIndex[leftNodeId];
    int rightIndex = self.nodeIdToIndex[rightNodeId];
    
    Node memory left = self.nodes[uint(leftIndex)];
    Node memory right = self.nodes[uint(rightIndex)];
    
    if (left.size == 0 && right.size == 0) {
      return true;
    }

    if (left.size == 0) { 
      self.nodeIdToIndex[curNodeId] = self.nodeIdToIndex[rightNodeId];
      return true;
    }
    
    if (right.size == 0) {
      self.nodeIdToIndex[curNodeId] = self.nodeIdToIndex[leftNodeId];
      return true;
    }
    
    if (left.priority < right.priority) {
      _merge(self, right.leftNodeId, leftNodeId, right.leftNodeId);
      self.nodeIdToIndex[curNodeId] = self.nodeIdToIndex[rightNodeId];
    } else {
      _merge(self, left.rightNodeId, left.rightNodeId, rightNodeId);
      self.nodeIdToIndex[curNodeId] = self.nodeIdToIndex[leftNodeId];
    }
    
    int curIndex = self.nodeIdToIndex[curNodeId];
    Node storage current = self.nodes[uint(curIndex)];
    current.size = 1;
    if (current.leftNodeId != -1) {
      int childIndex = self.nodeIdToIndex[current.leftNodeId];
      current.size += self.nodes[uint(childIndex)].size;
    }
    if (current.rightNodeId != -1) {
      int childIndex = self.nodeIdToIndex[current.rightNodeId];
      current.size += self.nodes[uint(childIndex)].size;
    }

    return true;
  }

  function _split(Treap storage self, int curNodeId, int leftNodeId, int rightNodeId, int index, int add)
    private
    returns (bool)
  {
    if (curNodeId <= 0) {
      return true;
    }

    int curIndex = self.nodeIdToIndex[curNodeId];
    Node memory current = self.nodes[uint(curIndex)];
    if (current.size == 0) {
      return true;
    }

    int accIndex = add + current.size;
    if (curIndex <= index) {
      _split(self, current.rightNodeId, current.rightNodeId, current.rightNodeId, index, accIndex + 1);
      self.nodeIdToIndex[leftNodeId] = self.nodeIdToIndex[curNodeId];
    } else {
      _split(self, current.leftNodeId, leftNodeId, current.leftNodeId, index, add);
      self.nodeIdToIndex[rightNodeId] = self.nodeIdToIndex[curNodeId];
    }
  
    current.size = 1;
    if (current.leftNodeId != -1) {
      int childIndex = self.nodeIdToIndex[current.leftNodeId];
      current.size += self.nodes[uint(childIndex)].size;
    }
    if (current.rightNodeId != -1) {
      int childIndex = self.nodeIdToIndex[current.rightNodeId];
      current.size += self.nodes[uint(childIndex)].size;
    }
    return true;
  }
  
  function random() pure private returns (int) {
    return 0;
  }

  function insert(Treap storage treap, int index, int data)
    internal
    returns (bool)
  {  
    treap.nodeIdCounter += 1;
    require(treap.nodeIdCounter > 0, "Should be greater than zero.");

    int rootId = treap.rootId;
    int leftId = -1;
    int rightId = -1;
    
    int nodeId = treap.nodeIdCounter;
    int nodeIndex = int(treap.nodes.length);
    treap.nodeIdToIndex[nodeId] = nodeIndex;

    treap.nodes.push(Node({
      value: data,
      min: data,
      max: data,
      sum: data,
      size: 1,
      leftNodeId: -1,
      rightNodeId: -1,
      priority: random()
    }));
    
    _split(treap, rootId, leftId, rightId, index - 1, 0);
    _merge(treap, leftId, leftId, nodeId);
    _merge(treap, rootId, leftId, rightId);
    return true;
  }
}
