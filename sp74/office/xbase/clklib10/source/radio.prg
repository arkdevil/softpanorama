*FUNCTION: Radio - Display a Radio button object (no dlg support)
*AUTHOR  : Carl Kingsford
*SYSTEM  : dBASE IV v2.0
*DATE    : 19 Jul 1994

Function Radio
 Parameters row1,col1,numch,fcolor,msg1,msg2,msg3,msg4,msg5
 Private oldch, curch, done

 set talk off
 set cursor off

 do case
    case numch = 1
       @row1,col1   say "( ) "+msg1 color &fcolor.
    case numch = 2
       @row1,col1   say "( ) "+msg1 color &fcolor.
       @row1+1,col1 say "( ) "+msg2 color &fcolor.
    case numch = 3
       @row1,col1   say "( ) "+msg1 color &fcolor.
       @row1+1,col1 say "( ) "+msg2 color &fcolor.
       @row1+2,col1 say "( ) "+msg3 color &fcolor.
    case numch = 4
       @row1,col1   say "( ) "+msg1 color &fcolor.
       @row1+1,col1 say "( ) "+msg2 color &fcolor.
       @row1+2,col1 say "( ) "+msg3 color &fcolor.
       @row1+3,col1 say "( ) "+msg4 color &fcolor.
    case numch = 5
       @row1,col1   say "( ) "+msg1 color &fcolor.
       @row1+1,col1 say "( ) "+msg2 color &fcolor.
       @row1+2,col1 say "( ) "+msg3 color &fcolor.
       @row1+3,col1 say "( ) "+msg4 color &fcolor.
       @row1+4,col1 say "( ) "+msg5 color &fcolor.
 endcase

 store .F. to done
 store 1 to oldch
 store 1 to curch
 do while .not. done
    @row1+oldch-1,col1+1 say " " color &fcolor.
    @row1+curch-1, col1+1 say "*" color &fcolor.
    oldch = curch
    ch = InKey(0)
    do case
       case (ch = 5) .or. (ch = -400)
	  if curch > 1
	     curch = curch-1
	  else
	     curch = numch
	  endif

       case (ch = 24) .or. (ch = 9)
	  if curch < numch
	     curch = curch+1
	  else
	     curch = 1
	  endif

       case (ch = 13)
	  done = .T.

       case (ch = 18)
	   curch = 1

       case (ch = 3)
	   curch = numch

       otherwise
	  ?? chr(7)
    endcase
 enddo
 set cursor on
Return curch
