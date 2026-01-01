#include <dos.h>
#include <alloc.h>
#include <stdio.h>
#include <conio.h>
#include <wgt.h>
#include <scroll.h>
#include <time.h>

// Feel free to modify any of this code!
// Generic platform game using a character which is 32 pixels high.
// Modify the defines and character stats below for a quick and instant
// platform game.  This should really help you get started with a game
// of this type.

// The character is a little stiff, and there's nothing else on the map,
// but hey! It is only a demo!


#define YOU 50
#define WALKRIGHT1 1
#define WALKRIGHT2 8
#define STANDRIGHT 9
#define JUMPRIGHT 10
#define WALKLEFT1 11
#define WALKLEFT2 18
#define STANDLEFT 19
#define JUMPLEFT 20

#define LEFT 1
#define RIGHT 2

#define SOLID 1
#define HOLLOW 0

void checkfeet(void);
void checkhead(void);
void checkright(void);
void checkleft(void);

int oldx,oldy,direction,anim;
int jumping,gravity;
int spx,spy;

int charheight=32;	// main character's height in pixels
int extra=2;		// leave a bit of extra space above head and below
			// feet to fit through tight places in the map.

// 4 TIME structures to hold different info
time_t tim1,tim2,tim3,tim4;
// The number of times the screen is updated
long updates;

int windx,windy;	// window vars

wgtmap gamemap;			// our world map

int kbdon[100]={0,0,0,0,0,0};	// our keyboard on/off array;
int kbdscanlist[100]={72,80,75,77,1,29};	// our keyboard scan codes;
// You must have the above two if you want the keyboard interrupt 

color palette[256];		// our palette of colours

block blocks[1001];		// our blocks for the map
block sprites[1001];		// our sprites 

int i;

void main(void)
{
printf("Wordup Graphics Toolkit     Platform SCROLLING DEMO\n");
printf("Arrow keys move, CTRL jumps. Up/down looks in direction\n");
printf("\nWindow Width (2-17):");
scanf("%i",&windx);
printf("\nWindow Height (2-10):");
scanf("%i",&windy);

vga256();					// init
wloadsprites(&palette,"tiles.spr",blocks);    	// load tiles
wloadsprites(&palette,"object.spr",sprites);    	// load objects

gamemap=wloadmap("map.wmp");		// load our world map

winitscroll(windx,windy);	

wnormscreen();					// go back to normal screen
wcls(0);					// clear it

wshowwindow(0,10,gamemap);			// start looking at world
						// at 0,0
installkbd();					// start new keyboard interrupt
numsprites=100;
// original sprite locations and numbers are stored within the map file
// created by the map maker...


jumping=0; gravity=0;
anim=1;

gettime(&tim1);
// get beginning time
window(1,1,80,25);

do
{
gettime(&tim3);
// used to store time needed for one frame

spx=0;
spy=0;
oldx=wobject[YOU].x;
oldy=wobject[YOU].y;

if (jumping==1)
  gravity+=2;
if (gravity>15)
   gravity=15;

if ((kbdon[5]==1) & (jumping==0))
   {
   jumping=1;
   gravity=-14;		// make smaller for a higher jump
   }

if (kbdon[2]==1)		// Pressing left
  {
  wobject[YOU].x-=8;
  checkleft();
  if (direction !=LEFT)
    {
    direction=LEFT;
    anim=WALKLEFT1;
    }
  anim++;
  if (anim>WALKLEFT2)
    anim=WALKLEFT1;
  }
else if (kbdon[3]==1)	// Pressing right
  {
  wobject[YOU].x+=8;
  checkright();
  if (direction !=RIGHT)
    {
    direction=RIGHT;
    anim=WALKRIGHT1;
    }
  anim++;
  if (anim>WALKRIGHT2)
    anim=WALKRIGHT1;
  }

wobject[YOU].num=anim;

if (wobject[YOU].x==oldx)	// haven't moved left or right?

  if (direction==LEFT)
     wobject[YOU].num=STANDLEFT;
  else wobject[YOU].num=STANDRIGHT;

wobject[YOU].y+=gravity;
if (wobject[YOU].y<0) wobject[YOU].y=0;
if (gravity<0)
   checkhead();


if (jumping==1)
  if (direction==LEFT)
     wobject[YOU].num=JUMPLEFT;
  else wobject[YOU].num=JUMPRIGHT;

 checkfeet();

spx=wobject[YOU].x-worldx-windowmaxx/2;
spy=wobject[YOU].y-worldy-windowmaxy/2;

if (kbdon[0]==1)		// Pressing up
  {
     spy=-4;
  }
if (kbdon[1]==1)	// Pressing down
  {
 spy+=4;
 }

//moveguys();
wscrollwindow(spx,spy,gamemap);	// update the scrolling window
wshowobjects();

wcopyscroll(30,10);
nosound();
updates++;
// Run once, to find out the frame rate. Now take the milliseconds
// per frame value, and put it in the while statement. Unremark this
// while statement, and give it a try using a smaller scrolling window.
// It should run at the same speed regardless of the window size.
// Of course if it is a larger window, it will be slower than you want it.
/*do {
   gettime(&tim4);
   } while (wtimer(tim3,tim4)<5);*/ 
// Each frame takes at least 5 milliseconds right now. Raise and lower
// the number to change the speed of the game.

} while (kbdon[4] !=1);			// until right button is pressed
gettime(&tim2);
// get final time

uninstallkbd();

wendscroll();
wfreesprites(blocks);
wfreesprites(sprites);
wfreemap(gamemap);
textmode(C80);
printf("\n# seconds: %d",wtimer(tim1,tim2)/100);
printf("\n# ms: %i",wtimer(tim1,tim2));
printf("\n# updates: %i",updates);


printf("\nAverage frame rate: %2.2f frames/sec",(float)updates/(float)(wtimer(tim1,tim2)/100));
printf("\nMilliseconds per frame: %2.2f ms/f",wtimer(tim1,tim2)/(float)updates);
printf("\nRemember this-------------^");
// now that you now this, you can delete all uses of tim1, and tim2
// and only use tim3,tim4 to control timing. Try it!

getch();
}


void checkright(void)
{
int j,k,l;

  j=wgetworldblock(wobject[YOU].x+16,wobject[YOU].y+extra,gamemap);
  k=wgetworldblock(wobject[YOU].x+16,wobject[YOU].y+15,gamemap);
  l=wgetworldblock(wobject[YOU].x+16,wobject[YOU].y+charheight-extra-1,gamemap);
   if ((tiletype[j]==SOLID) || (tiletype[k]==SOLID) ||(tiletype[l]==SOLID))
    {
	j=wgetworldblock(wobject[YOU].x+15,wobject[YOU].y+extra,gamemap);
	k=wgetworldblock(wobject[YOU].x+15,wobject[YOU].y+15,gamemap);
	l=wgetworldblock(wobject[YOU].x+15,wobject[YOU].y+charheight-extra-1,gamemap);
	while ((tiletype[j]==SOLID) || (tiletype[k]==SOLID)
		 ||(tiletype[l]==SOLID))
	{
	   wobject[YOU].x--;
  j=wgetworldblock(wobject[YOU].x+15,wobject[YOU].y+extra,gamemap);
  k=wgetworldblock(wobject[YOU].x+15,wobject[YOU].y+15,gamemap);
  l=wgetworldblock(wobject[YOU].x+15,wobject[YOU].y+charheight-extra-1,gamemap);

   }
   }
}

void checkleft(void)
{
int j,k,l;

  j=wgetworldblock(wobject[YOU].x-1,wobject[YOU].y+extra,gamemap);
  k=wgetworldblock(wobject[YOU].x-1,wobject[YOU].y+15,gamemap);
  l=wgetworldblock(wobject[YOU].x-1,wobject[YOU].y+charheight-extra-1,gamemap);
   if ((tiletype[j]==SOLID) || (tiletype[k]==SOLID) ||(tiletype[l]==SOLID))
    {
  j=wgetworldblock(wobject[YOU].x,wobject[YOU].y+extra,gamemap);
  k=wgetworldblock(wobject[YOU].x,wobject[YOU].y+15,gamemap);
  l=wgetworldblock(wobject[YOU].x-1,wobject[YOU].y+charheight-extra-1,gamemap);
   while ((tiletype[j]==SOLID) || (tiletype[k]==SOLID)
	 ||(tiletype[l]==SOLID))
 {
   wobject[YOU].x++;
  j=wgetworldblock(wobject[YOU].x,wobject[YOU].y+extra,gamemap);
  k=wgetworldblock(wobject[YOU].x,wobject[YOU].y+15,gamemap);
  l=wgetworldblock(wobject[YOU].x,wobject[YOU].y+charheight-extra-1,gamemap);
   }
   }
}

void checkfeet(void)
{
int j,k;

  j=wgetworldblock(wobject[YOU].x,wobject[YOU].y+charheight,gamemap);
  k=wgetworldblock(wobject[YOU].x+15,wobject[YOU].y+charheight,gamemap);
  if ((tiletype[j]==HOLLOW) & (tiletype[k]==HOLLOW))
    jumping=1;
    else {
   jumping=0;
   gravity=0;
   j=wgetworldblock(wobject[YOU].x,wobject[YOU].y+charheight-1,gamemap);
   k=wgetworldblock(wobject[YOU].x+15,wobject[YOU].y+charheight-1,gamemap);
   while ((tiletype[j]==SOLID) || (tiletype[k]==SOLID)) {
   wobject[YOU].y--;
   j=wgetworldblock(wobject[YOU].x,wobject[YOU].y+charheight-1,gamemap);
   k=wgetworldblock(wobject[YOU].x+15,wobject[YOU].y+charheight-1,gamemap);
   }
   }
}

void checkhead(void)
{
int j,k;

  j=wgetworldblock(wobject[YOU].x,wobject[YOU].y-1,gamemap);
  k=wgetworldblock(wobject[YOU].x+15,wobject[YOU].y-1,gamemap);
  if ((tiletype[j]==SOLID) || (tiletype[k]==SOLID))
    {
   jumping=0;
   gravity=0;
   j=wgetworldblock(wobject[YOU].x,wobject[YOU].y,gamemap);
   k=wgetworldblock(wobject[YOU].x+15,wobject[YOU].y,gamemap);
   while ((tiletype[j]==SOLID) || (tiletype[k]==SOLID))
    {
   wobject[YOU].y++;
   j=wgetworldblock(wobject[YOU].x,wobject[YOU].y,gamemap);
   k=wgetworldblock(wobject[YOU].x+15,wobject[YOU].y,gamemap);
   }
   }
}


