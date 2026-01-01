*PROCEDURE: Shadow - Add the shadow attrib to a box/window.
*AUTHOR   : Carl Kingsford
*SYSTEM   : dBASE IV v2.0
*DATE     : 17 Jul 1994

Procedure Shadow
 Parameters row1,col1, row2,col2, fcolor
 
 @ row2+1,col1+1 fill to row2+1,col2+1 color &fcolor.
 @ row1+1,col2+1 fill to row2,col2+1 color &fcolor.
Return
