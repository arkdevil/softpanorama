#include <conio.h>
#include <stdio.h>
#include <wgt.h>
/*   WORDUP Graphics Toolkit   Version 3.5
     Demonstration program 18

This program shows how to make animation with two screens.

One way to produce animation is to use two screens.  One screen is
constantly displayed while you draw things on the other.  Once the
drawing is complete, you then copy the whole screen in the background
to the one that is being displayed.


	    Visual Screen			   Background Screen
    ..............................          ..............................
    ......o.......................          ......o..............o........
    ...../Y\......................          ...../Y\............/Y\.......
    ......|.......................          ......|..............|........
    ...../.\......................          ...../.\............/.\.......
    ..............................          ..............................
    ..............................          .Pos 1-> Clear Screen ->Pos 2.
    ..............................          ..............................

Here we have a person shown on the visual page. It has just been copied
over from the background screen. Now you must clear the background screen
somehow (put a picture over top, or wcls(0) it).  Once it is cleared, you
can use putblock to show the person in a different place on the screen.
Then you copy the background screen to the visual screen and repeat the
process.  This method is slow, but can be sped up by decreasing the number
of putblocks you use as sprites, and make the area copied from one screen
to another smaller.


*/

block screen1,circ;		// one virtual screen and our sprite circ
int y;

void main(void)
{
vga256();		// initializes system

screen1=wnewblock(0,0,319,199);

wsetcolor(40);
wfill_circle(30,30,20);		// draw a circle with a box cut out in middle
wsetcolor(0);
wbar(20,20,40,40);

circ=wnewblock(10,10,50,50);		// get the sprite


wsetscreen(screen1);		// sets to screen1

do {
mread();
for (y=0; y<200; y++)
  {
  wsetcolor(y);
  wline(0,y,319,y);		// clear the screen by drawing horz lines (fast)
  }

wputblock(mx,my,circ,1);	// put the block using xray mode at mouse position
wputblock(319-mx,my,circ,1);
wputblock(mx,199-my,circ,1);
wputblock(319-mx,199-my,circ,1);
wcopyscreen(0,0,319,199,screen1,0,0,NULL);  // copy the whole screen
// notice how we never use wnormscreen at all!

} while (but==0);



wfreeblock(screen1);	// remember to free that memory
wfreeblock(circ);
textmode(C80);				// used to return to text mode
}