*\(*)/*\(*)/*\(*)/*\(*)/*\*
*  PROCEDURE KREST     && *  ПОЗИЦИОНИРОВАНИЕ КУРСОРА НА ЭКРАНЕ ДИСПЛЕЯ
*\(*)/*\(*)/*\(*)/*\(*)/*\*  С ОТОБРАЖЕНИЕМ ЕГО КООРДИНАТ
*
* Задействованы клавиши со стрелками и клавиши Enter, Home, End, Tab
PARAMETER Kre_PRG, Kre_NUMB, Kre_VAR
*IF  Kre_PRG="KREST"
*     RETURN && ЧТОБЫ НА WAIT НЕ ВЫЙТИ И САМ СЕБЯ НЕ ВЫЗВАТЬ
*ENDIF
* set curs off
M->ROW=ROW() && КООРДИНАТЫ КУРСОРА НАДО ЖЕ КОНЕЧНО ЗАПОМНИТЬ
M->COL=COL()
Kre_COLOR=SETCOLOR()
*SAVE SCREEN TO Kre_SCR
*SET COLOR TO W/N
CLEAR TYPEAHEAD
Kre_S    =CHR(01)  && РОЖИЦА
IF TYPE("Kre_ROW0") # "N"
  PUBLIC Kre_ROW0,Kre_COL0,Kre_ROW0W,Kre_COL0W,Kre_ROWT,Kre_COLT
  Kre_ROW0 =0        && ОТНОСИТЕЛЬНО ЧЕГО ПОЗИЦИОНИРОВАТЬ
  Kre_COL0 =0
  Kre_ROW0W=24
  Kre_COL0W=79
  Kre_ROWT =M->ROW   && ТЕКУЩИЕ КООРДИНАТЫ
  Kre_COLT =M->COL
ENDIF
Kre_ROWS =00       && КОРДИНАТЫ ВЫВОДА КООРДИНАТ
Kre_COLS =00
Kre_ROWT1=M->ROW
Kre_COLT1=M->COL
    Kre_SAVE1=SAVESCREEN(0,0,1,40)
Kre_T   = .T.
Kre_KEY = 1
Kre_61C=C(61) && Подвал
Kre_63C=C(63) && Подвал
DO WHILE   Kre_KEY # 27
 IF Kre_T
    Kre_ROWT2=Kre_ROWT
    IF Kre_ROWT2 > 23
       Kre_ROWT2 = 23
    ENDIF
    Kre_COLT2=Kre_COLT
    IF Kre_COLT2 > 78
       Kre_COLT2 = 78
    ENDIF
    Kre_SAVE2=SAVESCREEN(Kre_ROWT2,Kre_COLT2,Kre_ROWT2+1,Kre_COLT2+1)
 ENDIF
 SET COLOR TO (Kre_61C)
 Kre_NULS=STR(Kre_ROWT-Kre_ROW0,3)+STR(Kre_COLT-Kre_COL0,3)+" Enter - нач. коорд., Esc - выход"
 @ Kre_ROWS,Kre_COLS    SAY Kre_NULS
 SET COLOR TO (Kre_63C)
 @ Kre_ROWS,Kre_COLS+07 SAY "Enter"
 @ Kre_ROWS,Kre_COLS+28 SAY "Esc"
 @ Kre_ROWT,Kre_COLT    SAY Kre_S
 Kre_KEY=INKEY(0)
 Kre_T=.T.
 DO CASE
    CASE Kre_KEY  =05                      && ВВЕРХ
         Kre_ROWT =ABS(MOD(Kre_ROWT-1,25))
    CASE Kre_KEY  =24                      && ВНИЗ
         Kre_ROWT =ABS(MOD(Kre_ROWT+1,25))
    CASE Kre_KEY  =04                      && ВПРАВО
         Kre_COLT =ABS(MOD(Kre_COLT+1,80))
    CASE Kre_KEY  =19                      && ВЛЕВО
         Kre_COLT =ABS(MOD(Kre_COLT-1,80))
    CASE Kre_KEY  =13                      && НОВЫЕ КООРДИНАТЫ
         Kre_ROW0W=Kre_ROW0
         Kre_COL0W=Kre_COL0
         Kre_ROW0 =Kre_ROWT
         Kre_COL0 =Kre_COLT
    CASE Kre_KEY  =01                      && Home ВОЗВРАТ К КООРД. КУРСОРА
         Kre_ROWT =Kre_ROW0
         Kre_COLT =Kre_COL0
    CASE Kre_KEY  =06                      && End  ВОЗВРАТ К ПРЕД. КООРД.
         Kre_ROWT =Kre_ROW0W
         Kre_COLT =Kre_COL0W
    CASE Kre_KEY  =09                      && Tab  ПЕРЕКЛЮЧЕНИЕ КООРДИНАТ
         Kre_NUL1 =Kre_ROW0
         Kre_NUL2 =Kre_COL0
         Kre_ROW0 =Kre_ROW0W
         Kre_COL0 =Kre_COL0W
         Kre_ROW0W=Kre_NUL1
         Kre_COL0W=Kre_NUL2
    OTHERWISE
         Kre_T=.F.
 ENDCASE
 IF Kre_T
    RESTSCREEN(Kre_ROWT2,Kre_COLT2,Kre_ROWT2+1,Kre_COLT2+1,Kre_SAVE2)
 ENDIF
ENDDO
    RESTSCREEN(Kre_ROWT,Kre_COLT,Kre_ROWT+1,Kre_COLT+1,Kre_SAVE2)
    RESTSCREEN(0,0,1,40,Kre_SAVE1)
* * * * * * * *
 SETCOLOR(Kre_COLOR)
* set curs on
@ M->ROW,M->COL SAY ""
*CLEAR TYPEAHEAD
IF  Kre_PRG="SUPERMEN"
   KEYBOARD(CHR(13))
ENDIF
* RESTORE SCREEN FROM Kre_SCR
 RELEASE ALL LIKE Kre_*
 RETURN
