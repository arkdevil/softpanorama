*!*********************************************************************
*! Function: WaitBox(<y>,<x>[,<Prompt>[,<Head>])
*! Notes:    Окно с сообщением типа "Ждите"
*!           если y или x <0 - центрует

FUNCTION  WaitBox
PARAMETERS Y,X,Prompt,Head
PRIVATE Height,Width,j
J=0
IF  PCOUNT()<4
   Head=""
ENDIF
IF  PCOUNT()<3
   Prompt=""
ENDIF
* определение размеров окна
PRIVATE Height,Width
Width=MAX(MAX(LEN(TRIM(Head))+2,9),LEN(Prompt)+2)
Width=IF(Width>80,80,Width)
Height=IF(LEN(Prompt)=0,3,4)
Height=IF(Height>22,22,Height)

* центровка при отрицательных координатах
If  X<0
  X=INT((MAXCOL()+1-Width)/2)
  X=If(X<0,0,X)
EndIF
If  Y<0
  Y=INT((MAXROW()+1-Height)/2)
  Y=If(Y<0,0,Y)
EndIF

* заголовок
SETCOLOR(SysWBdCol)
WEXPAND(Y,X,Y+Height-1,X+Width-1,WnBorder+WnBackgr)
SETCOLOR(SysWHdCol)
@ Y,X+(Width+1-LEN(TRIM(Head)))/2 SAY TRIM(Head)

* текст в окне
IF  LEN(Prompt)<>0
    SETCOLOR(SysWTxCol)
    @ Y+1,X+(Width+1-LEN(TRIM(Prompt)))/2 SAY TRIM(Prompt)
ENDIF
*** End of WAITBOX() ***
RETURN .T.
*** End of YNBox() ***********
