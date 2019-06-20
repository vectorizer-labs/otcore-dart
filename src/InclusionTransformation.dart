import 'DocState.dart';
import 'Operation.dart';
import 'OperationResult.dart';

class InclusionTransformation
{
  //Precondition: Oa AND Ob HAVE THE SAME CONTEXT i.e. the same ID
  //Postcondition : Ob -> Oa' i.e. 
  static OperationResult IT(Operation Oa, Operation Ob, DocState dc)
  {


    Operation OaPrime = Operation.from(Oa)//deep copy to create a separate Oa'
                                 .roll_revision_forward();//increment the id by 1 to create Oa'

    //Check_RA
    OaPrime = dc.Check_RA(OaPrime, Ob);

    if(Oa.is_insert && Ob.is_insert) return IT_II(OaPrime, Ob, dc);
    else if(Oa.is_insert && !Ob.is_insert) return IT_ID(OaPrime, Ob, dc);
    else if(!Oa.is_insert && Ob.is_insert) return IT_DI(OaPrime, Ob, dc);
    else /*if(!Oa.is_insert && !Ob.is_insert)*/ return IT_DD(OaPrime, Ob, dc);
  }

  static OperationResult IT_II(Operation Oa, Operation Ob, DocState dc)
  {
    //Oa's effect is before Ob so no Transformation needed
    if(Oa.index < Ob.index) return OperationResult.from_single(Oa);

    //Oa's effect is after Ob so increment the index to account for Ob 
    else return OperationResult.from_single(Oa.set_index(Oa.index + Ob.length()));
  }

  static OperationResult IT_ID(Operation Oa, Operation Ob, DocState dc)
  {
    //Oa's effect is before Ob so no Transformation needed
    if(Oa.index <= Ob.index) return OperationResult.from_single(Oa);

    //Oa's effect is after Ob so we need to roll back the index of Oa by the amount deleted by Ob
    else if (Oa.index > Ob.end()) return OperationResult.from_single(Oa.set_index(Oa.index - Ob.length()));

    //Oa's effect is in the middle of Ob's delete section
    //since that section has already been deleted because Ob has been applied to the document
    //the index reference to the char inside the delete section no longer exists
    //therefore, we put the index of Oa at the begginning of the deleted section
    //and we save the real index reference(to a nonexistent character) in SAVE_LI
    //in case we need to exclude Oa later
    else
    {
      //Save_LI
      Operation OaPrime = Operation.from(Oa).set_index(Ob.index);
      dc.Save_LI(Oa, OaPrime);

      //return LIed Oa'
      return OperationResult.from_single(OaPrime);
    } 
  }

  static OperationResult IT_DI(Operation Oa, Operation Ob, DocState dc)
  {
    //the delete of Oa comes before the insert of Ob so no transformation needed  
    if(Ob.index >= Oa.end()) return OperationResult.from_single(Oa);

    //The delete of Oa comes after the insert of Ob
    //We have to roll the index of Oa forward to account for Ob
    else if( Oa.index >= Ob.index) return OperationResult.from_single(Oa.set_index(Oa.index + Ob.length()));
    else 
    {
    //create a split of a delete operation 
    //in the case that a concurrent operation to this delete is an insert
    //that happens to be in the middle of our delete operation
      Operation Oa1 = new Operation(false, Ob.index - Oa.index, Oa.index, Oa.id, Oa.time_stamp, Oa.user_id);
      Operation Oa2 = new Operation(false, Oa.length() - (Ob.index - Oa.index), Ob.end(), Oa.id, Oa.time_stamp, Oa.user_id);
      
      return OperationResult.from_double(Oa1, Oa2);
    }
  }

  static OperationResult IT_DD(Operation Oa, Operation Ob, DocState dc)
  {
    //The delete of Oa is before the delete of Ob so no transformation needed
    if(Ob.index >= Oa.end()) return OperationResult.from_single(Oa);

    //the start of the delete of Oa is after the delete of Ob
    //so adjust the index by the length of Ob 
    else if(Oa.index >= Ob.end()) return OperationResult.from_single(Oa.set_index(Oa.index - Ob.length()));

    //its a cluster-guc of overlapping deletes 
    //(info is lost no matter what so we must save the original Oa using SAVE_LI)
    else
    {
      Operation OaPrime = Operation.from(Oa);

      //The case where Oa is swallowed inside Ob
      //i.e. \<------------------------->\Ob
      //         \<------->\Oa
      if((Ob.index < Oa.index) && Oa.end() <= Ob.end()) OaPrime = OaPrime.set_length(0);

      //The case where Oa starts at the same index as Ob or in the middle of Ob
      //but Oa ends after Ob ends so we just trim off the beggining thats inside Ob
      // i.e  \<--------->\Ob
      //         \<-------\<cut---------->\Oa
      else if((Ob.index <= Oa.index) && Oa.end() > Ob.end())
      {
        OaPrime = OaPrime.set_index(Ob.index)
                         .set_length(Oa.end() - (Ob.end()));
      }

      //The case where Ob starts inside Oa and ends after or at the same index as Oa
      //so we just trim off the end thats inside Ob
      //i.e.          \<------------------------------>\Ob
      //        \<---------------------------->\ Oa
      else if((Ob.index > Oa.index) && (Ob.end()) >= (Oa.end())) OaPrime = OaPrime.set_length(Ob.index - Oa.index);

      //The case where Ob is swallowed by Oa
      //since Ob has already been applied and deleted a sub region of
      //the region to be deleted by Oa we just shorten Oa by the length of Ob              
      //i.e.        \<-------------->\ Ob
      //      \<----\cut----------cut\----->\Oa
      else OaPrime = OaPrime.set_length(Oa.length() - Ob.length());

      //Save_LI
      dc.Save_LI(Oa, OaPrime);
      return OperationResult.from_single(OaPrime);
    }

  }

}