*!*********************************************************************
*! Function: MESSAGE(<ExpC>)
*!    Notes: выводит pop-up сообщение (небольшое)

FUNCTION MESSAGE
PARAMETERS Head
PRIVATE J,Height,Width,Savscr,X,Y
SAVE SCREEN TO Savscr

* определение размеров
Height=3
Width=MAX(LEN(TRIM(Head))+2,9)
Width=IF(Width>80,80,Width)

* центровка
X=INT((MAXCOL()+1-Width)/2)
X=If(X<0,0,X)
Y=INT((MAXROW()+1-Height)/2)
Y=If(Y<0,0,Y)

SETCOLOR(SysMesCol)
WEXPAND(Y,X,Y+Height-1,X+Width-1,WnBorder+WnBackgr)
@ Y,X+(Width+1-LEN(TRIM(Head)))/2 SAY TRIM(Head)

SETCOLOR("W/N")
@ Y+1,X+(Width-3)/2 SAY " Ok "
INKEY(0)

SETCOLOR(SysMesCol)
WSHRINK(Y,X,Y+Height-1,X+Width-1,WnBorder+WnBackgr,SavScr)

RETURN .T.
*** End of MESSAGE() ***
 
