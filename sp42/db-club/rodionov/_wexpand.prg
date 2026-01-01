*!*********************************************************************
*! Function: WEXPAND(<y1>,<x1>,<y2>,<x2>,<b>)
*! Notes: Развертывание окна
*!        Параметры: 1-4 - координаты окна, 5- символы рамки (8-9 шт)

FUNCTION WEXPAND
PARAMETERS Y1,X1,Y2,X2,Brdr
IF  WnExpand
   PRIVATE I
   * эффект развертывания
   FOR I=INT((X2-X1)/2-1) TO 0 STEP -2
      @ Y1,X1+I,Y2,X2-I BOX Brdr
   NEXT
   * сигнал
   If  WnSound
      Tone(280,1)
   EndIF
ENDIF
@ Y1,X1,Y2,X2 BOX Brdr
IF  WnShadow
   * тень
   WShadow(Y1,X1,Y2,X2)
ENDIF
RETURN .T.
*** End of WEXPAND() ***********
