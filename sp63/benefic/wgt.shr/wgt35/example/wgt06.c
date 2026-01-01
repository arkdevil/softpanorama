#include <conio.h>
#include <wgt.h>
/*   WORDUP Graphic Toolkit   Version 3.5
     Demonstration program 6

Draws vertical lines of different colours, waits for a key, then
fades the colours in and out.

*/

int x,y,col;
color palette[255];


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

getch();
wfade_out(0,255,40,palette);
delay(1000);
wfade_in(1,255,40,palette);
wfade_out(25,50,0,palette);
wfade_out(50,75,0,palette);
wfade_out(75,100,0,palette);
wfade_out(100,125,0,palette);
wfade_out(125,150,0,palette);
wfade_out(150,175,0,palette);
wfade_out(175,200,0,palette);

getch();		// get the key


textmode(C80);		// used to return to text mode
}