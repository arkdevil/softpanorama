#include <conio.h>
#include <wgt.h>
/*   WORDUP Graphics Toolkit   Version 3.5
     Demonstration program 15

This program shows how to use virtual graphics pages and tells how
they are used in animation.  More complicated examples follow after this
one.

*/

int x,y;
block screen1;


void main(void)
{
vga256();		// initializes system

screen1=wnewblock(0,0,319,199);
	// virtual screens are created by making a block with size
	// 0-319 and 0-199.  These screens can be used like any other
	// block, however they make also be drawn on top of.
	// You can tell which screen to draw to by calling
	// wsetscreen(name of block) and wnormscreen() to restore
	// drawing to the default screen.
	// For example:

wsetscreen(screen1);		// sets to screen1
for (y=0; y<200; y++)
  {
  wsetcolor(y);
  wline(0,0,319,y);		// draw something on another screen
  wline(319,199,0,y);
  }

sound(500);		// This is to let you know when it is finished
delay(100);
nosound();
getch();		// there is nothing on the screen yet

// now use putblock to show what happened on the other screen

wnormscreen();		// make the putblock go onto the default screen
wputblock(0,0,screen1,0);

getch();		// now everything is shown!


wfreeblock(screen1);	// remember to free that memory (64004 bytes for a screen)

textmode(C80);				// used to return to text mode
}