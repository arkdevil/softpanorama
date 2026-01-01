// This is a small program 'template' to help you get started
// with the sprites library.

/*   WORDUP Graphics Toolkit   Version 3.5
     Demonstration program 22

     Sprite program template.

*/

#include <stdio.h>
#include <dos.h>
#include <conio.h>
#include <stdlib.h>
#include <alloc.h>
#include <wgt.h>
#include <spr.h>

color palette[256];			// the palette
block sprites[1001];			// all the sprites
int quit;				// if quit !=0, program quits

void looper(void);			// a routine which controls the sprites

void main(void)
{
vga256();
wloadsprites(&palette,"invader.spr",sprites);    // load them
initspr();					// initialize them
spon=10;					// number of sprites on

spriteon(1,160,100,1);				// turn on any sprites
spriteon(2,10,100,3);				// you need

// Spriteon has the following format:
// Sprite number, x coord, y coord, sprite number in array of sprites
// Therefore sprite #1 would be displayed at 160,100 with sprite 1 in the array


movex(2,"(1,300,0)(-1,300,0)R");		// set up any movement
movexon(2);					// or animation needed

// This move will go left 1, for 300 times, and right 1 for 300 times,
// and repeat

animate(2,"(3,50)(4,50)(5,50)(4,50)R");
animon(2);

// This animation will animate sprite 2 through a sequence of sprites
// in the sprite array and keep repeating.

wsetscreen(spritescreen);

do {
looper();
} while (!quit);


spriteoff(1);			// turn off sprites
spriteoff(2);
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
// notice how sprite #2 moves and animates on its own now!
// You don't need to change anything to make it move!


drawspr();			// draw them back on
if (kbhit()) quit=1;
}
