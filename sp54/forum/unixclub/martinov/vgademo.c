#include <stdio.h>
#include <malloc.h>
#include "vgallev.h"

main()
{ int i,j,linenumber;
  FILE *ptr1;
  char *buffer,*buffer2,key;
  long x,y,dx,dy;

  do
  { printf("\n Please select videomode (1 - EGA, 2 - VGA): ");
    i=getch() & ~'0';
  }
  while(i!=1 && i!=2);

  if(initgr(i) < 0)
    { printf("\7 Could not set graphic videomode\n");
      return(-1);
    }
  if(i==1)
    linenumber=350;
  else
    linenumber=480;

  setpal(0x04,0x36); /* dark red will be yellow */
  setpal(0x09,0x03); /* light blue will be cyan */

  drawln(0,linenumber/2,320,0,10);
  drawln(320,0,639,linenumber/2,10);
  drawln(639,linenumber/2,320,linenumber-1,10);
  drawln(320,linenumber-1,0,linenumber/2,10);

  rectab(140,78,500,118,11,1);
  putext("Press Ctrl-P if you want to make hard copy",-1,150,80,0,0);
  putext("or Ctrl-S to create PCX file",-1,206,100,0,0);
  key=getch();
  if(key=='P'-'A'+1) hardco();
  if(key=='S'-'A'+1)
    { x=y=0;
      dx=640; dy=linenumber;
      savpcx_(&x,&y,&dx,&dy,"vgademo.pcx");
    }

  derase(9);
  for(i=0;i<640;i++)
    for(j=40;j<120;j++)
      putpix(i,j,12);
  getch();
  for(i=125;i<170;i+=15)
    for(j=i;j<i+8;j++)
      drawln(40,j,560,j,j-i);

  for(i=100;i<220;i++)
    for(j=100;j<180;j++)
      putpix(i+74,j+141,getpix(i,j));
  getch();

  buffer=malloc(80*120);
  rdpblk(100,100,120,80,buffer);
  wrpblk(344,241,120,80,buffer);
  free(buffer);
  getch();

  if(linenumber==350)
    { setpag(1);
      derase(2);
      putext("This is video page 1",-1,230,150,11,0);
      getch();
      setpag(0);
      getch();
      setpag(1);
      getch();
      setpag(0);
    }

  buffer=malloc(linenumber/2*80/2*4); /* 1/4 of screen */
  buffer2=malloc(linenumber/2*80/2*4);
  rdbblk(0,0,320,linenumber/2,buffer);
  rdbblk(320,linenumber/2,320,linenumber/2,buffer2);
  wrbblk(0,0,320,linenumber/2,buffer2);
  wrbblk(320,linenumber/2,320,linenumber/2,buffer);
  getch();

  wrbblk(0,0,320,linenumber/2,buffer);
  wrbblk(320,linenumber/2,320,linenumber/2,buffer2);
  free(buffer);
  free(buffer2);
  getch();

  rectab(25,25,615,linenumber-25,15,0);
  drawln(40,220,600,180,11);
  drawln(0,0,639,linenumber-1,10);
  drawln(400,10,220,linenumber-10,13);
  getch();

  setpal(0x09,0xFF); /* restore default colormap for color 4 */
  for(j=0;j<150;j++)
    horlin(320-j,80+j,j+j,j>>2);

  putext("Top side",-1,290,3,14,0);
  putext("Left hand side",-1,3,linenumber/2+50,14,1);
  putext("Right hand side",-1,636,linenumber/2-50,14,3);
  putext("Bottom side",-1,340,linenumber-3,14,2);
  setfnt("/usr/lib/vidi/font8x8.rus");
  putext("That's all (№╘╧ ╫╙┼)",-1,240,50,1,0);
  getch();

  textmode:
  initgr(0);
}
