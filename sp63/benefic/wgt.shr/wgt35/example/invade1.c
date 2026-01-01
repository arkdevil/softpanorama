#include <stdio.h>
#include <dos.h>
#include <conio.h>
#include <stdlib.h>
#include <alloc.h>
#include <wgt.h>
#include <spr.h>

/* This is a series of programs to help you learn how to use the
   sprite library. Compile each program, run it, and look at the code.
   After you understand what it is doing, go on to the next one.
   */

color palette[256];
block sprites[1001];
int x,y,i;

void looper();		// the part that repeats everything


void main(void)
{
printf("WordUp Graphics Toolkit Example Program\n\n");
printf("This program is meant to show off what the\n");
printf("WGT Library can do, and is not meant as a\n");
printf("complete shareware or public domain game.\n");
printf("Please remember this while playing the game.\n\n\n");


i=minit();
if (i==0)
   {
   printf("Mouse not detected.  You need a mouse for this example program\n");
   printf("Press any key\n");
   getch();
   exit(1);
   }
else printf("Mouse with %i buttons detected.\n",i);
printf("Press any key\n");
getch();
vga256();
wloadsprites(&palette,"invader.spr",sprites);
initspr();
spon=1;

wsetscreen(spritescreen);


for (y=160; y<200; y++)
    {
    wsetcolor((y/2)-78);
    wline(0,y,319,y);
    }
wcopyscreen(0,0,319,199,spritescreen,0,0,NULL);

spriteon(1,160,152,1);

 msetbounds(0,152,319,152);

do {
looper();
} while (but !=2);		// 2 means quit

 msetbounds(0,0,319,199);
textmode(C80);
}


void looper(void)
{
erasespr();

mread();
s[1].x=mx;
s[1].y=my;

drawspr();
}


