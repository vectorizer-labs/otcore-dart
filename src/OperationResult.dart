import 'Operation.dart';

class OperationResult
{
  Operation Oa1;
  Operation Oa2;
  bool is2;

  OperationResult(Operation res1, Operation res2, bool is2)
  {
    this.Oa1 = res1;
    this.Oa2 = res2;
    is2 = is2;
  }

  //makes a single operation result
  static OperationResult from_single(Operation res1) => new OperationResult(res1, null, false);

  //makes a double operation result
  //for the uninitiated: this can only occur when Oa is a delete and Ob is an insert
  static OperationResult from_double(Operation res1, Operation res2)=> new OperationResult(res1, res2, true);


}