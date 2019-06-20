import 'Operation.dart';
import 'dart:collection';

class DocState<T>
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
  //Could be GOT, GOTO, Raph's Algo, or P-GOTO
  Function merge_op;

  DocState(int id, Function merge_op)
  {
    this.user_id = id; 
    this.merge_op = merge_op;
  }

  Operation Check_LI(Operation OaPrime )
  {
    //return the original Oa if it exists
    if(this.LI.containsKey(OaPrime)) return this.LI.remove(OaPrime);
    return OaPrime;
  }

  void Save_LI(Operation Oa, Operation OaPrime)
  {
    //if the map doesn't have this key then add it
    if(!this.LI.containsKey(OaPrime)) this.LI[OaPrime] = Oa;
    else throw new Exception("Tried to Save_LI for an operation that already existed in the map!");
  }

  Operation Check_RA(Operation OaPrime, Operation Ob)
  {
    //return the Ob if it exists
    if(this.RA[OaPrime] == Ob) return this.RA.remove(OaPrime);
    //Otherwise return Oa Prime
    else return OaPrime;
  }

  void Save_RA(Operation OaPrime, Operation Ob)
  {
    //if the map doesn't have this key then add it
    if(!this.LI.containsKey(OaPrime)) this.LI[OaPrime] = Ob;
    else throw new Exception("Tried to Save_LI for an operation that already existed in the map!");
  }
    
}