#include <conio.h>
#include <wgt.h>
/*   WORDUP Graphics Toolkit   Version 3.5
     Demonstration program 10

Shows the difference between normal and xray putblock modes
and demonstrates the flipblock procedure.

*/

int i,x,y;
color palette[256];
block part1;			// part of the screen


void main(void)
{
vga256();		// initializes system


for (y=1; y<64; y++)		
   wsetrgb(y,y,y,y,&palette);   	// sets first 64 colours to grey
					// note the use of &
for (y=0; y<64; y++)
   wsetrgb(y+64,y,0,0,&palette);        // next 64 to red
for (y=0; y<64; y++)
   wsetrgb(y+128,0,y,0,&palette);       // green
for (y=0; y<64; y++)
   wsetrgb(y+192,0,0,y,&palette);	// blue

   wsetrgb(1,63,63,63,&palette);   	// sets color 1 to white
 wsetpalette(0,255,palette);		// and finally change them
					// all at once

for (y=40; y>=4; y--)
  {
  wfill_circle(y+40,y+10,y);			// draw a pattern
  wsetcolor(y+20);
  }
part1=wnewblock(0,0,160,100);	// get the circle in a block
wcls(0);			// clear the screen
for (x=0; x<320; x++)
  {
  wsetcolor(x);
  wline(x,0,x,199);
  }

getch();
  wputblock(160,0,part1,0);		// normal mode
  wflipblock(part1,vertical);
getch();
  wputblock(160,100,part1,1);		// XRAY mode
  wflipblock(part1,horizontal);
getch();
  wputblock(0,100,part1,0);		// normal mode
  wflipblock(part1,vertical);
getch();
  wputblock(0,0,part1,1);		// XRAY mode
  

getch();				// get the key
wfreeblock(part1);
textmode(C80);				// used to return to text mode
}