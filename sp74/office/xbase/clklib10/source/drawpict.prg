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
