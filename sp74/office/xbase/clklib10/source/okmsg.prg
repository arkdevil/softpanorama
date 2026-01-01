*PROCEDURE: OKMsg  - Puts a dialog box with a message & an OK choice
*AUTHOR   : Carl Kingsford
*SYSTEM   : dBASE IV v2.0
*DATE     : 5 Jul 1994

Procedure OKMsg
 Parameters row1,col1, message, fcolor, ncolor
 Private answer, scrn, center, ch

 set talk off
 set cursor off

 save screen to scrn
 store .T. to answer
 store col1+Int((Len(message)+3)/2) to center

 @ row1,col1 clear to row1+7, col1+6+Len(message)

 do NiceBox with row1,col1, row1+7,col1+6+Len(message), fcolor,ncolor

 @ row1+1,col1+2+Int( ((col1+3+Len(message)-col1)/2) - (Len(message)/2));
	say message;
	color &fcolor.

 @ row1+3, center-4 say "╔═════════╗" color &fcolor.
 @ row1+4, center-4 say "║   OK    ║" color &fcolor.
 @ row1+5, center-4 say "╚═════════╝" color &fcolor.

 do while InKey() <> 0
 enddo

 store "J" to ch
 do while .not. (ch $ "Oo"+chr(13))
    ch = chr(InKey(0))
    if .not. (ch $ "Oo"+chr(13))
      ?? chr(7)
    endif
 enddo

 restore screen from scrn
 release screen scrn
 set cursor on
Return
