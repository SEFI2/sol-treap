pragma solidity >=0.4.22 <0.9.0;

library TreapLibrary {
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
    int root;

    mapping (int => uint) nodeIdToIndex;
    int nodeIdCounter;
    Node[] nodes;
  }

  function merge(Treap storage treap, int curNodeId, int leftNodeId, int rightNodeId) private returns (bool) {
    uint leftIndex = treap.nodeIdToIndex[leftNodeId];
    uint rightIndex = treap.nodeIdToIndex[rightNodeId];
    
    Node memory left = treap.nodes[leftIndex];
    Node memory right = treap.nodes[rightIndex];
    
    if (left.size == 0 && right.size == 0) {
      return true;
    }

    if (left.size == 0) { 
      treap.nodeIdToIndex[curNodeId] = treap.nodeIdToIndex[rightNodeId];
      return true;
    }
    
    if (right.size == 0) {
      treap.nodeIdToIndex[curNodeId] = treap.nodeIdToIndex[leftNodeId];
      return true;
    }
    
    if (left.priority < right.priority) {
      merge(treap, right.leftNodeId, leftNodeId, right.leftNodeId);
      treap.nodeIdToIndex[curNodeId] = treap.nodeIdToIndex[rightNodeId];
    } else {
      merge(treap, left.rightNodeId, left.rightNodeId, rightNodeId);
      treap.nodeIdToIndex[curNodeId] = treap.nodeIdToIndex[leftNodeId];
    }
    
    uint curIndex = treap.nodeIdToIndex[curNodeId];
    Node storage current = treap.nodes[curIndex];
    current.size = 1;
    if (current.leftId != -1) {
      uint childIndex = treap.nodeIdToIndex[current.leftId];
      current.size += treap.nodes[childIndex].size;
    }
    if (current.rightId != -1) {
      uint childIndex = treap.nodeIdToIndex[current.rightId];
      current.size += treap.nodes[childIndex].size;
    }

    return true;
  }

  function split(Treap storage treap, int curNodeId, int leftNodeId, int rightNodeId, int index, int add) private returns (bool) {
    if (curNodeId <= 0) {
      return true;
    }

    uint curIndex = treap.nodeIdToIndex[curNodeId];
    Node memory current = treap.nodes[curIndex];
    if (current.size == 0) {
      return true;
    }

    int accIndex = add + treap.nodes[current.leftId].size;
    if (curIndex <= index) {
      split(treap, current.righNodeId, current.rightNodeId, current.rightId, index, accIndex + 1);
      treap.nodeIdToIndex[curNodeId] = treap.nodeIdToIndex[leftNodeId];
      require(moveToFrom(treap, leftId, curId));
    } else {
      split(treap, rightId, rightId, current.rightId, index, add);
      treap.nodeIdToIndex[curNodeId] = treap.nodeIdToIndex[leftNodeId];
      require(moveToFrom(treap, rightId, curId));  
    }
  
    Node storage newCurrent = treap.nodes[curId];
    newCurrent.size = treap.nodes[newCurrent.leftId].size + treap.nodes[newCurrent.rightId].size + 1;
    return true;
  }
  
  function random() pure private returns (int) {
    return 0;
  }

  function insert(Treap storage treap, int index, int data) internal returns (bool) {  
    treap.nodeIdCounter += 1;
    treap.nodeIdToIndex[-1] = 0;
    treap.nodes[0] =;
    require(treap.nodeIdCounter > 0, "Should be greater than zero.");

    int rootId = treap.root;
    int leftId = -1;
    int rightId = -1;

    Node storage newNode;
    newNode.value = newNode.min = newNode.max = newNode.sum = data;
    newNode.size = 1;
    newNode.leftId = newNode.rightId = -1;
    newNode.priority = random();

    int nodeId = treap.nodeIdCounter;
    int nodeIndex = int(treap.nodes.length);
    treap.nodes.push(newNode);
    treap.nodeIdToIndex[nodeId] = nodeIndex;

    // split(treap, rootId, leftId, rightId, index - 1, 0);
    // merge(treap, leftId, leftId, newNodeId);
    // merge(treap, rootId, leftId, rightId);
    return true;
  }
}
