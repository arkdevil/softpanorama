#include <wgt.h>
#include <conio.h>
// WordUp Graphics Toolkit demo program 32
// Demonstrates the use of wwarp

// Press q to quit during random shapes

int i,t,c,b;
color pal[256];
block wgt1;

void main(void)
{
int top[320];
int bot[320];
vga256();
wgt1=wloadblock("wgt1.blk");
wloadpalette("wgt1.pal",&pal);
wsetpalette(0,255,&pal);

wcls(0);
wclip(0,0,319,199);
wsline(0,199,319,0,&top);
wsline(0,199,319,199,&bot);
wwarp(0,319,&top,&bot,wgt1);
getch();
// squish it

wcls(0);
wsline(0,100,100,0,&top);
wsline(101,70,218,70,&top);
wsline(219,0,319,100,&top);

wsline(0,100,100,199,&bot);
wsline(101,130,218,130,&bot);
wsline(219,199,319,100,&bot);
wwarp(0,319,&top,&bot,wgt1);
getch();
// make a double arrow

wcls(0);
do {
b=rand() % 100;
c=(rand() % 100)+100;
for (t=0; t<=319; t++)
  {
  i=rand() % 2;
  if (i==0) b++; else b--;
  i=rand() % 2;
  if (i==0) c++; else c--;
  if (b>100) b=100;
  if (b<0) b=0;
  if (c>197) c=197;
  if (c<100) c=100;

  top[t]=b;
  bot[t]=c;
  }
wwarp(0,319,&top,&bot,wgt1);
i=getch();
wcls(0);
} while (i !='q');
// do random shapes

wfreeblock(wgt1);
textmode(C80);
}
