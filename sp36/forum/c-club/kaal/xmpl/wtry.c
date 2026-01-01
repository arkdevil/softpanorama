#include "window.h"
#include <dos.h>
#include <time.h>
#include <stdlib.h>
#include <stdio.h>
#include <conio.h>

static char *frames[]={
	SINGLEFRAME,
	DOUBLEFRAME,
	HMIXFRAME,
	VMIXFRAME,
	FATFRAME
};

int leave(void)
{
	while(closewnd())
		;
	puts("\nOuch...  You're not such a nice guy after all!");
	return 0;
}

void main(int argc,char *argv[])
{
int x1,y1,x2,y2,c1,f,t,zoom,cols,zlim=0;
unsigned long boxes=1;
char s[81];
	if (argc==2)
		snowtest((*argv[1]=='+'));
	while ((zlim<1) || (zlim>100)) {
		printf("\nEnter Zoom limit : ");
		scanf("%d",&zlim);
	}
	zlim--;
	ctrlbrk(leave);
	_AH=0x0f;
	geninterrupt(0x10);
	cols=_AH-2;
	randomize();
	makewnd(0,0,cols+1,24,"░░░░░░░░░",0x0101,80);
	while (1) {
		zoom=(zlim) ? random(zlim)+1 : 1;
		f=random(5);
		x1=random(cols);
		x2=random(cols-x1)+x1+2;
		y1=random(23);
		y2=random(23-y1)+y1+2;
		c1=(random(127)+1)*256+random(127)+1;
		if (x1>x2) {
			t=x1;
			x1=x2;
			x2=t;
		}
		if (y1>y2) {
			t=y1;
			y1=y2;
			y2=t;
		}
		if (!(makewnd(x1,y1,x2,y2,(char far *) frames[f],c1,zoom)))
			break;
		locate(0,0);
		sprintf(s," Window # %lu ",boxes++);
		prtcwnd(-1,(char far *)s,_curntwnd->color/256);
		if (kbhit())
			if (getch()==27)
				break;
	}
	while (closewnd());
}
