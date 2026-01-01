#include <stdio.h>
#include <dos.h>
#include <conio.h>
#include <stdlib.h>
#include <alloc.h>
#include <wgt.h>
#include <spr.h>

block title;				// the title screen

color palette[256];
block sprites[1001];
int x,y,i;

void looper();

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
title=wloadpak("invade.pak");			// load the title screen
wloadsprites(&palette,"invader.spr",sprites);
initspr();
spon=1;

wsetscreen(spritescreen);

wputblock(0,0,title,0);				// show the title
wcopyscreen(0,0,319,199,spritescreen,0,0,NULL);

getch();					// wait for a key

wsetcolor(0);					// blank out the title
wbar(0,0,319,140);
wcopyscreen(0,0,319,199,spritescreen,0,0,NULL);

spriteon(1,160,148,1);				// start the game
msetbounds(0,148,319,148);

do {
looper();
} while (but!=2);

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

