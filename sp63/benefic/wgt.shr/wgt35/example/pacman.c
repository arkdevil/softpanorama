#include <dos.h>
#include <alloc.h>
#include <stdio.h>
#include <conio.h>
#include <wgt.h>
#include <scroll.h>

void checkpos(void);

int spx,spy;
int pacanim,pacdir;
int ox,oy;

wgtmap mymap;			// our world map

int kbdon[100]={0,0,0,0,0};	// our keyboard on/off array;
int kbdscanlist[100]={72,80,75,77,1};	// our keyboard scan codes;
// You must have the above two if you want the keyboard interrupt 

color palette[256];		// our palette of colours

block blocks[1001];		// our blocks for the map
block sprites[1001];		// our sprites 


int bonus,traptime[5];
int killtime[5];
int i;
int pacspeed=8,ghostspeed=8;
int moved[5],movedir[5];
int bluetime;

void moveghost(int);

void main(void)
{
vga256();

wloadsprites(&palette,"pacman.spr",blocks);    	// load blocks
wloadsprites(&palette,"pac.spr",sprites);    	// load sprites

wputblock(0,0,blocks[1],0);
wputblock(0,40,sprites[1],0);
getch();

mymap=wloadmap("pacman.wmp");		// load our world map


winitscroll(10,10);				// make a 12x10 box
						// for the scrolling

wnormscreen();					// go back to normal screen
wcls(0);					// clear it
wbutt(1,1,318,198);

wshowwindow(0,0,mymap);			// start looking at world
						// at 0,0
installkbd();					// start new keyboard interrupt

numsprites=5;
wobject[0].on=1; wobject[0].x=192; wobject[0].y=176; wobject[0].num=1;

wobject[1].on=1; wobject[1].x=176; wobject[1].y=112; wobject[1].num=21;
wobject[2].on=1; wobject[2].x=176; wobject[2].y=112; wobject[2].num=22;
wobject[3].on=1; wobject[3].x=176; wobject[3].y=112; wobject[3].num=23;
wobject[4].on=1; wobject[4].x=176; wobject[4].y=112; wobject[4].num=24;
for (i=1; i<5; i++) moved[i]=0;
pacanim=1;


do
{
// The keyboard interrupt sets the value in dir[] to the corresponding
// key from lst[];

spx=0;
spy=0;
ox=wobject[0].x;
oy=wobject[0].y;

if (kbdon[2]==1)		// Pressing left
  {
  wobject[0].x-=pacspeed;
  checkpos();
  pacdir=2;
  }
else if (kbdon[3]==1)	// Pressing right
  {
  wobject[0].x+=pacspeed;
  checkpos();
  pacdir=0;
  }
else if (kbdon[0]==1)		// Pressing up
  {
  wobject[0].y-=pacspeed;
  checkpos();
  pacdir=1;
  }
else if (kbdon[1]==1)	// Pressing down
  {
  wobject[0].y+=pacspeed;
  checkpos();
  pacdir=3;
  }

    if (bluetime>0)
    bluetime--;

for (i=1; i<5; i++)
 {
 if (traptime[i]==0)
   {
   moveghost(i);
 if (bluetime>0)
    wobject[i].num=25;
 if ((bluetime==1) | ((bluetime<40) & (bluetime % 2==1)))
    wobject[i].num=20+i;
 if ((soverlap(i,0)==1) & (traptime[i]==0))
   {
   if (bluetime>0)
     {
     wobject[i].num=27+bonus;
     bonus++;
     traptime[i]=100;
     }
   }
  }
  else traptime[i]--;
 if (traptime[i]==1)
    {
    wobject[i].x=192;
    wobject[i].y=144;
    wobject[i].num=20+i;
    bonus=0;
}
 }


pacanim++;
if (pacanim>5)
  pacanim=1;
wobject[0].num=pacanim+(pacdir*5);


if (wobject[0].x-worldx<windowmaxx/2-1)
   spx=-pacspeed;
else if (wobject[0].x-worldx>windowmaxx/2+1)
   spx=pacspeed;
if (wobject[0].y-worldy<windowmaxy/2-1)
   spy=-pacspeed;
else if (wobject[0].y-worldy>windowmaxy/2+1)
   spy=pacspeed;

nosound();
wscrollwindow(spx,spy,mymap);	// update the scrolling window
wshowobjects();
wcopyscroll(80,15);
} while (kbdon[4] !=1);			// until right button is pressed

uninstallkbd();
wendscroll();
wfreesprites(blocks);
wfreesprites(sprites);
wfreemap(mymap);
textmode(C80);
}

void checkpos(void)
{
int hit=0;

  i=wgetworldblock(wobject[0].x,wobject[0].y,mymap);
  if (tiletype[i]==0)
    hit=1;
  i=wgetworldblock(wobject[0].x+15,wobject[0].y,mymap);
  if (tiletype[i]==0)
    hit=1;
  i=wgetworldblock(wobject[0].x,wobject[0].y+15,mymap);
  if ((tiletype[i]==0) | (tiletype[i]==4))
    hit=1;
  i=wgetworldblock(wobject[0].x+15,wobject[0].y+15,mymap);
  if (tiletype[i]==0)
    hit=1;
  i=wgetworldblock(wobject[0].x+7,wobject[0].y+7,mymap);
  if (tiletype[i]==2)
    {
    sound(500);
    wputworldblock(wobject[0].x+7,wobject[0].y+7,12,mymap);
    }
  if (tiletype[i]==3)
     {
    sound(800);
    wputworldblock(wobject[0].x+7,wobject[0].y+7,12,mymap);
     bluetime+=150;
     }

  if (hit==1)
     {
     wobject[0].x=ox;
     wobject[0].y=oy;                   
     }
  }


void moveghost(int numb)
{
int gox,goy,hit=0,j;

gox=wobject[numb].x;
goy=wobject[numb].y;

if (moved[numb]==0)
   movedir[numb]=(rand() % 5)+1;

   if (movedir[numb]==1)
   wobject[numb].x+=ghostspeed;
   else if (movedir[numb]==2)
   wobject[numb].x-=ghostspeed;
   else if (movedir[numb]==3)
   wobject[numb].y+=ghostspeed;
   else if (movedir[numb]==4)
   wobject[numb].y-=ghostspeed;

   moved[numb]+=ghostspeed;
   if (moved[numb]>=16)
     moved[numb]=0;

 if (wobject[numb].x<0)
    wobject[numb].x=0;
else if (wobject[numb].x>(mapwidth-1)*16)
    wobject[numb].x=(mapwidth-1)*16;
 if (wobject[numb].y<0)
    wobject[numb].y=0;
else if (wobject[numb].y>(mapheight-1)*16)
    wobject[numb].y=(mapheight-1)*16;

  j=wgetworldblock(wobject[numb].x,wobject[numb].y,mymap);
  if (tiletype[j]==0)
    hit=1;
  j=wgetworldblock(wobject[numb].x+15,wobject[numb].y,mymap);
  if (tiletype[j]==0)
    hit=1;
  j=wgetworldblock(wobject[numb].x,wobject[numb].y+15,mymap);
  if (tiletype[j]==0)
    hit=1;
  if ((tiletype[j]==4) & (movedir[numb]==3))
    hit=1;
  j=wgetworldblock(wobject[numb].x+14,wobject[numb].y+15,mymap);
  if (tiletype[j]==0)
    hit=1;
  if (hit==1)
     {
     wobject[numb].x=gox;
     wobject[numb].y=goy;
     moved[numb]=0;
     }
if ((wobject[numb].x==gox) & (wobject[numb].y==goy))
  moveghost(numb);

}
