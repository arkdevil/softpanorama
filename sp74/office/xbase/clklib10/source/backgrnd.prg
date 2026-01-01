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
