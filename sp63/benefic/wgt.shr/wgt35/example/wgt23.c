/*   WORDUP Graphics Toolkit   Version 3.5
     Demonstration program 23

     Make a large 256 colour, animating mouse cursor!

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
spon=1;					// number of sprites on
minit();

for (i=0; i<200; i++)		// draw a background
  {
  wsetcolor(i);
  wline(0,i,159,i);
  wline(160,199-i,319,199-i);
  }

wcopyscreen(0,0,319,199,NULL,0,0,spritescreen);
// when using sprites, whatever is on the visual page must be on
// spritescreen too!

// Also, you must make sure you turn a sprite on AFTER you draw
// the background or it will leave a black spot where the sprite 
// is first shown.
wsetscreen(spritescreen);
spriteon(1,160,100,1);				// turn on any sprites

animate(1,"(1,30)(2,30)(3,30)(4,30)(3,30)(2,30)R");
animon(1);
// animate the sprite




do {
looper();
} while (!quit);


spriteoff(1);			// turn off sprites
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

mread();
s[1].x=mx;			// any direct sprite movements must be placed
s[1].y=my;			// between erasespr and drawspr
// This will place sprite number 1 where the mouse cursor is.


drawspr();			// draw them back on
if (kbhit()) quit=1;
}
