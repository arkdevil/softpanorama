/**************************************************************************
** TESTTIME.PRG                                                          **
**      Test Program for CALENDAR(), outputs to file the beginning,      **
**      ending and current system date.  Program creates a data file for **
**      another program written by KinWah Nelson Ng, which creates a     **
**      plot of the data created by this program and another related     **
**      module.                                                          **
**                                      Mod User:       Rod Cushman      **
**                                      Mod Date:       04/12/92 03:44pm **
**************************************************************************/

#include "Inkey.ch"
#include "Box.ch"

  BegDate := CtoD("")
  EndDate := CtoD("")
  CurDate := Date()
  mSelect := Date()
  nTopRow      := 10
  nLftCol      := 25
* cColor      := "n/W,W+/n,,n/g"                        /* Mono Monitor  */
  cColor      := "W/B,B/W,,,I+"                         /* Color Monitor */
  Clear

* @ 2,1 say "Top Row : " get nTopRow    Picture '99'                      ;
*                          Valid ( nTopRow < MaxRow()- 8 .and. nTopRow > 0)
* @ 3,1 say "Left Col: " get nLftCol    Picture '99'                      ;
*                          Valid ( nLftCol < MaxCol()-21 .and. nLftCol > 0)
* @ 4,1 say "Color: "    get cColor    Picture '!!!!!!!!!!!!!!!!!!!!!!!!!!'
* Read

* dDate  := CALENDAR(dDate, nTopRow, nLftCol, cColor)


  aDates := GetDateRng( Date(), BegDate, EndDate, nTopRow, nLftCol, cColor)

  @ 20,10 say "You Selected: ( " + DtoC(aDates[1])+", "+DtoC(aDates[2])+" )"
  @ 21,10 say "Difference =  " + StrZero( aDates[2] - aDates[1] , 4, 0)
  @ 22,10 Say "Today's Date: " + DtoC( Date() )
  @ 23,10 Say "Diff(CurDate,BegDate) : " + StrZero(Date()-aDates[1],4,0)+ ;
              "   Diff(CurDate,EndDate) : " +StrZero(Date()-aDates[2],4,0)
  @ 24,10 Say "Press Any Key"
  InKey(0)
Return NIL


/**************************************************************************
** GetDateRng( nDefaultDate, dBegDate, dEndDate, nTop, nLft, cColor)     **
**      Pop - Up Edit of Date Range, returns validated range.            **
**************************************************************************/
Static Function GetDateRng( nDefaultDate, dBegDate, dEndDate, nTop, nLft, ;
                         cColor )
  Local sWin := SaveScreen(nTop, nLft, nTop+4, nLft+27),                  ;
        oGetList := GetList
   GetList := {}                              /* Save old GetList, Reset */
   DispWin( nTop, nLft, nTop+4, nLft+27, cColor )
   @ nTop+ 0, nLft+3 Say     " SELECT DATE RANGE "  Color cColor
   @ nTop+ 1, nLft+1 Say "BEGINNING DATE "   Get dBegDate Picture '@D'    ;
        Valid Iif(Empty(dBegDate),                                        ;
             (dBegDate:=CALENDAR(dBegDate,nTop+1,nLft+29,cColor),.t.),.t.)
   @ nTop+ 3, nLft+1 Say "ENDING DATE    "   Get dEndDate Picture '@D'    ;
        Valid Iif(Empty(dEndDate),                                        ;
             (dEndDate:=CALENDAR(dEndDate,nTop,nLft+29,cColor),.t.),.t.)  ;
             .and. (dEndDate > dBegDate)
   Read

   RestScreen( nTop, nLft, nTop+4, nLft+27, sWin )
   GetList := oGetList                          /* Restore prior GetList */
Return { dBegDate, dEndDate }


/**************************************************************************
** Function DispWin                                                      **
**      clear window area and draw box for window                        **
**************************************************************************/
Static Function DispWin
  Parameters nT,nL,nB,nR, cColor               /* top row, bot. row, etc */

  cColor := Iif( cColor = NIL, SetColor(), cColor)
  SetColor( cColor )
  DispBegin()
  @ nT,nL CLEAR TO nB,nR
  @ nT,nL,nB,nR BOX B_DOUBLE_SINGLE  Color cColor
  DispEnd()
Return  NIL
