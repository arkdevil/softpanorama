#include <conio.h>
#include <stdio.h>
#include <stdlib.h>
#include <wgt.h>

color p[256];
int backr[21];
int starx[20],stary[20];
int i,y,bottom,c,ctr,c2;
int speed=5,ofs=0;
block sc;
block sprites[1001];
int numg;
int ox,turns,turn=5;
int shootx[20],shooty[20],shootoy[20],shooton[20],numshots=0;


void resizepill(int);
void setupground(void);

void main(void)
{
vga256();
wloadsprites(&p,"fly.spr",sprites);
sc=wnewblock(0,0,319,199);
resizepill(19);
resizepill(29);
resizepill(39);
minit();

msetbounds(0,0,319,100);
setupground();
 wbutt(0,0,319,50);
wsetscreen(sc);
y=0;

 wsetcolor(0);
 wbar(0,0,319,50);
do {
mread();

    if ((but==1) & (numshots<19))  // shoot with left mouse button
    {
    for (i=0; i<20; i++)
      {
      if (shooton[i]==0)
	{
	sound(300);
	shootx[i]=mx+24;
	shooty[i]=180;
	shootoy[i]=my+7;
	shooton[i]=1;
	numshots++;
	break;
	}
      }
    }

 wsetcolor(0);
 wbar(0,0,319,50);
 wsetcolor(17);
 wbar(0,50,319,150);
nosound();
for (i=0; i<20; i++)
   {
   starx[i]-=(turn-5)*2;
   if (starx[i]<0) starx[i]=319;
   else if (starx[i]>319) starx[i]=0;
   shootx[i]-=(turn-5)*4;
   if (shootx[i]<0) shootx[i]=319;
   else if (shootx[i]>319) shootx[i]=0;
   wsetcolor(1);
   wfastputpixel(starx[i],stary[i]);
   }

for (i=numg; i>=0; i--)
 {
 c2=(float)((float)backr[i]/(600-backr[i]))*backr[i];
 c=backr[i]/30;
 if (c2<100)
 {
 wsetcolor(12);
 wbar(0,50+c2,319,c2+c+50);
 }
 backr[i]+=speed;
 if (backr[i]>200)
      backr[i]=backr[i]-200;
 }

turns=(mx-ox)/5;
if (turns==0)
   {
   if (turn<5) turn++;
   if (turn>5) turn--;
   }
if (turns<0) turn--;
if (turns>0) turn++;

if (turn<1) turn=1;
if (turn>9) turn=9;
 for (i=0; i<20; i++)
   {
   if (shooton[i]==1)
      {
      shooty[i]-=10;
      if (shooty[i]<0)
	 {
	 shooton[i]=0;
	 shooty[i]=0;
	 numshots--;
	 }
      }
   }
wputblock(mx,105,sprites[turn+9],1);
 for (i=0; i<20; i++)
   {
   if (shooton[i]==1)
      wputblock(shootx[i],(float)((float)shooty[i]/(600-shooty[i]))*shooty[i]+shootoy[i]-50,sprites[38-(shooty[i]/20)],1);
   }
wputblock(mx,my,sprites[turn],1);
ox=mx;
wcopyscreen(0,0,319,150,sc,0,50,NULL);
} while (but !=2);
wfreeblock(sc);
textmode(C80);
}

void setupground(void)
{
for (i=0; i<21; i++)
   backr[i]=i*15;
i=0;

numg=12;

for (i=0; i<20; i++)
 {
 starx[i]=rand() % 319;
 stary[i]=rand() % 50;
 }
}


void resizepill(int num)
{
int g,h,nx,ny;

g=wgetblockwidth(sprites[num]);
h=wgetblockheight(sprites[num]);

for (i=9; i>=1; i--)
  {
  wcls(0);
  nx=(float)i/10*g;
  ny=(float)i/10*h;

  wresize(0,0,nx,ny,sprites[num]);
  sprites[num+1+(9-i)]=wnewblock(0,0,nx,ny);
 }
}