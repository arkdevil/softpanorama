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
