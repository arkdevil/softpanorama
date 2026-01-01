/*--------- robotron.c -----------*/

#include <dos.h>
#include <io.h>
#include <fcntl.h>
#include <stdio.h>
#include <sys\stat.h>
#include <process.h>

void interrupt (*oldprn)();
void interrupt newprn();
#define sizeprogram 450
unsigned intsp,intss;
unsigned myss,stack;
unsigned char sim;
static union REGS rg;
static struct SREGS seg;

void interrupt newprn(bp,di,si,ds,es,dx,cx,bx,ax,ip,cs,flgs){
  if(_AH == 2){ 
   _AH = 144;
  } 
  else _AH = 0;
 ax = _AX;
}


void main()
{
  if(peekb(0,416) != 111)
	{
	 printf("┌────────────────────────┐\n");
	 printf("│   Эмулятоp пpинтеpа  │\n");
	 printf("│    14.10.92  г.Киев    │\n");
	 printf("│     Шаpов И.Б.       │\n");
	 printf("└────────────────────────┘\n");
	 pokeb(0,416,111);
	}
  else
	{
	 printf(" Я уже загpужен !!!");
	 exit(1);
	}

  segread(&seg);

  myss = _SS;

  oldprn = getvect(0x17);
  setvect(0x17,newprn);

  stack = (sizeprogram - (seg.ds - seg.cs))*16-300;

  rg.x.ax = 0x3100;
  rg.x.dx = sizeprogram;
  intdos(&rg,&rg);
}