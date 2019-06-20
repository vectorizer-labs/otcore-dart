import 'ExclusionTransformation.dart';
import 'InclusionTransformation.dart';
import 'Operation.dart';
import 'DocState.dart';
import 'OperationResult.dart';

//Not to be confused with the show GOT
//The GOT algorithm from "Operational Transformation in Real-Time Group Editors" 
class GOT
{

  //Evaluates 3 Cases and merges an operation after making DC(O) = EC(O)
  /*
    EC - Execution Context (The context in which the operation will be execued, i.e. how the log looks right now)
    DC - Definition Context (The context the operation was executed in, in the origin document node)
    ->   Causally preceeding notation (If O ccomes causally after the execution of Operation 2 its said that 'EO2 -> O')
    ||   Concurrent notation

    Case 1 : All operations in EC(O) are causually preceeding O. 
    It must be that DC(O) = EC(O). i.e. no transformation is needed.

    Case 2 : Operations causally proceeding O are listed in EC(O) before opertions that are concurrent to O.
    Since E01 -> 0, E02 || O, EO3 || O, by transforming O against EO2 and EO3 in sequence we get EO such that DC(O) = EC(O).   
  
    Case 3 : At least one causally preceeding operation is positioned after a concurrent operarion in EC(O). 
    Since E01 -> 0, E02 || O, EO3 -> O, it must be that DC(O) = [EO1, EO3'] where EO3' is the original form of EO3 when O was generated at the local site.
    The strategy taken by the GOT algorithm is as follows:
    (1) apply exclusion transformation on EO3 against EO2 to get EO3'
    (2) apply exclusion transformation on O against EO3' to get a new O'
    (3) apply inclusion transformation on O' against EO2 and EO3 in sequence. 
    We Get EO such that DC(O) = EC(O).
  */
  Operation merge_op(Operation O, DocState dc)
  {
    return case_1(O,dc);
  }

  Operation case_1(Operation O, DocState dc)
  {
    //loop through the log to find the first operation EOK such that EOK || O
    for(int i = 0; i < O.id; i++)
    {
      //we found a concurrent operation so move on to check for case 2
      if(O.is_concurrent(dc.log[i])) return case_2(dc.log[i], O, dc);
    }
    //Its a match for Case 1 which means no transformation is needed
    return O;
  }

  Operation case_2(Operation EOK, Operation O, DocState dc)
  {
    //the list of operations causally preceeding O in the EC(O)
    List<Operation> L1 = new List();

    //loop through all the operatons from k to the end of the log to see if any are causally preceeding O
    for(int i = EOK.id + 1; i < dc.log.length; i++) if(O.id > dc.log[i].id) L1.add(Operation.from(dc.log[i])); 

    if(L1.length == 0) return LIT(EOK, O, dc);

  }

  Operation LIT(Operation EOK, Operation O, DocState dc)
  {
    for(int i = EOK.id + 1; i < dc.log.length; i++)
    {
      OperationResult result = InclusionTransformation.IT(O,dc.log[i], dc);
      switch(result.oType)
      {
        case OperationType.SINGLE: 
        return result.Oa1; 

        case OperationType.DOUBLE:
        throw new UnimplementedError("Can't handle a split case yet");

      }

    }
  }

  Operation LET(Operation EOK, Operation O, DocState dc)
  {
    for(int i = EOK.id + 1; i < dc.log.length; i++)
    {
      OperationResult result = ExclusionTransformation.ET(O,dc.log[i], dc);
      switch(result.oType)
      {
        case OperationType.SINGLE: 
        return result.Oa1; 

        case OperationType.DOUBLE:
        throw new UnimplementedError("Can't handle a split case yet");

      }

    }
  }

  
}