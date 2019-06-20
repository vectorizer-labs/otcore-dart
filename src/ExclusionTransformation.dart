import 'DocState.dart';
import 'Operation.dart';
import 'OperationResult.dart';

class ExclusionTransformation
{
  static OperationResult ET(Operation Oa, Operation Ob, DocState dc)
  {
    //TODO Fix
    Oa = dc.Check_RA(Oa, Ob);


    if(Oa.is_insert && Ob.is_insert) return ET_II(Oa, Ob);
    else if(Oa.is_insert && !Ob.is_insert) return ET_ID(Oa,Ob);
    else if(!Oa.is_insert && Ob.is_insert) return ET_DI(Oa, Ob);
    else /*if(!Oa.is_insert && !Ob.is_insert)*/ return ET_DD(Oa, Ob);
  }

  static OperationResult ET_II(Operation Oa, Operation Ob)
  {
    //The insert of Oa comes before the insert of Ob
    //so there;s no effect on Oa
    if(Oa.index <= Ob.index) return OperationResult.from_single(Oa);

    //The insert of Oa comes after the insert of Ob
    //roll the index backward to remove the effect of Ob
    else if(Oa.index >= Ob.end()) return OperationResult.from_single(Oa.set_index(Oa.index - Ob.length()));

    //Oa starts in the middle of Ob
    //subtract off the part of Ob that comes before Oa 
    //as a relative index
    else return OperationResult.from_single(Oa.set_index(Oa.index - Ob.index)); //TODO:Save_RA
  }

  static OperationResult ET_ID(Operation Oa, Operation Ob)
  {
    //TODO: Check LI
    //Oa = doc.Check_LI(Oa,Ob)

    //Oa's insert comes before Ob's delete so there's no effect on Oa
    if(Oa.index <= Ob.index) return OperationResult.from_single(Oa);

    //Oa's insert comes after Ob's delete so we need to roll the index forward
    //to give the effect of removing Ob's delete from the document
    else return OperationResult.from_single(Oa.set_index(Oa.index + Ob.length()));
  }

  static OperationResult ET_DI(Operation Oa, Operation Ob)
  {
    //Oa's delete comes before Ob's insert so there's no effect
    if((Oa.end()) <= Ob.index) return OperationResult.from_single(Oa);
    //Oa's delete come's after Ob's insert so we need to roll the index backward
    //to give the effect of removing Ob's insert from the document
    else if (Oa.index >= Ob.end()) return OperationResult.from_single(Oa.set_index(Oa.index - Ob.length()));
    //its a cluster guc of overlapping deletes and inserts
    else
    {
      //Oa is swallowed by Ob so we roll back the index by the index of Ob 
      //to remove the effect of Ob's insert and we save it as relative 
      //i.e. \<----------------------->\Ob
      //            \<-------->\Oa 
      if((Ob.index <= Oa.index) && (Oa.end() <= Ob.end())) return OperationResult.from_single(Oa.set_index(Oa.index - Ob.index));

      //Ob's insert ends in the middle of Oa
      //so we split Oa and make 2 Ob relative slices
      //i.e. \<----------------------------->\Ob
      //              \<-------------------------------------->\Oa
      //              \<--------------------->\Oa1
      //                                      \<--------------->\Oa2
      else if((Ob.index <= Oa.index) && (Oa.end() > Ob.end())) 
      {
        Operation Oa1 = Operation.from(Oa)
                                 .set_length(Ob.end() - Oa.index)
                                 .set_index(Oa.index - Ob.index);

        Operation Oa2 = Operation.from(Oa)
                                 .set_length(Oa.end() - Ob.end())
                                 .set_index(Ob.index);
        
        return OperationResult.from_double(Oa1,Oa2);
      }

      //Oa swallows Ob so we split Oa in two
      //i.e.          \<---------->\Ob
      //      \<------------------------------>\Oa
      //              \<---------->\Oa1
      //                           \<---->\Oa2
      else if((Oa.index < Ob.index) && (Ob.end()) <= (Oa.end())) 
      {
        Operation Oa1 = Operation.from(Oa)
                                 .set_length(Ob.length())
                                 .set_index(0);

        Operation Oa2 = Operation.from(Oa)
                                 .set_length(Oa.length() - Ob.length());
        
        return OperationResult.from_double(Oa1,Oa2);
      }

      //Oa's delete ends in the middle of Ob's insert ?
      //i.e.        \<----------------->\Ob
      //    \<----------------->\Oa
      //            \<------>\Oa1
      //    \<----->\Oa2
      else 
      {
        Operation Oa1 = Operation.from(Oa)
                                 .set_length(Oa.end() - Ob.index)
                                 .set_index(0);

        Operation Oa2 = Operation.from(Oa)
                                 .set_length(Ob.index - Oa.index);
        
        return OperationResult.from_double(Oa1,Oa2);
      }
    }
  }

  static OperationResult ET_DD(Operation Oa, Operation Ob)
  {
    //Check_LI
    if(Ob.index >= Oa.end()) return OperationResult.from_single(Oa);
    else if(Oa.index >= Ob.index) return OperationResult.from_single(Oa.set_index(Oa.index + Ob.length()));
    else 
    {
      Operation Oa1 = Operation.from(Oa)
                               .set_length(Ob.index - Oa.index);

      Operation Oa2 = Operation.from(Oa)
                               .set_length(Oa.length() - (Ob.index - Oa.index));

      return OperationResult.from_double(Oa1,Oa2);
    }
  }
}