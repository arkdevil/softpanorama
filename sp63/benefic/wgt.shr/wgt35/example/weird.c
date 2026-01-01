#include <stdio.h>
#include <conio.h>
#include <wgt.h>

// WEIRD! Try moving the mouse around and watch the 'snakes' follow it!

int x,y,i,j;
int px[256],py[256];
color p[256];
int numpix;

void main(void)
{
numpix=155;
vga256();
wloadpalette("wgt1.pal",&p);
wsetpalette(0,255,&p);
i=minit();
for (i=0; i<256; i++)
  {
  px[i]=0;
  py[i]=0;
  }


do {
mread();
wsetcolor(0);
for (i=numpix; i>=1; i--)
 {
 wfastputpixel(px[i],py[i]);
 wfastputpixel(319-px[i],199-py[i]);
// wfastputpixel(319-px[i],py[i]);
// wfastputpixel(px[i],199-py[i]);
 px[i]=px[i-1];
 py[i]=py[i-1];
}
 wsetcolor(0);
 wfastputpixel(px[0],py[0]);
 wfastputpixel(319-px[0],199-py[0]);
// wfastputpixel(319-px[0],py[0]);
// wfastputpixel(px[0],199-py[0]);

px[0]=mx;
py[0]=my;

for (i=0; i<numpix; i++)
 {
 wsetcolor(i);
 wfastputpixel(px[i],py[i]);
 wfastputpixel(319-px[i],199-py[i]);
// wfastputpixel(319-px[i],py[i]);
// wfastputpixel(px[i],199-py[i]);

}

} while (but !=2);
textmode(C80);
}

