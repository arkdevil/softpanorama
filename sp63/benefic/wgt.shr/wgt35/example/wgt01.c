#include <conio.h>
#include <wgt.h>

/*   WORDUP Graphics Toolkit   Version 3.5
     Demonstration program 1

Simply starts the graphics mode (320x200x256), draws a line, gets a key, 
returns to text mode, and exits.
*/

void main(void)
{
vga256();		// initializes system

wsetcolor(15);
wline(0,0,319,199);
getch();
textmode(C80);		// used to return to text mode
}