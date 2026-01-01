#include <conio.h>
#include <wgt.h>
/*   WORDUP Graphics Toolkit   Version 3.5
     Demonstration program 5

Draws vertical lines of different colours, and rotates the colours
until you hit a key.
Note: Fast colour rotation with many colours causes 'snow'
*/

int x,y,col;
color palette[256];


void main(void)
{
vga256();		// initializes system

for (y=0; y<64; y++)		
   wsetrgb(y,y,y,y,&palette);   	// sets first 64 colours to grey
					// note the use of &

for (y=0; y<64; y++)
   wsetrgb(y+64,y,0,0,&palette);        // next 64 to red
for (y=0; y<64; y++)
   wsetrgb(y+128,0,y,0,&palette);       // green
for (y=0; y<64; y++)
   wsetrgb(y+192,0,0,y,&palette);	// blue
wsetpalette(0,255,palette);		// and finally change them
					// all at once

for (y=0; y<200; y++)			// draw lines down the screen
   {
   wsetcolor(y);
   wline(0,y,319,y);
   }

do {
   wcolrotate(1,255,0,palette);
   } while (kbhit() == 0);
getch();		// get the key

do {
   wcolrotate(1,255,1,palette);
   } while (kbhit() == 0);
getch();		// get the key

do {
   wcolrotate(1,100,1,palette);
   wcolrotate(100,255,0,palette);
   } while (kbhit() == 0);
getch();		// get the key


textmode(C80);		// used to return to text mode
}