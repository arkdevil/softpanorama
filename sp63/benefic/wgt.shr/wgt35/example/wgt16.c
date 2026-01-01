#include <conio.h>
#include <stdio.h>
#include <wgt.h>
/*   WORDUP Graphics Toolkit   Version 3.5
     Demonstration program 16

This program shows how to use wcopyscreen

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

wsetscreen(screen1);		// sets to screen1
for (y=0; y<200; y++)
  {
  wsetcolor(y);
  wfline(0,0,319,y);		// draw something on another screen
  wfline(319,199,0,y);
  }

minit();
moff();
wnormscreen();		// make the putblock go onto the default screen

do {
  mread();
  wcopyscreen(mx,my,mx+20,my+20,screen1,mx,my,NULL);
  // this means copy a square 20*20 from screen1 to the same spot
  // on the default screen.  Move the mouse around and watch the black
  // wipe away as screen1 copies over.

  // NULL means the default screen.  Be sure to #include <stdio.h>
  // so it knows what NULL means.

   } while (!kbhit());

getch();		// wasn't that fun?!


wfreeblock(screen1);	// remember to free that memory (64004 bytes for a screen)

textmode(C80);				// used to return to text mode
}