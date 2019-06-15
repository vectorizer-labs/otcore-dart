import 'dart:core';
import 'dart:html';

import 'OperationResult.dart';

class Operation<T>
{
    bool is_insert;//is this operation an insert or a remove?
    T object;// the object the operation applies to
    int index; //the list index where the operation occurs
    int id; // the linear order in which the operation came i.e. revision ID
    int time_stamp;// the epoch time stamp
    int user_id;// the user id

  Operation(bool is_insert, T object, int index, int id, int time_stamp, int user_id)
  {
    this.is_insert = is_insert;
    this.object = object;
    this.index = index;
    this.id = id;
    this.time_stamp = time_stamp;
    this.user_id = user_id;
  }

  bool is_concurrent(Operation O){ return this.id == O.id; }

  //A simple Clone deep copy utility that follows the Dart and Rust convention
  static Operation from(Operation O) => new Operation(O.is_insert, O.object, O.index, O.id, O.time_stamp, O.index);

  //increment the ID of this operation by one
  Operation roll_revision_forward(){ this.id++; return this; }

  //increment the index by the length of Ob
  Operation roll_index_forward(int len){ this.index += len; return this; }

  //decrement the index by the length of Ob
  Operation roll_index_backward(int len){ this.index -= len; return this; }

  //set the index to that of Ob
  Operation set_index_to_Ob(Operation Ob){ this.index = Ob.index; return this; }

  //set the length of a delete operation to 0
  Operation set_length_to_0(){ this.object = 0 as T; return this;}

  Operation set_length(int len){ this.object = len as T; return this; }
}

