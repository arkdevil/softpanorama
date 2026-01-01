*!*********************************************************************
*! Function: WShrink(<Y1>,<X1>,<Y2>,<X2>,<Border>,<Screen>)
*! Notes: Сворачивание окна
*!        Параметры: 1-4 - координаты окна, 5 - символы рамки,
*!        6 - образ экрана

FUNCTION  WShrink
PARAMETERS Y1,X1,Y2,X2,Brdr,Savscr
IF  WnShrink
   PRIVATE I
   * эффект сворачивания
   REST SCREEN FROM Savscr
   FOR I=0 TO INT((X2-X1)/2-1) STEP 2
      @ Y1,X1+I,Y2,X2-I BOX Brdr
      REST SCREEN FROM Savscr
   NEXT
   * сигнал
   If  WnSound
      Tone(200,1)
   EndIF
ELSE
   REST SCREEN FROM Savscr
ENDIF
RETURN .T.
*** End of WShrink() ***********
