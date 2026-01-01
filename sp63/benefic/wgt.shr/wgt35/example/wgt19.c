#include <conio.h>
#include <stdio.h>
#include <wgt.h>
#include <spr.h>
/*   WORDUP Graphics Toolkit   Version 3.5
     Demonstration program 19

  This program loads in some sprite created with the
  WordUp Sprite Creator.

*/

block screen1;		// one virtual screen
block sprites[1001];	// you MUST make this array of 1001
			// this holds all the sprites in an array
			// of blocks.

int y,sp;
color palette[256];

void main(void)
{
vga256();		// initializes system
wloadsprites(&palette,"space.spr",sprites);    // load the sprites
//	 the palette,  the file,  the array of sprites


screen1=wnewblock(0,0,319,199);
wsetscreen(screen1);		// sets to screen1

sp=1;				// sprites always start at 1 in the array

msetbounds(0,0,160,199);

do {
mread();
for (y=0; y<200; y++)
  {
  wsetcolor(y);
  wfline(0,y,319,y);		// clear the screen by drawing horz lines (fast)
  }

wputblock(mx,my,sprites[sp],1);	// put the block using xray mode at mouse position
wcopyscreen(0,0,160,199,screen1,0,0,NULL);  // copy the whole screen
// notice how we never use wnormscreen at all!
if (but==1)
   {
   sp++;
   if (sp>4) sp=1;
   noclick();
   }


} while (but !=2);		// right button exits

msetbounds(0,0,319,199);


wfreeblock(screen1);	// remember to free that memory
wfreesprites(sprites);  // frees all sprites
textmode(C80);				// used to return to text mode
}