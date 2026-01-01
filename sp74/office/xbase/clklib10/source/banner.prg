*PROCEDURE: Draw a moving line of text until the user hits a key
*AUTHOR   : Carl Kingsford
*SYSTEM   : dBASE IV v2.0
*DATE     : 7-19

Procedure Banner
 Parameters message, line, col1, col2, fcolor, speed
 Private curcol, done, scrn

 save screen to scrn
 store col2 to curcol
 set talk off
 set cursor off
 set escape off

 @ line,col1 clear to line,col2
 @ line,col1 fill to line, col2 color &fcolor

 do while InKey() <> 0
 enddo

 store .F. to done
 do while .not. done

    if curcol <= col1-Len(message)
       curcol = col2
    else
       curcol = curcol-1
       @ line,col()-1 say " " color &fcolor.
    endif

    do case
       case curcol <= col1
	  @line, col1 say Right(message, Len(message)-(col1-curcol));
		      color &fcolor.
       case curcol+Len(message) => col2
	  @line, curcol say Left(message,(col2-curcol)+1);
			color &fcolor.
       otherwise
	  @line, curcol say message color &fcolor.
    endcase
    if InKey(speed) <> 0
       done = .T.
    endif
 enddo

 set cursor on
 set escape on
 restore screen from scrn
 release screen scrn
Return
