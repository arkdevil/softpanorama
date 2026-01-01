/* This is the restricted variant of the "console" library */
/* Implied for Turbo C 2.0                                 */
/* Copyright (C) 1990 Tim Shaporev                         */
/* (Turbo C is a registered trademark of the Borland Int.) */

#include <dos.h>
#include "console.h"

unsigned char _scrpage = 255;

static void scr_001(void)
{
   _AH = 15; geninterrupt(0x10); _scrpage = _BH;
}

void AskVideo(struct VideoSettings far *v)
{
   union REGS r; struct SREGS s;
   register unsigned i, j, k;

   r.h.ah = 15;	int86(0x10, &r, &r);
   v->vs_mode  = r.h.al;
   v->vs_width = r.h.ah;
   v->vs_page  = r.h.bh;
   v->vs_color = r.h.al!=6 && r.h.al!=7 && r.h.al!=15;
   v->vs_graph = (r.h.al>3 && r.h.al<7) || r.h.al>=11;

   r.h.ah = 3;	int86(0x10, &r, &r);
   v->vs_cursor.x = r.x.cx;

   r.x.ax = 0x1130;
   r.h.bh = 0;
   r.h.dl = 24;
   r.h.cl = 0;
   int86x(0x10, &r, &r, &s);
   v->vs_height = r.h.dl + 1;
   v->vs_point  = r.h.cl;
   v->vs_hivid  = r.h.cl != 0;

   for (i=0xA000; i<0xC000; i+=0x20) {
      k = peek(i, 0); poke(i, 0, ~k);
      j = peek(i, 0); poke(i, 0,  k);
      if (j == ~k) goto seg;
   }
   v->vs_segment = 0; v->vs_blocks = 0; goto end;

   seg: v->vs_segment = i;
   while ((i+=20)<0xC000 && ~k==j) {
      k = peek(i, 0); poke(i, 0, ~k);
      j = peek(i, 0); poke(i, 0,  k);
   }
   v->vs_blocks = (i - v->vs_segment) / 0x20;

   end: _scrpage = v->vs_page;
}

void scrpoke(unsigned c)
{
   union REGS r;
   if (_scrpage & 0x80) scr_001();
   r.h.ah = 9;
   r.h.al = c & 255;
   r.h.bh = _scrpage;
   r.h.bl = c >> 8;
   r.x.cx = 1;
   int86(0x10, &r, &r);
}

void scrputc(char c)
{
   if (_scrpage & 0x80) scr_001();
   _BH = _scrpage; _AL = c; _BL = 0; _AH = 14;
   geninterrupt(0x10);
}

void scrputs(char far *s)
{
   while (*s) scrputc(*s++);
}

void scrgoto(short x, short y)
{
   if (_scrpage & 0x80) scr_001();
   _BH = _scrpage; _DH = y; _DL = x; _AH = 2;
   geninterrupt(0x10);
}

void scrouts(short x, short y, char far *s)
{
   scrgoto(x, y); scrputs(s);
}

void scrwipe(short l, short t, short r, short b, short a)
{
   _CL = l; _CH = t; _DL = r; _DH = b; _BH = a; _AX = 0x0600;
   geninterrupt(0x10);
}

void scrolup(short l, short t, short r, short b, short a, short n)
{
   _CL = l; _CH = t; _DL = r; _DH = b; _BH = a; _AL = n; _AH = 6;
   geninterrupt(0x10);
}

