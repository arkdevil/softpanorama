// Тестирование основных функций Object DBKit
#include "classes.ch"
#include "oop.ch"

#define ANIMAL_SIZE 2
#define BIRD_SIZE ANIMAL_SIZE+1

#define AN_WEIGHT 1
#define AN_SIZE   2
#define BR_WINGS  AN_SIZE+1

local ANIMAL,BIRD,DUCK

? "start"
class ANIMAL ancestor Object size ANIMAL_SIZE ;
  variables ;
     Weight is anWeight, ;
     Size   is anSize  ;
  methods ;
     INIT is anInit

class BIRD ancestor ANIMAL size BIRD_SIZE ;
  methods ;
       INIT is brInit ;
  variables ;
       Wings is brWings

new DUCK of BIRD with 1,2,3,4,5

duck:init(2.5,0.3,2)

? duck:weight,duck:size,duck:wings

duck:wings :=1
duck:weight:=1.5

? duck:weight,duck:size,duck:wings
? duck:class:name,duck:class:len,duck:class:number
? duck:class():ancestor:name,duck:class():ancestor:len,duck:class():ancestor:number
? duck:isMemberOf("Bird"),duck:respondsTo("size"),duck:respondsTo("Kaka")
? duck:isKindOf("Bird"),duck:isKindOf("Animal"),duck:isKindOf("Object"),duck:isKindOf("Medwed")
? duck:class:getmethod("init"),duck:class:getmethod("wings")
? duck:class:getmethod("size")
? memory(0),memory(1),memory(2)

animal:=animal:done()
duck:=NIL
bird:=NIL
? memory(0),memory(1),memory(2)

/////////////////////////
constructor aninit with weight,size
 selfData[AN_WEIGHT]:=weight
 selfdata[AN_SIZE]:=size
 ? "aninit",weight,size
end_constructor

constructor brinit with weight,size,wings
  local oanc:=selfanc():new()
  assign oanc := self()
  oanc:init(weight,size)
  selfData[BR_WINGS]:=wings
  ? "brinit",wings
end_constructor

rvmethod anWeight with AN_WEIGHT
vmethod  anSize   with AN_SIZE
vmethod  brWings  with BR_WINGS

