#include <stdio.h>
#include <dos.h>
#include <conio.h>
#include <stdlib.h>
#include <alloc.h>
#include <ctype.h>
#include <wgt.h>
#include <spr.h>

block title;

color palette[256];
block sprites[1001];
int x,y,i,ops;
char k;
int shoot;
int alshoot[15],totshoot;


// sprites numbers (So you don't get confused)
// 1    = spaceship
// 2    = missile fired
// 3-24 = aliens!
// 25-39= aliens missiles

void looper();

void main(void)
{
printf("WordUp Graphics Toolkit Example Program\n\n");
printf("This program is meant to show off what the\n");
printf("WGT Library can do, and is not meant as a\n");
printf("complete shareware or public domain game.\n");
printf("Please remember this while playing the game.\n\n");
printf("Press q during the game to quit...\n\n\n");


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
title=wloadpak("invade.pak");
wloadsprites(&palette,"invader.spr",sprites);
initspr();
spon=39;				// thirty nine sprites on now
spclip=1;

wsetscreen(spritescreen);

wputblock(0,0,title,0);
wcopyscreen(0,0,319,199,spritescreen,0,0,NULL);

getch();

wsetcolor(0);
wbar(0,0,319,140);
wcopyscreen(0,0,319,199,spritescreen,0,0,NULL);

spriteon(1,160,148,1);

for (y=0; y<3; y++)
  for (x=1; x<8; x++)
    {
    spriteon((y*7)+x+2,x*20+10,20+y*30,3);			// turn alien on
    animate((y*7)+x+2,"(3,3)(4,3)(5,3)(4,3)R");			// animate it
    animon((y*7)+x+2);
    movex((y*7)+x+2,"(1,150,0)(0,30,0)(-1,150,0)(0,30,0)R"); 	// set up x movement
    movey((y*7)+x+2,"(0,150,0)(1,30,0)(0,150,0)(-1,30,0)R");	// set up y movement
    movexon((y*7)+x+2);
    moveyon((y*7)+x+2);
    }



msetbounds(0,148,319,148);

do {
looper();
} while (k !='Q');

msetbounds(0,0,319,199);
textmode(C80);
}


void looper(void)
{
erasespr();

mread();
s[1].x=mx;
s[1].y=my;

if (but==1)				// if you pressed the left button
  {
    if (shoot==0)			// not shooting then
      {
      sound(600);
      spriteon(2,s[1].x+3,s[1].y,2);    // turn on the missile sprite
      movey(2,"(-2,200,0)");  		// make it move up
      moveyon(2);			// turn the movement on
      shoot=1;
      }
  }

  for (y=0; y<3; y++)			// loop through all aliens
    for (x=1; x<8; x++)
     {
     if (s[(y*7)+x+2].on !=0)		// if you haven't hit it yet
     {
     if ((rand() % 50==5) & (totshoot <13))	// 1 in 50 chance of shooting
       {				// cannot shoot more than 14 at once
					// since we can only have 40 sprites
       ops=1;
       i=1;
	do {
	 if (alshoot[i]==0)		// find an open slot for missile
	   ops=i;
	 i++;
	 } while (i<14);

       alshoot[ops]=1;
       totshoot++;
       spriteon(ops+24,s[(y*7)+x+2].x+4,s[(y*7)+x+2].y,2); // turn shot on
       movey(ops+24,"(1,160,0)");			// move it down
       moveyon(ops+24);
       }

     if (overlap(2,(y*7)+x+2)==1)       // and your missile is hitting it
	{
	sound(200);
	spriteoff(2);			// turn off the missile
	shoot=0;			// not shooting anymore
	animate((y*7)+x+2,"(6,5)(7,5)(8,5)(9,5)(10,5)");  // show explosion
	animon((y*7)+x+2);   				// reset animation
	}
     if (s[(y*7)+x+2].num==10)		// if finished animating,
	 spriteoff((y*7)+x+2);		// turn off the sprite
       }
     }


for (y=1; y<15; y++)
  {
  if (s[y+24].y>154)
     {
     alshoot[y]=0;
     spriteoff(y+24);
     totshoot--;
     }
  }


if (s[2].y<-10)
  shoot=0;

if (kbhit())
   k=toupper(getch());			// convert to uppercase letter
drawspr();
nosound();
}

