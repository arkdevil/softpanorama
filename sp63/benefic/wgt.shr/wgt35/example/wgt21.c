#include <conio.h>
#include <stdio.h>
#include <wgt.h>

/*   WORDUP Graphics Toolkit   Version 3.5
     Demonstration program 21

    Shows off some special FX using wvertres.

*/

void crush(block,block,int);

block screen1,screen2;		// two virtual screens

int y,s;
color palette[256];

void main(void)
{
vga256();		// initializes system
screen1=wloadblock("wgt1.blk");
screen2=wloadblock("wgt2.blk");
wloadpalette("wgt1.pal",&palette);
wsetpalette(0,255,&palette);

  wputblock(0,0,screen1,0);
do {
  crush(screen1,screen2,5);
  crush(screen2,screen1,5);
  } while (!kbhit());



wfreeblock(screen1);	// remember to free that memory
wfreeblock(screen2);
textmode(C80);				// used to return to text mode
}


void crush(block b1, block b2, int dir)
{
int q,w,e;

for (q=199; q>=0; q-=dir)
  {
  wvertres(0,0,q,b1);
  wvertres(0,q,199,b2);
  }

}





