import 'dart:math';

class Node<V>
{
  Node left;
  V value;
  Node right;
  int height;
  int size;

  //creates a raw node including calculating the balancing metrics
  //mk_tree_raw
  Node(Node left, V value, Node right)
  {
    //set local variables
    this.left = left;
    this.value = value;
    this.right = right;

    //calculate balancing metrics
    this.size = size_of(left) + 1 + size_of(right);
	  var left_height = left == null ? 0 : left.height;
	  var right_height = right == null ? 0 : right.height;
	  this.height = max(left_height, right_height) + 1;
  }

  //balances the node and returns it
  //mk_tree
  static Node fromUnbalancedNode(Node left, int value, Node right)
  {
    var left_height = left == null ? 0 : left.height;
    var right_height = right == null ? 0 : right.height;
    if (left_height > right_height + 1) {
      // unbalanced, rotate right
      var new_right = new Node(left.right, value - left.value, right);
      return new Node(left.left, left.value, new_right);
    } else if (right_height > left_height + 1) {
      // unbalanced, rotate left
      var new_left = new Node(left, value, right.left);
      return new Node(new_left, value + right.value, right.right);
    }
    return new Node(left, value, right);
  }

  static int size_of(Node<int> node) => node == null ? 0 : node.size;
}