/**************************************************************************
** Test Program for CALENDAR()                                           **
**************************************************************************/

  dDate   := CtoD("")
  mSelect := Date()
  nTopRow      := 10
  nLftCol      := 25
  cl      := "W/B,B/W,,,I+"                             /* Color Monitor */
  clear
* @ 2,1 say "Top Row : " get nTopRow    Picture '99'                      ;
*                          Valid ( nTopRow < MaxRow()- 8 .and. nTopRow > 0)
* @ 3,1 say "Left Col: " get nLftCol    Picture '99'                      ;
*                          Valid ( nLftCol < MaxCol()-21 .and. nLftCol > 0)
  @ 4,1 say "Color: "    get cl    Picture '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
  Read
  @ 6,1 SAY "Date: "     get dDate Picture '@D'                           ;
        Valid Iif(Empty(dDate),                                           ;
                 (dDate := CALENDAR(dDate, nTopRow, nLftCol, cl),.t.),.t. )
  Read

* dDate := CALENDAR(dDate, nTopRow, nLftCol, cl)
* dDate := CALENDAR(Date(), nTopRow, nLftCol, cl)
  @ 23,10 say "You Selected: " + DtoC(dDate)
Return dDate
