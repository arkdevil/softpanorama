#include <conio.h>
#include <wgt.h>
/*   WORDUP Graphics Toolkit   Version 3.5
     Demonstration program 4

This program has several loops which perform a drawing action
until you press a key.
Loops include line,fline,rectangle,bar,circle and filled circle
*/

int x,y,col;

void main(void)
{
vga256();		// initializes system
do {
   x=rand() % 320;
   y=rand() % 200;
   col=rand() % 255;
   wsetcolor(col);
   wline(rand() % 320,rand() % 200,x,y);	 // draw randomly
   } while (kbhit()==0);
getch();		// get the key
   wcls(0);
do {
   x=rand() % 319;
   y=rand() % 199;
   col=rand() % 255;
   wsetcolor(col);
   wfline(rand() % 319,rand() % 199,x,y);	 // draw randomly
   } while (kbhit()==0);
getch();		// get the key
   wcls(0);
do {
   x=rand() % 320;
   y=rand() % 200;
   col=rand() % 255;
   wsetcolor(col);
   wrectangle(rand() % 320,rand() % 200,x,y);
   } while (kbhit()==0);
getch();		// get the key
   wcls(0);
do {
   x=rand() % 320;
   y=rand() % 200;
   col=rand() % 255;
   wsetcolor(col);
   wbar(rand() % 320,rand() % 200,x,y);
   } while (kbhit()==0);
getch();		// get the key
   wcls(0);
do {
   x=rand() % 320;
   y=rand() % 200;
   col=rand() % 255;
   wsetcolor(col);
   wcircle(x,y,rand() % 100);
   } while (kbhit()==0);
getch();
   wcls(0);
do {
   x=rand() % 320;
   y=rand() % 200;
   col=rand() % 255;
   wsetcolor(col);
   wfill_circle(x,y,rand() % 100);
   } while (kbhit()==0);
getch();		// get the key
textmode(C80);		// used to return to text mode
}