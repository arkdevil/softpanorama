#include <conio.h>
#include <wgt.h>
#include <wgtfli.h>
// WordUp Graphics Toolkit FLI demo program
// This beauty resizes an FLI as it plays, and allows
// you to change the size of the window.
// Use the right hand mouse button to resize, and the left to move the 
// window. Press any key to exit.


int wx=0,wy=0,ww=100,wh=100; // fli window coordinates
block other;		     // the virtual screen to show FLI on


void movebox(void)   // Move the fli window around
{
 wclip(0,0,319,199);
 wsetcolor(0);
 wbar(wx,wy,wx+ww,wy+wh);

do {
mread();
wsetcolor(0);
wline(wx,wy,wx+ww,wy);
wline(wx,wy,wx,wy+wh);
wline(wx+ww,wy,wx+ww,wy+wh);
wline(wx,wy+wh,wx+ww,wy+wh);

wx=mx; wy=my;
wsetcolor(1);
wline(wx,wy,wx+ww,wy);
wline(wx,wy,wx,wy+wh);
wline(wx+ww,wy,wx+ww,wy+wh);
wline(wx,wy+wh,wx+ww,wy+wh);

} while (but==1);
 wclip(wx+1,wy+1,wx+ww-1,wy+wh-1);
}

void resizebox(void)  // resize the fli window
{
 wclip(0,0,319,199);
wsetcolor(0);
wbar(wx,wy,wx+ww,wy+wh);
msetbounds(wx+2,wy+2,319,199);

do {
mread();
wsetcolor(0);
wline(wx,wy,wx+ww,wy);
wline(wx,wy,wx,wy+wh);
wline(wx+ww,wy,wx+ww,wy+wh);
wline(wx,wy+wh,wx+ww,wy+wh);

ww=mx-wx; wh=my-wy;
wsetcolor(1);
wline(wx,wy,wx+ww,wy);
wline(wx,wy,wx,wy+wh);
wline(wx+ww,wy,wx+ww,wy+wh);
wline(wx,wy+wh,wx+ww,wy+wh);

} while (but==2);
 wclip(wx+1,wy+1,wx+ww-1,wy+wh-1);
 msetbounds(0,0,319,199);
}

void main(void)
{
     vga256();
     other=wnewblock(0,0,319,199);
     fliscreen=other;

     openfli("wordup.fli");
     wsetcolor(1);
     wline(wx,wy,wx+ww,wy);
     wline(wx,wy,wx,wy+wh);
     wline(wx+ww,wy,wx+ww,wy+wh);
     wline(wx,wy+wh,wx+ww,wy+wh);
     wclip(wx+1,wy+1,wx+ww-1,wy+wh-1);

     minit();
     do {
     mread();
     nextframe();
     moff();
     wnormscreen();
     wclip(0,0,319,199);
     wresize(wx+1,wy+1,wx+ww-1,wy+wh-1,other); 
     // instead of using copyfli, we will resize the fli
     // although it is slow at large sizes
     mon();
     if (but==1) movebox();
     if (but==2) resizebox();
     }while (!kbhit());
     getch();
     wfreeblock(other);
     closefli();
     textmode(C80);
}

