import './Operation.dart';

//Not to be confused with the show GOT
//The GOT algorithm from "Operational Transformation in Real-Time Group Editors" 
class GOTDoc<T>
{
  int user_id;
  List<Operation<T>> log;
  StringBuffer readable;

  GOTDoc(int id)
  {
    this.user_id = id; 
    this.log = new List();
    this.readable = new StringBuffer();
  }

  //Evaluates 3 Cases and merges an operation after making DC(O) = EC(O)
  /*
    EC - Execution Context (The context in which the operation will be execued)
    DC - Definition Context (The context the operation was executed in, in the origin document node)
    ->   Causally preceeding notation (If O ccomes causally after the execution of Operation 2 its said that 'EO2 -> O')

    Case 1 : All operations in EC(O) are causually preceeding O. 
    It must be that DC(O) = EC(O). i.e. no transformation is needed.

    Case 2 : Operations causally proceeding O are listed in EC(O) before opertions that are concurrent to O.
    Since E01 -> 0, E02 || O, EO3 || O, by transforming O against EO2 and EO3 in sequence we get EO such that DC(O) = EC(O).   
  
    Case 3 : At least one causally preceeding operation is positioned after  an inddependent operarion in EC(O). 
    This 
  */
  merge_op(Operation O)
  {
    

  }
}