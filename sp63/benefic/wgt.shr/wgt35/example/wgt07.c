#include <conio.h>
#include <wgt.h>
/*   WORDUP Graphics Toolkit   Version 3.5
     Demonstration program 7

Displays some text with the text grid off until you hit a key, then
turns the grid on and displays text, to show the difference.

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


   wcls(0);
wtextgrid(0);
wtexttransparent(2);
do {
   x=rand() % 320;
   y=rand() % 200;
   col=rand() % 255;
   wouttextxy(x,y,"WORDUP Graphics Toolkit",NULL);
   wtextcolor(col);
   } while (kbhit()==0);
 getch();

wcls(0);
wtextgrid(1);
do {
   x=rand() % 80;
   y=rand() % 25;
   col=rand() % 255;
   wtextcolor(col);
   wtextbackground(rand() % 255);
   wouttextxy(x,y,"WORDUP Graphics Toolkit",NULL);
   } while (kbhit()==0);


getch();		// get the key
textmode(C80);		// used to return to text mode
}