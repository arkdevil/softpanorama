/* detect.c	Copyright (c) 1990 Tim Shaporev */

#include "console.h"
#include "detect.h"

#include <bios.h>
#include <dos.h>

#ifndef DEBUG
	void exit(int n)    { void _exit(int); _exit(n); }
	void _setenvp(void) {}
	void _setargv(void) {}
#endif

#define BRIGHT	15
#define NORMAL  7
#define INVERT  0x70
#define ITALIC  LIGHTMAGENTA
#define TRUE    1
#define FALSE   0
#define ERROR   (-1)
#define dim(x)  (sizeof(x)/sizeof((x)[0]))
#define BCD(x)  (10*((x)>>4)+(x&15))
#define DATE(y,m,d)	(31*(12*((y)-1980)+(m))+(d))
/* #define TIME(h,m,s)	(60*(60*(long)(h)+(long)(m))+(long)(s)) */
#define TIME(h,m,s)	seconds((h),(m),(s))

struct VideoSettings _vinfo;
char _l1, _l2, _bottom, _cmostop;
static long _time;
static _cmostate;

struct _biosdef { unsigned short seg, blocks, text, len; };

static void cursor(int k)
{
   _CX = k ? _vinfo.vs_cursor.x : 0x2020; _AH = 1; geninterrupt(0x10);
}

static long seconds(short h, short m, short s)
{
   return (60*(60*(long)(h)+(long)(m))+(long)(s));
}

static void put2h(int n)
{
   static char h[] = "0123456789ABCDEF";
   scrputc(h[n>>4]); scrputc(h[n&15]);
}

static void put4h(unsigned u)
{
   put2h(u>>8); put2h(u&255);
}

#define DEC2(a,b)   (10*(a)+(b)-(11*'0'))

static void mtype(short x, short y)
{
   register n;
   register i, j, d;
   register unsigned char far *b = (unsigned char far *)0xFFFF0000L;

   static struct { unsigned char id; int sub, date; char *type; } db[] = {
      { 0xF8, -1, DATE(1987, 01, 01), "PS/2 Model 80"       },
      { 0xF9, -1, DATE(1985,  9, 13), "PC Convertible"      },
      { 0xFA, -1, DATE(1986,  9, 02), "PS/2 Model 30"       },
      { 0xFB, -1, DATE(1986, 05,  9), "XT-2 (640K)"         },
      { 0xFB, -1, DATE(1986, 01, 10), "XT"                  },
      { 0xFC, 06,         -1,         "Gearbox"             },
      { 0xFC, 05, DATE(1987, 02, 13), "PS/2 Model 60"       },
      { 0xFC, 04, DATE(1987, 02, 13), "PS/2 Model 50"       },
      { 0xFC, 02, DATE(1986, 04, 21), "XT/286"              },
      { 0xFC, 00,         -1,         "Industrial AT"       },
      { 0xFC, -1, DATE(1986, 11, 15), "AT, Enhanced 8mHz"   },
      { 0xFC, -1, DATE(1984, 01, 10), "AT"                  },
      { 0xFD, -1, DATE(1983, 06, 01), "PCjr"                },
      { 0xFE, -1, DATE(1982,  8, 11), "Portable or 3270 PC" },
      { 0xFF, -1, DATE(1982, 10, 19), "PC or XT/370 (256K)" },
      { 0xFF, -1, DATE(1981, 04, 24), "PC-1 (64K)"          },
      { 0xFF, -1,         -1,         "PC-0 (16K)"          },
      { 0x9A, -1,         -1,         "Compaq Plus (XT)"    },
      { 0x2D, -1,         -1,         "Compaq PC (4.77)"    },
   };

   scrouts(x, y, "  Machine type: ");

/*
   i = (unsigned)peekb(0xFFFF, 0x000E);
   j = (unsigned)peekb(0xFFFF, 0x000F);
   d = DATE(DEC2((unsigned)peekb(0xFFFF,11), (unsigned)peekb(0xFFFF,12))+1900,
            DEC2((unsigned)peekb(0xFFFF, 5), (unsigned)peekb(0xFFFF, 6)),
            DEC2((unsigned)peekb(0xFFFF, 8), (unsigned)peekb(0xFFFF, 9)));
*/
   i = b[14];
   j = b[15];
   d = DATE(DEC2(b[11], b[12])+1900, DEC2(b[5], b[6]), DEC2(b[8], b[9]));

   for (n=0; n<dim(db); n++) {
      if (db[n].id == i && (db[n].sub < 0 || db[n].sub == j) &&
         (db[n].date < 0 || d >= db[n].date)) {
         scrputs(db[n].type);
         goto end;
      }
   }
   put2h(i); scrputc('/'); put2h(j);
   scrputs("h (unknown)");
   end:;
}

static void cputype(short x, short y)
{
   register i, j;
   register char *s;

   scrouts(x, y, "Main Processor: ");
   j = CPUname(); i = j<0 ? -j : j;
   switch (i) {
      case CPU_8086: s = "Intel 8086";    break;
      case CPU_8088: s = "Intel 8088";    break;
      case CPU80186: s = "Intel 80186";   break;
      case CPU80286: s = "Intel 80286";   break;
      case CPU80386: s = Is_486() ? "Intel 80486" : "Intel 80386"; break;
      case CPUSX386: s = "Intel 80386SX"; break;
      case CPUNEC20: s = "NEC V20";       break;
      case CPUNEC30: s = "NEC V30";       break;
      default      : s = "(unknown)";
   }
   scrputs(s); if (j<0) scrputs(" (priv)");
}

static void co_type(short x, short y)
{
   static char *c[] = {"none", "Intel 8087", "Intel 80287", "Intel 80387",
		       "Weitek 1167", "Weitek 1167 & 80387" };

   scrouts(x, y, "  Co-processor: "); scrputs(c[MathUnit()]);
}

static void put3d(int n)
{
   scrputc(n < 100 ? ' ' : n/100+'0');
   scrputc(n / 10 % 10 + '0');
   scrputc(n % 10 + '0');
}

static void onevideo(int s, int d)
{
   static char *IBMname [] = { "(none)", "MDA",  "CGA", "EGA",
                               "PGA",    "MCGA", "VGA", "PC 3270" },
               *Hercname[] = { "HGC", "HGC+", "InColor" },
               *Display [] = { "(none)",          "MDA-like mono",
                               "CGA-like color",  "EGA-like color",
                               "professional",    "PS/2-like mono",
                               "PS/2-like color", "PC 3270",
                              };

   register short j;
   register unsigned short n;
   register char l;
   char b[5];

   if (s >= VSYS_Any && s <= VSYS_3270) {
      scrputs(IBMname[s]);
   } else if (s >= VSYS_HGC && s <= VSYS_InC) {
      scrputs(Hercname[s-VSYS_HGC]);
   } else if (s == VSYS_LCD) {
      scrputs("LCD (Model "); put3d(d); scrputc(')');
      return;
   } else if (s == VSYS_Tandy) {
      scrputs("Tandy 1000");
      return;
   }
   if (s == VSYS_EGA) {
      _AH = 0x12; _BL = 0x10; geninterrupt(0x10); n = _BL;
      n = 64*(n+1);
      j = 5;
      do {
         b[--j] = n % 10 + '0';
         n /= 10;
      } while (n && j>0);
      if (j>1) { if (j>0) scrputc(','); scrputc(' '); };
      while (j<5) scrputc(b[j++]);
      scrputc('K');
      l = TRUE;
   } else {
      l = FALSE;
   }
   scrputs(" (");
   if (d>=VDEV_Any && d<=VDEV_cPS) {
      scrputs(Display[d]);
   } else {
      put2h(d);
   }
   if (!l) scrputs(" display");
   scrputc(')');
}

static void put5d(unsigned n)
{
   register i, j;
   char b[5];

   j = 5;
   do {
      b[--j] = n % 10 + '0';
      n /= 10;
   } while (n && j>0);
   for (i=0; i<j; i++) scrputc(' ');
   while (j<5) scrputc(b[j++]);
}

static int expmem(short x, short y)
{
   unsigned long l; union REGS r;

   l = (unsigned long)getvect(0x67);
   if (l!=0 && peekb((unsigned)(l>>16), (unsigned)l)!=0xCF) {
      /* non-trivial EMM vector found */
      r.x.dx = 0; r.h.ah = 0x42; int86(0x67, &r, &r);
      if (r.h.ah!=0x42 && r.x.dx!=0) {
         scrouts(x, y, "Expanded memory");
         put5d(r.x.dx<<4); scrputs("K reported");
         return TRUE;
      }
   }
   return FALSE;
}

static unsigned long drvsize(int n)
{
   union REGS r;

   if (n & 0x80) {
      r.h.ah = 0x10;               /* test drive ready        */
      r.h.dl = n;                  /* drive number            */
      int86(0x13, &r, &r);
      if (r.h.ah!=0 && r.h.ah!=0x10) return 0;
   }

   r.h.ah = 8;                     /* get drive params        */
   r.x.cx = n & 0x80 ? 0 : 0x2808; /* dummy for ancient BIOS  */
   r.h.dh = 0;                     /* analogous, num of heads */
   r.h.dl = n;                     /* drive number            */
   int86(0x13, &r, &r);
   return ((unsigned long)(r.h.cl & 63) /* sectors */ *
           (unsigned long)(r.h.dh + 1)  /* heads   */ *
           ((r.h.ch|(((unsigned)r.h.cl<<2)&0x300))+1)) >> 1;
}

static void driverep(short x, short y, int n, unsigned long s)
{
   register i;
   register unsigned j;
   char b[5];

   scrgoto(x, y);
   scrputc(n&0x80 ? 'H' : 'F');
   scrputs("D∙");
   scrputc((n&7)|'0');
   scrputc(' ');
   if (s < 1000) {
      put3d((int)s); scrputc('K');
   } else {
      j = (unsigned)(s/1000);
      i = 5;
      do {
         b[--i] = j % 10 + '0';
         j /= 10;
      } while (j && i>0);
      while (i<5) scrputc(b[i++]);
      scrputc('.');
      scrputc(s % 1000 / 100 + '0');
      scrputc('M');
   }
}

static int bootlab(short x, short y)
{
   unsigned char b[512];
   register n, k;
   int i, h, t, s;
   register char *p;

   n = 0; do k = biosdisk(2, 0x80, 0, 0, 1, 1, b); while (++n<3 && k);
   if (k || *(unsigned short *)(b+510)!=0xAA55) return ERROR;
   for (i=0x1BE; i<510 && !(b[i]&0x80); i+=16) ;
   if (i>=510 || !(b[i]&0x80)) return ERROR;
   h = b[i+1];                                    /* head   */
   s = b[i+2] & 63;                               /* sector */
   t = ((unsigned)(b[i+2] & 0xC0) << 2) | b[i+3]; /* track  */
   i = b[i+4];                                    /* sys ID */
   scrouts(x, y, "Boot ID ");
   n = 0; do k = biosdisk(2, 0x80, h, t, s, 1, b); while (++n<3 && k);
   if (k || *(unsigned short *)(b+510)!=0xAA55) {
      scrputs("- IO error");
      return 1;
   }
   scrputc('\'');
   for (n=0; n<8; n++) {
      scrpoke((NORMAL<<8)|b[n+3]);
      scrgoto(x+10+n, y);
   }
   scrputc('\'');
   switch (i) {
      case 1: case 4: p = " DOS";           break;
      case 2: case 3: p = " XENIX";         break;
      case 6:         p = " DOS 4.+";       break;
      case 99:        p = " UNIX System V"; break;
      case 100:       p = " Netork";        break;
      case 117:       p = " PC/IX";         break;
      case 219:       p = " CP/M";          break;
      case 255:       p = " BBT";           break;
      default: scrputs(" Type "); put2h(i);
               scrputc('h');      return 0;
   }
   scrputs(p);
   return 0;
}

static unsigned int cmosbyte(int a)
{
   outportb(0x70, a); return inportb(0x71);
}

static unsigned int cmosword(int a)
{
   return ((unsigned)cmosbyte(a+1)<<8) | (unsigned)cmosbyte(a);
}

static void cmostime(short left, short top, long *p)
{
   register unsigned char h, m, s;
   register long l;

   s = cmosbyte(0); m = cmosbyte(2); h = cmosbyte(4);

   if ((l=TIME(BCD(h), BCD(m), BCD(s))) != *p) {
      scrgoto(left+3, top+3);
      put2h(h); scrputc(':'); put2h(m); scrputc(':'); put2h(s);
      *p = l;
   }
}

static void cmosflop(short x, short y, unsigned equip, int nflop)
{
   register unsigned j;

   scrgoto(x, y);
   if (!(equip & 1) || nflop > (equip >> 6)) {
      scrputs("none");
   } else {
      j = cmosbyte(0x10); j = nflop ? j&15 : j>>4;
      switch (j) {
         case 0 : scrputs("none"); break;
         case 1 : scrputs("360K"); break;
         case 2 : scrputs("1.2M"); break;
         case 3 : scrputs("720K"); break;
         case 4 : scrputs("1.4M"); break;
         default: scrputc('-');
                  scrputc(j>9 ? j+('A'-10) : j+'0');
                  scrputs("h-");
      }
   }
}

static void cmosdisk(short x, short y, int ndisk)
{
   register i;
   unsigned d; unsigned long s;
   static unsigned long sms[] = {
      512L * 000 * 0 * 17,
      512L * 306 * 4 * 17,
      512L * 615 * 4 * 17,
      512L * 615 * 6 * 17,
      512L * 940 * 8 * 17,
      512L * 940 * 6 * 17,
      512L * 615 * 4 * 17,
      512L * 462 * 8 * 17,
      512L * 733 * 5 * 17,
      512L * 900 *15 * 17,
      512L * 820 * 3 * 17,
      512L * 855 * 5 * 17,
      512L * 855 * 7 * 17,
      512L * 306 * 8 * 17,
      512L * 733 * 7 * 17,
   };

   d = cmosbyte(0x12); d = ndisk ? d&15 : d>>4;

   if (!d) {
      scrouts(x, y, "- unsupported -");
      return;
   }
   if (d == 15) {
      d = cmosbyte(ndisk ? 0x1A : 0x19);
      for (i=16; i<d && peek(0xFE4F, 1+i-16); i++) ;
      if (i>=d && peek(0xFE4F, 1+d-16)) {
         s = (long)peek(0xFE4F, 1+d-16) * peekb(0xFE4F, 3+d-16) * 17 * 512L;
      } else {
         s = 0;
      }
   } else {
      s = sms[d];
   }

   scrouts(x, y, "Type"); put3d(d);

   if (!s) return;

   s >>= 10;
   put5d((unsigned)(s / 1000));
   scrputc('.');
   scrputc((unsigned)(s % 1000) / 100 + '0');
   scrputc('M');
}

static int cmos(int left, int top)
{
   register i, n;
   unsigned short j, s;
   int retcode;

   scrouts(left+11, top+1, "CMOS ");

   for (i=0x10, n=0, s=0; i<0x2E; i++) {
      s += (j = cmosbyte(i));
      if (j == 0xFF) ++n;
   }
   if (n == 0x1E) {
      scrputs("not found");
      return ERROR;
   }
   if (s != (j=(((unsigned)cmosbyte(0x2E)<<8) | (unsigned)cmosbyte(0x2F)))) {
      scrwipe(left+16, top+1, left+29, top+1, ITALIC+BLINK);
      scrouts(left+16, top+1, "checksum error");
      retcode = 1;
   } else {
      scrputs("configuration");
      retcode = 0;
   }
   scrouts(left+2,  top+2, "Time&Date:     Floppy  Hard Drives");
   scrouts(left+15, top+3, "0:");
   scrouts(left+15, top+4, "1:");

   _time = 0;
   cmostime(left, top, &_time);

   scrgoto(left+2, top+4);
   put2h(cmosbyte(8)); /* month */ scrputc('-');
   put2h(cmosbyte(7)); /* day   */ scrputc('-');
   scrputs ((j = cmosbyte(9)) >= 0x80 ? "19" : "20");
   put2h(j);           /* year  */

   j = cmosbyte(0x14); /* equipment byte */
   cmosflop(left+18, top+3, j, 0);
   cmosflop(left+18, top+4, j, 1);
   cmosdisk(left+23, top+3, 0);
   cmosdisk(left+23, top+4, 1);

   scrouts(left+20, top+5, "Co-processor: ");
   scrputs(j&2 ? "here" : "none");

   scrouts(left+20, top+6, "Display: ");
   j &= 0x30;
   scrputs( j==0x10 ? "CGA 40col" : j==0x20 ? "CGA 80col" :
            j==0x30 ? "TTL Mono" : "special");

   scrouts(left+2,top+5,"Base memory "); put3d(cmosword(0x15)); scrputc('K');
   scrouts(left+2,top+6,"Ext memory");   put5d(cmosword(0x17)); scrputc('K');

   return retcode;
}

static int biosview(short x, short y, struct _biosdef *d)
{
   register i, j, n;
   register char far *p;

   scrgoto(x, y); put4h(d->seg);
   p = (char far *)(((unsigned long)(d->seg) << 16) | (d->text));
   for (i=0, n=0; i<d->len && n<_bottom-y; n++) {
      scrgoto(x+5, y+n); for (j=0; i<d->len && j<31; ++i,j++) scrputc(p[i]);
   }
   return d->len > 0 ? (d->len+30) / 31 : 1;
}

static void copyrt(unsigned short s,     unsigned short blocks,
                   unsigned short *text, unsigned short *len)
{
   register unsigned char far *p;
   register unsigned short i;

   p=(unsigned char far *)((unsigned long)s << 16);
   i = 0;
   do {
      if (p[i] == '(') {
         if (p[i+2]==')' && (p[i+1]=='c'||p[i+1]=='C')) goto notice;
      } else if (p[i] == 'c' || p[i] == 'C') {
         if ((p[i+1]=='o' || p[i+1]=='O') &&
             (p[i+1]=='p' || p[i+1]=='P')) goto notice;
      }
   } while (i < 512L*blocks && ++i);
   *text = 0; *len = 0; return;
   notice:
   *text = i;
   for (p+=i, i=0; p[i]>=' ' && p[i]<127; i++) ;
   *len = i;
}

static void biosmain(struct _biosdef *d)
{
   register unsigned short s; register unsigned char far *p;
   register unsigned short i;

   p = (unsigned char far *)0xFFFF0005L;
   for (i=0; i<8; i++) scrputc(p[i]);

   s = (*(unsigned short far *)0xFFFF0001L >> 4) +
        *(unsigned short far *)0xFFFF0003L;
   s &= 0xFFE0;
   while (s > 0xF000) {
      p = (unsigned char far *)((unsigned long)(s-0x20) << 16);
      for (i=0; i<512; i++) if (p[i]!=0xFF) goto extloop;
      goto endloop;
      extloop:
      s -= 0x20;
   }
   endloop: d->seg = s; d->blocks = (0-s) >> 5; /* (0x10000 - s) / 32 */

   copyrt(s, d->blocks, &(d->text), &(d->len));
}

static void biosext(struct _biosdef *d)
{
   register unsigned short s; register unsigned char far *p;
   register unsigned short i; register unsigned char c;

   for (s = d->seg + ((d->blocks) << 5); s; s+= 0x20) {
      if (*(unsigned short far *)((unsigned long)s << 16) == 0xAA55) {
         p = (unsigned char far *)((unsigned long)s << 16);
         c = 0;
         i = 0;
         do {
            c += p[i];
         } while (++i && i<512L*p[2]);
         if ((c & 255) == 0) goto found;
      }
   }
   d->seg = 0; d->blocks = 0; return;

   found: d->seg = s; d->blocks = p[2];

   copyrt(s, d->blocks, &(d->text), &(d->len));
}

static void yes_no(int a)
{
   scrputs(a ? " yes" : " no");
}

static void box(int left)
{
   register i;

   scrouts(left, 0, "╔══════════════════════════════════════╗");
   for (i=1; i<_bottom; i++) {
      scrgoto(left,    i); scrputc('║');
      scrgoto(left+39, i); scrputc('║');
   }
   scrouts(left, _bottom, "╚══════════════════════════════════════");
   scrpoke((BRIGHT<<8) | '╝');
}

static void pause(int flag)
{
   while (bioskey(1)) (void)bioskey(0);
   if (flag) {
      if (_cmostate >= 0) while (!bioskey(1)) cmostime(_l1,_cmostop,&_time);
   }
   (void)bioskey(0);
}

int main()
{
   register i, j;
   register unsigned long l;
   short left, row;
   struct VideoIdent vid[2];
   unsigned short _equip;
   struct _biosdef d;
   register unsigned short u, v;

   AskVideo(&_vinfo);
   if (_vinfo.vs_width < 80) {
      _l1 = _l2 = _vinfo.vs_width/2 - 20;
   } else {
      _l1 = (_l2 = _vinfo.vs_width/2) - 40;
   }
   _bottom  = _vinfo.vs_height - 1;
   _scrpage = _vinfo.vs_page;
   _cmostop = _vinfo.vs_height - 8;

   cursor(0);

   scrwipe(0, 0, _vinfo.vs_width-1, _bottom, BRIGHT);

   box(_l1);
   scrouts(_l1+13, 0, " Detect  v1.3 ");

   scrwipe(_l1+1, 1, _l1+38, _bottom-1, NORMAL);

   left = _l1+2; row = 1;

   mtype  (left, row++);
   cputype(left, row++);
   co_type(left, row++);

   VideoID(vid);
   scrouts(left, row++, "Video: ");
   onevideo(vid[0].VideoSubsystem, vid[0].VideoDisplay);
   if (vid[1].VideoSubsystem) {
      scrouts(left, row++, "   +   ");
      onevideo(vid[1].VideoSubsystem, vid[1].VideoDisplay);
   }

   _equip = biosequip();
   scrouts(left, row++, "Ports: ");
   scrputc(((_equip >>  9) & 7) | '0'); scrputs(" serial + ");
   scrputc(((_equip >> 14) & 3) | '0'); scrputs(" parallel");
   if (_equip & 0x1000) scrputs(" + game");

   scrouts(left, row++, "Conv.mem: ");
   put3d(biosmemory()); scrputs("K by BIOS, ");
   put3d(FindCMem());   scrputs("K found");

   scrouts(left, row++, "Display memory ");
   if (_vinfo.vs_segment) {
      scrputs("found: "); put3d(_vinfo.vs_blocks / 2);
      scrputs("K at ");   put4h(_vinfo.vs_segment);
   } else {
      scrputs("not found");
   }

   scrouts(left, row++, "BIOS ext memory");
   _AX = 0x8800; geninterrupt(0x15); i = _AX;
   _AX = 0x88FF; geninterrupt(0x15); j = _AX;
   if (i!=j) {
      scrputs(": unsupported");
   } else {
     put5d(i); scrputs("K reported");
   }

   if (expmem(left, row)) ++row;

   scrouts(_l1+11, row++, "BIOS drive report:");
   driverep(left, (i=row++), 0, drvsize(0));
   j = 0;
   if ((_equip & 0xC0) > 0x40) {/* floppies > 2 */
      driverep(_l1+14, i, 2, drvsize(2));
      if ((_equip & 0xC0) > 0x80) driverep(_l1+14, i+1, 3, drvsize(3));
      j = 1;
   }
   if ((l = drvsize(0x80)) > 0) {
      driverep(_l1+26, i, 0x80, l);
      if ((l = drvsize(0x81)) > 0) {
         driverep(_l1+26, i+1, 0x81, l);
         j = 1;
      }
   }
   if ((_equip & 0xC0) > 0) {/* second floppy found */
      if (j) driverep(left, i+1, 1, drvsize(1));
      else   driverep(_l1+14, i,  1, drvsize(1));
   }
   row += j;

   if (bootlab(left, row) >= 0) row++;

   scrwipe(_l1, _cmostop, _l1+39, _cmostop, BRIGHT);
   scrouts(_l1, _cmostop, "╟──────────────────────────────────────╢");
   _cmostate = cmos(_l1, _cmostop);

   if (_l1 == _l2) pause(TRUE);

   if (_l1==_l2) {
      scrouts(_l2, _cmostop, "║"); scrouts(_l2+39, _cmostop, "║");
   } else {
      box(_l2);
   }
   scrwipe(_l2+1, 1, _l2+38, _bottom-1, NORMAL);

   row = 1;

   scrouts(_l2+14, row++, "Chip Search:");

   scrwipe(_l2+14, row, _l2+16, row+2, BRIGHT);
   scrwipe(_l2+35, row, _l2+37, row+2, BRIGHT);

   scrouts(_l2+2,  row, "Slave DMA :");
   i = 0;
   do {
      u=inport(0xC0); v=inport(0xC2);
   } while (u==0xFFFF && v==0xFFFF && ++i<3);
   yes_no(u!=0xFFFF || v!=0xFFFF);

   scrouts(_l2+20, row, "  AT keyboard:");
   i = 0; do j=inportb(0x64); while (j==0xFF && ++i<3);
   yes_no(j!=0xFF);

   ++row;

   if ((i = conflags()) != -1) {
      scrwipe(_l2+2,  row, _l2+38, row, NORMAL);
      scrouts(_l2+10, row++, "BIOS feature flags:");
      scrouts(_l2+2,  row, "Slave 8259:");    yes_no(i & 0x40);
      scrouts(_l2+20, row, "Micro Channel:"); yes_no(i & 0x02);
      ++row;
   }

   ++row;
   scrwipe(_l2+1, row, _l2+38, row, BRIGHT);
   scrouts(_l2+2, row++, "Seg             Notice");
   scrouts(_l2+8, row++, "Main BIOS dated ");
   biosmain(&d); row += biosview(_l2+2, row, &d);

   u = d.seg; d.seg = 0xC000; d.blocks = 0;
   i = FALSE;
   do {
      biosext(&d); if (d.blocks == 0) continue;
      if (!i) {
         scrouts(_l2+12, row++, "BIOS extensions");
         i = TRUE;
      }
      if ((d.len ? (d.len+30)/31 : 1) >= _bottom-row) goto scroll;
      row += biosview(_l2+2, row, &d);
   } while (d.blocks && d.seg + (d.blocks << 5) < u);
   goto end;

   scroll: i = 1;
   do {
      j = d.len ? (d.len+30)/31 : 1;
      if (i+j >= _bottom) {
         pause(_l1 != _l2);
         i = 1;
      }
      scrolup(_l2+1, 1, _l2+38, _bottom, NORMAL, j);
      (void)biosview(_l2+2, _bottom-j, &d);
      biosext(&d);
   } while (d.blocks && d.seg + (d.blocks << 5) < u);

   end: pause(_l1 != _l2);

   scrwipe(0, 0, _vinfo.vs_width-1, _bottom, NORMAL);
   scrgoto(0, 0);
   cursor(1);
   return 0;
}
