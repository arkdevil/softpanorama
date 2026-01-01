#include <dos.h>
#include <alloc.h>
#include <stdio.h>
#include <conio.h>
#include <wgt.h>
#include <scroll.h>
#include <time.h>

// Demonstrates timing control

#define YOU 37
void checkfeet(void);
void checkhead(void);
void checkright(void);
void checkleft(void);
void findelevators(void);
void upelev(void);
void downelev(void);
void checkelevators(void);
void moveguys(void);

int ox,oy,dir,anim;
int jumping,addy;
int spx,spy;

// 4 TIME structures to hold different info
time_t tim1,tim2,tim3,tim4;
// The number of times the screen is updated
long updates;

int feet1,feet2,head1,head2;
int windx,windy;

wgtmap mymap;			// our world map

int kbdon[100]={0,0,0,0,0,0};	// our keyboard on/off array;
int kbdscanlist[100]={72,80,75,77,1,29};	// our keyboard scan codes;
// You must have the above two if you want the keyboard interrupt 

color palette[256];		// our palette of colours

block blocks[1001];		// our blocks for the map
block sprites[1001];		// our sprites 

int i;

typedef struct {
    int curheight;
    int origy,origx;
    int timer;
    } elevator;

int replace[200];
int elevup=-1;


elevator elev[30];
int numelev=0;

void main(void)
{
printf("Wordup Graphics Toolkit     4-WAY SCROLLING DEMO\n");
printf("Copyright 1992 WordUp Software Productions\n\n");
printf("Arrow keys move, CTRL jumps. Up/down looks in direction or operates\n");
printf("elevators.\n\nWindow Width (2-17):");
scanf("%i",&windx);
printf("\nWindow Height (2-10):");
scanf("%i",&windy);

vga256();					// init
wloadsprites(&palette,"munchmap.spr",blocks);    	// load blocks
wloadsprites(&palette,"munchkin.spr",sprites);    	// load sprites

mymap=wloadmap("mun.wmp");		// load our world map

findelevators();

winitscroll(windx,windy);	

wnormscreen();					// go back to normal screen
wcls(0);					// clear it

wshowwindow(0,10,mymap);			// start looking at world
						// at 0,0
installkbd();					// start new keyboard interrupt
numsprites=40;
wobject[YOU].on=1; wobject[YOU].x=16; wobject[YOU].y=242; wobject[YOU].num=1;

jumping=0; addy=0;
anim=2;

gettime(&tim1);
// get beginning time
window(1,1,80,25);
do
{
gettime(&tim3);
// used to store time needed for one frame

spx=0;
spy=0;
ox=wobject[YOU].x;
oy=wobject[YOU].y;

if (jumping==1)
  addy+=2;
if (addy>15)
   addy=15;

if ((kbdon[5]==1) & (jumping==0))
   {
   jumping=1;
   addy=-14;
   }

if (kbdon[2]==1)		// Pressing left
  {
  wobject[YOU].x-=8;
  checkleft();
  if (dir !=1)
    {
    dir=1;
    anim=5;
    }
  anim++;
  if (anim>8)
    anim=5;
  }
else if (kbdon[3]==1)	// Pressing right
  {
  wobject[YOU].x+=8;
  checkright();
  if (dir !=2)
    {
    dir=2;
    anim=1;
    }
  anim++;
  if (anim>4)
    anim=1;
  }

wobject[YOU].num=anim;
if (wobject[YOU].x==ox)
  if (dir==1)
     wobject[YOU].num=9;
  else wobject[YOU].num=1;

wobject[YOU].y+=addy;
if (wobject[YOU].y<0) wobject[YOU].y=0;
if (addy<0)
   checkhead();


if ((jumping==1))
  if (dir==1)
     wobject[YOU].num=6;
  else wobject[YOU].num=2;

 checkfeet();

spx=wobject[YOU].x-worldx-windowmaxx/2;
spy=wobject[YOU].y-worldy-windowmaxy/2;

if (kbdon[0]==1)		// Pressing up
  {
  if ((feet1==105) | (feet2==105))
     upelev();
  else
     spy=-4;
  }
if (kbdon[1]==1)	// Pressing down
  {
  if ((feet1==105) | (feet2==105))
     downelev();
  else
     spy=+4;
 }

checkelevators(); // make sure they come back down when not standing on them


moveguys();


wscrollwindow(spx,spy,mymap);	// update the scrolling window
wshowobjects();

wcopyscroll(30,10);
nosound();
updates++;
gotoxy(1,23); printf("%i",updates);
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
wfreemap(mymap);
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

  j=wgetworldblock(wobject[YOU].x+16,wobject[YOU].y+1,mymap);
  k=wgetworldblock(wobject[YOU].x+16,wobject[YOU].y+15,mymap);
  if ((j>=100) | (k>=100))
    {
	j=wgetworldblock(wobject[YOU].x+15,wobject[YOU].y+1,mymap);
	k=wgetworldblock(wobject[YOU].x+15,wobject[YOU].y+15,mymap);
   while ((j>=100) | (k>=100)) {
   wobject[YOU].x--;
  j=wgetworldblock(wobject[YOU].x+15,wobject[YOU].y+1,mymap);
  k=wgetworldblock(wobject[YOU].x+15,wobject[YOU].y+15,mymap);

   }
   }
}

void checkleft(void)
{
int j,k,l;

  j=wgetworldblock(wobject[YOU].x-1,wobject[YOU].y,mymap);
  k=wgetworldblock(wobject[YOU].x-1,wobject[YOU].y+15,mymap);
  if ((j>=100) | (k>=100))
    {
  j=wgetworldblock(wobject[YOU].x,wobject[YOU].y,mymap);
  k=wgetworldblock(wobject[YOU].x,wobject[YOU].y+15,mymap);
   while ((j>=100) | (k>=100)) {
   wobject[YOU].x++;
  j=wgetworldblock(wobject[YOU].x,wobject[YOU].y,mymap);
  k=wgetworldblock(wobject[YOU].x,wobject[YOU].y+15,mymap);
   }
   }
}

void checkfeet(void)
{
int j,k;

  feet1=wgetworldblock(wobject[YOU].x,wobject[YOU].y+16,mymap);
  feet2=wgetworldblock(wobject[YOU].x+15,wobject[YOU].y+16,mymap);
  if ((feet1<50) & (feet2<50))
    jumping=1;
    else {
   jumping=0;
   addy=0;
   j=wgetworldblock(wobject[YOU].x,wobject[YOU].y+15,mymap);
   k=wgetworldblock(wobject[YOU].x+15,wobject[YOU].y+15,mymap);
   while ((j>=100) | (k>=100)) {
   wobject[YOU].y--;
   j=wgetworldblock(wobject[YOU].x,wobject[YOU].y+15,mymap);
   k=wgetworldblock(wobject[YOU].x+15,wobject[YOU].y+15,mymap);
   }
   }
}

void checkhead(void)
{
int j,k;

  head1=wgetworldblock(wobject[YOU].x,wobject[YOU].y-1,mymap);
  head2=wgetworldblock(wobject[YOU].x+15,wobject[YOU].y-1,mymap);
  if ((head1<50) & (head2<50))
    jumping=1;
    else {
   jumping=0;
   addy=0;
   j=wgetworldblock(wobject[YOU].x,wobject[YOU].y,mymap);
   k=wgetworldblock(wobject[YOU].x+15,wobject[YOU].y,mymap);
   while ((j>=100) | (k>=100)) {
   wobject[YOU].y++;
   j=wgetworldblock(wobject[YOU].x,wobject[YOU].y,mymap);
   k=wgetworldblock(wobject[YOU].x+15,wobject[YOU].y,mymap);
   }
   }
}

void findelevators(void)
{
int i,j,k;
for (i=0; i<=mapheight; i++)
  for (j=0; j<=mapwidth; j++)
    {
	k=wgetworldblock(j*16,i*16,mymap);
	if (k==105)
	  {
	  elev[numelev].curheight=i;
	  elev[numelev].origx=j;
	  elev[numelev].origy=i;
	  elev[numelev].timer=0;

	  for (k=0; k<200; k++)
	  replace[k]=0;
	  numelev++;
	}
    }
  }

void upelev(void)
{
int ii,jj;
for (ii=0; ii<numelev; ii++)
 {
 if ( (elev[ii].origx>=(wobject[YOU].x/16)-1)
    & (elev[ii].curheight>=(wobject[YOU].y/16)-1)
    & (elev[ii].origx<=(wobject[YOU].x/16)+1)
    & (elev[ii].curheight<=(wobject[YOU].y/16)+1)
    & ((elevup==-1) | (elevup==ii))
    & (wobject[YOU].y>16))
    {
     checkhead();
     if ((head1<50) & (head2<50))
     {
     replace[elev[ii].curheight-1]=wgetworldblock(elev[ii].origx*16,(elev[ii].curheight-1)*16,mymap);
     wputworldblock(elev[ii].origx*16,elev[ii].curheight*16,104,mymap);
     wputworldblock(elev[ii].origx*16,(elev[ii].curheight-1)*16,105,mymap);
     elev[ii].curheight--;
     elevup=ii;
     wobject[YOU].y-=16;
      elev[ii].timer=10;
     }
     }
    }
}

void downelev(void)
{
int ii,jj;
for (ii=0; ii<numelev; ii++)
 {
 if ((elev[ii].origx>=(wobject[YOU].x/16)-1)
    & (elev[ii].curheight>=(wobject[YOU].y/16)-1)
    & (elev[ii].origx<=(wobject[YOU].x/16)+1)
    & (elev[ii].curheight<=(wobject[YOU].y/16)+1)
    & (elev[ii].curheight !=elev[ii].origy))
    {
     wputworldblock(elev[ii].origx*16,elev[ii].curheight*16,replace[elev[ii].curheight],mymap);
     wputworldblock(elev[ii].origx*16,(elev[ii].curheight+1)*16,105,mymap);
     elev[ii].curheight++;
     if (elev[ii].curheight==elev[ii].origy)
	 elevup=-1;
     wobject[YOU].y+=16;
     elev[ii].timer=10;
     }
    }
}

void checkelevators(void)
{
int ii;

for (ii=0; ii<numelev; ii++)
  {
  if ((elev[ii].curheight !=elev[ii].origy))
  {
  if (elev[ii].timer==0)
  {
     wputworldblock(elev[ii].origx*16,elev[ii].curheight*16,replace[elev[ii].curheight],mymap);
     wputworldblock(elev[ii].origx*16,(elev[ii].curheight+1)*16,105,mymap);
     elev[ii].curheight++;
     if (elev[ii].curheight==elev[ii].origy)
	 elevup=-1;
   elev[ii].timer=0;
  }
  else elev[ii].timer--;
  }
}
}

void moveguys(void)
{
int j,k;

for (i=0; i<=36; i++)
  {
  if ((wobject[i].on==1) &				// sprite on
      (sprites[wobject[i].num] !=NULL))		// sprite made
	{
	if ((wobject[i].x<worldx+windowmaxx) &		// and on the screen
	    (wobject[i].y<worldy+windowmaxy) &
	    (wobject[i].x+spritewidth[wobject[i].num]>worldx) &
	    (wobject[i].y+spriteheight[wobject[i].num]>worldy))
	    {
	    if (wobject[i].num<16)  // walking right
	       {
	       wobject[i].num++;
	       if (wobject[i].num>15) wobject[i].num=12; // walking animation loop
	       wobject[i].x+=3;
	       j=wgetworldblock(wobject[i].x+16,wobject[i].y+16,mymap);
	       k=wgetworldblock(wobject[i].x+16,wobject[i].y+8,mymap);
	       if ((j<50) | (k>=50)) wobject[i].num=16;
	       }
	    if (wobject[i].num>15)  // walking left
	       {
	       wobject[i].num++;
	       if (wobject[i].num>19) wobject[i].num=16; // walking animation loop
	       wobject[i].x-=3;
	       j=wgetworldblock(wobject[i].x,wobject[i].y+16,mymap);
	       k=wgetworldblock(wobject[i].x,wobject[i].y+8,mymap);
	       if ((j<50) | (k>=50)) wobject[i].num=12;
	       }



	}
  }
 }
}