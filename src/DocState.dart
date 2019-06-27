import './Transformation/character-wise/Operation.dart';
import 'Algo/Levien/LevienTree.dart';

// Copyright 2016 Google Inc. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//This algorithm from https://github.com/google/ot-crdt-papers/blob/master/ot_toy.js
// has been adapted to a more readable version below that includes 
//references from the source material by Raph Levien and the GOTO paper:
//http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.53.933&rep=rep1&type=pdf

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
    //if its an insert call insertIntoString
    //else deleteFromString
    O.is_insert ? insertIntoString(O) : deleteFromString(O);
  }

  void deleteFromString(Operation O)
  {
    //if we already deleted the character in question then 
    //ignore this operation because the effect is the same 
    if (this.deletes.contains(O.index)) return;

    //otherwise get the log space index
		int index = this.deletes.getLogSpaceIndex(O.index);
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

  //gets the log space index for this docstate
  //used for creating new insert operations in the GUI
  int getLogSpaceIndex(int index) => this.deletes.getLogSpaceIndex(index);

}

