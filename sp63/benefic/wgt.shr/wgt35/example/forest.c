#include <dos.h>
#include <alloc.h>
#include <stdio.h>
#include <conio.h>
#include <wgt.h>
#include <scroll.h>
/* WordUp Graphics Toolkit Scrolling Demo
 This program demonstrates a method of animating the tiles in a map.
 The basic idea is to scan through the map, looking for the tile
 you want to animate. For every occurrence, store the x and y coordinates
 in an array. Keep track of the number of tiles found.
 In the main loop, keep changing the tiles with wputworldblock.
*/

wgtmap forestmap;			// our world map

unsigned char waterx[300],watery[300]; // x and y coords of animated tiles
unsigned char wateranim[300]; // current tile number in animation

int number_of_water_blocks; // number of tiles needed to change

int kbdon[100]={0,0,0,0,0};	// our keyboard on/off array;
int kbdscanlist[100]={72,80,75,77,1};	// our keyboard scan codes;
// You must have the above two if you want the keyboard interrupt 

color palette[256];		// our palette of colours

block blocks[1001];		// our blocks for the map
block sprites[1001];		// our sprites 

int i,xmove,ymove;

void scanwater(void);	// Search map for all water tiles.
void movewater(void);   // Animate the tiles

void main(void)
{
vga256();					// init
wloadsprites(&palette,"forest.spr",blocks);    	// load blocks
forestmap=wloadmap("forest.wmp");		// load our world map

winitscroll(13,10);				// make a 13x10 box
						// for the scrolling

wnormscreen();					// go back to normal screen
wcls(0);					// clear it

wshowwindow(0,0,forestmap);			// start looking at world
						// at 0,0
installkbd();					// start new keyboard interrupt

scanwater();  					// find the tiles
do
{

xmove=0;
ymove=0;
if (kbdon[2]==1)		// Pressing left
  xmove=-8;
else if (kbdon[3]==1)		// Pressing right
  xmove=8;
if (kbdon[0]==1)		// Pressing up
  ymove=-8;
else if (kbdon[1]==1)		// Pressing down
  ymove=8;

wscrollwindow(xmove,ymove,forestmap);	// update the scrolling window

movewater();				// animate the tiles
wcopyscroll(0,0);			// copy to visual screen
} while (kbdon[4] !=1);			// until ESC is pressed

uninstallkbd();				// remove keyboard interrupt

wendscroll();				// close down the scrolling
wfreesprites(blocks);
free(forestmap);
textmode(C80);
}


void scanwater(void)
{
int i,j,temp;

number_of_water_blocks=0;
for (i=0; i<=mapheight; i++)
  for (j=0; j<=mapwidth; j++)
     {
     temp=wgetworldblock(j*16,i*16,forestmap);
     if (temp==2) // it is water
       {
       waterx[number_of_water_blocks]=j;		// store x and y
       watery[number_of_water_blocks]=i;
       wateranim[number_of_water_blocks]=2;
       number_of_water_blocks++;
       }
     }
}


void movewater(void)
{
int j;

  for (j=0; j<=number_of_water_blocks; j++)
     {
      if ((waterx[j]*16>worldx-16) &
	  (waterx[j]*16<worldx+windowmaxx+16) &
	  (watery[j]*16>worldy-16) &
	  (watery[j]*16<worldy+windowmaxy+16))
	  {
	  wateranim[j]++;
	  if (wateranim[j]>4)
	  wateranim[j]=2;
	  wputworldblock(waterx[j]*16,watery[j]*16,wateranim[j],forestmap);
       }
       }
}
