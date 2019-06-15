import 'dart:html';

import 'Operation.dart';
import 'OperationResult.dart';

class InclusionTransformation
{
  //Precondition: Oa AND Ob HAVE THE SAME CONTEXT i.e. the same ID
  //Postcondition : Ob -> Oa' i.e. 
  OperationResult IT(Operation Oa, Operation Ob)
  {
    
    Operation OaPrime = Operation.from(Oa)//deep copy to create a separate Oa'
                                 .roll_revision_forward();//increment the id by 1 to create Oa'

    if(Oa.is_insert && Ob.is_insert) return IT_II(OaPrime, Ob);
    else if(Oa.is_insert && !Ob.is_insert) return IT_ID(OaPrime, Ob);
    else if(!Oa.is_insert && Ob.is_insert) return IT_DI(OaPrime, Ob);
    else /*if(!Oa.is_insert && !Ob.is_insert)*/ return IT_DD(OaPrime, Ob);
  }

  OperationResult IT_II(Operation Oa, Operation Ob)
  {
    //Oa's effect is before Ob so no Transformation needed
    if(Oa.index < Ob.index) return OperationResult.from_single(Oa);
    //Oa's effect is after Ob so increment the index to account for Ob 
    else return OperationResult.from_single(Oa.roll_index_forward(Ob.object.length));
  }

  OperationResult IT_ID(Operation Oa, Operation Ob)
  {
    //Oa's effect is before Ob so no Transformation needed
    if(Oa.index <= Ob.index) return OperationResult.from_single(Oa);
    else if (Oa.index > (Ob.index + Ob.object.length)) return OperationResult.from_single(Oa.roll_index_backward(Ob.object.length));
    else return OperationResult.from_single(Oa.set_index_to_Ob(Ob));//TODO SAVE_LI
  }

  OperationResult IT_DI(Operation Oa, Operation Ob)
  {
    //Ob comes causally after Oa so no Transformation needed
    if(Ob.index >= (Oa.index + Oa.object.length)) return OperationResult.from_single(Oa);
    else if( Oa.index >= Ob.index) return OperationResult.from_single(Oa.roll_index_forward(Ob.object.length));
    else return split_deletion(Oa,Ob);
  }

  //creates a split of a delete operation 
  //in the case that a concurrent operation to this delete is an insert
  //that happens to be in the middle of our delete operation
  OperationResult split_deletion(Operation Oa, Operation Ob)
  {
    Operation Oa1 = new Operation(false, Ob.index - Oa.index, Oa.index, Oa.id, Oa.time_stamp, Oa.user_id);
    Operation Oa2 = new Operation(false, Oa.object - (Ob.index - Oa.index), (Ob.index + Ob.object), Oa.id, Oa.time_stamp, Oa.user_id);

    return OperationResult.from_double(Oa1, Oa2);
  }

  OperationResult IT_DD(Operation Oa, Operation Ob)
  {
    //Oa's effect is before Ob so no Transformation needed
    if(Ob.index >= (Oa.index + Oa.object)) return OperationResult.from_single(Oa);
    else if(Oa.index >= (Ob.index + Ob.object)) return OperationResult.from_single(Oa.roll_index_backward(Ob.object));
    else
    {
      if((Ob.index < Oa.index) && (Oa.index + Oa.object) <= (Ob.index + Ob.object)) OperationResult.from_single(Oa.set_length_to_0());
      else if((Ob.index <= Oa.index) && (Oa.index + Oa.object) > (Ob.index + Ob.object))
      {
        OperationResult.from_single(Oa.set_index_to_Ob(Ob)
                       .set_length(Oa.index + Oa.object - (Ob.index + Ob.object)));
      }
      else if((Ob.index > Oa.index) && (Ob.index + Ob.object) >= (Oa.index + Oa.object)) return OperationResult.from_single(Oa.set_length(Ob.index - Oa.index));
      else return OperationResult.from_single(Oa.set_length(Oa.object - Ob.object));//TODO: SAVE_LI

    }

  }

}