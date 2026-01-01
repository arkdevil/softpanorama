#include <conio.h>
#include <wgt.h>

/*   WORDUP Graphics Toolkit   Version 3.5
     Demonstration program 27

Draws some circles, captures a block,
and skews the block while rotating the colours.

*/

block skewit;
int i=0;
color palette[256];

void main(void)
{
vga256();		// initializes system

wreadpalette(0,255,&palette);

wcls(0);
for (i=100; i>0; i--)
  {
  wsetcolor(i);
  wfill_circle(160,100,i);
  }

wsetcolor(0);
wbar(0,0,104,199);
wbar(216,0,319,199);
skewit=wnewblock(100,40,220,160);

wcls(0);
do {
for (i=-100; i<100; i+=2)
  {
  wskew(100,40,skewit,i);
  wcolrotate(1,100,0,&palette);
  }
for (i=100; i>-100; i-=2)
  {
  wskew(100,40,skewit,i);
  wcolrotate(1,100,0,&palette);
  }
} while (!kbhit());

getch();
textmode(C80);		// used to return to text mode
}