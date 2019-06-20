import 'Operation.dart';

class OperationResult
{
  Operation Oa1;
  Operation Oa2;
  OperationType oType;

  OperationResult(Operation res1, Operation res2, OperationType oType)
  {
    this.Oa1 = res1;
    this.Oa2 = res2;
    this.oType = oType;

  }

  //makes a single operation result
  static OperationResult from_single(Operation Oa) => new OperationResult(Oa, null, OperationType.SINGLE);

  //makes a double operation result
  //for the uninitiated: this can only occur when Oa is a delete and Ob is an insert
  static OperationResult from_double(Operation Oa1, Operation Oa2) => new OperationResult(Oa1, Oa2, OperationType.DOUBLE);

}

enum OperationType
{
  SINGLE,
  DOUBLE
}