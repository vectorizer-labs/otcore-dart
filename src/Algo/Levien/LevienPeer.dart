import '../../DocState.dart';
import '../../Peer.dart';
import '../../Transformation/character-wise/Operation.dart';
import 'LevienTree.dart';

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

class LevienPeer extends Peer
{

  //Handles 3 cases as seen in the GOTO paper
  Operation merge_op(Operation O, DocState dc)
  {

  }

  //All Operation in EC(O) are causally preceding  O.
  //It must be that DC(O) = EC(O) so no transformation needed
  void case1(Operation O, DocState dc)
  {
    if (this.revision < dc.log.length && dc.log[this.revision].id == O.id) 
    {
			// we already have this, roll revision forward
			this.revision++;
			while (this.revision < dc.log.length && this.context.contains(dc.log[this.revision].id)) 
      {
				this.context.remove(dc.log[this.revision].id);
				this.revision++;
			}
			return;
		}
  }

  //Operations causally preceeding O are listed in EC(O) before operations concurrent to O
  //Since EO1 -> O, EO2 || O, EO3 || O, by transforming O against EO2 and EO3 in sequence
  //we get EO such that DC(EO) = EC(O)
  void case2(Operation O, DocState dc)
  {
    for (var ix = this.revision; ix < dc.log.length; ix++) 
    {
			if (dc.log[ix].id == O.id) {
				// we already have this, but can't roll revision forward
				this.context.add(O.id);
				return;
			}
		}
  }

  //At least one causally preceeding operation is positioned after a concurrent operation in EC(O).
  //Since EO1 -> O, EO2 || O, EO3 -> O it must be that DC(O) = [EO1, EO3']
  //where EO3' is the original form of EO3 when O was generated
  Operation case3(Operation O, DocState dc)
  {
    // we don't have it, need to merge
		List<List<int>> ins_list = new List();

    //a list of all operations from the end of the log to this.revision
    //with their state as if all operations were undone back to this.revision  
    LevienTree T = new LevienTree();

    //a list of all operations CONCURRENT TO O
    // from the end of the log to this.revision
    //these operations are transformed against the non concurrent members of set T
    //until all the concurrent operations are at the end of the log
		LevienTree S = new LevienTree();
  
    //loop backwards through the log building up patches S and T
    //until we reach the revision this context is up to date on
		for (var ix = dc.log.length - 1; ix >= this.revision; ix--) 
    {
			Operation current = dc.log[ix];

      //we don't have to care about delete operations because tombstones
			if (!current.is_insert) continue;

      //handle the insert
      //get the real log space index
			int i = S.getLogSpaceIndex(current.index);


			if (!this.context.contains(current.id)) 
      {
				ins_list.add([T.getStringSpaceIndex(i), current.user_id]);
				T.insert(i);
			}
			S.insert(i);
		}
		for (var i = ins_list.length - 1; i >= 0; i--) O = transform_ins(O, ins_list[i][0], ins_list[i][1]);
  }
  
  Operation transform_ins(Operation op1, int ix, int user_id) 
  {
	if (op1.is_insert) 
  {
		if (op1.index < ix || (op1.index == ix && op1.user_id < user_id)) return op1;

		return op1.set_index(op1.index + 1);
	} 
  else 
  { // op1.ty is del
		if (op1.index < ix) return op1;

		return op1.set_index(op1.index + 1);
	}
}


}