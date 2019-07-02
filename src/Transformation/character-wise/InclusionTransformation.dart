import './Operation.dart';

class InclusionTransformation
{
  //Precondition: Oa AND Ob HAVE THE SAME CONTEXT i.e. the same ID
  //Postcondition : Ob -> Oa' i.e. 
  static Operation IT(Operation Oa, Operation Ob)
  {
    Operation OaPrime = Operation.from(Oa)//deep copy to create a separate Oa'
                                 .roll_revision_forward();//increment the id by 1 to create Oa'
    
    if(Oa.is_insert && Ob.is_insert) return IT_II(OaPrime, Ob);
    else if(Oa.is_insert && !Ob.is_insert) return IT_ID(OaPrime, Ob);
    else if(!Oa.is_insert && Ob.is_insert) return IT_DI(OaPrime, Ob);
    else /*if(!Oa.is_insert && !Ob.is_insert)*/ return IT_DD(OaPrime, Ob);
  }

  static Operation IT_II(Operation Oa, Operation Ob)
  {
    //Oa's effect is before Ob so no Transformation needed
    if(Oa.index < Ob.index) return Oa;

    //Oa's effect is after Ob so increment the index to account for Ob 
    else return Oa.set_index(Oa.index + Ob.length());
  }

  static Operation IT_ID(Operation Oa, Operation Ob)
  {
    //Oa's effect is before Ob so no Transformation needed
    if(Oa.index <= Ob.index) return Oa;
    
    //Oa's effect is after Ob so we need to roll back the index of Oa by the amount deleted by Ob
    else /*if (Oa.index > Ob.index)*/ return Oa.set_index(Oa.index - Ob.length());
  }

  static Operation IT_DI(Operation Oa, Operation Ob)
  {
    //the delete of Oa comes before the insert of Ob so no transformation needed  
    if(Ob.index >= Oa.index) return Oa;

    //The delete of Oa comes after the insert of Ob
    //We have to roll the index of Oa forward to account for Ob
    else /*if( Oa.index >= Ob.index)*/ return Oa.set_index(Oa.index + Ob.length());

  }

  static Operation IT_DD(Operation Oa, Operation Ob)
  {
    //The delete of Oa is before the delete of Ob so no transformation needed
    if(Ob.index >= Oa.index) return Oa;

    //the start of the delete of Oa is after the delete of Ob
    //so adjust the index by the length of Ob 
    else /*if(Oa.index >= Ob.index)*/ return Oa.set_index(Oa.index - Ob.length());
  }

}