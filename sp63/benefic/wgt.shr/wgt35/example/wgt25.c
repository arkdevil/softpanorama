/*   WORDUP Graphics Toolkit   Version 3.5
     Demonstration program 25

     Good practice for understanding the movement commands.
     See if you can guess what each move will do before you
     run this program.  It will help you understand the format
     for the movements.

*/

#include <stdio.h>
#include <dos.h>
#include <conio.h>
#include <stdlib.h>
#include <alloc.h>
#include <wgt.h>
#include <spr.h>

int i;
color palette[256];			// the palette
block sprites[1001];			// all the sprites
int quit;				// if quit !=0, program quits

void looper(void);			// a routine which controls the sprites

void main(void)
{
vga256();
wloadsprites(&palette,"mouse.spr",sprites);    // load them
initspr();					// initialize them
spon=4;					// number of sprites on
minit();

for (i=0; i<200; i++)		// draw a background
  {
  wsetcolor(i);
  wfline(0,i,159,i);
  wfline(160,199-i,319,199-i);
  }

wcopyscreen(0,0,319,199,NULL,0,0,spritescreen);
// when using sprites, whatever is on the visual page must be on
// spritescreen too!

// Also, you must make sure you turn a sprite on AFTER you draw
// the background or it will leave a black spot where the sprite 
// is first shown.
wsetscreen(spritescreen);
spriteon(1,0,0,1);		
animate(1,"(1,30)(2,30)(3,30)(4,30)(3,30)(2,30)R");
movex(1,"(2,150,0)(0,90,0)(-2,150,0)(0,90,0)R");
movey(1,"(0,150,0)(2,90,0)(0,150,0)(-2,90,0)R");

spriteon(2,160,0,1);		
animate(2,"(1,30)(2,30)(3,30)(4,30)R");
movex(2,"(-1,150,0)(1,300,0)(-1,150,0)R");
movey(2,"(1,180,0)(-1,180,0)R");

spriteon(3,0,100,1);		
animate(3,"(1,30)(4,30)R");
movex(3,"(1,300,1)(-300,1,0)R");
movey(3,"(0,1,0)");				// must set a y move since
						// I turn it on below even
						// if it doens't do anything
for (i=1; i<4; i++) {
animon(i);
movexon(i);
moveyon(i); }


do {
looper();
} while (!quit);


spriteoff(1);			// turn off sprites
spriteoff(2);			// turn off sprites
spriteoff(3);			// turn off sprites
// To be safe, turn off all sprites before ending program.
// This will free any memory used from them.


wfreesprites(sprites);		// free memory
wfreeblock(spritescreen);
wcls(0);
textmode(C80);
}


void looper(void)
{
erasespr();			// clear the sprites
drawspr();			// draw them back on
if (kbhit()) quit=1;
}
