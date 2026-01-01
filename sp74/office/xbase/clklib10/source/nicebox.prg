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
