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
