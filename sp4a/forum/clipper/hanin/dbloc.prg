/*******************************************************
*            Файл dbloc.prg
*
*     Программа иллюстрирует пример замены конструкции
*     WHILE ... END на DBEVAL(), определяет выигрыш во 
*     времени выполнения при использовании DBEVAL()
*
*     Киев, "ИнфоМир", CLIPPER 5.0
*     Август, 1992,  Ханин С.Г., Ханин А.Г.
********************************************************/
LOCAL time1,time2,mas1:={},mas2:={}
USE gorod NEW
**************
time1:=SECONDS()
LOCATE FOR SUBSTR(gorod->city,1,1)=="Л"
WHILE !EOF()
  AADD(mas1,RECNO())
  CONTINUE
END
time2:=SECONDS()
? time2-time1
**************
time1:=SECONDS()
DBEVAL({||IF(SUBSTR(gorod->city,1,1)=="Л",AADD(mas2,RECNO()),NIL)})
time2:=SECONDS()
? time2-time1
