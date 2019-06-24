import '../../Peer.dart';
import '../../Transformation/string-wise/Operation.dart';

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
  Operation merge_op()
  {

  }

  //All Operation in EC(O) are causally preceding  O.
  //It must be that DC(O) = EC(O) so no transformation needed
  Operation case1()
  {

  }

  //Operations causally preceeding O are listed in EC(O) before operations concurrent to O
  //Since EO1 -> O, EO2 || O, EO3 || O, by transforming O against EO2 and EO3 in sequence
  //we get EO such that DC(EO) = EC(O)
  Operation case2()
  {

  }

  //At least one causally preceeding operation is positioned after a concurrent operation in EC(O).
  //Since EO1 -> O, EO2 || O, EO3 -> O it must be that DC(O) = [EO1, EO3']
  //where EO3' is the original form of EO3 when O was generated
  Operation case3()
  {

  }
  
}