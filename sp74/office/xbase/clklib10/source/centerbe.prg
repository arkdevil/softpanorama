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
