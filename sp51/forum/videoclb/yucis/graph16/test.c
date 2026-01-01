#include "graph16.h"
#include <stdlib.h>
#include <stdio.h>

#ifdef __TURBOC__
#define _asm asm
#endif

int getch(void);

int BytesPerLine=100;

void main(int ac, char **av)
{ int vmode, xmax, ymax, i;
  char mess[] = "Press any key...", *p=mess;

  if(ac<2) { printf("Syntax: test <video_mode>\n"); exit(1); }

  vmode = atoi(av[1])&127;

  switch(vmode) {
  	case 13: BytesPerLine = 40; ymax = 200; break;
	case 14: BytesPerLine = 80; ymax = 200; break;
  	case 15: case 16:
		BytesPerLine = 80; ymax = 350;  break;
  	case 17: case 18:
                BytesPerLine = 80; ymax = 480;  break;
        default:
		if(vmode>19) { BytesPerLine = 100; ymax = 600; }
		else { printf("Invalid video mode %d",vmode); exit(2); }
  }
  xmax = BytesPerLine * 8;

  _asm mov ax,vmode
  _asm int 10h

  Line(0,0,xmax-1,ymax-1,10);
  Line(0,ymax-1,xmax-1,0,11);
  Ellipse(xmax/2, ymax/2, 150, 80, 12);
  FillRegion(xmax/2-2, ymax/2, 1, 12);

  i = 0;
  do {
	DisplayChar(*p, i, 0, 14, 0);  
	i+=8;
  }
  while(*++p);  
 
getch();

_asm mov ax,3
_asm int 10h
}
