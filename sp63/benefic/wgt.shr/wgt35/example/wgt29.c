#include <dos.h>
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <wgt.h>
#include <spr.h>

color p[256];
block sprites[1001];
char *scrolltext="MOVESCREEN IS USEFUL FOR SCROLLING AREAS OF THE SCREEN.  IT CAN BE USED FOR MAKING IMPRESSIVE INTROS!!!!!  REGISTER THE WGT SYSTEM....";
int scrnum;
int nextlet,j,k;
int i;




void main(void)
{
vga256();
wloadsprites(&p,"letters.spr",sprites);

for (i=0; i<180; i++)
  {
  wsetcolor(i);
  wline(0,0,319,i);
  wline(319,199,0,180-i);
  }

scrnum=0;
wsetcolor(0);
do {
scrnum=0;
do
  {
  nextlet=wgetblockwidth(sprites[scrolltext[scrnum]+1]);
  for (j=0; j<=nextlet+1; j+=2)
    {
    wbar(318,189,319,199);
    wputblock(319-j,189,sprites[scrolltext[scrnum]+1],0);
    wretrace();
    wmovescreen(0,189,319,199,2,2);
    }
  scrnum++;
  } while (scrolltext[scrnum+1] !=0);
} while (!kbhit());
wfreesprites(sprites);
}
