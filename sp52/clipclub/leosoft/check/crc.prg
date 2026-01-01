#include "leo.ch"
#include "inkey.ch"
#include "directry.ch"
          
Function CheckSum()
LOCAL aBad := {},aDir := {},aDir1:={}
LOCAL cScreen := SaveScreen(9,20,12,60)
@ 9,20,12,60 Box B_DOUBLE Color "+W/B"
@ 9,21 Say(PadC(" Проверка целостности данных ",39) Color "+W/B"
If !(File("check.crc"))
   CreatNtx(aNtxData)
   CreatCrc()
Else
   cData:=MemoRead("Check.crc")
   If Len(cData)<Len(aNtxData)*25
      CreatNtx(aNtxData)
      CreatCrc()
   Else
       aDir := Directory("*.ntx")
       Creat Bar 11,23 LineLen 35 Count Len(aNtxData) to aBar
       For i:=1 to Len(aNtxData)
           Display Bar aBar
           If (nPos:=AScan(aDir,{|x| Upper(x[F_NAME])==Upper(aNtxData[i,3])}))==0
              AAdd(aBad,aNtxData[i])
           Else
              aDir1 := Directory(aNtxData[i,2])
              @ 10,21 Say PadC("Проверка "+aNtxData[i,1],38) Color "+GR/B"
              If (FileCheck(aDir[nPos,F_NAME]) != Val(SubStr(cData,(i-1)*25+1,12))).OR.;
                 (aDir1[1,F_DATE] != CtoD(SubStr(cData,(i-1)*25+13,8))).OR.;
                 ((aDir1[1,F_DATE] == CtoD(SubStr(cData,(i-1)*25+13,8))).AND.;
                  (SubStr(aDir1[1,F_TIME],1,5) != SubStr(cData,(i-1)*25+21,5)))
                 AAdd(aBad,aNtxData[i])
              EndIf
           EndIf
       Next
   EndIf
EndIf
RestScreen(9,20,12,60,cScreen)
Return NIL


Function CreatNtx(aNtx)
Creat Bar 11,23 LineLen 35 Count Len(aNtx) to aBar
For i:=1 To Len(aNtx)
    Display Bar aBar
    @ 10,21 Say PadC("Восстановление "+aNtx[i,1],38) Color "+GR/B"
    EVal(aNtx[i,4])
Next
Return NIL

Function CreatCrc()
LOCAL cStr := ""
LOCAL aDir := {}
LOCAL cScreen := SaveScreen(9,20,12,60)
@ 9,20,12,60 Box B_DOUBLE Color "+W/B"
@ 9,21 Say(PadC(" Проверка целостности данных ",39) Color "+W/B"
Creat Bar 11,23 LineLen 35 Count Len(aNtxData) to aBar
For i:=1 To Len(aNtxData)
    Display Bar aBar
    @ 10,21 Say PadC("Перепроверка "+aNtxData[i,1],39) Color "+GR/B"
    cStr += Str(FileCheck(aNtxData[i,3]),12)
    aDir := Directory(aNtxData[i,2])
    cStr := cStr+DtoC(aDir[1,F_DATE])+SubStr(aDir[1,F_TIME],1,5)
Next
RestScreen(9,20,12,60,cScreen)
MemoWrit("Check.crc",cStr)
Return (NIL)


Function RefResh()
LOCAL cScreen := SaveScreen(9,20,12,60)
@ 9,20,12,60 Box B_DOUBLE Color "+W/B"
@ 9,21 Say(PadC(" Перестройка индексов ",39) Color "+W/B"
CreatNtx(aNtxData)
CreatCrc()
RestScreen(9,20,12,60,cScreen)
Return .T.
