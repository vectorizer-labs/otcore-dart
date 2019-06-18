import 'Operation.dart';
import 'OperationResult.dart';

class ExclusionTransformation
{
  OperationResult ET(Operation Oa, Operation Ob)
  {
    if(Oa.is_insert && Ob.is_insert) return ET_II(Oa, Ob);
    else if(Oa.is_insert && !Ob.is_insert) return ET_ID(Oa,Ob);
    else if(!Oa.is_insert && Ob.is_insert) return ET_DI(Oa, Ob);
    else /*if(!Oa.is_insert && !Ob.is_insert)*/ return ET_DD(Oa, Ob);
  }

  OperationResult ET_II(Operation Oa, Operation Ob)
  {
    //
    if(Oa.index <= Ob.index) return OperationResult.from_single(Oa);
    else if(Oa.index >= (Ob.index + Ob.length())) return OperationResult.from_single(Oa.roll_index_backward(Ob.length()));
    else return OperationResult.from_single(Oa.roll_index_backward(Ob.index)); //TODO:Save_RA
  }

  OperationResult ET_ID(Operation Oa, Operation Ob)
  {
    //Check LI
    if(Oa.index <= Ob.index) return OperationResult.from_single(Oa);
    else return OperationResult.from_single(Oa.roll_index_forward(Ob.length()));
  }

  OperationResult ET_DI(Operation Oa, Operation Ob)
  {
    if((Oa.index + Oa.length()) <= Ob.index) return OperationResult.from_single(Oa);
    else if (Oa.index >= Ob.index + Ob.length()) return OperationResult.from_single(Oa.roll_index_backward(Ob.length()));
    else
    {
      if((Ob.index <= Oa.index) && (Oa.index + Oa.length() <= Ob.index + Ob.length())) return OperationResult.from_single(Oa.roll_index_backward(Ob.length()));
      else if((Ob.index <= Oa.index) && (Oa.index + Oa.length() > Ob.index + Ob.length())) return split_deletion(Oa, Ob);
      else if((Oa.index < Ob.index) && (Ob.index + Ob.length()) <= (Oa.index + Oa.length())) return OperationResult.from_double(Ob.set_index_to_0(), Oa.set_length(Oa.length() - Ob.length()));
      else 
      {
        Operation Oa1 = Operation.from(Oa)
                               .set_length(Oa.index + Oa.length() - Ob.index)
                               .set_index(0);

        Operation Oa2 = Operation.from(Oa)
                               .set_length(Ob.index - Oa.index);
        
        return OperationResult.from_double(Oa1,Oa2);
      }
    }
  }

  OperationResult ET_DD(Operation Oa, Operation Ob)
  {
    //Check_LI
    if(Ob.index >= Oa.index + Oa.length()) return OperationResult.from_single(Oa);
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