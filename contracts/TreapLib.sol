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

    bool notNull;
  }
  int private constant NULL = -1;

  struct Treap {
    int rootId;

    mapping (int => Node) nodes;
    int nodeIdCounter;
  }

  function init(Treap storage self)
    public
  {
    self.rootId = 0;
    self.nodeIdCounter = 1;
 
    self.nodes[self.rootId].notNull = false;
    /*
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
    */
  }

  function length(Treap storage self) 
    public
    view
    returns (int)
  {
    Node storage root = self.nodes[self.rootId];
    return root.size;
  }

  function _getSize(Treap storage self, int nodeId) 
    private
    view
    returns (int) 
  {
    return self.nodes[nodeId].size;
  }

  function _getValue(Treap storage self, int nodeId)
    private
    view
    returns (int)
  {
    Node memory node = self.nodes[nodeId];
    return node.value;
  }

  function get(Treap storage self, int index)
    internal
    returns (int)
  {
    int rootId = self.rootId;
    int leftId = self.nodeIdCounter ++;
    int rightId = self.nodeIdCounter ++;
    int midId = self.nodeIdCounter ++;
    self.nodes[leftId].notNull = false;
    self.nodes[rightId].notNull = false;
    self.nodes[midId].notNull = false;
    
    _split(self, rootId, leftId, rightId, index - 1, 0);
    _split(self, rightId, midId, rightId, index, 0);

    int val = _getValue(self, midId);    
    console.log("val: %d", uint(val));
    console.log("size: %d", uint(_getSize(self, midId)));
    _merge(self, leftId, leftId, midId);
    _merge(self, rootId, leftId, rightId);
    return val;
  }

  function traverseAndShow(Treap storage self, int nodeId)
    public
    view
  {
    Node memory node = self.nodes[nodeId];
    if (node.notNull == false) {
      return;
    }
    
    console.log("leftNodeId: '%d', rightNodeId: '%d'", uint(node.leftNodeId), uint(node.rightNodeId));
    console.log("");
    traverseAndShow(self, node.leftNodeId);
    console.log("Node Value: '%d'", uint(node.value));
    traverseAndShow(self, node.rightNodeId);
  }

  function insert(Treap storage self, int index, int data)
    internal
    returns (bool)
  {      
    int nodeId = self.nodeIdCounter ++;
    int leftNodeId = self.nodeIdCounter ++;
    int rightNodeId = self.nodeIdCounter ++;
    
    // self.nodes[nodeId] = ;
    self.nodes[leftNodeId].notNull = false;
    self.nodes[rightNodeId].notNull = false;
    
    self.nodes[nodeId] = Node({
      value: data,
      min: data,
      max: data,
      sum: data,
      size: 1,
      leftNodeId: leftNodeId,
      rightNodeId: rightNodeId,
      priority: _random(self),
      notNull: true
    });
    
    int rootId = self.rootId;
    int leftId = self.nodeIdCounter ++;
    int rightId = self.nodeIdCounter ++;
    self.nodes[leftId].notNull = false;
   
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

  function _update(Treap storage self, int nodeId)
    private
  {
    Node storage current = self.nodes[nodeId];
    current.size = 1;
    current.size += _getSize(self, current.leftNodeId);
    current.size += _getSize(self, current.rightNodeId);
  }

  function _merge(Treap storage self, int nodeId, int leftNodeId, int rightNodeId)
    private
    returns (bool)
  {
    if (self.nodes[leftNodeId].notNull == false) { 
      self.nodes[nodeId] = self.nodes[rightNodeId];
      console.log("Left is NULL");
      console.log("");
      return true;
    }
    
    if (self.nodes[rightNodeId].notNull == false) {
      self.nodes[nodeId] = self.nodes[leftNodeId];
      console.log("Right is NULL");
      console.log("");
      return true;
    }

    console.log("Merge:");
    console.log("nodeId: '%d'", uint(nodeId));
    console.log("leftNodeId: '%d'", uint(leftNodeId));
    console.log("rightNodeId: '%d'", uint(rightNodeId));
    console.log("");
    
    Node memory left = self.nodes[leftNodeId];
    Node memory right = self.nodes[rightNodeId];
    
    if (left.size == 0 || right.size == 0) {
      console.log("Very strange :(");
      return false;
    }
    
    if (left.priority < right.priority) {
      _merge(self, right.leftNodeId, leftNodeId, right.leftNodeId);
      self.nodes[nodeId] = self.nodes[rightNodeId];
    } else {
      _merge(self, left.rightNodeId, left.rightNodeId, rightNodeId);
      self.nodes[nodeId] = self.nodes[leftNodeId];
    }

    _update(self, nodeId);
    return true;
  }



  function _split(Treap storage self, int nodeId, int leftNodeId, int rightNodeId, int index, int add)
    private
    returns (bool)
  {
    if (self.nodes[nodeId].notNull == false) { 
      self.nodes[leftNodeId].notNull = self.nodes[rightNodeId].notNull = false;
      return true;
    }
    
    console.log("Split");
    console.log("nodeId: '%d'", uint(nodeId));
    console.log("leftNodeId: '%d'", uint(leftNodeId));
    console.log("rightNodeId: '%d'", uint(rightNodeId));
    console.log("");
  
    Node memory current = self.nodes[nodeId];
    if (current.size == 0) {
      console.log("Something strange...");
      return false;
    }

    int accIndex = add + _getSize(self, current.leftNodeId);
    if (accIndex <= index) {
      _split(self, current.rightNodeId, current.rightNodeId, rightNodeId, index, accIndex + 1);
      self.nodes[leftNodeId] = self.nodes[nodeId];
    } else {
      _split(self, current.leftNodeId, leftNodeId, current.leftNodeId, index, add);
      self.nodes[rightNodeId] = self.nodes[nodeId];
    }
  
    _update(self, nodeId);
    return true;
  }
  
  function _random(Treap storage self) private view returns (int) {
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
