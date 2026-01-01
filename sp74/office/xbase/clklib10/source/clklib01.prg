
****---------------------file radio.prg---------------------****

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

****---------------------file beep.prg---------------------****

Procedure Beep
 set cursor off
 ?? chr(7)
 set cursor on
Return
****---------------------file chkbox.prg---------------------****

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

****---------------------file nicewind.prg---------------------****

*PROCEDURE: NiceWindow - Draws a nice box around a window (that it DEFINEs).
*AUTHOR   : Carl Kingsford
*SYSTEM   : dBASE IV v2.0
*DATE     : 3 Jul 1994

*Parameters:
*  row? and col? are the coordinates for the BOX, the window will be place one
*  position inside that box. fcolor is the color for the top and left lines,
*  ncolor is the color for the bottom and right lines.

Procedure NiceWindow
 Parameters row1, col1, row2, col2, fcolor, ncolor, name

 do nicebox with row1, col1, row2, col2, fcolor, ncolor
 define window &name. from row1+1, col1+1 to row2-1, col2-1 none color &fcolor
Return

****---------------------file nicebox.prg---------------------****

*PROCEDURE: NiceBox - Draws a box with a niec outline on the screen.
*AUTHOR   : Carl Kingsford
*SYSTEM   : dBASE IV v2.0
*DATE     : 3 Jul 1994


Procedure NiceBox
 Parameters row1, col1, row2, col2, fcolor, ncolor

****** These commands CLEAR the area under the box.  They slow down the display
*      so they are commented out. If you have need of them - uncomment.
*
* set color to &fcolor.
* @ row1,col1 clear to row2,col2
* set color to &_defcolor.

 @ row1,col1 fill to row2,col2 color &fcolor.		&& Draw in background

 @ row1,col1 to row1,col2 color &fcolor.		&& Draw in borders
 @ row1+1,col1 to row2,col1 color &fcolor.
 @ row1+1,col2 to row2,col2 color &ncolor.
 @ row2, col1+1 to row2,col2-1 color &ncolor.
 
 @ row1,col1 SAY chr(218) color &fcolor.		&& Draw in corners
 @ row1,col2 say chr(191) color &fcolor.
 @ row2,col2 say chr(217) color &ncolor.
 @ row2,col1 say chr(192) color &ncolor.
Return

****---------------------file statusli.prg---------------------****

***** This procedure sets up the status line at line *line* and with color
* *fcolor*. This procedure draws the "bar" on the given line every time is is 
* so the line apears to "flash" once after the first time. To update the
* display procedure UpDateSL should be used.

Procedure StatusLine
 Parameters line, fcolor, text

 @ line,0 to line,79 " " color &fcolor.

 if .not. text = ".none." 
    @ line,0 say text color &fcolor.
 else
    @ line,0  say "Disk Free: " + Str(DiskSpace()) +" Bytes" color &fcolor.
 endif

 @ line,30 say "║ Memory Free: " + Right(Str(Memory(0)),6) + "K ║" color &fcolor.
 @ line,55 say DMY(Date()) color &fcolor.
 set clock to line,68
Return


***** This procedure updates the status line without the "flashing",
* Before this procedure is used, StatusLine should have been called, (but
* it's not a prerequsite).  If the text passed to it (a char. string) is
* ".none." it will display the Free Disk Space information, otherwise it
* will display your message.
* When you update, Line and fcolor should (*but don't HAVE to be *) the 
* same as when you first StatusLine'ed.
* The clock's position is changed in this procedure.

Procedure UpDateSL
 Parameters line, fcolor, text

 @ line,0 to line,30 " " color &fcolor.  		&& clear the message

 if .not. text = ".none."				&& if message is there
    @ line,0 say text color &fcolor.			&& display it
 else
    @ line,0 say "Disk Free: " + Str(DiskSpace()) +" Bytes" color &fcolor.
 endif

 @ line,30 say "║ Memory Free: "+Right(Str(Memory(0)),6) + "K ║" color &fcolor.
 @ line,55 say DMY(Date()) color &fcolor.
Return


****---------------------file backgrnd.prg---------------------****

*PROCEDURE: Draw a background with a given char
*AUTHOR   : Carl Kingsford
*SYSTEM   : dBASE IV v2.0
*DATE     : 7-19-94

Procedure Backgrnd
 Parameters s_size, ch, bcolor
 Private y, disp

 set talk off

 store 0 to y
 store Replicate(ch, 80) to disp

 do while y < s_size

  @y,0 say disp color &bcolor.
  y = y + 1

 enddo

 release y, disp
Return

****---------------------file pjobdone.prg---------------------****

*PROCEDURE: PJobDone - Displays a nice box with percent job done indicator
*AUTHOR   : Carl Kingsford
*SYSTEM   : dBASE IV v2.0
*DATE     : 3 Jul 1994

Procedure PJobDone
 Parameters row1, col1, total, current, size, ch, fcolor, bcolor, text
 Private bar, pos

 set talk off

 do NiceBox with row1,col1, row1+3, col1+size+3, fcolor, bcolor

 store Replicate(ch,size) to bar
 @row1+1,col1+2 say bar color &bcolor.

 store Replicate(chr(219),Int(current*(size/total))) to bar
 @row1+1,col1+2 say bar color &bcolor.

 pos = col1+2+( (size/2) - (Len(Text)/2) )

 @row1+2, pos say text color &fcolor.

 release bar, pos

Return

*----------------------------------------------------------------
*PROCEDURE: UpDatePJ - Updates the PJ Bar without total redraw
*AUTHOR   : Carl Kingsford
*SYSTEM   : dBASE IV v2.0
*DATE     : 3 Jul 1994

Procedure UpDatePJ
 Parameters row1, col1, total, current, size,bcolor
 Private bar

 store Replicate(chr(219),Int(current*(size/total))) to bar
 @row1+1,col1+2 say bar color &bcolor.

 release bar
Return

****---------------------file checkbox.prg---------------------****

*FUNCTION: Display a check box object (no dlg support)
*AUTHOR  : Carl Kingsford
*SYSTEM  : dBASE IV v2.0
*DATE    : 7 Jul 1994

Function CheckBox
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

 store iif(choices[1]=.T.,"X","O") to choices[1]
 store iif(choices[2]=.T.,"X","O") to choices[2]
 store iif(choices[3]=.T.,"X","O") to choices[3]
 store iif(choices[4]=.T.,"X","O") to choices[4]
 store iif(choices[5]=.T.,"X","O") to choices[5]

 rstr = choices[1] + choices[2] + choices[3] + choices[4] + choices[5]
Return rstr

****---------------------file ischecke.prg---------------------****

*FUNCITON: IsChecked - Returns .T. if option num is checked
*AUTHOR  : Carl Kingsford
*SYSTEM  : dBASE IV v2.0
*DATE    : 19 Jul 1994

Function IsChecked
 Parameters str,num
 Private rans

 set talk off

 if Left(Right(str,Len(str)-num+1),1) = "X"
    rans = .T.
 else
    rans = .F.
 endif
Return rans

****---------------------file drawpict.prg---------------------****

*PROCEDURE: DrawPict - Dump a formated text file to the screen.
*AUTHOR   : Carl Kingsford
*SYSTEM   : dBASE IV v2.0
*DATE     : 7 Jul 1994

Procedure DrawPict
 Parameters row,col,filename, fcolor
 Private fh, r, junk

 set talk off

 store Fopen(filename,"R") to fh
 store Val(Fread(fh,2)) to numrows
 store Fgets(fh) to junk
 store 1 to r

 do while (r <= numrows) .and. (.not. Feof(fh))
  @ row+r-1,col say fgets(fh) color &fcolor.
  row = row+1
 enddo
 junk = Fclose(fh)
Return

****---------------------file scrnsave.prg---------------------****

*PROCEUDRE: ScrnSave - Until the user hits a key display a moving message.
*AUTHOR   : Carl Kingsford
*SYSTEM   : dBASE IV v2.0
*DATE     : 19 Jul 1994


Procedure ScrnSave
 Parameters scrnsize, message, fcolor
 Private scrn, junk, lastx, lasty

 set talk off

 save screen to scrn
 @ 0,0 clear

 store Rand(-1) to junk
 store 0 to lastx, lasty

 do while (InKey() <> 0)
 enddo
 
 set cursor off
 
 lastx = Mod(Rand()*100, scrnsize)
 lasty = Mod(Rand()*100, 80-Len(message))
 @ lastx,lasty say message color &fcolor.

 do while (Inkey(3) = 0)
    @ lastx,lasty say Space(Len(message))

    lastx = Mod(Rand()*100, scrnsize)
    lasty = Mod(Rand()*100,80-Len(message))

    @ lastx,lasty say message color &fcolor.
 enddo

 set cursor on

 restore screen from scrn
 release screen scrn

Return


****---------------------file yesno.prg---------------------****

*PROCEDURE: YesNo  - Puts a dialog box with a message & YES/NO choices
*AUTHOR   : Carl Kingsford
*SYSTEM   : dBASE IV v2.0
*DATE     : 5 Jul 1994


Function YesNo
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
 @ row1+4, center-9 say "║   Yes   ║  ║    No   ║" color &fcolor.
 @ row1+5, center-9 say "╚═════════╝  ╚═════════╝" color &fcolor.

 do while InKey() <> 0
 enddo

 store "J" to ch
 do while .not. (ch $ "YNyn"+chr(13))
    ch = chr(InKey(0))
    if .not. (ch $ "YNyn"+chr(13))
      ? chr(7)
    endif
 enddo

 if (ch $ "Nn")
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

****---------------------file extractc.prg---------------------****

*FUNCTION: ExtractCh - Get the num-th char from a string.
*AUTHOR  : Carl Kingsford
*SYSTEM  : dBASE IV v2.0
*DATE    : 19 Jul 1994

Function ExtractCh
 Parameters str,num

Return Left(Right(str,Len(str)-num+1),1)

****---------------------file clearkbd.prg---------------------****

*PROCEDURE: Clear the keyboard buffer.
*AUTHOR   : Carl Kingsford
*SYSTEM   : dBASE IV v2.0
*DATE     : 7 Jul 1994

Procedure ClearKBD
 do while (InKey() <> 0)
 enddo 
Return

****---------------------file centerbe.prg---------------------****

*PROCEDURE: Center a message in between to columns
*AUTHOR   : Carl Kingsford
*SYSTEM   : dBASE IV v2.0
*DATE     : 7 Jul 1994

Procedure CenterBet
 Parameters line,col1,col2, message,fcolor
 Private center

 center = col1+( (col2-col1)/2 )+1
 @line,(center-(Len(message)/2)) say message color &fcolor.
Return

****---------------------file getmsg.prg---------------------****

*FUNCTION: GetMsg - Get a message from a rc dbf file.
*AUTHOR  : Carl Kingsford
*SYSTEM  : dBASE IV v2.0
*DATE    : 19 Jul 1994

Function GetMsg
 Parameters rcfile,ptopic
 Private mtext
 
 set exact on
 set talk off

 select select()
 use &rcfile. order topic
 
 if seek(ptopic, rcfile)
   mtext = message
 else
   mtext = "Message not found."
 endif

 close database

Return mtext
  

****---------------------file shadow.prg---------------------****

*PROCEDURE: Shadow - Add the shadow attrib to a box/window.
*AUTHOR   : Carl Kingsford
*SYSTEM   : dBASE IV v2.0
*DATE     : 17 Jul 1994

Procedure Shadow
 Parameters row1,col1, row2,col2, fcolor
 
 @ row2+1,col1+1 fill to row2+1,col2+1 color &fcolor.
 @ row1+1,col2+1 fill to row2,col2+1 color &fcolor.
Return

****---------------------file dots.prg---------------------****

*FUNCTION: Dots - Pad the end of a string with dots (.)
*AUTHOR  : Carl Kingsford
*SYSTEM  : dBASE IV v2.0
*DATE    : 7 Jul 1994

Function Dots
 Parameters name, size
 Private rstr

 rstr = name + Replicate(".",size-Len(name))

Return rstr

****---------------------file plural.prg---------------------****

*FUNCTION: Plural - Make most words plural
*AUTHOR  : Carl Kingsford
*SYSTEM  : dBASE IV v2.0
*DATE    : 19 Jul 1994

Function Plural
 Parameters word
 Private rstr
 
 set talk off

 store Trim(word) to tstr
 
 do case
    case Upper(Right(tstr,2)) = "'S"
       rstr = Left(tstr,Len(tstr)-2) + "s'"

    case Right(tstr,1) $ "sS"
       rstr = tstr
          
    case (Right(tstr,1) $ "hH") .or. (Upper(Right(tstr,2)) = "SS")
       rstr = tstr + "es"

    case Upper(Right(tstr,2)) = "S'"
       rstr = tstr

    otherwise
       rstr = tstr + "s"
 endcase 

Return rstr

****---------------------file possesiv.prg---------------------****

*FUNCTION: Possesive - Make most words possesive
*AUTHOR  : Carl Kingsford
*SYSTEM  : dBASE IV v2.0
*DATE    : 19 Jul 1994

Function Possesive
 Parameters word
 Private tstr

 set talk off
 store Trim(word) to tstr

 do case
   case (Right(tstr,1) = "'") .or. (Upper(Right(tstr,2)) = "'S")
      rstr = tstr
   case Right(tstr,1) $ "sS"
      rstr = tstr + "'"
   otherwise
      rstr = tstr + "'s"
 endcase
Return rstr

****---------------------file state.prg---------------------****

*FUNCTION: State- Return a state's name given it's abrv.
*AUTHOR  : Carl Kingsford
*SYSTEM  : dBASE IV v2.0
*DATE    : 17 Jul 1994


Function State
 Parameters name
 Private rstr, db, done
 Declare db[51]
 
 set talk off
 store "" to rstr

 db[1] = "AL Alabama"
 db[2] = "AK Alaska"
 db[3] = "AZ Arizona"
 db[4] = "AR Arkansas"
 db[5] = "CA California"
 db[6] = "CO Colorado"
 db[7] = "CT Conneticut"
 db[8] = "DE Delaware"
 db[9] = "FL Florida"
 db[10] = "GA Georgia"
 db[11] = "HI Hawaii"
 db[12] = "ID Idaho"
 db[13] = "IL Illinois"
 db[14] = "IN Indiana"
 db[15] = "IA Iowa"
 db[16] = "KS Kansas"
 db[17] = "KY Kentucky"
 db[18] = "LA Louisiana"
 db[19] = "ME Maine"
 db[20] = "MD Maryland"
 db[21] = "MA Massachusetts"
 db[22] = "MI Michigan"
 db[23] = "MN Minnesota"
 db[24] = "MS Mississippi"
 db[25] = "MO Missouri"
 db[26] = "MT Montana"
 db[27] = "NE Nebraska"
 db[28] = "NV Nevada"
 db[29] = "NH New Hampshire"
 db[30] = "NJ New Jersy"
 db[31] = "NM New Mexico"
 db[32] = "NY New York"
 db[33] = "NC North Carolina"
 db[34] = "ND North Dakota"
 db[35] = "OH Ohio"
 db[36] = "OK Oklahoma"
 db[37] = "OR Oregon"
 db[38] = "PA Pennsylvania"
 db[39] = "RI Rhode Island"
 db[40] = "SC South Carolina"
 db[41] = "SD South Dakota"
 db[42] = "TN Tennessee"
 db[43] = "TX Texas"
 db[44] = "UT Utah"
 db[45] = "VT Vermont"
 db[46] = "VA Virginia"
 db[47] = "WA Washington"
 db[48] = "WV West Virginia"
 db[49] = "WI Wisconsin"
 db[50] = "WY Wyoming"
 db[51] = "DC Washington D.C."

 store .F. to done
 store 1 to indx
 do while (.not. done) .and. (Left(db[indx],2) <> Upper(Trim(name)))
    indx = indx +1
    if indx > 51
       done = .T.
    endif
 enddo

 if done
    rstr = ".none."
 else
    rstr = Right(db[indx],Len(db[indx])-3)
 endif
Return rstr

****---------------------file banner.prg---------------------****

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

****---------------------file clipboar.prg---------------------****

**FILE: Clipboard routines - ShowClip, Cut, Paste, Copy

*PROCEDURE: ShowClip - Dump the clipboard at given position.
*AUTHOR   : Carl Kingsford
*SYSTEM   : dBASE IV v2.0
*DATE     : 7 Jul 1994

Procedure ShowClip
 Parameters row1,col1,fcolor
 Public jClipBoard

 @row1,col1 say jClipBoard color &fcolor.
Return


*PROCEDURE: Cut - Remove the contents of the current field to the cb.
*AUTHOR   : Carl Kingsford
*SYSTEM   : dBASE IV v2.0
*DATE     : 7 Jul 1994

Procedure Cut
 Parameters field
 Public jClipBoard
 Private ch

 set talk off

 store Type(field) to ch
 store &field. to jClipBoard

 do case
   case "C" = ch
     store "" to &field.
   case "N" = ch
     store 0 to &field.
   case "L" = ch
     store .T. to &field.
   case "D" = ch
     store {} to &field.
   case "F" = ch
     store 0.0 to &field.
 endcase
Return

*PROCEDURE: Copy - Copy the contents of the cur. field to the cb.
*AUTHOR   : Carl Kingsford
*SYSTEM   : dBASE IV v2.0
*DATE     : 7 Jul 1994

Procedure Copy
 Parameters field
 Public jClipBoard

 set talk off
 store &field. to jClipBoard

Return

*PROCEDURE: Paste - Copy the contents of the cb to the cur. field.
*AUTHOR   : Carl Kingsford
*SYSTEM   : dBASE IV v2.0
*DATE     : 7 Jul 1994

Procedure Paste
 Parameters field
 Public jClipBoard

 set talk off
 store &field.+jClipBoard to &field.
Return

*PROCEDURE: ClipBoard - Store text to the clipboard.
*AUTHOR   : Carl Kingsford
*SYSTEM   : dBASE IV v2.0
*DATE     : 7 Jul 1994
**NOTE    : This procedure MUST be called before any of the above!

Procedure ClipBoard
 Parameters text
 Public jClipBoard

 set talk off
 store text to jClipBoard
Return

****---------------------file getpass.prg---------------------****

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

****---------------------file ret_can.prg---------------------****

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

****---------------------file okmsg.prg---------------------****

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

****---------------------file roman.prg---------------------****

*FUNCTION: Return the roman numeral for a number 0..10
*AUTHOR  : Carl Kingsford
*SYSTEM  : dBASE IV v2.0
*DATE    : 19 Jul 1994

Function Roman
 Parameters num
 Private db, rstr
 Declare db[10]

 set talk off

 if num = 0
    rstr = "0"
 else
    db[1] = "I"
    db[2] = "II"
    db[3] = "III"
    db[4] = "IV"
    db[5] = "V"
    db[6] = "VI"
    db[7] = "VII"
    db[8] = "VIII"
    db[9] = "IX"
    db[10] = "X"

    if num <= 10
       rstr = db[num]
    else
       rstr = ".none."
    endif
 endif

 Release db
Return rstr
