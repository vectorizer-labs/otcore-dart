
class Operation<T>
{
    bool is_insert;//is this operation an insert or a remove?
    T object;// the object the operation applies to
    int index; //the list index where the operation occurs
    int id; // the linear order in which the operation came
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
}

main(List<String> args) 
{
  Operation op1 = new Operation();


}