*FUNCTION: GetPass - Read in a string without echo.
*AUTHOR  : Carl Kingsford
*SYSTEM  : dBASE IV v2.0
*DATE    : 19 Jul 1994



Function GetPass
 Parameters row1, col1, size, fcolor
 Private rpass, done

 set talk off

 store "" to rpass

 @ row1,col1 clear to row1,col1+size-1
 @ row1,col1 fill to row1,col1+size-1 color &fcolor.
 @ row1,col1 say ""

 store .F. to done
 do while .not. done
    store InKey(0) to ch

    do case
       case ch = 13
	  done = .T.
       case ch = 127
	  rpass = Left(rpass,len(rpass)-1)
	  @ row1,col()-1 say " " color &fcolor.
	  @ row1,col()-1 say ""
       case ch = 27
	  rpass = ""
	  @ row1,col1 clear to row1,col1+size-1
	  @ row1,col1 fill to row1,col1+size-1 color &fcolor.
	  @ row1,col1 say ""

       otherwise
	  if len(rpass) < size
	     rpass = rpass + chr(ch)
	     @ row1,col() say "*" color &fcolor.
	  else
	     ?? chr(7)
	  endif
    endcase
 enddo

Return rpass
