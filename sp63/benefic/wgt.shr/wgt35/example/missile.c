// missile command type game
// REQUIRES MOUSE!
#include <alloc.h>
#include <mem.h>
#include <conio.h>
#include <dos.h>
#include <stdlib.h>
#include <time.h>
#include <wgt.h>

#define true 1;
#define down 1
#define left 2
#define right 3
#define vertical 0
#define horizontal 1

color palette[255];
int tone;
void so(void);
void init(void);
void changepalette256(void);

   unsigned cursor[32] = {
	0xfe3f,0xfe3f,0xfe3f,0xfe3f,0xfe3f,0xfe3f,0x81c0,0x81c0,
	0x81c0,0xfe3f,0xfe3f,0xfe3f,0xfe3f,0xfe3f,0xfe3f,0xffff,
	0x0,0x80,0x80,0x80,0x80,0x0,0x0,0x3c1e,
	0x0,0x0,0x80,0x80,0x80,0x80,0x0,0x0};
block chunk,build,base,noth;
block mouses;
int oldx,oldy;
int i,a,sc,j;
int ex[31],exx[31],exy[31];
int sx[501],sy[501],dx[501];
int maxs=30,level=5,chk,hits,shoot;
int baseh[3];
int buildh[20];
char ans;


void main(void)
{
 do {
init();

msetspeed(6,6);
msetthreshhold(40);
wnormscreen();
    do {
    so();
    shoot=0;

    sc=0;
    wsetscreen(chunk);
    for (i=0; i<50; i++)		// clears top of screen
      {
      wsetcolor(i);
      wbar(0,sc,319,sc+3);
      sc+=3;
      }

    mread();

    moff();
     if ((but==1) & (baseh[0]==1))
       {
      wline(20,149,mx,my);
      shoot=1;
      }
     else if ((but==2) & (baseh[1]==1))
      {
      wline(305,149,mx,my);
      shoot=1;
      }
	 i=0;
	 do {
	 if (ex[i]==0) {
	  if (shoot ==1) {
	  ex[i]=14;
	  exx[i]=mx;
	  exy[i]=my;
// shoot snd
	tone=600;
	so();
	  i=7;}
	  }
	  else {
	   ex[i]--;
	   wsetcolor(128+ex[i]*4);
	   wfill_circle(exx[i],exy[i],ex[i]);
	tone=ex[i]*20;
	so();
	   }
	  i++;
	  } while (i<maxs);

	 i=0;
	 do {
	 if ((sy[i]<1) & (rand() % 30==5))
	   {
	   sy[i]=1;
	   sx[i]=rand() % 300;
	   dx[i]=(rand() % 6)-3;
	   }
	 else if (sy[i]>0)
	   {
	   sy[i]+=2;
	   sx[i]+=dx[i];
	   if (sx[i]>317)
	     sx[i]=0;
	   if (sx[i]<0)
	     sx[i]=317;
	   wsetcolor(90);
	   chk=wgetpixel(sx[i],sy[i]);
	   wbar(sx[i],sy[i],sx[i]+1,sy[i]+1);
	   if ((sy[i]>149) | (chk>127))
	      {
	      if (sy[i]>149)
		{
	    if ((sx[i]>10) & (sx[i]<30) & (baseh[0]==1))
	      {  // hit base 1
	      wnormscreen();
	      wputblock(10,150,noth,0);
	      wputblock(20,150,noth,0);
	      wsetscreen(chunk);
	      baseh[0]=0;
// hit snd
	tone=800;
	so();
	      }
	    if ((sx[i]>300) & (sx[i]<320) & (baseh[1]==1))
	      {     // hit base 2
	      wnormscreen();
	      wputblock(295,150,noth,0);
	      wputblock(305,150,noth,0);
	      wsetscreen(chunk);
	      baseh[1]=0;
// hit snd
	tone=800;
	so();
	      }
	    for (j=1; j<15; j++)
		{  // check building hits
		chk=j*17+40;
		if ((sx[i]>chk) & (sx[i]<chk+10) & (buildh[j-1]==1))
		  {
		  wnormscreen();
		  wputblock(j*17+40,150,noth,0);
		  wsetscreen(chunk);
		  buildh[j-1]=0;
		  hits++;
// hit snd
	tone=800;
	so();
		  }
		}
		}
	      sy[i]=-10;
// explo snd
	tone=300;
	so();
		}
	   }
	 i++;
	 } while (i<level);


    wcopyscreen(0,0,319,149,chunk,0,0,NULL);
     mon();
     } while (!kbhit());
   nosound();
   getch();
     wnormscreen();
     wfreeblock(chunk);
     wfreeblock(build);
     wfreeblock(base);
     wfreeblock(noth);
    moff();
    textmode(C80);
   window(1,1,80,24);
   gotoxy(1,1);
   printf("Play again? (Y/N) ");
   scanf("%s",&ans);
 } while ((ans !='n') & (ans !='N'));
}

void changepalette256(void)
{
  wsetrgb(0,0,0,0,&palette);

  for (i=1; i<64; i++) 
       wsetrgb(i,0,63-i,63-i/2,&palette);
  for (i=64; i<128; i++) 
       wsetrgb(i,127-i,127-i,127-i,&palette);
  for (i=128; i<192; i++) 
       wsetrgb(i,i-127,(i-127)/2,0,&palette);
  for (i=192; i<256; i++) 
       wsetrgb(i,63,63,i-192,&palette);
 wsetpalette(0,255,palette);
}

void init()
{
vga256();
minit();
mon();
mouseshape(8,7,cursor);
randomize();
changepalette256();
wcls(0);
   window(1,1,80,24);
   gotoxy(1,1);
   printf("Start at what level? ");
   scanf("%d",&level);

    for (i=1; i<11; i++)
    {
    wsetcolor(i+74);
    wline(i,0,i,9);
    }
    wsetcolor(0);
    wbar(3,1,4,2);
    wbar(6,1,7,2);
    wbar(3,4,4,5);
    wbar(6,4,7,5);
    wbar(8,6,9,9);
    build=wnewblock(1,0,10,9);
    wcls(0);

    for (i=150; i<160; i++)
      {
      wsetcolor(i/3);
      wline(0,i-150,319,i-150);
      }
    noth=wnewblock(0,0,9,9);
    for (i=10; i>0; i--)
     {
     wsetcolor(80+i);
    wfill_circle(10,10,i);
    }
    base=wnewblock(0,0,20,10);
    wcls(0);

    for (i=150; i<160; i++)
      {
      wsetcolor(i/3);
      wline(0,i,319,i);
      }
    wputblock(10,150,base,0);
    wputblock(295,150,base,0);
    baseh[0]=1;
    baseh[1]=1;

    wsetcolor(74);
    for (i=1; i<15; i++)
	{
	wputblock(i*17+40,150,build,0);
	buildh[i-1]=1;
        }
    for (i=160; i<200; i++)
      {
      wsetcolor(i-86);
      wline(0,i,319,i);
      }

    chunk=wnewblock(0,0,319,199);
    wsetscreen(chunk);

    sc=0;
    for (i=1; i<50; i++)
      {
      wsetcolor(sc);
      wbar(0,sc,319,sc+3);
      sc+=3;
      }
}

void so()
{
if (tone>100)
 {
sound(tone);
 tone-=100;
 }
if (tone<105)
nosound();
}

