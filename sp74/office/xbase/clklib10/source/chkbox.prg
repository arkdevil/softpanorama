*FUNCTION: Display a check box object (no dlg support)
*AUTHOR  : Carl Kingsford
*SYSTEM  : dBASE IV v2.0
*DATE    : 7 Jul 1994

Function ChkBox
 Parameters row1,col1,numch,fcolor,msg1,msg2,msg3,msg4,msg5
 Private oldch, curch, done, choices, rstr
 Declare choices[5]

 store .F. to choices[1]
 store .F. to choices[2]
 store .F. to choices[3]
 store .F. to choices[4]
 store .F. to choices[5]

 set talk off

 do case
    case numch = 1
       @row1,col1   say "[ ] "+msg1 color &fcolor.
    case numch = 2
       @row1,col1   say "[ ] "+msg1 color &fcolor.
       @row1+1,col1 say "[ ] "+msg2 color &fcolor.
    case numch = 3
       @row1,col1   say "[ ] "+msg1 color &fcolor.
       @row1+1,col1 say "[ ] "+msg2 color &fcolor.
       @row1+2,col1 say "[ ] "+msg3 color &fcolor.
    case numch = 4
       @row1,col1   say "[ ] "+msg1 color &fcolor.
       @row1+1,col1 say "[ ] "+msg2 color &fcolor.
       @row1+2,col1 say "[ ] "+msg3 color &fcolor.
       @row1+3,col1 say "[ ] "+msg4 color &fcolor.
    case numch = 5
       @row1,col1   say "[ ] "+msg1 color &fcolor.
       @row1+1,col1 say "[ ] "+msg2 color &fcolor.
       @row1+2,col1 say "[ ] "+msg3 color &fcolor.
       @row1+3,col1 say "[ ] "+msg4 color &fcolor.
       @row1+4,col1 say "[ ] "+msg5 color &fcolor.
 endcase

 store .F. to done
 store 1 to curch

 do while .not. done
    @row1+curch-1,col1+1 say ""
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
       case (ch = 32)
	   if choices[curch] = .F.
	      choices[curch] = .T.
	      @row1+curch-1, col1+1 say "X" color &fcolor.
	   else
	      choices[curch] = .F.
	      @row1+curch-1, col1+1 say " " color &fcolor.
	   endif
       otherwise
	  ?? chr(7)
    endcase
 enddo

 rstr = ""
 tstr = choices[1]
 rstr = rstr + iff(tstr=.T.,"X","O")
 store iif(choices[2]=.T.,"X","O") to choices[2]
 store iif(choices[3]=.T.,"X","O") to choices[3]
 store iif(choices[4]=.T.,"X","O") to choices[4]
 store iif(choices[5]=.T.,"X","O") to choices[5]

 rstr = choices[1] + choices[2] + choices[3] + choices[4] + choices[5]
Return rstr
