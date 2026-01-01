* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*                                                                           *
*  DAVID -(FLASH)- GORDON  /  [75130,3664]  /  FLASHPOINT  /  10-NOV-89     *
*                                                                           *
*  Just Another Neat Function Looking For An Application                    *
*                                                                           *
*  Echo dots when a password or user id is entered.  This version checks    *
*       for back space, delete, and left arrow and treats them all as       * 
*       destructive backspaces.  Enter exits to do your checks.  Esc will   *
*       abort out of the entry system.                                      *
*                                                                           *
*  Feel free to copy or modify this code segment...If you find a use for it *
*       or enhance it or have other routines similar to this one, let me    *
*       know, I may have a use for them.                                    *
*                                                                           *
*                     1 0 0 %   C l i p p e r   C o d e                     *
*                                                                           *
*                                                                           *
*  Revisions:                                                               *
*     Version 1.1  10 Aug 1994 Jim Straight (c/o CIS 73062,3166)            *
*                  Convert code to generalized function (Clipper 5.2D)      *
*                                                                           *
*                                                                           *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* CLIPPER dots /m/n/w           RTLINK file dots
* 

procedure Main  //Test the function
   local pw
   cls
   @ 3,0 say "Password:"
   pw := GetHidden(3,11,8,"N/W, N/W")
   if lastkey() != 27
      @ 5,0 say "The password actually entered was:  " + pw
   endif
   @ 7,0 say ""
quit


*****************************************
function GetHidden(nRow, nCol, nLen, cColor)
*****************************************
* nRow,nCol are screen coordinates for the password prompt
* nLen is the length of password allowed
* cColor is the color of the data being keyed by the user

#include "inkey.ch"
#include "setcurs.ch"
#define  THUD          tone(60,.05)
#define  K_CCBRACE     125

local oldcolor := setcolor("N/N, N/N"), nPos := 0, password := "", keypress := 0, ;
      nDelKey_ := {K_DEL, K_BS, K_CTRL_S}, nExitKey_ := {K_ESC, K_ENTER}

@ nRow,nCol say space(nLen) color cColor

do while ascan(nExitKey_, keypress) == 0 .and. nPos <= nLen
   @ nRow,nCol+nPos say ""
   keypress := inkey(0)

   if ascan(nDelKey_, keypress) != 0
      if nPos > 0
         nPos--
      endif
      password := left(password,nPos)
      @ nRow,nCol+nPos say " " color cColor
   elseif ascan(nExitKey_, keypress) == 0 .and. ;
      keypress >= K_SPACE .and. keypress <= K_CCBRACE
      if nPos < nLen
         nPos++
         password += chr(keypress) 
         @ nRow,nCol+nPos-1 say "." color cColor
      else
         THUD
      endif
   endif 
enddo               

setcolor(oldcolor)
return password

