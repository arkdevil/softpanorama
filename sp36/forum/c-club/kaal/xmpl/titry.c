#include "window.h"
#include <bios.h>
#include <dos.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define CHANNELS 21

int clocks[CHANNELS];
void interrupt far (*oldvect)();

void myexit(void)
{
	_deinittimer();
	while (closewnd());
	if (oldvect)
		setvect(0x1b,oldvect);
}

void interrupt far mybreak(void)
{
}

void main(void)
{
int i;
char s[80];
	atexit(myexit);
	oldvect=getvect(0x1b);
	setvect(0x1b,mybreak);
	makewnd(5,0,32,CHANNELS+3,SINGLEFRAME,0x0f0f,80);
	cursoroff();
	for (i=0;i<CHANNELS;i++) {
		sprintf(s,"Timer channel %d",i+1);
		prtwnd(2,i+1,s,0x0f);
		clocks[i]=(i+1)*50;
	}
	_inittimer(CHANNELS,clocks);
	while (!bioskey(1)) {
		for(i=0;i<CHANNELS;i++) {
			itoa(clocks[i],s,10);
			strcat(s,"      ");
			prtwnd(19,i+1,s,0x0f);
		}
	}
	while(bioskey(1))
		bioskey(0);
}
