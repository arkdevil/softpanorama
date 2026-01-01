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

