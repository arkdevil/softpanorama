#include <conio.h>
#include <wgt.h>
/*   WORDUP Graphics Toolkit   Version 3.5
     Demonstration program 13

Demonstrates mouse noclick, mousehape, msetspeed, and wbutt

*/

color palette[256];

int i,doneflag;				// end of loop

   unsigned wgtcursor[32] = {
	0x3ff, 0x3ff, 0x7ff, 0x3ff, 0x1ff, 0x20ff,0xf07f,0xf8ff,
	0xfdff,0x1000,0x0,   0x0,   0x1,   0x1,   0x1,   0x1,
	0x0,   0x7800,0x7000,0x7800,0x5c00,0xe00 ,0x700, 0x200,
	0x0,   0x0,   0x45ce,0x4504,0x5564,0x5524,0x7de4,0x0};

   // this is the shape of the mouse cursor. There are many shareware
   // or public domain programs that help you make these.


void main(void)
{
vga256();		// initializes system

for (i=1; i<253; i++)
   wsetrgb(i,i+30,i+30,i,&palette); 		// just something other
						// than black!

wsetrgb(253,60,60,60,&palette);
wsetrgb(254,50,50,50,&palette);
wsetrgb(255,40,40,40,&palette);
wsetpalette(0,255,&palette);

wcls(0);

wbutt(1,1,319,50);
wbutt(1,60,319,109);
wbutt(1,189,319,199);

wtextcolor(253);
wtexttransparent(0);
wouttextxy(30,10,"This button doesn't use noclick()",NULL);
wouttextxy(60,70,"This button does!",NULL);
wouttextxy(100,191,"Click here to quit",NULL);



minit();				// init mouse
msetbounds(0,0,319,199);
msetspeed(20,5);			// make x slow and y real fast
mouseshape(0,0,wgtcursor);		// 0,0 for hotspot

mon();					// turn it on

doneflag=0;				// keep looping until flag is 1

do {
mread();				// read mouse
					// stores info into mx,my,but

if (but !=0)				// button pressed
   {
   if (my<50)
      {
      sound(500);
      delay(30);
      nosound();
      }
   else if ((my<109) & (my>60))
      {
      sound(500);
      delay(30);
      nosound();
      noclick();
      }
   else if (my>189)
       doneflag=1;				// you hit the quit button

   }
} while (!doneflag);

textmode(C80);				// used to return to text mode
}