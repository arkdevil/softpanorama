#include <stdio.h>
#include <dos.h>
#include <conio.h>
#include <stdlib.h>
#include <alloc.h>
#include <wgt.h>
#include <spr.h>

color palette[256];
block sprites[1001];
int x,y,i;
int chk1,chk2,chk3,chk4;
int blk[10][28]={
   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
   0,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,
   0,3,4,3,3,3,4,3,3,3,3,3,4,4,4,4,4,3,3,3,3,3,4,4,4,4,4,3,
   0,3,4,3,3,3,4,3,3,3,3,3,4,3,3,3,3,3,3,3,3,3,3,3,4,3,3,3,
   0,3,4,3,3,3,4,3,3,3,3,3,4,3,3,3,3,3,3,3,3,3,3,3,4,3,3,3,
   0,3,4,3,4,3,4,3,3,3,3,3,4,3,4,4,4,3,3,3,3,3,3,3,4,3,3,3,
   0,3,4,3,4,3,4,3,3,3,3,3,4,3,3,3,4,3,3,3,3,3,3,3,4,3,3,3,
   0,3,4,3,4,3,4,3,3,3,3,3,4,3,3,3,4,3,3,3,3,3,3,3,4,3,3,3,
   0,3,4,4,4,4,4,3,3,3,3,3,4,4,4,4,4,3,3,3,3,3,3,3,4,3,3,3,
   0,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3};

;

void dobounce(void);

float sbx,sby,sp,lx,ly;
float xsp,ysp;

void looper();
void hit(int,int);

int hits;			// number of bricks hit

void main(void)
{
i=minit();
printf("%i   ",i);
if (i==0)
   {
   printf("Mouse not detected.  You need a mouse for this example program\n");
   printf("Press any key\n");
   getch();
   exit(1);
   }
else printf("Mouse with %i buttons detected.\n",i);
printf("Press any key\n");
getch();

vga256();
wloadsprites(&palette,"break.spr",sprites);
initspr();
spon=2;

wsetscreen(spritescreen);


for (y=0; y<200; y++)
    {
    wsetcolor((y/8)+1);
    wline(0,y,319,y);
    }
wsetcolor(0);
wbar(50,10,270,189);
wsetcolor(16);
wrectangle(49,9,271,190);


for (x=1; x<28; x++)
  for (y=1; y<10; y++)
    {
    wputblock(x*7+57,y*5+20,sprites[blk[y][x]],0);
    }



wcopyscreen(0,0,319,199,spritescreen,0,0,NULL);

spriteon(1,160,100,1);
spriteon(2,160,100,2);

msetbounds(50,129,245,179);


xsp=.1;
ysp=.3;

sbx=xsp;
sby=ysp;
lx=160; ly=100;


do {
looper();
} while (but!=2);

msetbounds(0,0,319,199);
textmode(C80);
}


void looper(void)
{
erasespr();

mread();
s[1].x=mx;
s[1].y=my;

if (lx>267) {
   dobounce();
   lx=267;
   sbx=-sbx; }
if (lx<49)  {
   dobounce();
   lx=49;
   sbx=-sbx; }
if (ly<9) {
   dobounce();
   ly=9;
   sby=-sby;  }

lx+=sbx;
ly+=sby;
s[2].x=(float)lx;
s[2].y=(float)ly;


if (s[2].y>186)
   {
   for (i=2000; i>=200; i--)
      sound(i);
   nosound();
   lx=160; ly=100;
   }


if (overlap(1,2))
   {
   sound(900);
     sby=-ysp;
   if (s[2].x>s[1].x+21)
     sbx=xsp*4;
   else if (s[2].x>s[1].x+18)
     sbx=xsp*2;
   else if (s[2].x>s[1].x+12)
     sbx=xsp;
   else if (s[2].x>s[1].x+6)
     sbx=-xsp;
   else if (s[2].x>s[1].x+3)
     sbx=-xsp*2;
   else
     sbx=-xsp*4;
  }

chk1=wgetpixel(s[2].x+3,s[2].y-1);
chk2=wgetpixel(s[2].x+3,s[2].y+6);
chk3=wgetpixel(s[2].x-1,s[2].y+3);
chk4=wgetpixel(s[2].x+6,s[2].y+3);
if (chk1>28)
   {
   hit(3,-1);
   sby=ysp;
   }
else if (chk2>28)
   {
   hit(3,6);
   sby=-ysp;
   }
if (chk3>28)
   {
   hit(-1,3);
   sbx=-sbx;
   lx+=2;
   }
else if (chk4>28)
   {
   hit(6,3);
   sbx=-sbx;
   lx-=2;
   }

nosound();
drawspr();
}




void hit(int ix,int iy)
{
sound(600);
for (x=1; x<28; x++)
  for (y=1; y<10; y++)
    {
    if ((s[2].x+ix>=x*7+57) & (s[2].x+ix<=x*7+63)
     &  (s[2].y+iy>=y*5+20)  & (s[2].y+iy<=y*5+24) & (blk[y][x] !=0))
      {
      wsetcolor(0);
      wbar(x*7+57,y*5+20,x*7+63,y*5+24);
      s[2].minx=49; s[2].miny=20; s[2].maxx=271; s[2].maxy=98;
      blk[y][x]=0;
      hits++;
      if ((hits % 15)==0)
	 {
	 xsp+=.1;
	 ysp+=.1;
	 }

      }
    }
}

void dobounce(void)
{
sound(200);
nosound();
}

