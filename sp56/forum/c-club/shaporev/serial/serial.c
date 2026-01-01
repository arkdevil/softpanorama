/* Problem description & consulting by Dmitry S.Severov */
/* Original coding by Serge V.Popov                     */
/* Interface design & debugging by Tim V.Shaporev       */
/* The pogram is considered to be in a public domain    */

#define LOGGING

#include <alloc.h>
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

#define BEEP()   scrputc(7)

/* divisor latch values */
#define D_115200 1
#define D_57600  2
#define D_38400  3
#define D_19200  6
#define D_9600  12
#define D_4800  24
#define D_3600  32
#define D_2400  48
#define D_1800  64
#define D_1200  96
#define D_600  192
#define D_300  384
#define D_110 1047

extern long suscount(void);
extern void suspend (long);
static long us270272;

static struct VideoSettings _vinfo;
static char _l1, _l2, _bottom, _top;
static char ins;

static char mainame[] = " Serial Port Test ";
static char version[] = " v1.1 ";

#ifdef LOGGING
	static char logflag;

        static void dupouts(short x, short y, char *s)
        {
           scrouts(x, y, s); if (logflag) printf("          %s\n", s);
        }

        static void dupputs(char *s)
        {
           scrputs(s); if (logflag) printf("          %s\n", s);
        }
#else
#	define dupouts(x,y,s)	scrouts((x),(y),(s))
#	define dupputs(s)	scrputs(s)
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

static void scrdec(int n)
{
   register i; char b[5];

   i = sizeof(b);
   do b[--i] = n%10 + '0'; while ((n /= 10)!=0 && i!=0);
   while (i<sizeof(b)) scrputc(b[i++]);
}

static void scrhex(int n)
{
   register i; char b[4];
   static char h[] = "0123456789ABCDEF";

   i = sizeof(b);
   do b[--i] = h[n & 15]; while ((n >>= 4)!=0 && i!=0);
   while (i<sizeof(b)) scrputc(b[i++]);
}

static int _row;

static void newline(void)
{
   if (_row < _vinfo.vs_height-3) {
      _row += 1;
   } else {
      scrolup(_l2+1, 2, _l2+38, _vinfo.vs_height-3, NORMAL, 1);
   }
   scrgoto(_l2+1, _row);
}

static int intok;
static int resint[4]={ 0, 0, 0, 0 };
static int i_vect_b = 0xB, i_vect_c = 0xC;

static struct { int numb; long speed; int stop; char kont; }
   asx = { 1, 1200L, 1, 'n' };

struct { unsigned long speed; int del, div; char text[8]; } speeds[] = {
   {115200L,2, D_115200,"115200"},
   {57600L, 1, D_57600, " 57600"},
   {38400L, 1, D_38400, " 38400"},
   {19200L, 1, D_19200, " 19200"},
   {9600L,  1, D_9600,  "  9600"},
   {4800L,  1, D_4800,  "  4800"},
   {3600L,  1, D_3600,  "  3600"},
   {2400L,  1, D_2400,  "  2400"},
   {1800L,  1, D_1800,  "  1800"},
   {1200L,  2, D_1200,  "  1200"},
   {600L,  10, D_600,   "   600"},
   {300L,  30, D_300,   "   300"},
   {110L,  45, D_110,   "   110"},
};

static int irqnum = 0, cdata;

#define cspead1   cdata
#define cspead2  (cdata+1)
#define cint     (cdata+1)
#define cidint   (cdata+2)
#define clcont   (cdata+3)
#define clstat   (cdata+5)
#define mcontreg (cdata+4)
#define mstatreg (cdata+6)

static void viewport(short y)
{
   scrwipe(_l1+10, y, _l1+29, y, INVERT);
   scrouts(_l1+11, y, "COM");
   scrputc(asx.numb ? asx.numb + '0' : '?');
   scrputs(":  ");
   scrhex(cdata);
   scrputs("h  IRQ ");
   scrdec(irqnum);
}

static void chport(void)
{
   register i, f, thiscom, h, maxcom, a;
   static char v[] = {
      0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F,
      0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77,
   };

   scrouts(_l2,   0, "╔════════════ Select  Port ════════════╗");
   scrwipe(_l2+1, 1, _l2+38, _vinfo.vs_height-2, BRIGHT);

   i_vect_b = 0xB; i_vect_c = 0xC;

   thiscom = maxcom = 0; f = 0;
   if (*(int far *)0x0400L) { ++maxcom; f |= 1; }
   if (*(int far *)0x0402L) { ++maxcom; f |= 2; }
   if (*(int far *)0x0404L) { ++maxcom; f |= 4; }
   if (*(int far *)0x0406L) { ++maxcom; f |= 8; }

   if (maxcom == 0) scrline(_l2+13, 8, "No COM in BIOS", NORMAL);

   scrouts(_l2+16, 9, "┌──────┐");
   h = 0;
   do {
      scrouts(_l2+16, 10+h, "│      │");
   } while (h++ < maxcom);
   scrouts(_l2+16, 10+h, "└──────┘");
   scrwipe(_l2+18, 10,   _l2+21, 10+h-1, NORMAL);

   while (1) {
      h = 10;
      scrwipe(_l2+18, h,         _l2+21, h+maxcom,  NORMAL);
      scrwipe(_l2+18, h+thiscom, _l2+21, h+thiscom, INVERT);
      if (f) {
         for (i=0; i<4; i++) {
            if (f & (1<<i)) {
               scrouts(_l2+18, h++, "COM");
               scrpoke(((scrpeek() & 0xF000) | (BRIGHT << 8)) | (i + '1'));
            }
         }
      }
      scrouts(_l2+18, h, "COM");
      scrpoke(((scrpeek() & 0xF000) | (BRIGHT << 8)) | '?');

      if ((i = readkey()) & 255) {
         switch (i &= 255) {
            case ESC : goto end;
            case '\r': goto selected;
            case '1' :
            case '2' :
            case '3' :
            case '4' : if (f & (1 << (i -= '1'))) {
                          thiscom = i; goto selected;
                       }
                       break;
            case '/' : /* dummy for convinience */
            case '?' : thiscom = maxcom;
                       goto selected;
         }
      } else if (maxcom) {
         if        (i == 0x4800) {
            do {
               if (--thiscom < 0) thiscom = maxcom;
            } while (thiscom < maxcom && (f & (1 << thiscom)) == 0);
         } else if (i == 0x5000) {
            do {
               if (++thiscom > maxcom) thiscom = 0;
            } while (thiscom < maxcom && (f & (1 << thiscom)) == 0);
         }
      }
   }
selected:
   h = _top + 10;
   scrwipe(_l2+18, h, _l2+21, h+maxcom, NORMAL);
   if (f) {
      for (i=0; i<4; i++) {
         if (f & (1<<i)) {
            scrouts(_l2+18, h++, "COM");
            scrpoke(((scrpeek() & 0xF000) | (BRIGHT << 8)) | (i + '1'));
         }
      }
   }
   scrouts(_l2+18, h, "COM");
   scrpoke(((scrpeek() & 0xF000) | (BRIGHT << 8)) | '?');

   if (thiscom < maxcom) {
      cdata = *(int far *)(0x400L-2 + 2*(asx.numb = thiscom+1));
      irqnum = 4 - (thiscom & 1);
   } else {
      scrwipe(_l2+3, 16, _l2+36, 18, BRIGHT);
      scrouts(_l2+3, 16, "┌────────────────────────────────┐");
      scrouts(_l2+3, 17, "│ Base port address (hex):       │");
      scrouts(_l2+3, 18, "│        IRQ number (dec):       │");
      scrouts(_l2+3, 19, "└────────────────────────────────┘");
      cursor(1);
      for (a=0;;) {
         scrwipe(_l2+31, 17, _l2+33, 17, INVERT);
         scrgoto(_l2+31, 17); if (a) scrhex(a);
         i = keyserv(0) & 255;
         if        (i == '\r') {
            goto baseport;
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
baseport:
      asx.numb = 0; cdata = a; irqnum = 4;
      for (a=0;;) {
         scrwipe(_l2+31, 18, _l2+33, 18, INVERT);
         scrgoto(_l2+31, 18); if (a) scrdec(a);
         i = keyserv(0) & 255;
         if        (i == '\r') {
            goto entered;
         } else if (i == ESC ) {
            goto end;
         } else if (i == '\b' || i ==  0 ) {
            a /= 10;
         } else if (i >= '0' && i<='9') {
            if (10*a + i <= '0'+15) a = 10*a + (i-'0');
         }
      }
entered:
      i_vect_b = i_vect_c = v[irqnum = a];
      cursor(0);
   }
end:;
#ifdef LOGGING
   if (logflag) {
      printf("          Selected device COM%c:   %3.3Xh  IRQ %d\n",
             asx.numb ? asx.numb+'0' : '?', cdata, irqnum);
   }
#endif
}

static void inic(int d)
{
   register unsigned char c;           /* line control mask */
   c = 3;                              /* word length = 8   */
   if (asx.stop == 2) c |= 4;          /* two stop bits     */
   if      (asx.kont == 'e') c |= 030; /* set parity even   */
   else if (asx.kont == 'o') c |= 010; /* set odd parity    */

   outportb(cint, 0);          /* disable modem interrupts    */
   outportb(clcont, c | 0x80); /* enable divisor latch access */

   outport(cspead1, d & 255);  /* set baud rate */
   outport(cspead2, d >> 8 );

   outportb(clcont, c); /* finally set required mode */
}

static int wr_send(void)
{
   register unsigned i=0; while (++i && !(inportb(clstat) & 0x20)); return !i;
}

static int wr_read(void)
{
   register unsigned i=0; while (++i && !(inportb(clstat) & 1)); return !i;
}

#define IN_BOX_W 16
#define IN_BOX_L (_l2+21)

static void drawbytes(short y, unsigned b[], int length)
{
   register j;

   scrgoto(IN_BOX_L, y);
   for (j=0; j<length; j++) {
      if ((b[j] & 255) == 8) {
         scrpoke(b[j] | (BRIGHT << 8));
         scrgoto(IN_BOX_L+1+j, y);
      } else {
         scrputc(b[j]);
      }
   }
}

static werewarn;

static int comtest2(int ty, short yshow, short ydiag)
{
   register int i, j, r;
   register unsigned char send, buf1, buf2;
   register long uscount;
   register unsigned u;
   static unsigned char tbytes[] = {
      0,  1,  2,  4,  8,  16, 32, 64, 128,
      255,254,253,250,247,239,223,191,127,
   };
   unsigned bsent[IN_BOX_W], brets[IN_BOX_W];

   for (j=0; j<IN_BOX_W; j++) bsent[j] = brets[j] = (BRIGHT << 8) + ' ';

   /* delay for a char in microseconds */
   uscount = (2 * 8 * 1000000L + asx.speed) / (2 * asx.speed);
   /* compute delay counter for suspend() - prevent an overflow */
   if (uscount + 270272L/2 > 0x7FFFFFFFL/us270272) {
      if (uscount > us270272) {
         uscount = (uscount + 270272L/2) / 270272L * us270272;
      } else {
         uscount = (us270272 + 270272L/2) / 270272L * uscount;
      }
   } else {
      uscount = (uscount * us270272 + 270272L/2) / 270272L;
   }
   if (uscount == 0) uscount = 1;

   outportb(mcontreg, (ty ? 0x10 : 0));

   while (inportb(clstat) & 1) (void)inportb(cdata);

   for (i=0, r=0; i<dim(tbytes); i++) {
      if (keyserv(1) && keyserv(0) == 0x011B) return r ? r : ESC;

      send = tbytes[i];

      for (j=0; j<IN_BOX_W-1; j++) {
         bsent[j] = bsent[j+1];
         brets[j] = brets[j+1];
      }
      bsent[IN_BOX_W-1] = (BRIGHT<<8) | send;

      drawbytes(yshow, bsent, IN_BOX_W);

      wr_send(); outportb(cdata, send);
      wr_read(); buf1 = (int)inportb(cdata);

      drawbytes(yshow+6, brets, IN_BOX_W-1);
      scrpoke(brets[IN_BOX_W-1] = (BRIGHT<<8) | buf1);

      if (buf1 == send) continue;

      suspend(uscount);
      wr_read();
      if ((buf2 = (int)inportb(cdata)) == send) {
         scrpoke(brets[IN_BOX_W-1] = (BRIGHT<<8) | buf2);
         if (werewarn) continue;
         BEEP();
         scrwipe(_l2+1, ydiag, _l2+38, ydiag, ITALIC);
         dupouts(_l2+4, ydiag, "Unsynchronized adapter/mainboard");
         werewarn = 1;
      } else {
         r = ERROR; BEEP();
         scrwipe(_l2+1, ydiag, _l2+38, ydiag, ITALIC);
         scrouts(_l2+3, ydiag, "Error: send ");
         scrhex(send); scrputs("h - received ");
         scrhex(buf1); scrputc('h');
#ifdef LOGGING
         if (logflag) {
            printf("          Error at %ld baud: sent %2.2Xh - received %2.2Xh\n",
                   asx.speed, send, buf1);
         }
#endif
      }
      scrline(_l2+2,ydiag+1,"ESC to abort,  any other to continue", BRIGHT);
      u = readkey();
      scrwipe(_l2+2, ydiag+1, _l2+37, ydiag+1, BRIGHT);
      if (u == 0x011B) goto e;
   }
e:
   outportb(mcontreg, 0);
   return r;
}

static void smallbox(short y)
{
   scrouts(IN_BOX_L-1,  y,  "┌────────────────┐");
   scrouts(IN_BOX_L-1, y+1, "│                │");
   scrouts(IN_BOX_L-1, y+2, "└────────────────┘");
}

static void menu2(short y)
{
   scrline(_l2+1,   y,   "──────────────────────────────────────", BRIGHT);
   dupouts(_l2+13,  y,   " Data Port Test ");
   scrline(_l2+1,  y+15, "──────────────────────────────────────", BRIGHT);
   scrouts(_l2+2,  y+1,  "Baudrate Result");
   scrouts(_l2+25, y+3,  "Output"); smallbox(y+4);
   scrouts(_l2+25, y+9,  "Input"); smallbox(y+10);
}

static int test2(int ty, short y)
{
   register i, r, flag;

   menu2(y);

   r = 0;   werewarn = 0;

   for (i=0; i<dim(speeds); i++) {
      scrwipe(IN_BOX_L, y+5,   IN_BOX_L+IN_BOX_W-1, y+5,  BRIGHT);
      scrwipe(IN_BOX_L, y+11,  IN_BOX_L+IN_BOX_W-1, y+11, BRIGHT);
      scrouts(_l2+3,    y+2+i, speeds[i].text); scrputs("  Testing");

      asx.speed = speeds[i].speed;
      inic(speeds[i].div);
      flag = comtest2(ty, y+5, y+16);
      scrgoto(_l2+11, y+2+i);
      if (flag & 1) {
         scrputs("Failed "); r = ERROR;
      } else {
         scrputs("Passed ");
      }

      if (flag || keyserv(1) || i>=12) {
         scrwipe(_l2+1, y+17, _l2+38, y+17, BRIGHT);
         if (i < 12) {
            scrouts(_l2+2, y+17, "ESC to abort,  any other to continue");
         } else {
            scrouts(_l2+6, y+17, "Test over.  Press any key...");
         }
         if (readkey() == 0x011B) return r ? r : ESC;
      }
   }
   return r;
}

static void diagint(int n)
{
   static char *inm[] = {
      "Interruption on modem status:",
      "Int on transmit buffer's empty:",
      "Int rec'd data is available:",
      "Int on rec'r line status:",
   };

   newline(); scrputc(' '); dupputs(inm[n]);
   if (!resint[n]) {
      newline(); dupputs("          Interruption O'k");
   } else {
      if (resint[n] & 1) {
         newline(); scrwipe(_l2+1, _row, _l2+38, _row, ITALIC);
         dupputs("       No interruption occured");
      } else if (resint[n] & 2) {
         newline(); scrwipe(_l2+1, _row, _l2+38, _row, ITALIC);
         dupputs("       Too many interrutions");
      } else if (resint[n] & 4) {
         newline(); scrwipe(_l2+1, _row, _l2+38, _row, ITALIC);
         dupputs("       Misinterrupt");
      } else if (resint[n] & 8) {
         newline(); scrwipe(_l2+1, _row, _l2+38, _row, ITALIC);
         dupputs("       Unexpected interrupt");
      }
   }
}

static void enprnint(void) /*ready for COM*/
{
   disable();
   outportb(0x21, (inportb(0x21) & ~24));
   enable();
}

static void diprnint(void) /*ready for COM*/
{
   disable();
   outportb(0x21, (inportb(0x21) | 24));
   enable();
}

static void interrupt intrport()
{
   intok = inportb(cidint) & 7;
   diprnint();
   enable();
   outportb(0x20, 0x20);
}

static void comint(int a)
{
   void interrupt (*oldvectb)();
   void interrupt (*oldvectc)();

   oldvectb = getvect(i_vect_b); setvect(i_vect_b, intrport);
   oldvectc = getvect(i_vect_c); setvect(i_vect_c, intrport);

   asx.speed = 1200L; inic(D_1200);

   /*inerruption 00*/

   if (a==1) {
      outportb(cint, 0);
      outportb(mcontreg, 8+1);

      inportb(mstatreg);

      outportb(cint, 8+4);
      intok=128;
      enprnint();
      outportb(mcontreg, 8+2);

      delay(500);
      inportb(mstatreg);

      diprnint();

      switch (intok) {
         case 128: resint[0] += 1; break;
         case  0 : break;
      /* case  1 : resint[0] += 2; break; */
         case  2 : resint[1] += 4;
         case  3 : resint[0] += 1; resint[1] += 4; break;
         case  4 : resint[2] += 4;
         case  5 : resint[0] += 1; resint[2] += 4; break;
         case  6 : resint[3] += 4;
         case  7 : resint[0] += 1; resint[3] += 4; break;
      }

      outportb(cint,~8);

      intok=128;
      outportb(mcontreg, 8+2);

      enprnint();
      outportb(mcontreg, 8+1);

      delay(500);
      inportb(mstatreg);

      diprnint();
      switch (intok) {
         case 128: break;
         case  1 : resint[0] += 8;
         case  0 : resint[0] += 8; break;
      }
   }

   /*inerruption 01 -- can work without loopback*/
   outportb(cdata, 31);
   wr_send();

   outportb(cint, 2+4);
   intok=128;
   enprnint();

   outportb(cdata, 31);

   wr_send();

   diprnint();

   switch (intok) {
      case 128: resint[1] += 1; break;
      case  2 : break;
      case  3 : resint[1] += 2; break;
      case  0 : resint[0] += 4;
      case  1 : resint[1] += 1; resint[0] += 4; break;
      case  4 : resint[2] += 4;
      case  5 : resint[1] += 1; resint[2] += 4; break;
      case  6 : resint[3] += 4;
      case  7 : resint[1] += 1; resint[3] += 4; break;
   }

   outportb(cdata, 31);
   wr_send();

   outportb(cint, ~2);
   intok = 128;
   enprnint();
   outportb(cdata, 31);
   wr_send();
   delay(50);
   diprnint();

   switch (intok) {
      case 128: break;
      case  2 : resint[1] += 8;
      case  3 : resint[1] += 8; break;
   }

   /*interruption 10*/

   if (a==1) {
      inportb(cdata);
      wr_send();

      outportb(cint, 1+4);

      intok = 128;
      wr_send();
      delay(5);
      enprnint();
      outportb(cdata, 31);
      wr_read();
      delay(50);
      inportb(cdata);

      diprnint();
      switch (intok) {
         case 128: resint[2] += 1; break;
         case  4 : break;
         case  5 : resint[2] += 2; break;
         case  0 : resint[0] += 4;
         case  1 : resint[2] += 1; resint[0] += 4; break;
         case  2 : resint[1] += 4;
         case  3 : resint[2] += 1; resint[1] += 4; break;
         case  6 : resint[3] += 4;
         case  7 : resint[2] += 1; resint[3] += 4; break;
      }
      inportb(cdata);
      wr_send();

      outportb(cint, ~1);
      inportb(cdata);

      intok=128;
      wr_send();
      delay(5);
      enprnint();
      outportb(cdata, 31);
      wr_read();
      delay(50);
      inportb(cdata);

      diprnint();
      switch (intok) {
         case 128: break;
         case  4 : resint[2] += 8;
         case  5 : resint[2] += 8; break;
      }
   }

   diprnint();
   setvect(i_vect_c, oldvectc);
   setvect(i_vect_b, oldvectb);
}

static int intint(void)
{
   register r = 0;

   resint[0] = resint[1] = resint[2] = resint[3] = 0;

   scrouts(_l2+1,  19, "──────────────────────────────────────");
   dupouts(_l2+9,  19, " Interruption  Test ");
   scrline(_l2+15, 20, "Working...", BRIGHT+BLINK);

   comint(1);

   scrwipe(_l2+15, 20, _l2+24, 20, NORMAL);

   if (resint[1] || resint[3]) {
      r = ERROR; BEEP(); _row = 19;
      diagint(1);
      diagint(2);

      newline();
      if (resint[3]) {
         scrwipe(_l2+1, _row, _l2+38, _row, ITALIC);
         dupputs("       Interruption 11 occured");
      } else {
         dupputs("     Interruption 11 not occured");
      }
   } else {
      dupouts(_l2+11, 20, "Interruptions O'k");
   }
   if (ins) {
      scrwipe(_l2+1,  _vinfo.vs_height-2, _l2+38, _vinfo.vs_height-2, BRIGHT);
      scrouts(_l2+12, _vinfo.vs_height-2, "Press any key...");
      if (readkey() == 0x011B) return r;
   }
   return r;
}

static int internal(void)
{
   register r;

   dupouts(_l2+12, 0, " Internal  Test ");
   scrwipe(_l2+1,  1, _l2+38, _vinfo.vs_height-2, NORMAL);
   if (_l1 == _l2) viewport(1);
   if ((r = test2(1,2)) != 0) return r==ERROR ? ERROR : r;
   return intint() == ERROR ? ERROR : 0;
}

static int test1(int ty)
{
   register i, c, f;

   scrwipe(_l2+1, 2, _l2+38, 2, BRIGHT);
   scrouts(_l2+1, 2, "─── Register test (plug ");
   scrputs(ty ? "TWO" : "ONE");
   scrputs(") ─────────");

   f = 0;
   if (ty /* == 1 */) {
      for (i=0; i<10; i++) {
         outportb(mcontreg, 1);
         if ((inportb(mstatreg) & 0x40) == 0) f |= 1;

         outportb(mcontreg, 2);
         if ((inportb(mstatreg) & 0x80) == 0) f |= 2;

         outportb(mcontreg, ~1 & 0xEF);
         if ((inportb(mstatreg) & 0x40) != 0) f |= 1;

         outportb(mcontreg, ~2 & 0xEF);
         if ((inportb(mstatreg) & 0x80) != 0) f |= 2;
      }
   } else {/* ty == 0 */
      for (f=0, i=0; i<10; i++) {
         outportb(mcontreg, 1);
         if ((inportb(mstatreg) & 0x20) == 0) f |= 1;

         outportb(mcontreg, 2);
         if ((inportb(mstatreg) & 0x10) == 0) f |= 2;

         outportb(mcontreg, ~1 & 0xEF);
         if ((inportb(mstatreg) & 0x20) != 0) f |= 1;

         outportb(mcontreg, ~2 & 0xEF);
         if ((inportb(mstatreg) & 0x10) != 0) f |= 2;
      }
   }
   outportb(mcontreg, 0);

   if (f) {
      scrwipe(_l2+1,  3, _l2+38, 3, ITALIC);
      scrouts(_l2+3,  3, "Error in line(s): ");
      if (f&1) scrputs(ty ? "DTR-RI   " : "DTR-DSR  ");
      if (f&2) scrputs(ty ? "RTS-DCD"   : "RTS-CTS");
#ifdef LOGGING
      if (logflag) {
         printf("          Error in line(s): ");
         if (f&1) printf("%s", ty ? "DTR-RI   " : "DTR-DSR  ");
         if (f&2) printf("%s", ty ? "RTS-DCD"   : "RTS-CTS");
         printf("\n");
      }
#endif
      BEEP();
   } else {
      dupouts(_l2+11, 3, "No errors detected");
   }
   scrline(_l2+12, 4, "Press any key...", BRIGHT);
   c = readkey();
   return f ? ERROR : (c == 0x011B);
}

int extint(void)
{
   register r = 0;
   resint[0] = resint[1] = resint[2] = resint[3] = 0;

   _row = 20; newline(); scrwipe(_l2+1, _row, _l2+38, _row, NORMAL);

   newline();
   scrwipe(_l2+1, _row, _l2+38, _row, BRIGHT);
   scrputs("──────────────────────────────────────");
   dupouts(_l2+9, _row, " Interruption  Test ");
   newline(); scrline(_l2+15, _row, "Working...", BRIGHT+BLINK);

   comint(1);

   scrwipe(_l2+1, _row, _l2+38, _row, NORMAL);

   if (resint[0] || resint[1] || resint[2] || resint[3]) {
      r = ERROR; BEEP();
      diagint(0);
      diagint(1);
      diagint(2);
      diagint(3);

      newline();
      if (resint[3]) {
         scrwipe(_l2+1, _row, _l2+38, _row, ITALIC);
         dupputs("       Interruption 11 occured");
      } else {
         dupputs("     Interruption 11 not occured");
      }
   } else {
      newline(); dupouts(_l2+11, _row, "Interruptions O'k");
   }
   return r;
}

static int prompt(int n, short y)
{
   register c;
   scrwipe(_l2+1,  2,  _l2+38, _vinfo.vs_height-2, NORMAL);
   scrouts(_l2+9,  y,  "Please insert plug ");
   scrputs(n == 2 ? "TWO" : n == 1 ? "ONE" : "");
   scrouts(_l2+8, y+1, "Press any key when ready");
   c = readkey();
   scrwipe(_l2+1,  y,  _l2+38, y+1, NORMAL);
   return c == 0x011B;
}

static int external(void)
{
   register k, r = 0;

   dupouts(_l2+12, 0, " External  Test ");
   if (_l1 == _l2) viewport(1);

   if (prompt(1, (_vinfo.vs_height-1)/2)) return 0;
   if ((k = test1(0)) == 1) return r; else if (k==ERROR) r=k;
   if (test2(0,4) == ERROR) r = ERROR;
   if ((r = extint()) == 1) return r; else if (k==ERROR) r=k;
   scrwipe(_l2+1,  _vinfo.vs_height-2, _l2+38, _vinfo.vs_height-2, BRIGHT);
   scrouts(_l2+12, _vinfo.vs_height-2, "Press any key...");
   if (readkey() == 0x011B) return r;

   if (prompt(2, (_vinfo.vs_height-1)/2)) return r;

   if (test1(1) == ERROR) r = ERROR;
   return r;
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
   { "Quit test",        NULL   },
   { "Select port",      NULL   },
   { "Internal tests", internal },
   { "eXternal tests", external },
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
   menuauto[item].res = (menudata[item].fun)();
   menuauto[item].run =  menuauto[item].res != ESC;
   if (menuauto[item].run && _l1 != _l2) {
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
   us270272 = suscount();

   i_vect_b = 0xB; i_vect_c = 0xC;
   asx.numb = 0; cdata = 0;
   if        (*(int far *)0x0400L) {
      asx.numb = 1; cdata = *(int far *)0x0400L; irqnum = 4;
   } else if (*(int far *)0x0402L) {
      asx.numb = 2; cdata = *(int far *)0x0402L; irqnum = 3;
   } else if (*(int far *)0x0404L) {
      asx.numb = 3; cdata = *(int far *)0x0404L; irqnum = 4;
   } else if (*(int far *)0x0406L) {
      asx.numb = 4; cdata = *(int far *)0x0406L; irqnum = 3;
   }

   cursor(0);

   remenu = TRUE;
   scrwipe(0, 0, _vinfo.vs_width-1, _bottom, BORDER);
   if (_l1 != _l2) box(_l2);
   while (1) {
      if (remenu) {
         scrwipe(_l1, 0, _l1+39, _bottom, BORDER);
         box(_l1);
         scrouts(_l1+8, 0, mainame); scrputs(version);

         scrwipe(_menu_left, 1, _diag_left-2, _bottom-1, NORMAL);

         if (cdata) viewport(2); else current = 1;

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

      if (!cdata) {
         chport(); viewport(2);
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
         chport(); viewport(2);
         if (_l1 != _l2) {
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