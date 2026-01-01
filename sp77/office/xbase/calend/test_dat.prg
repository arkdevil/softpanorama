/**************************************************************************
** Test Program for CALENDAR(), prompts user for different date formats. **
** - Rod Cushman                                                         **
** 04/26/92 10:07am                                                      **
**************************************************************************/

#include "inkey.ch"
#include "box.ch"

  dDate   := CtoD("")
  mSelect := Date()

  Set Date to British

  Set Date Format to GetDateFmt( Set( _SET_DATEFORMAT ), 10, 26,          ;
                                                          "w/r,r/w,,,b/w" )
  nTopRow := 10
  nLftCol := 25
* cl      := "n/W,W+/n,,n/g"                            /* Mono Monitor  */
  cl      := "W/B,B/W,,,I+"                             /* Color Monitor */
  clear
* @ 2,1 Say "Top Row : " get nTopRow    Picture '99'                      ;
*                          Valid ( nTopRow < MaxRow()- 8 .and. nTopRow > 0)
* @ 3,1 Say "Left Col: " get nLftCol    Picture '99'                      ;
*                          Valid ( nLftCol < MaxCol()-21 .and. nLftCol > 0)
  @ 4,1 Say "Color: "    get cl    Picture '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
  Read
  @ 6,1 Say "Date: "     get dDate Picture '@D'                           ;
        Valid Iif(Empty(dDate),                                           ;
                 (dDate := CALENDAR(dDate, nTopRow, nLftCol, cl),.t.),.t. )
  Read

* dDate := CALENDAR(dDate, nTopRow, nLftCol, cl)
* dDate := CALENDAR(Date(), nTopRow, nLftCol, cl)
  @ 23,10 say "You Selected: " + DtoC(dDate)
Return dDate


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


/**************************************************************************
** GetDateFmt( cDefaultFormat, nTop, nLft, cColor )                      **
**      Pop - Up Menu for Date Format selection. Returns character string**
**      for chosen date format...                                        **
**************************************************************************/
Function GetDateFmt( cDefaultFmt, nTop, nLft, cColor )
  Local cFmt   := cDefaultFmt,                                            ;
        nFmt   := 1,                                                      ;
        sWin   := "",                                                     ;
        tTop   := 11,                                                     ;
        tLft   := 63,                                                     ;
        coColr := SetColor()
        acFmt  := {   "mm/dd/yy", "yy.mm.dd", "dd/mm/yy", "dd/mm/yy",     ;
                      "dd.mm.yy", "dd-mm-yy", "yy/mm/dd", "mm-dd-yy",     ;
                      Set( _SET_DATEFORMAT )                              ;
                  }

                                   /* Establish Calendar box coordinates */
  tTop     := If(nTop == NIL, 0, If(nTop > MaxRow()-13, MaxRow()-13, nTop))
  tLft     := If(nLft == NIL, 0, If(nLft > MaxCol()-17, MaxCol()-17, nLft))

  KeyBoard Chr(K_HOME) + Replicate(Chr(K_DOWN),                           ;
                                             AScan( acFmt, cDefaultFmt)-1 )
  sWin   := SaveScreen(tTop, tLft, tTop+13, tLft+15)

  DispBegin()
  SetColor( cColor )
  DispWin( tTop, tLft, tTop+10, tLft+25, cColor )
  @ tTop+ 0, tLft+1 Say    " SELECT FORMAT "  Color cColor
  @ tTop+ 1, tLft+1 Prompt "1)  American - mm/dd/yy "
  @ tTop+ 2, tLft+1 Prompt "2)  ANSI     - yy.mm.dd "
  @ tTop+ 3, tLft+1 Prompt "3)  British  - dd/mm/yy "
  @ tTop+ 4, tLft+1 Prompt "4)  French   - dd/mm/yy "
  @ tTop+ 5, tLft+1 Prompt "5)  German   - dd.mm.yy "
  @ tTop+ 6, tLft+1 Prompt "6)  Italian  - dd-mm-yy "
  @ tTop+ 7, tLft+1 Prompt "7)  Japan    - yy/mm/dd "
  @ tTop+ 8, tLft+1 Prompt "8)  USA      - mm-dd-yy "
  @ tTop+ 9, tLft+1 Prompt "9)  Current  - " + Set( _SET_DATEFORMAT )
  DispEnd()
  Menu to nFmt

  SetColor( coColr )
  RestScreen( tTop, tLft, tTop+10, tLft+25, sWin )
Return acFmt[ Iif(Empty(nFmt), 1, nFmt) ]
