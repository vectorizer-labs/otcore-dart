import 'dart:indexed_db';

import './Transformation/character-wise/Operation.dart';

import 'Algo/Levien/LevienTree.dart';

class DocState<T>
{
  int user_id;

  //the log of Operations in linear monotonic order
  List<Operation<T>> log = new List();

  //user visible space indices for saving selection
  List<int> points = new List();

  //
  LevienTree deletes = new LevienTree();

  //the user visible flat string
  String str;



  DocState(int id)
  {
    this.user_id = id; 
  }

  void add(Operation O)
  {
    this.log.add(O);
    //delete
		if (!O.is_insert) deletFromString(O);
    //insert
    else insertIntoString(O);
  }

  void deletFromString(Operation O)
  {
    //if we already deleted the character in question then 
    //ignore this operation because the effect is the same 
    if (this.deletes.contains(O.index)) return;

    //otherwise get the string space index
		int index = this.deletes.getStringSpaceIndex(O.index);
    //delete it
		this.deletes.insert(O.index);
    //modify the actual string to reflect the change
		this.str = this.str.substring(0, index) + this.str.substring(index + 1);
    //update the points in the UI view
    //move back every character after the delete by one
    for (int i = 0; i < this.points.length; i++) if (this.points[i] > index) this.points[i] -= 1;
  }

  void insertIntoString(Operation O)
  {
    //update the deletes 
    //by incrementing all the delete indexes after our insert by one
    this.deletes.incrementIndicesPastIndex(O.index);
    //get the string space index of our insert now that we've updated
    int index = this.deletes.getStringSpaceIndex(O.index);

    //modify the actual string to reflect the change
    this.str = this.str.substring(0, index) + O.object + this.str.substring(index);

    //update the points in the UI view
    //move every character after the insert up by one
    for (int i = 0; i < this.points.length; i++) if (this.points[i] > index) this.points[i] += 1;
  }

}

