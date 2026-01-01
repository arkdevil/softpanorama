Local aDbf:={}
Private nRecNo:=1
Set Color To "+GR/B"
Clear
@ 1,1 Say "Создание тестовой базы данных "
aAdd(aDbf,{"field1","Character",6 ,0 })
aAdd(aDbf,{"field2","Character",6 ,0 })
aAdd(aDbf,{"field3","Character",6 ,0 })
aAdd(aDbf,{"field4","Character",6 ,0 })
DbCreate("Test",aDbf)
@ 2,1 Say "Заполнение тестовой базы данных "
Use Test Alias test New
For i:=1 to 10000
test->(DbAppend())
test->field1:="t"+str(i,5)
test->field2:="e"+str(i,5)
test->field3:="s"+str(i,5)
test->field4:="t"+str(i,5)
Next
test->(DbGoTop())
@ 3,1 Say "Построение индекса ,запись номер->"Color "+GR/B"
test->(DbCreateInd("test","Upper(field4)",{||ShowProg(Upper(field4))}))
close test

function ShowProg(aaa)
@ 3,1 Say "Построение индекса ,запись номер->"+Str(nRecNo++)
Return aaa
