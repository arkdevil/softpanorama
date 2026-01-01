*!*********************************************************************
*! Function: XMenu(<y>,<x>,<Массив опций>[,<Заголовок>])
*! Notes:    Простое вертикальное pop-up меню
*!           Возвращает выбранную опцию; если y или x <0 - центрует
*!

FUNCTION  XMenu
  PARAMETERS Y,X,OptArray,Head
  PRIVATE NumOpts,Width,J,Height,SelOpt

  IF  PCOUNT()<4
      Head=""
  ENDIF

  SelOpt=1

  * Определение размеров окна
  NumOpts=LEN(OptArray)
  Width=LEN(TRIM(Head))+2
  Height=IF(NumOpts+Y>24,24-Y,NumOpts)
  FOR J=1 TO NumOpts
    Width=MAX(Width,LEN(OptArray[j])+2)
    IF  Width>79-X+2
        Width=79-X+2
        EXIT
    ENDIF
  NEXT
  Width=IF(Width>80,80,Width)
  Height=IF(Height>18,18,Height)

  * центровка окна при отрицательных координатах
  IF  X<0
    X=INT((MAXCOL()+1-Width)/2)
    X=If(X<0,0,X)
  ENDIF
  IF  Y<0
      Y=INT((MAXROW()+1-Height)/2)
      Y=If(Y<0,0,Y)
  ENDIF

  SAVE SCREEN TO SavScr
  SETCOLOR(SysWBdCol)
  WEXPAND(Y,X,Y+Height+1,X+Width-1,WnBorder+WnBackgr)

  * Заголовок
  SETCOLOR(SysWHdCol)
  @ Y,X+(Width+1-LEN(TRIM(Head)))/2 SAY TRIM(Head)

  * Выбор
  SETCOLOR(SysMLoCol+","+SysMHiCol+",,,"+SysMUnCol)
  SelOpt=ACHOICE(Y+1,X+1,Y+Height,X+Width-2,OptArray,.T.,"",SelOpt)

  SETCOLOR(SysWBdCol)
  WSHRINK(Y,X,Y+Height+1,X+Width-1,WnBorder+WnBackgr,SavScr)
  RETURN SelOpt
*** End of XMenu() ***********