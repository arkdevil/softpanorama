#include "oop.ch"
/*работа с эквивалентными массивами*/

/*сложение двух массивов*/
function aPlus(a1,a2)
  local aret:=aclone(a1),i
  for i:=1 to len(a1) do aret[i]:=a1[i]+a2[i]
  return aret

/*вычитание двух массивов*/
function aMinus(a1,a2)
  local aret:=aclone(a1),i
  for i:=1 to len(a1) do aret[i]:=a1[i]-a2[i]
  return aret

/*сравнение двух массивов (по < )*/
function aLess(a1,a2)
  local i
  for i:=1 to len(a1)
    if a1[i] >= a2[i]
       return (FALSE)
    end
  next
  return TRUE

/*сравнение двух массивов (по > )*/
function aGreat(a1,a2)
  local i
  for i:=1 to len(a1)
    if a1[i] <= a2[i]
       return (FALSE)
    end
  next
  return TRUE

/*сравнение двух массивов (по = )*/
function aEqual(a1,a2)
  local i
  for i:=1 to len(a1)
    if a1[i] <> a2[i]
       return (FALSE)
    end
  next
  return TRUE

/* действительное удаление элемента из массива */
procedure aTrueDel(array,n)
   adel(array,n)
   asize(array,len(array)-1)


