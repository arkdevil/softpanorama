#include <conio.h>
#include <wgt.h>
/*   WORDUP Graphics Toolkit   Version 3.5
     Demonstration program 9

Shows how the block functions work

*/

int i,x,y;
color palette[256];
block screen1;			// a full screen
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

for (i=1; i<200; i++)
   {
   wsetcolor(i);
   wline(0,i,319,i);
   }

screen1=wnewblock(0,0,319,199);		// capture the entire screen
part1=wnewblock(100,100,150,150);	// get a part of the screen
wcls(0);

do {
  x=rand() % 320;
  y=rand() % 200;
  wputblock(x,y,part1,0);		// put the part somewhere
  } while (!kbhit());
getch();
wputblock(0,0,screen1,0);		// replace the mess with the
					// original screen
getch();				// get the key
wfreeblock(screen1);			// *** make sure to free the memory!
wfreeblock(part1);
textmode(C80);				// used to return to text mode
}