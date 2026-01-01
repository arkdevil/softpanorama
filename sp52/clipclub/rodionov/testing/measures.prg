// Временные показатели эффективности различных методов вызова процедур
// в Clipper 5.01
#xcommand FOR <i>:=<s> TO <n> DO <*statement*> =>;
         FOR <i>:=<s> TO <n> ; <statement> ; END

local xClass:=__classnew("xClass",1)
local xObject,i,j:=0,a,k,idle
local tstCount:=32000
__classadd(xClass,"xSelector","xMethod")
xObject:=__classins(xClass)
xObject[1]:=0


? "Испытания",tstCount,'раз'

? "Пустой проход"
i:=seconds()
for k:=1 to tstCount
  j:=j+1; j:=j-1
end
idle:=seconds()-i
? "Время",idle

? "Обращение напрямую"
i:=seconds()
for k:=1 to tstCount
  j:=j+1; j:=j-1
  a:=xObject[1]
end
? "Время",seconds()-i-idle

? "Обращение через метод"
i:=seconds()
for k:=1 to tstCount
  j:=j+1; j:=j-1
  a:=xObject:xSelector(xObject)
end
? "Время",seconds()-i-idle

? "Вызов через функцию"
i:=seconds()
for k:=1 to tstCount
  j:=j+1; j:=j-1
  a:=xFunction(xObject)
end
? "Время",seconds()-i-idle

? "Вызов через блок"
i:=seconds()
for k:=1 to tstCount
  j:=j+1; j:=j-1
  a:=eval({|x| x[1] } ,xObject)
end
? "Время",seconds()-i-idle

function xMethod(xParam)
  return (qself()[1])

function xFunction(xParam)
  return (xParam[1])

