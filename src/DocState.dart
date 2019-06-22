import './Transformation/character-wise/Operation.dart';
import 'dart:collection';

class DocState<T, OP>
{
  int user_id;
  List<Operation<T>> log = new List();
  StringBuffer readable = new StringBuffer();

  //The saved lost information of a transformed operation
  //get(Oa') => Oa (the original untransformed operation)
  //This relys on the objects hashcode so its imperitive that 
  //Oa' is a deep copy of Oa to gaurantee they have unique hashcodes
  HashMap<Operation, Operation> LI = new HashMap<Operation, Operation>();

  //The saved relative address of operations that have undefined ranges after transformation
  //get(Oa') => Ob
  //If it doesn't exist in the hashmap then its address isn't relative
  //otherwise the returned operation is the operation its address is relative to
  HashMap<Operation, Operation> RA = new HashMap<Operation, Operation>();

  //the merge function empolyed by this DocState
  //Could be GOTO, Raph's Algo, or P-GOTO
  Function merge_op;

  DocState(int id, Function merge_op)
  {
    this.user_id = id; 
    this.merge_op = merge_op;
  }


    
}