
import 'dart:developer';
import './Operation.dart';

main(List<String> args) 
{


  Operation o1 = new Operation(true, 'a'.codeUnitAt(0),0,0, Timeline.now,0);
  Operation o2 = new Operation(true, 'b'.codeUnitAt(0),1,1, Timeline.now,0);
  Operation o3 = new Operation(true, 'c'.codeUnitAt(0),2,2, Timeline.now,0);

  Operation o4 = new Operation(true, '2'.codeUnitAt(0),1,1, Timeline.now,1);

}

