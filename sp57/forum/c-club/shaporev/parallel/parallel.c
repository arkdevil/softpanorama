/* Problem description & consulting by Dmitry S.Severov */
/* Original coding by Serge V.Popov                     */
/* Interface design & debugging by Tim V.Shaporev       */
/* The pogram is considered to be in a public domain    */

#define LOGGING

#include "console.h"
#include "define.h"

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <dos.h>
#include <dir.h>
#ifdef LOGGING
#	include <io.h>
#endif

#ifndef DEBUG
	void _setenvp(void) {}
#endif

/* Printer Contol Register Bits 0x37A */
#define STROB0   0xC
#define STROB1   0xB
#define ENB_INTR 16
#define DIS_INTR 0
#define COLL_INTR 16

#define GINT 0x10
#define B_1 8
#define B_2 16
#define B_3 32
#define B_4 64
#define B_5 128

/* Printer Contol Register Bits 0x37A */
#define INIC   8
#define REINIC 12
#define STROB  1

/* Printer Status Register Bits 0x379 */
#define READY 0x40
#define BUSY  0x80

static int dataport=0, errorp, contport;
static int lptnumb;
static int intok;

#define BEEP()   scrputc(7)

static struct VideoSettings _vinfo;
static char _l1, _l2, _bottom, _top;
static char ins;

static char mainame[] = " Parallel Port Test ";
static char version[] = " v1.1 ";

#ifdef LOGGING
	static char logflag;

        static void dupline(short x, short y, char *s)
        {
           scrouts(x, y, s); if (logflag) printf("          %s\n", s);
        }

        static void logline(char *s)
        {
           if (logflag) printf("          %s\n", s);
        }
#else
#	define dupline(x,y,s)	scrouts((x),(y),(s))
#	define logline(s)
#endif

static void cursor(int k)
{
   _CX = k ? _vinfo.vs_cursor.x : NOCURSOR; _AH = 1; geninterrupt(0x10);
}

static int readkey(void)
{
   scrgoto(0, _vinfo.vs_height); return keyserv(4);
}

static void box(int left)
{
   register i;

   scrouts(left, 0, "╔══════════════════════════════════════╗");
   for (i=1; i<_bottom; i++) {
      scrouts(left,    i, "║");
      scrouts(left+39, i, "║");
   }
   scrouts(left, _bottom, "╚══════════════════════════════════════");
   scrpoke((BORDER<<8) | BR_CHAR);
}

static void scrhex(int n)
{
   register i; char b[4];
   static char h[] = "0123456789ABCDEF";

   i = 4;
   do b[--i] = h[n & 15]; while ((n >>= 4)!=0 && i!=0);
   while (i<4) scrputc(b[i++]);
}

static void viewport(void)
{
   scrwipe(_l1+15, 2, _l1+24, 2, INVERT);
   scrouts(_l1+15, 2, "LPT");
   scrputc(lptnumb ? lptnumb+'0' : '?');
   scrputs(": ");
   scrhex(dataport);
   scrputc('h');
}

static int linic(int lnum)
{
   if (lnum) dataport = *(int far *)(0x406L + 2*lnum);
   errorp   = dataport+1;
   contport = dataport+2;
   return !dataport;
}

static void chport(void)
{
   register i, f, thislpt, h, maxlpt, a;

   scrouts(_l2,   0, "╔════════════ Select  Port ════════════╗");
   scrwipe(_l2+1, 1, _l2+38, _vinfo.vs_height-2, BRIGHT);

   maxlpt = 0; f = 0;
   if (*(int far *)0x0408L) { ++maxlpt; f |= 1; }
   if (*(int far *)0x040AL) { ++maxlpt; f |= 2; }
   if (*(int far *)0x040CL) { ++maxlpt; f |= 4; }
   if (*(int far *)0x040EL) { ++maxlpt; f |= 8; }

   if (maxlpt) {
      thislpt = maxlpt;
   } else {
      thislpt = 1;
      scrline(_l2+13, _top+8, "No LPT in BIOS", NORMAL);
   }
   scrouts(_l2+16, _top+9, "┌──────┐");
   h = 0;
   do {
      scrouts(_l2+16, _top+10+h, "│      │");
   } while (h++ < maxlpt);
   scrouts(_l2+16, _top+10+h, "└──────┘");
   scrwipe(_l2+18, _top+10,   _l2+21, _top+10+h-1, NORMAL);

   while (1) {
      h = _top+10;
      scrwipe(_l2+18, h,         _l2+21, h+(maxlpt ? maxlpt : 1), NORMAL);
      scrwipe(_l2+18, h+thislpt, _l2+21, h+thislpt,               INVERT);
      if (f) {
         for (i=0; i<4; i++) {
            if (f & (1<<i)) {
               scrouts(_l2+18, h++, "LPT");
               scrpoke(((scrpeek() & 0xF000) | (BRIGHT << 8)) | (i + '1'));
            }
         }
      }
      scrouts(_l2+18, h, "LPT");
      scrpoke(((scrpeek() & 0xF000) | (BRIGHT << 8)) | '?');

      if ((i = readkey()) & 255) {
         switch (i &= 255) {
            case ESC : goto end;
            case '\r': goto selected;
            case '1' :
            case '2' :
            case '3' :
            case '4' : if (f & (1 << (i -= '1'))) {
                          thislpt = i; goto selected;
                       }
                       break;
            case '/' : /* dummy for convinience */
            case '?' : thislpt = maxlpt ? maxlpt : 1;
                       goto selected;
         }
      } else if (maxlpt) {
         if        (i == 0x4800) {
            do {
               if (--thislpt < 0) thislpt = maxlpt;
            } while (thislpt < maxlpt && (f & (1 << thislpt)) == 0);
         } else if (i == 0x5000) {
            do {
               if (++thislpt > maxlpt) thislpt = 0;
            } while (thislpt < maxlpt && (f & (1 << thislpt)) == 0);
         }
      }
   }
selected:
   h = _top + 10;
   scrwipe(_l2+18, h, _l2+21, h+(maxlpt ? maxlpt : 1), NORMAL);
   if (f) {
      for (i=0; i<4; i++) {
         if (f & (1<<i)) {
            scrouts(_l2+18, h++, "LPT");
            scrpoke(((scrpeek() & 0xF000) | (BRIGHT << 8)) | (i + '1'));
         }
      }
   }
   scrouts(_l2+18, h, "LPT");
   scrpoke(((scrpeek() & 0xF000) | (BRIGHT << 8)) | '?');

   if (thislpt < maxlpt) {
      linic(lptnumb = thislpt+1);
   } else {
      scrwipe(_l2+3, _top+16, _l2+36, _top+18, BRIGHT);
      scrouts(_l2+3, _top+16, "┌────────────────────────────────┐");
      scrouts(_l2+3, _top+17, "│ Base port address (hex):       │");
      scrouts(_l2+3, _top+18, "└────────────────────────────────┘");
      cursor(1);
      for (a=0;;) {
         scrwipe(_l2+31, _top+17, _l2+33, _top+17, INVERT);
         scrgoto(_l2+31, _top+17); if (a) scrhex(a);
         i = keyserv(0) & 255;
         if        (i == '\r') {
            goto entered;
         } else if (i == ESC ) {
            goto end;
         } else if (i == '\b' || i ==  0 ) {
            a >>= 4;
         } else if ((a & ~0xFF) == 0) {
            if        (i >= '0' && i <= '9') {
               a = (a << 4) | (i - '0');
            } else if (i >= 'A' && i <= 'F') {
               a = (a << 4) | (i - ('A'-10));
            } else if (i >= 'a' && i <= 'f') {
               a = (a << 4) | (i - ('a'-10));
            }
         }
      }
entered:
      cursor(0);
      dataport = a; linic(lptnumb = 0);
   }
end:;
#ifdef LOGGING
   if (logflag) {
      printf("          Selected device LPT%c %3.3Xh\n",
             lptnumb ? lptnumb+'0' : '?', dataport);
   }
#endif
}

static int internal(void)
{
   register i, b, flag;

   scrouts(_l2, 0,    "╔══════════════════════════════════════╗");
   dupline(_l2+12, 0, " Data Port Test ");
   scrwipe(_l2+1,      1,     _l2+38, _top+20, NORMAL);
   scrwipe(_l2+1,  _top+21, _l2+38, _bottom-1, BRIGHT);
   if (_l1 == _l2) viewport();

   scrline(_l2+1,_top+3, "─── OUTPUT ───────────────────────────",BRIGHT);
   scrline(_l2+1,_top+12,"─── INPUT ────────────────────────────",BRIGHT);
   scrline(_l2+1,_top+21,"──────────────────────────────────────",BRIGHT);

   for (i=0, flag=0; i<256 && !flag; i++) {
      scrgoto(_l2+4+i%32, _top+4+i/32);  scrpoke((NORMAL << 8) | i);
      outportb(dataport, (char)i);
      if ((b = (int)inportb(dataport)) != i) flag = ERROR;
      scrgoto(_l2+4+i%32, _top+13+i/32); scrpoke((NORMAL << 8) | b);
   }

   if (flag) {
      BEEP(); scrwipe(_l2+2, _top+22, _l2+37, _top+22, ITALIC);
      dupline(_l2+8,  _top+22, "Unexpected byte received");
   } else {
      dupline(_l2+13, _top+22, "All is correct");
   }
   if (ins) {
      scrouts(_l2+12, _top+23, "Press any key...");
      (void)readkey();
   }
   return flag;
}

static int prompt(void)
{
   register c;
   scrouts(_l2+6, _top+12, "Please insert loopback plug");
   scrouts(_l2+6, _top+13, "Press any key when ready...");
   c = readkey() & 255;
   scrwipe(_l2+6, _top+12, _l2+33, _top+13, NORMAL);
   return c == ESC;
}

static void interrupt intrport(void)
{
   intok = 1; outportb(0x20, 0x20); enable();
}

static void enprnint(void)
{
   disable();
   outportb(0x21, (inportb(0x21) & 127));
   enable();
}

static void diprnint(void)
{
   disable();
   outportb(0x21, (inportb(0x21) | 128));
   enable();
}

static int lptint(void)
{
   void interrupt (*oldvectd)();
   void interrupt (*oldvectf)();
   register i;

   oldvectd = getvect(0x0d); setvect(0x0d, intrport);
   oldvectf = getvect(0x0f); setvect(0x0f, intrport);

   outportb(contport, INIC);
   enprnint();
   outportb(contport, 0x1c);

   intok = 0;
   outportb(contport, 0x18);
   delay(50);
   outportb(contport, 4);

   if (!intok) {
      i = 1;
   } else {
      outportb(contport, INIC);
      outportb(contport, 0x0c);
      intok = 0;
      outportb(contport, 0x08);
      delay(50);
      outportb(contport, 4);
      i = intok ? 2 : 0;
   }
   diprnint();
   setvect(0x0D, oldvectd);
   setvect(0x0F, oldvectf);
   return i;
}

static int scint(void)
{
   register y, b;

   y = _top + 12;

   scrouts(_l2,    0, "╔══════════════════════════════════════╗");
   dupline(_l2+10, 0, " Interruption  Test ");
   scrwipe(_l2+1,  1, _l2+38, _vinfo.vs_height-2, NORMAL);

   if (prompt()) return 0;

   scrline(_l2+6, y-1, "┌──────────────────────────┐", BRIGHT);
   scrline(_l2+6,  y,  "│                          │", BRIGHT);
   scrline(_l2+6, y+1, "└──────────────────────────┘", BRIGHT);
   if (_l1 == _l2) viewport();

   if ((b = lptint()) != 0) {
      scrwipe(_l2+8,  y, _l2+31, y, ITALIC); BEEP();
   }
   switch (b) {
      case 0: dupline(_l2+12, y, "Interruption O'k");        break;
      case 1: dupline(_l2+8,  y, "No interruption occured"); break;
      case 2: dupline(_l2+10, y, "Unexpected interrupt");    break;
   }
   if (ins && _l1!=_l2) {
      scrline(_l2+12, _vinfo.vs_height-2, "Press any key...", BRIGHT);
      (void)readkey();
   }
   return b ? ERROR : 0;
}

static int lscr(char wdata, char rdata)
{
   register int r, i;
   wdata &= 31;
   rdata  = (rdata & 248) >> 3;

   r = wdata != (rdata ^ 6);

   for (i=0; i<5; i++) {
      if (wdata & 1) {
         scrouts(_l2+19, _top+6+i, "1");
         scrwipe(_l2+21, _top+6+i, _l2+25, _top+6+i, INVERT);
         scrouts(_l2+22, _top+6+i, (i==0 || i==3 ? "High" : "Low "));
      } else {
         scrouts(_l2+19, _top+6+i, "0");
         scrwipe(_l2+21, _top+6+i, _l2+25, _top+6+i, BRIGHT);
         scrouts(_l2+22, _top+6+i, (i==0 || i==3 ? "Low " : "High"));
      }
      if (rdata & 1) {
         scrouts(_l2+19, _top+12+i, "1");
         scrwipe(_l2+21, _top+12+i, _l2+25, _top+12+i,
                 (i!=1 && i!=2 ? INVERT : BRIGHT));
         scrouts(_l2+22, _top+12+i, (i!=4 ? "High" : "Low "));
      } else {
         scrouts(_l2+19, _top+12+i, "0");
         scrwipe(_l2+21, _top+12+i, _l2+25, _top+12+i,
                 (i!=1 && i!=2 ? BRIGHT : INVERT));
         scrouts(_l2+22, _top+12+i, (i!=4 ? "Low " : "High"));
      }
      wdata >>= 1;
      rdata >>= 1;
   }
   sound(1000); delay(1); nosound();
   return r;
}

static int ltest1(void)
{
   register int i, byf;
   register unsigned char data;
   register r;
   static char *al1[] = {
      "PIN   NAME          STATE",
      "────  ────      ┌─┐ ─────",
      " 2  Data bit 0  │.│ Low",
      " 1  Strobe      │.│ Low      Output",
      " 14 AUTO LF     │.│ Low  <── data",
      " 16 INIT        │.│ Low      pins",
      " 17 SLCT IN     │.│ Low",
      "                ├─┤",
      "15 Error        │.│ Low",
      "13 Select       │.│ High     Input",
      "12 Out of paper │.│ High <── data",
      "10 Acknowledge  │.│ Low      pins",
      "11 Busy         │.│ Low",
      "                └─┘",
      "",
      " ESC - Stop test",
      "",
      "   Correct operation is indicated by",
      "one highlited bit rotating through",
      "both the output & input sets of bits",
   };

   scrouts(_l2,    0, "╔══════════════════════════════════════╗");
   dupline(_l2+10, 0, " Parallel Wire Test ");
   scrwipe(_l2+1,  1, _l2+38, _vinfo.vs_height-2, NORMAL);

   if (prompt()) return 0;

   scrwipe(_l2+19, _top+6,  _l2+19, _top+10, BRIGHT);
   scrwipe(_l2+19, _top+12, _l2+19, _top+16, BRIGHT);
   for (i=0; i<dim(al1); i++) scrouts(_l2+2, _top+4+i, al1[i]);
   scrline(_l2+1,_top+3, "──────────────────────────────────────",BRIGHT);
   scrline(_l2+1,_top+18,"──────────────────────────────────────",BRIGHT);
   if (_l1 == _l2) viewport();

   r = 0;
   do {
      outport(contport, 16);

      for (i=0; i<5 && !keyserv(1); i++) {
         if (i==0) {
            data = 1;
            outportb(dataport, data);
            delay(10);
            byf = inportb(errorp);
            outportb(dataport, 0);
         } else {
            outportb(contport, data);
            delay(10);
            byf = inportb(errorp);
            data <<= 1;
         }
         if (lscr(data, byf)) r = ERROR;
         delay(500);
      }
   } while (!keyserv(1));

   logline(r ? "Errors detected" : "No errors detected");
   if (_l1 == _l2) {
      scrwipe(_l2+1, _top+19, _l2+38, _vinfo.vs_height-2, NORMAL);
   }
   return r;
}

static int sendfrom(int i)
{
   register f, c;
   int save[24*4];

   scrpick(_l2+8, _top+10, _l2+31, _top+13, save);
   scrwipe(_l2+8, _top+10, _l2+31, _top+13, BRIGHT);
   scrouts(_l2+8, _top+10, "┌ Send characters from ┐");
   scrouts(_l2+8, _top+11, "│                      │");
   scrouts(_l2+8, _top+12, "│                      │");
   scrouts(_l2+8, _top+13, "└──────────────────────┘");

   f = i;
   do {
      scrwipe(_l2+17, _top+11, _l2+23, _top+11, (f ? NORMAL : INVERT));
      scrwipe(_l2+17, _top+12, _l2+23, _top+12, (f ? INVERT : NORMAL));
      scrgoto(_l2+17, _top+11);
      scrpoke((scrpeek() & 0xF0FF) | (BRIGHT << 8));
      scrouts(_l2+17, _top+11, "Console");
      scrgoto(_l2+17, _top+12);
      scrpoke((scrpeek() & 0xF0FF) | (BRIGHT << 8));
      scrouts(_l2+17, _top+12, "File");

      c = readkey();
      if (c & 255) {
         c &= 255;
         if        (c == 'c' || c == 'C') {
            f = 0; c = '\r';
         } else if (c == 'f' || c == 'F') {
            f = 1; c = '\r';
         }
      } else if (c == 0x4800 || c == 0x5000) {
         f = !f;
      }
   } while (c!='\r' && c!=ESC);
   scrload(_l2+8, _top+10, _l2+31, _top+13, save);
   return c == ESC ? -1 : f;
}

static FILE *getfile(void)
{
   register i, j, c;
   register k, s;
   register short left, right;
   register shift;
   unsigned save[3*40];
   char buf[MAXPATH];
   FILE *f;

   left = _l2+2, right = _l2+37;

   scrpick(left-2, _top+11, right+2, _top+13, save);
   scrwipe(left-2, _top+11, right+2, _top+13, BRIGHT);

   scrouts(left-2, _top+11, "┌");
   for (i=left-1; i<=right+1; i++) scrputc('─');
   scrputc('┐');

   scrouts(left-2,  _top+12, "│");
   scrouts(right+2, _top+12, "│");

   scrouts(left-2, _top+13, "└");
   for (i=left-1; i<=right+1; i++) scrputc('─');
   scrputc('┘');

   buf[0] = 0;

   scrwipe(left, _top+12, right, _top+12, INVERT);
   scrouts((left+right-16)/2, _top+11, " Enter file name ");
   scrgoto(left, _top+12);

   i = shift = 0;
   cursor(1);
   do {
      c = keyserv(0);
      if (c & 255) {
         c &= 255;
         if (c & ~037) {
            if (c>='a' && c<='z') c -= ('z'-'Z');
            if (buf[i]) {
               if ((j = strlen(buf)) < MAXPATH-1) {
                  for (k=i; k<=j; k++) {
                     s = buf[k]; buf[k] = c; c = s;
                     if (buf[k] && left+i-shift < right) {
                        scrputc(buf[k]);
                     }
                  }
                  buf[k] = c;
                  scrgoto(left-shift + ++i, _top+12);
               }
            } else {
               if (i < MAXPATH-1) {
                  buf[i++] = c;
                  if (left+i-shift < right) scrputc(c);
                  buf[i] = 0;
               }
            }
            if (left+i-shift > right) {
               shift = (i - (right-left) + 7) & ~7;
               scrwipe(left, _top+12, right, _top+12, INVERT);
               scrgoto(left, _top+12);
               for (j=0; j+left<right && buf[j+shift]; j++) {
                  scrputc(buf[j+shift]);
               }
               scrgoto(left+i-shift, _top+12);
            }
         } else if (c == '\b') {
            if (i > 0) {
               if (--i < shift) {
                  while (i<shift) shift -= 8;
                  scrwipe(left, _top+12, right, _top+12, INVERT);
                  scrgoto(left, _top+12);
                  for (j=0; j+left<=right && buf[j+shift]; j++) {
                     scrputc(buf[j+shift]);
                  }
               }
               scrgoto(left+i-shift, _top+12);
               goto delete;
            }
         }
      } else {
         switch(c) {
            case 0x4700: /* Home */
               shift = i = 0;
               scrwipe(left, _top+12, right, _top+12, INVERT);
               scrgoto(left, _top+12);
               for (j=0; j+left<=right && buf[j]; j++) scrputc(buf[j]);
               break;
            case 0x4F00: /* End */
               if ((i = strlen(buf)) > right-left) {
                  shift = (i - (right-left) + 7) & ~7;
               } else {
                  shift = 0;
               }
               scrwipe(left, _top+12, right, _top+12, INVERT);
               scrgoto(left, _top+12);
               for (j=0; j+left<=right && buf[j+shift]; j++) {
                  scrputc(buf[j+shift]);
               }
               break;
            case 0x4B00: /* Left */
               if (i > 0) {
                  if (--i < shift) {
                     while (i<shift) shift -= 8;
                     scrwipe(left, _top+12, right, _top+12, INVERT);
                     scrgoto(left, _top+12);
                     for (j=0; j+left<=right && buf[j+shift]; j++) {
                        scrputc(buf[j+shift]);
                     }
                  }
               }
               break;
            case 0x4D00: /* Right */
               if (buf[i]) {
                  if (++i + left-shift > right) {
                     shift = (i - (right-left) + 7) & ~7;
                     scrwipe(left, _top+12, right, _top+12, INVERT);
                     scrgoto(left, _top+12);
                     for (j=0; j+left<=right && buf[j+shift]; j++) {
                        scrputc(buf[j+shift]);
                     }
                  }
               }
               break;
            case 0x5300: /* Del */
                 delete:
               if (buf[i]) {
                  for (j=i; buf[j]; j++) {
                     buf[j] = buf[j+1];
                     if (left+j-shift <= right) scrputc(buf[j]);
                  }
                  if (left+j-shift <= right) scrputc(' ');
                  buf[j-1] = 0;
               }
               break;
         }
         scrgoto(left+i-shift, _top+12);
      }
   } while (c!='\r' && c!=27);
   cursor(0);

   f = NULL;
   if (c == '\r') {
      if ((f = fopen(buf, "r")) == NULL) {
         scrwipe(left, _top+12, right, _top+12, ITALIC);
         dupline((left+right-14)/2, _top+12, "\007Can't open file");
         (void)readkey();
      }
   }
   scrload(left-2, _top+11, right+2, _top+13, save);
   return f;
}

#define MHW 38

static void mhelp(void)
{
   register i;
   static char mh[][MHW+1] = {
      "┌────────────────────────────────────┐",
      "│   CONTROL PORT                 ┌─┐ │",
      "│ 1 Strobe  1 when sending byte  │∙│ │",
      "│ 2 AUTO LF 1 force LF after CR  │∙│ │",
      "│ 3 INIT    0 reset printer      │∙│ │",
      "│ 4 SLCT IN 1 select printer     │∙│ │",
      "│ 5 IRQ     1 enable             │∙│ │",
      "│                                └─┘ │",
      "│   STATUS PORT                  ┌─┐ │",
      "│ 1 ERROR   0 printer error      │∙│ │",
      "│ 2 SLCT    1 printer selected   │∙│ │",
      "│ 3 PE      1 out of paper       │∙│ │",
      "│ 4 ASC     0 ready for next ch  │∙│ │",
      "│ 5 BUSY    0 busy or offline    │∙│ │",
      "│                                └─┘ │",
      "└────────────────────────────────────┘",
   };
   int save[MHW * dim(mh)];

   scrpick(_l2+1,   _top+(25-dim(mh))/2,
           _l2+MHW, _top+(25-dim(mh))/2+dim(mh)-1, save);
   scrwipe(_l2+1,   _top+(25-dim(mh))/2,
           _l2+MHW, _top+(25-dim(mh))/2+dim(mh)-1, INVERT);
   for (i=0; i<dim(mh); i++) {
      scrouts(_l2+1, _top+(25-dim(mh))/2+i, mh[i]);
   }
   (void)readkey();
   scrload(_l2+1,   _top+(25-dim(mh))/2,
           _l2+MHW, _top+(25-dim(mh))/2+dim(mh)-1, save);
}

static void pscr(unsigned char dp, unsigned char sp, char text[], int t)
{
   unsigned char cp;
   int i;

   cp = inportb(contport) & 31;
   sp = (sp & 248) >> 3;

   scrgoto(_l2+14, _top+7);
   scrpoke((BRIGHT<<8) | dp);

   for (i=0; i<8; i++) {
      if (dp & 1) {
         scrouts(_l2+12, _top+10+i,"1");
         scrline(_l2+14, _top+10+i, "High", INVERT);
      } else {
         scrouts(_l2+12, _top+10+i,"0");
         scrline(_l2+14, _top+10+i, "Low ", BRIGHT);
      }
      dp >>= 1;
   }
   for (i=0; i<5; i++) {
      if (cp & 1) {
         scrouts(_l2+31, _top+7+i, "1");
         scrwipe(_l2+33, _top+7+i, _l2+37, _top+7+i, INVERT);
         scrouts(_l2+34, _top+7+i, (i==0 || i==3 ? "High" : "Low "));
      } else {
         scrouts(_l2+31, _top+7+i, "0");
         scrwipe(_l2+33, _top+7+i, _l2+37, _top+7+i, BRIGHT);
         scrouts(_l2+34, _top+7+i, (i==0 || i==3 ? "Low " : "High"));
      }
      cp >>= 1;
   }
   for (i=0; i<5; i++) {
      if (sp & 1) {
         scrouts(_l2+31, _top+14+i, "1");
         scrwipe(_l2+33, _top+14+i, _l2+36, _top+14+i, INVERT);
         scrouts(_l2+33, _top+14+i, (i!=4 ? "High" : "Low "));
      } else {
         scrouts(_l2+31, _top+14+i, "0");
         scrwipe(_l2+33, _top+14+i, _l2+36, _top+14+i, BRIGHT);
         scrouts(_l2+33, _top+14+i, (i!=4 ? "Low " : "High"));
      }
      sp >>= 1;
   }
   scrwipe(_l2+3, _top+4, _l2+35, _top+4, t);
   scrouts(_l2+3, _top+4, text);
#ifdef LOGGING
   if (t == ITALIC) logline(text);
#endif
}

static void pinic(void)
{
   pscr(0, (inport(errorp)), "initialise port", BRIGHT);
   outportb(contport,INIC);
   delay(300);

   pscr(0, (inport(errorp)), "reinitialise port", BRIGHT);
   outportb(contport,REINIC);
   delay(2000);
   pscr(0, (inport(errorp)), "ready to send characters", BRIGHT);
}

static int wlbyte(char a)
{
   register char e;
   register i;
   register f = 0;

   e = inportb(errorp);

   if (e & 32) {
      pscr(a, e, "Warning: paper out", ITALIC);
      BEEP(); delay(300);
      f = 1;
   }
   if ((e & B_1)==0) {
      pscr(a, e, "Warning: port error", ITALIC);
      BEEP(); delay(300);
      f = 1;
   }
   if ((e & B_5)==0){
      pscr(a, e, "Warning: printer busy", ITALIC);
      BEEP(); delay(300);
      f = 1;
   }

   outportb(dataport, a);

   for (i=0; i<30000; i++) {
      if ((e = inportb(errorp)) & READY) break;
   }
   if (i==30000) {
      pscr(a, e, "Warning: timeout", ITALIC);
      BEEP(); delay(300);
      f = 1;
   }

   outportb(contport, inport(contport) |  STROB);
   outportb(contport, inport(contport) & ~STROB);

   pscr(a, e, "character sent, ready for next", BRIGHT);
   return f;
}

static void dopspec(void)
{
   register c, i, j;
   static char *mt[] = {
      "Init",
      "Enable IRQ",
      "Disable IRQ",
      "Auto LF",
   };
   i = 0;
   do {
      scrwipe(_l2+8, _top+20,   _l2+19, _top+23,   NORMAL);
      scrwipe(_l2+8, _top+20+i, _l2+19, _top+20+i, INVERT);
      for (j=0; j<dim(mt); j++) {
         scrgoto(_l2+8, _top+20+j);
         scrpoke((scrpeek() & 0xF0FF) | (BRIGHT << 8));
         scrputs(mt[j]);
      }
      c = readkey();
      if (c & 255) {
         c &= 255;
         if (c>='a' && c<='z') c -= 'z'-'Z';
         switch (c) {
            case 'I': i = 0; c = '\r'; break;
            case 'E': i = 1; c = '\r'; break;
            case 'D': i = 2; c = '\r'; break;
            case 'A': i = 3; c = '\r'; break;
         }
      } else {
         if        (c == 0x4800) {
            if (--i < 0) i = 3;
         } else if (c == 0x5000) {
            if (++i > 3) i = 0;
         }
      }
   } while (c!=ESC && c!='\r');

   scrwipe(_l2+8, _top+20, _l2+19, _top+23, NORMAL);
   scrwipe(_l2+8, _top+20, _l2+8,  _top+23, BRIGHT);
   for (j=0; j<dim(mt); j++) {
      scrgoto(_l2+8, _top+20+j);
      scrpoke((scrpeek() & 0xF0FF) | (BRIGHT << 8));
      scrputs(mt[j]);
   }

   if (c != ESC) {
      switch (i) {
         case 0: pinic();
                 break;
         case 1: outportb(contport, (inportb(contport) | 16));
                 pscr(0, (inportb(errorp)), "IRQ enable", BRIGHT);
                 delay(300);
                 break;
         case 2: outportb(contport, (inportb(contport) & 15));
                 pscr(0, (inportb(errorp)), "IRQ enable", BRIGHT);
                 delay(300);
                 break;
         case 3: outportb(contport, (inportb(contport) | 2));
                 pscr(0, (inportb(errorp)), "AUTO LF ", BRIGHT);
                 delay(300);
                 break;
      }
   }
}

static int doptest(void) /* Printer test*/
{
   register c, i=0;
   register r, type;
   FILE *inp;
   static char *a[] = {
      "┌──────────────────────────── WORK ──┐",
      "│                                    │",
      "└────────────────────────────────────┘",
      " Character ┌───┐  CONTROL    ┌─┐",
      "  output   │' '│  1 Strobe   │.│",
      "           └───┘  2 AUTO LF  │.│",
      " DATA     ┌─┐     3 INIT     │.│",
      " 1 Bit 1  │.│     4 SLCT IN  │.│",
      " 2 Bit 2  │.│     5 IRQ      │.│",
      " 3 Bit 3  │.│                └─┘",
      " 4 Bit 4  │.│     STATUS     ┌─┐",
      " 5 Bit 5  │.│     1 -ERROR   │.│",
      " 6 Bit 6  │.│     2 +SLCT    │.│",
      " 7 Bit 7  │.│     3 +PE      │.│",
      " 8 Bit 8  │.│     4 -ASC     │.│",
      "          └─┘     5 -BUSY    │.│",
      "────── Press F2 to ──────┐   └─┘",
      "       Init              │",
      "       Enable IRQ        ├────────────",
      "       Disable IRQ       │ F1  - Help ",
      "       Auto LF           │ ESC - Quit ",
   };

   scrouts(_l2,    0, "╔══════════════════════════════════════╗");
   dupline(_l2+12, 0, " Workload  Test ");
   scrwipe(_l2+1,  1, _l2+38, _vinfo.vs_height-2, NORMAL);

   scrouts(_l2+9, _top+12, "Please attach printer");
   scrouts(_l2+6, _top+13, "Press any key when ready...");
   if ((readkey() & 255) == ESC) return 0;
   scrwipe(_l2+6,  _top+12, _l2+33, _top+13, NORMAL);
   scrwipe(_l2+12, _top+10, _l2+12, _top+17, BRIGHT);
   scrwipe(_l2+31, _top+7,  _l2+31, _top+11, BRIGHT);
   scrwipe(_l2+31, _top+14, _l2+31, _top+18, BRIGHT);
   scrwipe(_l2+8,  _top+20, _l2+8,  _top+23, BRIGHT);

   for (i=0; i<dim(a); i++) scrouts(_l2+1, _top+3+i, a[i]);
   if (_l1 == _l2) viewport();

   r = 0;
   type = 0;
   while (1) {
      if ((type = sendfrom(type)) < 0) {
         logline(r ? "Errors detected" : "No errors detected");
         return r;
      }
      if (type) {
         if ((inp = getfile()) == NULL) continue;
      }
      pinic();
      while (((c = readkey()) >> 8) != 1 /* ESC key */ &&
             !(type && (feof(inp) || ferror(inp)))) {
         if        (c == 0x3B00) {/* F1 */
            mhelp();
         } else if (c == 0x3C00) {/* F2 */
            dopspec();
         } else {
            if (type) {
               if (wlbyte(getc(inp))) r = ERROR;
            } else if (c & 255) {
               if (wlbyte(c & 255))   r = ERROR;
            }
         }
      }
   }
}

#define HELP_WIDTH 36

static void help(void)
{
   register i;
   register short left, top;
   static char help_text[][HELP_WIDTH+1] = {
      "┌──────────────────────────────────┐",
      "│ Use \x18\x19 keys to move frough menu  │",
      "│ SPACE or INS - mark current item │",
      "│ GRAY +/- mark/unmark all         │",
      "│ ENTER - run marked/current item  │",
      "│         Press any key...         │",
      "└──────────────────────────────────┘",
   };
   unsigned help_save[HELP_WIDTH * dim(help_text)];

   left = (_vinfo.vs_width - HELP_WIDTH) / 2;
   top  = (_vinfo.vs_height - dim(help_text)) / 2;

   scrpick(left, top, left+HELP_WIDTH-1, top+dim(help_text)-1, help_save);
   scrwipe(left, top, left+HELP_WIDTH-1, top+dim(help_text)-1, INVERT);
   for (i=0; i<dim(help_text); i++) {
      scrouts(left, top+i, help_text[i]);
   }
   (void)readkey();
   scrload(left, top, left+HELP_WIDTH-1, top+dim(help_text)-1, help_save);
}

#define MENU_TOP 4
#define BEG_PROG 2

static _menu_left, _diag_left, current;

struct _menu_auto { char hi, ins, row, run, res; };

static struct { char *text; int (*fun)(void); } menudata[] = {
   { "Quit test",                NULL   },
   { "Select port",              NULL   },
   { "internal Loopback test", internal },
   { "Interruption test",      scint    },
   { "Parallel wire test",     ltest1   },
   { "Workload test",          doptest  },
};

static void menuouts(short x, short y, char *s)
{
   scrgoto(x, y);
   while (*s) {
      if (*s < 'a' && *s > ' ') {
         scrpoke((scrpeek() & 0xF0FF) | (BRIGHT << 8));
      }
      scrputc(*s++);
   }
}

static void markitem(struct _menu_auto menuauto[],
                     int item, int flag, int attr)
{
   if (menudata[item].fun) {
      menuauto[item].ins = flag;
      if (flag) {
         scrwipe(_menu_left,   menuauto[item].row,
                 _diag_left-2, menuauto[item].row, (attr & 0xF0) | BRIGHT);
         scrouts(_menu_left-2, menuauto[item].row, "\x10");
      } else {
         scrwipe(_menu_left,   menuauto[item].row,
                 _diag_left-2, menuauto[item].row, attr);
         scrouts(_menu_left-2, menuauto[item].row, " ");
      }
      menuouts(_menu_left, menuauto[item].row, menudata[item].text);
   }
}

static void touchitem(struct _menu_auto menuauto[], int color)
{
   if (menuauto[current].ins) color = (color & 0xF0) | BRIGHT;
   scrwipe(_menu_left,   menuauto[current].row,
           _diag_left-2, menuauto[current].row, color);
   menuouts(_menu_left,  menuauto[current].row, menudata[current].text);
}

static void runtest(struct _menu_auto menuauto[], register int item)
{
   menuauto[item].run = TRUE;
   menuauto[item].res = (menudata[item].fun)();
   if (_l1 != _l2) {
      if (menuauto[item].res) {
         scrwipe(_diag_left,     menuauto[item].row,
                 _diag_left+2,   menuauto[item].row, ITALIC);
         scrouts(_diag_left,     menuauto[item].row, "err");
      } else {
         scrwipe(_diag_left,     menuauto[item].row,
                 _diag_left+2,   menuauto[item].row, NORMAL);
         scrouts(_diag_left,     menuauto[item].row, " √ ");
      }
   }
}

main(argc, argv) 
char *argv[];
{
   register c;
   register h, i, j, k;
   register run, remenu;
   struct _menu_auto menuauto[dim(menudata)];

   colorset(argc, argv);
   AskVideo(&_vinfo);
   if (_vinfo.vs_width < 80) {
      _l1 = _l2 = _vinfo.vs_width/2 - 20;
   } else {
      _l1 = (_l2 = _vinfo.vs_width/2) - 40;
   }
   _bottom  = _vinfo.vs_height - 1;
   _top = (_vinfo.vs_height - 25)/2;

   for (h=MENU_TOP, k=0, j=0; j<dim(menudata); j++) {
      menuauto[j].run = menuauto[j].ins = menuauto[j].res = 0;
      menuauto[j].row = h++;
      if (!menudata[j].fun && menudata[j+1].fun) ++h;
      for (i=0; menudata[j].text[i]; i++) {
         if (menudata[j].text[i] < 'a' && menudata[j].text[i] > ' ')
             menuauto[j].hi = menudata[j].text[i];
      }
      if (i > k) k = i; /* menu witdh */
   }

   _diag_left = (_menu_left = _l1 + (40 - 6 - k)/2 + 2) + k + 1;
#ifdef LOGGING
   logflag = !(ioctl(fileno(stdout), 0) & 128);
   if (logflag)
      printf("\n          ----------%s\t%s\t    ----------\n",
                    mainame, version);
#endif
   dataport = 0;
   if      (*(int far *)0x0408L) linic(lptnumb = 1);
   else if (*(int far *)0x040AL) linic(lptnumb = 2);
   else if (*(int far *)0x040CL) linic(lptnumb = 3);
   else if (*(int far *)0x040EL) linic(lptnumb = 4);
#ifdef LOGGING
   if (logflag && dataport) {
      printf("          Selected device LPT%c %3.3Xh\n",
             lptnumb ? lptnumb+'0' : '?', dataport);
   }
#endif
   current = 0;

   cursor(0);

   remenu = TRUE;
   scrwipe(0, 0, _vinfo.vs_width-1, _bottom, BORDER);
   if (_l1 != _l2) box(_l2);
   while (1) {
      if (remenu) {
         scrwipe(_l1, 0, _l1+39, _bottom, BORDER);
         box(_l1);
         scrouts(_l1+7, 0, mainame); scrputs(version);

      /* scrwipe(_l1+1, 1, _l1+38, _bottom-1, NORMAL); */
         scrwipe(_menu_left, 1, _diag_left-2, _bottom-1, NORMAL);

         viewport();

         scrwipe(_menu_left,   menuauto[current].row,
                 _diag_left-2, menuauto[current].row, INVERT);

         for (i=0; i<dim(menudata); i++) {
            if (menuauto[i].ins) {
               scrouts(_menu_left-2, menuauto[i].row, "\x10");
               scrwipe(_menu_left,   menuauto[i].row,
                       _diag_left,   menuauto[i].row,
                       i==current ? BRIGHT+INVERT : BRIGHT);
            }
            menuouts(_menu_left, menuauto[i].row, menudata[i].text);
            if (menuauto[i].run) {
               if (menuauto[i].res) {
                  scrwipe(_diag_left,   menuauto[i].row,
                          _diag_left+2, menuauto[i].row, ITALIC);
                  scrouts(_diag_left,   menuauto[i].row, "err");
               } else {
                  scrwipe(_diag_left,   menuauto[i].row,
                          _diag_left+2, menuauto[i].row, NORMAL);
                  scrouts(_diag_left,   menuauto[i].row, " √ ");
               }
            }
         }
         remenu = FALSE;
      }

      if (!dataport) {
         chport(); viewport();
      }

      run = FALSE;
      do {
         c = readkey();
         if (c & 255) {
            k = c & 255; if (k>='a' && k<='z') k -= ('z'-'Z');

            for (i=0; i<dim(menudata) && menuauto[i].hi!=k; i++);
            if (i < dim(menudata)) {
               touchitem(menuauto, NORMAL);
               current = i;
               ins = FALSE;
               run = TRUE;
               continue;
            }
         }
         switch (c >>= 8) {
            case 0x3B:
               help();
               break;
            case 0x01:
               goto e;
            case 0x47: case 0x48: case 0x49:
            case 0x4F: case 0x50: case 0x51:
               touchitem(menuauto, NORMAL);
               switch (c) {
                  case 0x47:
                  case 0x49: current = 0;
                             break;
                  case 0x48: if (--current < 0) current = dim(menudata)-1;
                             break;
                  case 0x50: if (++current >= dim(menudata)) current = 0;
                             break;
                  case 0x4F:
                  case 0x51: current = dim(menudata)-1;
                             break;
               }
               touchitem(menuauto, INVERT);
               break;
            case 0x39:
            case 0x52:
               if (current < dim(menudata)-1) {
                  markitem(menuauto, current, !menuauto[current].ins, NORMAL);
                  current += 1;
                  touchitem(menuauto, INVERT);
               } else {
                  markitem(menuauto, current, !menuauto[current].ins, INVERT);
               }
               break;
            case 0x4A:
               for (i=BEG_PROG; i<dim(menudata); i++) {
                  markitem(menuauto, i, FALSE, i==current ? INVERT : NORMAL);
               }
               break;
            case 0x4E:
               for (i=BEG_PROG; i<dim(menudata); i++) {
                  markitem(menuauto, i, TRUE, i==current ? INVERT : NORMAL);
               }
               break;
            case 0x1C:
               for (ins=FALSE, i=BEG_PROG; i<dim(menudata); i++) {
                  if (menuauto[i].ins) ins = TRUE;
               }
               run = TRUE;
               break;
         }
      } while (!run);

      if (ins) {
         for (i=BEG_PROG; i<dim(menudata); i++) {
            if (menuauto[i].ins) {
               runtest(menuauto, i);
               if (_l1 != _l2) {
                  markitem(menuauto, i, FALSE, i==current ? INVERT : NORMAL);
               } else {
                  menuauto[i].ins = FALSE;
               }
               if (menuauto[i].res) goto fault;
            }
         }
fault:   ;
      } else if (current == 0) {
         goto e;
      } else if (current == 1) {
         if (_l1!=_l2) touchitem(menuauto, NORMAL);
         chport();
         if (_l1 != _l2) {
            viewport();
            touchitem(menuauto, INVERT);
         }
         continue;
      } else {
         if (_l1!=_l2) touchitem(menuauto, NORMAL);
         runtest(menuauto, current);
         if (_l1!=_l2) touchitem(menuauto, INVERT);
      }
      if (_l1 == _l2) {
         remenu = TRUE;
         scrwipe(_l2+1, _bottom-1, _l2+38, _bottom-1, BRIGHT);
         scrouts(_l2+12,_bottom-1, "Press any key...");
         (void)readkey();
         scrwipe(_l2+1, _bottom-1, _l2+38, _bottom-1, NORMAL);
      }
   }
e: for (i=BEG_PROG, k=0; i<dim(menudata); i++) {
      if (menuauto[i].run && menuauto[i].res != 0 && menuauto[i].res != ESC) {
         k = 1;
      }
   }
   scrwipe(0, 0, _vinfo.vs_width-1, _bottom, EMPTY);
   scrgoto(0, 0);
   cursor(1);
   return k;
}
