#include <dos.h>
#include <alloc.h>
#include <stdio.h>
#include <conio.h>
#include <wgt.h>
#include <scroll.h>

/* Very basic scrolling demo
   Try starting your own scrolling game, beginning with
   this one and adding more as you need it.
   This program loads in the tiles, map, and objects,
   and scrolls around the map using one object overtop.
   This may run too fast on new computers since there is no timing control
   in this demo.
*/
int speedx,speedy;
int guyanim,guydir;
int ox,oy;

wgtmap castlemap;			// our world map

int kbdon[100]={0,0,0,0,0};	// our keyboard on/off array;
int kbdscanlist[100]={72,80,75,77,1};	// our keyboard scan codes;
// You must have the above two if you want the keyboard interrupt 

color palette[256];		// our palette of colours

block blocks[1001];		// our blocks for the map
block sprites[1001];		// our sprites 

int i,guyspeed;

void main(void)
{
vga256();					// init
wloadsprites(&palette,"castle.spr",blocks);    	// load blocks
wloadsprites(&palette,"guy.spr",sprites);    	// load sprites

castlemap=wloadmap("castle.wmp");		// load our world map

winitscroll(17,10);				// make a 17x10 box
						// for the scrolling

wnormscreen();					// go back to normal screen
wcls(0);					// clear it

wshowwindow(0,0,castlemap);			// start looking at world
						// at 0,0
installkbd();					// start new keyboard interrupt

numsprites=5;
wobject[0].on=1; wobject[0].x=16; wobject[0].y=16; wobject[0].num=1;

guyanim=1;
guyspeed=6;

do
{

speedx=0;
speedy=0;
ox=wobject[0].x;
oy=wobject[0].y;

if (kbdon[2]==1)		// Pressing left
  {
  wobject[0].x-=guyspeed;
  guydir=1;
  guyanim++;
  }
else if (kbdon[3]==1)	// Pressing right
  {
  wobject[0].x+=guyspeed;
  guydir=3;
  guyanim++;
}
if (kbdon[0]==1)		// Pressing up
  {
  wobject[0].y-=guyspeed;
  guydir=0;
  guyanim++;
}
else if (kbdon[1]==1)	// Pressing down
  {
  wobject[0].y+=guyspeed;
  guydir=2;
  guyanim++;
}


if (guyanim>4)
  guyanim=1;
wobject[0].num=guyanim+(guydir*4);

if (wobject[0].x-worldx<windowmaxx/2-20)
   speedx=-guyspeed;
else if (wobject[0].x-worldx>windowmaxx/2+20)
   speedx=guyspeed;
if (wobject[0].y-worldy<windowmaxy/2-1)
   speedy=-guyspeed;
else if (wobject[0].y-worldy>windowmaxy/2+20)
   speedy=guyspeed;

wscrollwindow(speedx,speedy,castlemap);	// update the scrolling window
wshowobjects();
wcopyscroll(0,0);
} while (kbdon[4] !=1);			// until right button is pressed

uninstallkbd();

wendscroll();
wfreesprites(blocks);
wfreesprites(sprites);
free(castlemap);
textmode(C80);
}

