/*--------- robotron.c -----------*/

#include <dos.h>
#include <io.h>
#include <fcntl.h>
#include <stdio.h>
#include <sys\stat.h>
#include <process.h>

void interrupt (*oldprn)();
void interrupt newprn();
void print_ch(char sim),print(char *stroke),rej(),zero();
char ready();

#define sizeprogram 550

unsigned intsp,intss;
unsigned myss,stack;
static union REGS rg;
unsigned sim,si;
int handl;
char buffer[256];
static struct SREGS seg;
int port_st=0x379,port_up=0x37A,port_dat=0x378;
char *rejim="\x1B\x4B\x06\x01";

//------------------------------------------------------------
void zero(){
  si = 0;
  print(&si);
}
//------------------------------------------------------------
void rej(){
  print(rejim);
}
//------------------------------------------------------------
void print(char *stroke){
  while(*stroke){
    while(ready() != 0);
    print_ch(*stroke);
    stroke++;
  }
}

//------------------------------------------------------------
void print_ch(char sim){
  if(sim == 1) sim = 0;
  outportb(port_dat,sim);
  outportb(port_up,13);
  outportb(port_up,12);}

//------------------------------------------------------------
char ready(){
 char s;
 s = inportb(port_st);
 if(s & 0x08 && s & 0x80) return(0);
 else return(1);
}


void interrupt newprn(bp,di,si,ds,es,dx,cx,bx,ax,ip,cs,flgs){
  sim = _AL;
  
  switch(sim){
   case  155:  rej();   //Ы
               print("\x01В~В\x01\x01\x01");
               break;
   case  235:  rej();   //ы
   	       print("\x01в>В\x01\x01\x01");
               break;
   case  154:  _AL=73;   //Ъ
               break;
   case  234:  _AL=105;   //ъ
               break;
   case  157:  rej();   //Э
   	       print("<RRR$\x01\x01");   
               break;
   case  237:  rej();   //э
   	       print("**\x01\x01\x01");   
               break;
   default  :  _AL = sim;
	       break;
 }
 (*oldprn)();
 ax = _AX;
}


void main()
{
  if(peekb(0,412) != 111)
	{
	 printf("┌────────────────────────┐\n");
	 printf("│    Дpайвеp пpинтеpа    │\n");
	 printf("│      Robotron          │\n");
	 printf("│    14.10.92  г.Киев    │\n");
	 printf("│      Шаpов И.Б.        │\n");
	 printf("└────────────────────────┘\n");
	 pokeb(0,412,111);
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
