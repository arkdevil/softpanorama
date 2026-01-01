#include <alloc.h>
#include <stdio.h>
#include <conio.h>
#include <time.h>
#include <stdlib.h>
#include <wgt.h>
#include <spr.h>

/*   WORDUP Graphics Toolkit   Version 3.5
     Demonstration program 20

  This program uses the same sprites as last time but
  this time in a shoot-em-up game.


*/

// Large example demonstrating many functions from WGT 

void scrolldown(void);		// scroll the screen down
void credits(void);
void changepalette256(void);
void l(void);


block scr,scr2;
block sprites[1001];

int shoot[10],sx[10],sy[10];

int cd;
int i,scrll=1;                          // scrll is ctr for offset
int ix=30,iy=0,ix2=250,iy2=199;		// coords of scrolling area
int speed=-1; 				// the scrolling speed
					// try changing speed and sign
color palette[256];


void main(void)
{
vga256();					// init
minit();
moff();
wsetpalette(0,255,&palette);
credits();
wloadsprites(&palette,"space.spr",sprites);    	// load sprites

scr=wnewblock(0,0,319,199);			// get two virtual screens
scr2=wnewblock(0,0,319,199);
wsetscreen(scr2);				// go to second one
wcls(0);					// clear it
for (i=1; i<300; i++)				// put some stars on (small)
  wputblock(rand() % 320,rand() % 200,sprites[3],0);   // sprite[3] is small stars

for (i=1; i<5; i++)
  wputblock(rand() % 320,rand() % 200,sprites[4],0);   // sprite[4] is large ones

wnormscreen();					// go back to normal screen
wcls(0);					// clear it
wbutt(0,0,29,199);				// make some side panels
wbutt(252,0,319,199);
my=0;
wsetscreen(scr);				// go to first screen
noclick();
speed=-1;
do {
mread();					// read mouse

scrolldown();					// scroll the second
						// screen by copying it to
						// a different offset on
						// screen one

if (but==1) {				// if you clicked the mouse
 i=0;                                   // set counter to 0
 do {
 if (shoot[i]==0)			// check to see if slot available
    {
    sound(100);				// yes, then make a sound
    shoot[i]=1;				// make it unavailable
    sx[i]=mx+7;				// set coords for shot
    sy[i]=my-7;
    i=9;				// end the loop
    }
 i++;				// otherwise look at the next slot
 } while (i<9);			// can shoot 9 at once
 }

 for (i=0; i<9; i++)		// if shot is active
    {
    if (shoot[i]==1)		// then show the sprite
       {
       wputblock(sx[i],sy[i],sprites[2],0);	// at the right coords
       sy[i]-=6;				// make it go up
       if (sy[i]<1)		  // if it is at top,
	  shoot[i]=0;		  // make it available again
       }
    }
wcopyscreen(ix,iy,ix2,iy2,scr,ix,iy,NULL);	// copy the first screen
						// to the base screen
 nosound();
} while (!kbhit());			// until right button is pressed
wfreeblock(scr);
wfreeblock(scr2);
wfreesprites(sprites);
textmode(C80);
}



void scrolldown(void)
{
// With a bit of work, you could make this routine scroll in
// four directions and make new graphics come on as it scrolls!
// Of course, we've already gone and done that for you! Check out wgt4scr.lib
wcopyscreen(ix,scrll,ix2,iy2,scr2,ix,iy,scr);	      // You may understand
wcopyscreen(ix,iy,ix2,scrll,scr2,ix,iy2-scrll,scr);   // this if you think
						      // hard enough!
						      // Don't worry about
						      // it for now!
wputblock(mx,my,sprites[1],1);
scrll+=speed;
if ((scrll<iy) & (speed<0))
  scrll=iy2+1-abs(scrll);
if ((scrll>iy2) & (speed>0))
  scrll=abs(iy2-scrll);
}

void credits(void)
{
wnormscreen();
wtextcolor(1);
wtextbackground(0);

cd=2;
// draw a pattern on the screen
for (i=0; i<320; i++) { l(); wsetcolor(cd);  wfline(160,100,i,0);  }
for (i=0; i<200; i++) { l(); wsetcolor(cd);  wfline(160,100,319,i);}
for (i=319; i>=0; i--) { l(); wsetcolor(cd);  wfline(160,100,i,199);}
for (i=199; i>=0; i--) { l(); wsetcolor(cd);  wfline(160,100,0,i);  }


changepalette256();

wouttextxy(50,20,"Shoot 'Em Up Sprite Example",NULL);
wouttextxy(50,28,"Showing what YOU could do with",NULL);
wouttextxy(50,36,"the WordUp Graphics Toolkit!",NULL);
wouttextxy(50,44,"Use mouse to move, button shoots",NULL);
wouttextxy(50,52,"Press any key to start",NULL);
wsetrgb(1,63,63,63,&palette);
wfade_in(0,255,1,palette);
do {
  wcolrotate(2,255,0,palette);
  } while (!kbhit());

getch();
wcls(0);
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// change the palette to the right colours
void changepalette256(void)
{
  wsetrgb(0,0,0,0,&palette);

  for (i=2; i<64; i++) 
       wsetrgb(i,i,0,0,&palette);
  for (i=64; i<128; i++) 
       wsetrgb(i,127-i,0,0,&palette);
  for (i=128; i<192; i++) 
       wsetrgb(i,0,0,i-128,&palette);
  for (i=192; i<256; i++) 
       wsetrgb(i,0,0,256-i,&palette);
 wsetrgb(253,60,60,60,&palette);
 wsetrgb(254,45,45,45,&palette);
 wsetrgb(255,30,30,30,&palette);
 wsetrgb(1,63,63,63,&palette);
// wsetpalette(0,255,palette);
}

void l(void)
{
cd++;
if (cd>127)
  cd=2;
}
