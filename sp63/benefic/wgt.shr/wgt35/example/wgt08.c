#include <conio.h>
#include <wgt.h>
/*   WORDUP Graphics Toolkit   Version 3.5
     Demonstration program 8

Shows how the region fill function works with various shapes.

Note: Fill is not perfected yet!
*/

unsigned _stklen=64000;		// set the stack very large to handle
			// any large fill operations

int x,y,col;
color palette[256];


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


wcls(0);
wsetcolor(1);
wcircle(160,100,50);		// try filling a circle
getch();
wsetcolor(40);
wregionfill(160,100);
wsetcolor(170);
wregionfill(0,0);

getch();
wcls(0);
for (col=1; col<5000; col++)		// try filling 10,000 random pixels
  {
  wsetcolor(rand() % 255);
  wputpixel(rand() % 320,rand() % 200);
  }
getch();
wsetcolor(40);
wclip(50,50,250,150);		 // fill works with clipping too!
wregionfill(160,100);


getch();		// get the key
textmode(C80);		// used to return to text mode
}