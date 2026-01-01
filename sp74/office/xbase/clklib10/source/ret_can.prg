*PROCEDURE: Ret_Can  - Puts a dialog box with a message & RETRY/CANCEL choices
*AUTHOR   : Carl Kingsford
*SYSTEM   : dBASE IV v2.0
*DATE     : 5 Jul 1994


Function Ret_Can
 Parameters row1,col1, message, fcolor, ncolor, default
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

 @ row1+3, center-9 say "╔═════════╗  ╔═════════╗" color &fcolor.
 @ row1+4, center-9 say "║  Retry  ║  ║  Cancel ║" color &fcolor.
 @ row1+5, center-9 say "╚═════════╝  ╚═════════╝" color &fcolor.

 do while InKey() <> 0
 enddo

 store "J" to ch
 do while .not. (ch $ "RCrc"+chr(13))
    ch = chr(InKey(0))
    if .not. (ch $ "RCrc"+chr(13))
      ?? chr(7)
    endif
 enddo

 if (ch $ "Cc")
    answer = .F.
 else
    if (ch $ chr(13))
      answer = default
    endif
 endif
 
 restore screen from scrn
 release screen scrn
 set cursor on
Return answer
