#include <conio.h>
#include <stdio.h>
#include <wgt.h>

/*   WORDUP Graphics Toolkit   Version 3.5
     Demonstration program 24

    Shows off some special FX using wwipe.

*/

block screen1,screen2;		// two virtual screens

int i,j;
color palette[256];

void main(void)
{
vga256();		// initializes system
screen1=wloadblock("wgt2.blk");
screen2=wnewblock(0,0,319,199);
wnormscreen();
wloadpalette("wgt1.pal",&palette);
wsetpalette(0,255,&palette);

wcls(0);
getch();
for (i=0; i<200; i++)
  {
  wwipe(0,0,319,i,screen1);
  wwipe(319,199,0,199-i,screen1);
  }
getch();


for (i=0; i<100; i++)
  {
  wwipe(0,i,319,i,screen2);
  wwipe(0,199-i,319,199-i,screen2);
  }
getch();
for (i=0; i<320; i++)
  wwipe(159,99,i,0,screen1);
for (i=0; i<200; i++)
  wwipe(159,99,319,i,screen1);
for (i=319; i>=0; i--)
  wwipe(159,99,i,199,screen1);
for (i=199; i>=0; i--)
  wwipe(159,99,0,i,screen1);
getch();
for (i=0; i<200; i++)
   wwipe(0,i,319,i,screen2);
getch();

wfreeblock(screen1);	// remember to free that memory
wfreeblock(screen2);
textmode(C80);				// used to return to text mode
}






