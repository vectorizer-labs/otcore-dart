import 'LevienNode.dart';

class LevienTree
{
  Node<int> root;

  //xi_inv
  //this function counts the number of indices
  //that haven't been tombstoned(deleted)
  //before the given index
  //(thus giving us the effective user visible space index)
  int getStringSpaceIndex(int index)
  {
    Node<int> node = this.root;
    int result = index;
    while (node != null) {
      if (index < node.value) {
        node = node.left;
      } else {
        index -= node.value;
        result -= Node.size_of(node.left) + 1;
        node = node.right;
      }
    }
    return result;
  }

  //xi
  //this function counts the number of tombstones
  //before the given index in O(logn)
  int getLogSpaceIndex(int index)
  {
    int base = 0;
    Node<int> node = this.root;
    while (node != null) {
      Node<int> left = node.left;
      int x = node.value - Node.size_of(left);

      if (index < x) node = left;
      else 
      {
        index = 1 + index - x;
        base += node.value;
        node = node.right;
      }
    }
	  return base + index;
  }

  //xi_one
  void incrementIndicesPastIndex(int index)
  {
    this.root = recursiveIncrement(this.root, index);
  }

  //decend the tree incrementing nodes higher than index
  //skip the branches we know are less than index
  Node<int> recursiveIncrement(Node<int> node, int index)
  {
    if (node == null) return null;
    else if (index <= node.value) 
    {
      Node left_seq = recursiveIncrement(node.left, index);
      //balance the node after incrementing it
      return Node.fromUnbalancedNode(left_seq, node.value + 1, node.right);
    } 
    else {
		  Node right_seq = recursiveIncrement(node.right, index - node.value);
      //balance the node
		  return Node.fromUnbalancedNode(node.left, node.value, right_seq);
	  }
  }

  //union_one
  void insert(int index)
  {
    this.root = union_one(this.root, index);
  }

  Node<int> union_one(Node<int> node, int index)
  {
    if (node == null) return Node.fromUnbalancedNode(null, index, null);
    else if (index < node.value) {
      var left_union = union_one(node.left, index);
      return Node.fromUnbalancedNode(left_union, node.value, node.right);
    } 
    else if (index == node.value) 
    {
      return node;
    } 
    else 
    {  // i > node.value
      var right_union = union_one(node.right, index - node.value);
      return Node.fromUnbalancedNode(node.left, node.value, right_union);
    }
  }

  bool contains(int index)
  {

    Node<int> node = this.root; 
    while (node != null) 
    {
      if (index < node.value) node = node.left;
      else if (index == node.value) return true;
      else 
      { 
        // i > node.value
        index -= node.value;
        node = node.right;
      }
	  }
	  return false;
  }

}

