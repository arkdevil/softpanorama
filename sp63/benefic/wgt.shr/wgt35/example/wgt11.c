#include <conio.h>
#include <wgt.h>
/*   WORDUP Graphics Toolkit   Version 3.5
     Demonstration program 11

Shows the use of wgetblockwidth and wgetblockheight, and
demonstrates resize procedure.

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

for (y=1; y<100; y++)
  {
  wsetcolor(y);
  wline(0,y,160,y);
  }
wtextcolor(1);
wouttextxy(10,10,"This block will",NULL);
wouttextxy(10,30,"be resized on",NULL);
wouttextxy(10,50,"the screen.",NULL);


part1=wnewblock(1,1,190,110);	// get the block
getch();
wcls(0);			// clear the screen
x=wgetblockwidth(part1);
y=wgetblockheight(part1);

textmode(C80);			// notice how you can go between text
gotoxy(1,1);
printf("Block width : %i\n",x);
printf("Block height: %i\n",y);
printf("Block size is %u bytes.",x*y+4);
printf("\nPress any key to resize...");
getch();
vga256();			// and graphics modes
wsetpalette(0,255,palette);	// but you must reset the colours.


do {
for (i=25; i<100; i+=2)
   wresize(80,50,80+i,50+i,part1);
for (i=100; i>25; i-=2)
   wresize(80,50,80+i,50+i,part1);
} while (!kbhit());
getch();


wcls(0);
  

wfreeblock(part1);
textmode(C80);				// used to return to text mode
}