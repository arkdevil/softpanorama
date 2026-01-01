#include <conio.h>
#include <wgt.h>
/*   WORDUP Graphics Toolkit   Version 3.5
     Demonstration program 12

Demonstrates mouse functions and msetbounds

*/

void main(void)
{
vga256();		// initializes system

wcls(0);
minit();				// init mouse
mon();					// turn it on

//msetbounds(50,50,270,150);
// unremark this line to try setting the boundaries

do {
mread();				// read mouse
					// stores info into mx,my,but
gotoxy(1,1);
printf("X: %i     Y: %i     Button: %i      ",mx,my,but);
// You can still use printf in graphics mode for quick debugging

if (but !=0)				// button pressed
   {
   moff();				// must turn off mouse
   wsetcolor(my);			// before drawing or
   wfill_circle(mx,my,30);		// mouse cursor will smear
   mon();				// on screen.
   }
} while (!kbhit());

getch();
textmode(C80);				// used to return to text mode
}