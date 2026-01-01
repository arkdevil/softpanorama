*!*********************************************************************
*! Function: YNBox(<y>,<x>[,<Prompt>[,<Head>]])
*! Notes:    Построение pop-up окна типа да/нет
*!           возвращает логическое значение; если y или x <0 - центрует

FUNCTION  YNBox
    PARAMETERS Y,X,Prompt,Head
    IF  PCOUNT()<4
        Head=""
    ENDIF
    IF  PCOUNT()<3
        Prompt=""
    ENDIF

    * определение размеров
    PRIVATE Reply,SavScr,J,Height,Width
    Height=IF(LEN(Prompt)=0,3,4)
    Width=MAX(MAX(LEN(TRIM(Head))+2,9) ,LEN(Prompt)+2)
    Width=IF(Width>80,80,Width)

    * центровка окна при отрицательных координатах
    IF  X<0
      X=INT((MAXCOL()+1-Width)/2)
      X=If(X<0,0,X)
    ENDIF
    IF  Y<0
        Y=INT((MAXROW()+1-Height)/2)
        Y=If(Y<0,0,Y)
    ENDIF

    * раскрыть окно
    SAVE SCREEN TO SavScr
    SETCOLOR(SysWBdCol)
    WEXPAND(Y,X,Y+Height-1,X+Width-1,WnBorder+WnBackgr)

    * заголовок
    SETCOLOR(SysWHdCol)
    @ Y,X+(Width+1-LEN(TRIM(Head)))/2 SAY TRIM(Head)
    J=1

    * текст в окне
    IF  LEN(Prompt)<>0
        SETCOLOR(SysWTxCol)
        @ Y+J,X+(Width+1-LEN(TRIM(Prompt)))/2 SAY TRIM(Prompt)
        J=2
    ENDIF

    * меню
    SETCOLOR(SysMLoCol+","+SysMHiCol)
    @ Y+J,X+INT((Width-7)/2)+4 Prompt "НЕТ"
    @ Y+J,X+INT((Width-7)/2) Prompt "ДА "
    MENU TO Reply
    SETCOLOR(SysWBdCol)
    WSHRINK(Y,X,Y+Height-1,X+Width-1,WnBorder+WnBackgr,SavScr)
RETURN IF(Reply=2,.T.,.F.)
*** End of YNBox() ***********
