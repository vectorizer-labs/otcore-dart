import './Operation.dart';

class ExclusionTransformation
{
  static Operation ET(Operation Oa, Operation Ob)
  {
    if(Oa.is_insert && Ob.is_insert) return ET_II(Oa, Ob);
    else if(Oa.is_insert && !Ob.is_insert) return ET_ID(Oa,Ob);
    else if(!Oa.is_insert && Ob.is_insert) return ET_DI(Oa, Ob);
    else /*if(!Oa.is_insert && !Ob.is_insert)*/ return ET_DD(Oa, Ob);
  }

  static Operation ET_II(Operation Oa, Operation Ob)
  {
    //The insert of Oa comes before the insert of Ob
    //so there;s no effect on Oa
    if(Oa.index <= Ob.index) return Oa;

    //The insert of Oa comes after the insert of Ob
    //roll the index backward to remove the effect of Ob
    else /*if(Oa.index >= Ob.index)*/ return Oa.set_index(Oa.index - Ob.length());
  }

  static Operation ET_ID(Operation Oa, Operation Ob)
  {
    //Oa's insert comes before Ob's delete so there's no effect on Oa
    if(Oa.index <= Ob.index) Oa;

    //Oa's insert comes after Ob's delete so we need to roll the index forward
    //to give the effect of removing Ob's delete from the document
    else return Oa.set_index(Oa.index + Ob.length());
  }

  static Operation ET_DI(Operation Oa, Operation Ob)
  {
    //Oa's delete comes before Ob's insert so there's no effect
    if((Oa.index) <= Ob.index) Oa;
    //Oa's delete come's after Ob's insert so we need to roll the index backward
    //to give the effect of removing Ob's insert from the document
    else /*if (Oa.index >= Ob.index)*/ Oa.set_index(Oa.index - Ob.length());
  }

  static Operation ET_DD(Operation Oa, Operation Ob)
  {
    //Oa's delete comes before Ob's delete so no transformation needed
    if(Ob.index >= Oa.index) return Oa;
    //Ob's delete comes before Oa's so we increment the index by Ob's length
    else /*if(Oa.index >= Ob.index)*/ return Oa.set_index(Oa.index + Ob.length());
  }
}