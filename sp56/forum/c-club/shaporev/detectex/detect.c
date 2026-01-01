/* The program is written by Tim V.Shaporev */
/* and considered to be in a public domain  */

#define LOGGING

#include "procesor.h"
#include "console.h"
#include "detect.h"
#include "define.h"

#include <bios.h>
#include <dos.h>
#ifdef LOGGING
#	include <fcntl.h>
#	include <stdio.h>
#	include <io.h>
#endif

#ifndef DEBUG
	void _setenvp(void) {}
#endif

#define BCD(x)  (10*((x)>>4)+(x&15))
#define DATE(y,m,d)	(31*(12*((y)-1980)+(m))+(d))
#define TIME(h,m,s)	seconds((h),(m),(s))

#ifdef LOGGING
	static char logflag;

	static void newline(void)
	{
	   if (logflag) printf("\n");
	}

	static void dupputc(char c)
	{
	   scrputc(c); if (logflag) printf("%c", c);
	}

	static void dupputs(char *s)
	{
	   scrputs(s); if (logflag) printf("%s", s);
	}

	static void dupends(char *s)
        {
           scrputs(s); if (logflag) printf("%s\n", s);
        }

	static void dupouts(short x, short y, char *s)
        {
           scrouts(x,y,s); if (logflag) printf("          %s", s);
        }
#else
#	define newline()
#	define dupputc(c)	scrputc(c)
#	define dupputs(s)	scrputs(s)
#	define dupends(s)	scrputs(s)
#	define dupouts(x,y,s)	scrouts((x),(y),(s))
#endif

static char mainame[] = " Detect ";
static char version[] = " v1.5 ";

struct VideoSettings _vinfo;
char _l1, _l2, _bottom, _cmostop;
static long _time;
static _cmostate;

struct _biosdef { unsigned short seg, blocks, text, len; };

static void cursor(int k)
{
   _CX = k ? _vinfo.vs_cursor.x : NOCURSOR; _AH = 1; geninterrupt(0x10);
}

static long seconds(short h, short m, short s)
{
   return (60*(60*(long)(h)+(long)(m))+(long)(s));
}
static void put2h(int n)
{
   static char h[] = "0123456789ABCDEF";
   dupputc(h[n>>4]); dupputc(h[n&15]);
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

   dupouts(x, y, "  Machine type: ");

   i = b[14];
   j = b[15];
   d = DATE(DEC2(b[11], b[12])+1900, DEC2(b[5], b[6]), DEC2(b[8], b[9]));

   for (n=0; n<dim(db); n++) {
      if (db[n].id == i && (db[n].sub < 0 || db[n].sub == j) &&
         (db[n].date < 0 || d >= db[n].date)) {
         goto end;
      }
   }
end:
   if (n < dim(db)) {
      dupends(db[n].type);
   } else {
      put2h(i); dupputc('/'); put2h(j);
      dupends("h (unknown)");
   }
}

static void put3d(int n)
{
   dupputc(n < 100 ? ' ' : n/100+'0');
   dupputc(n / 10 % 10 + '0');
   dupputc(n % 10 + '0');
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
   char b[7];

   if (s >= VSYS_Any && s <= VSYS_VGA) {
      dupputs(IBMname[s]);
   } else if (s >= VSYS_HGC && s <= VSYS_InC) {
      dupputs(Hercname[s-VSYS_HGC]);
   } else if (s == VSYS_LCD) {
      dupputs("LCD (Model "); put3d(d); dupends(")");
      return;
   } else if (s == VSYS_Tandy) {
      dupends("Tandy 1000");
      return;
   } else if (s == VSYS_3270) {
      dupends("PC 3270");
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
      if (j>1) {
         if (j>0) dupputs(","); dupputs(" ");
      }
      b[5] = 'K'; b[6] = 0; dupputs(b+j);
      l = TRUE;
   } else {
      l = FALSE;
   }
   dupputs(" (");
   if (d>=VDEV_Any && d<=VDEV_cPS) {
      dupputs(Display[d]);
   } else {
      put2h(d);
   }
   if (!l) dupputs(" display");
   dupends(")");
}

static int vchipset(int left, int row, int adapter)
{
   register i = 0;

   if (adapter == VSYS_VGA && (i = VGAChipset()) != 0) {
      dupouts(left, row, "       ");
      switch (i) {
         case chipTSENG: dupends("(Tseng Labs chip set)"); break;
         case chipPARA : dupends("(Paradise chip set)");   break;
         case chipV7   : dupends("(Video 7 chip set)");    break;
         default       : dupends("(unknown chip set)");
      }
   }
   return i;
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
   for (i=0; i<j; i++) dupputc(' ');
   while (j<5) dupputc(b[j++]);
}

static int expmem(short x, short y)
{
   unsigned long l; union REGS r;

   l = (unsigned long)getvect(0x67);
   if (l!=0 && peekb((unsigned)(l>>16), (unsigned)l)!=0xCF) {
      /* non-trivial EMM vector found */
      r.x.dx = 0; r.h.ah = 0x42; int86(0x67, &r, &r);
      if (r.h.ah!=0x42 && r.x.dx!=0) {
         dupouts(x, y, "Expanded memory");
         put5d(r.x.dx<<4); dupends("K reported");
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
   r.x.cx = n & 0x80 ? 0 : 0x2708; /* dummy for ancient BIOS  */
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
   dupputc(n&0x80 ? 'H' : 'F');
   scrputs("D∙");
#ifdef LOGGING
   if (logflag) printf("D.");
#endif
   dupputc((n&7)|'0');
   dupputc(' ');
   if (s < 1000) {
      put3d((int)s); dupputc('K');
   } else {
      j = (unsigned)(s/1000);
      i = 5;
      do {
         b[--i] = j % 10 + '0';
         j /= 10;
      } while (j && i>0);
      while (i<5) dupputc(b[i++]);
      dupputc('.');
      dupputc(s % 1000 / 100 + '0');
      dupputc('M');
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
   dupouts(x, y, "Boot ID ");
   n = 0; do k = biosdisk(2, 0x80, h, t, s, 1, b); while (++n<3 && k);
   if (k || *(unsigned short *)(b+510)!=0xAA55) {
      dupends("- IO error");
      return 1;
   }
   dupputc('\'');
   for (n=0; n<8; n++) {
      scrpoke((NORMAL<<8)|b[n+3]);
      scrgoto(x+10+n, y);
#ifdef LOGGING
      if (logflag) printf("%c", b[n+3]>=' ' && b[n+3]<='~' ? b[n+3] : '.');
#endif
   }
   dupputc('\'');
   switch (i) {
      case 1: case 4: p = " DOS";           break;
      case 2: case 3: p = " XENIX";         break;
      case 6:         p = " DOS 4.+";       break;
      case 99:        p = " UNIX System V"; break;
      case 100:       p = " Netork";        break;
      case 117:       p = " PC/IX";         break;
      case 219:       p = " CP/M";          break;
      case 255:       p = " BBT";           break;
      default: dupputs(" Type "); put2h(i);
               dupends("h");      return 0;
   }
   dupends(p);
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
      put2h(h); dupputc(':'); put2h(m); dupputc(':'); put2h(s);
      *p = l;
   }
}

static void cmosflop(short x, short y, unsigned equip, int nflop)
{
   register unsigned j;

   scrgoto(x, y);
   if (!(equip & 1) || nflop > (equip >> 6)) {
      dupputs("none");
   } else {
      j = cmosbyte(0x10); j = nflop ? j&15 : j>>4;
      switch (j) {
         case 0 : dupputs("none"); break;
         case 1 : dupputs("360K"); break;
         case 2 : dupputs("1.2M"); break;
         case 3 : dupputs("720K"); break;
         case 4 : dupputs("1.4M"); break;
         default: dupputc('-');
                  dupputc(j>9 ? j+('A'-10) : j+'0');
                  dupputs("h-");
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

   scrgoto(x, y);
   if (!d) {
      dupputs("- unsupported -");
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

   dupputs("Type"); put3d(d);

   if (!s) return;

   s >>= 10;
   put5d((unsigned)(s / 1000));
   dupputc('.');
   dupputc((unsigned)(s % 1000) / 100 + '0');
   dupputc('M');
}

static int cmos(int left, int top)
{
   register i;
   unsigned short j, s;
   int retcode;

   dupouts(left+11, top+1, "CMOS ");

   for (j=cmosbyte(0x10), i=0x11; i<0x30 && cmosbyte(i)==j; i++) ;
   if (i >= 0x30) {
      dupends("not found");
      return ERROR;
   }
   for (i=0x10, s=0; i<0x2E; i++) s += cmosbyte(i);
   if (s != (j=(((unsigned)cmosbyte(0x2E)<<8) | (unsigned)cmosbyte(0x2F)))) {
      scrwipe(left+16, top+1, left+29, top+1, ITALIC+BLINK);
      scrgoto(left+16, top+1); dupends("checksum error");
      retcode = 1;
   } else {
      dupends("configuration");
      retcode = 0;
   }
   scrouts(left+2,  top+2, "Time&Date:     Floppy  Hard Drives");
   scrouts(left+15, top+3, "0:");
   scrouts(left+15, top+4, "1:");

#ifdef LOGGING
   if (logflag) printf("          Time: ");
#endif
   _time = 0;
   cmostime(left, top, &_time);

#ifdef LOGGING
   if (logflag) printf("\tDate: ");
#endif
   scrgoto(left+2, top+4);
   put2h(cmosbyte(8)); /* month */ dupputc('-');
   put2h(cmosbyte(7)); /* day   */ dupputc('-');
   dupputs ((j = cmosbyte(9)) >= 0x80 ? "19" : "20");
   put2h(j);           /* year  */
   newline();

   j = cmosbyte(0x14); /* equipment byte */
#ifdef LOGGING
   if (logflag) printf("          Floppy: ");
#endif
   cmosflop(left+18, top+3, j, 0);
#ifdef LOGGING
   if (logflag) printf("   ");
#endif
   cmosflop(left+18, top+4, j, 1);
   newline();
#ifdef LOGGING
   if (logflag) printf("          Disks : ");
#endif
   cmosdisk(left+23, top+3, 0);
#ifdef LOGGING
   if (logflag) printf("\t");
#endif
   cmosdisk(left+23, top+4, 1);
   newline();

   dupouts(left+20, top+5, "Co-processor: ");
   dupends(j&2 ? "here" : "none");

   dupouts(left+20, top+6, "Display: ");
   j &= 0x30;
   dupends( j==0x10 ? "CGA 40col" : j==0x20 ? "CGA 80col" :
            j==0x30 ? "TTL Mono" : "special");

   dupouts(left+2,top+5,"Base memory "); put3d(cmosword(0x15)); dupends("K");
   dupouts(left+2,top+6,"Ext.memory");   put5d(cmosword(0x17)); dupends("K");

   return retcode;
}

static int biosview(short x, short y, struct _biosdef *d)
{
   register i, j, n;
   register char far *p;

#ifdef LOGGING
   if (logflag) printf("          ");
#endif
   scrgoto(x, y); put4h(d->seg);
   p = (char far *)(((unsigned long)(d->seg) << 16) | (d->text));
   for (i=0, n=0; i<d->len && n<_bottom-y; n++) {
      scrgoto(x+5, y+n); for (j=0; i<d->len && j<31; ++i,j++) scrputc(p[i]);
   }
#ifdef LOGGING
   if (logflag) {
      printf(" ");
      for (i=0, n=0; i<d->len && n<_bottom-y; n++) {
         for (j=0; i<d->len && j<55; ++i,j++) printf("%c", p[i]);
         if (i<d->len) printf("\n          %s", "     ");
      }
      newline();
   }
#endif
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
             (p[i+2]=='p' || p[i+2]=='P')) goto notice;
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
   for (i=0; i<8; i++) dupputc(p[i]);
   newline();

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
   dupputs(a ? " yes" : " no");
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
   scrpoke((BORDER<<8) + BR_CHAR);
}

static void pause(int flag)
{
#ifdef LOGGING
   register char saveflag;
#endif
   scrgoto (0, _vinfo.vs_height); while (keyserv(1)) (void)keyserv(0);
   if (flag  && _cmostate >= 0) {
#ifdef LOGGING
      saveflag = logflag; logflag = FALSE;
#endif
      while (!keyserv(1)) {
         cmostime(_l1,_cmostop,&_time); scrgoto (0, _vinfo.vs_height);
      }
#ifdef LOGGING
      logflag = saveflag;
#endif
   }
   scrgoto (0, _vinfo.vs_height); (void)keyserv(0);
}

main(argc, argv)
char *argv[];
{
   register i, j;
   register unsigned long l;
   short left, row;
   struct VideoIdent vid[2];
   unsigned short _equip;
   struct _biosdef d;
   register unsigned short u, v;
   int cpu_type, ndp_type;
   static char *cpu_name[] = {
      "Intel 8086",  "Intel 8088", "NEC V20", "NEC V30",
      "Intel 80186", "Intel 80188", "Intel 80286",
      "Intel 80386", "Intel 80386SX", "Intel 80386DX",
      "Intel 80486", "Intel 80486SX",
   };
   static char *ndp_name[] = {
      "(none)",
      "Intel 8087",
      "Intel 80287",
      "Intel 80287XL/T or 80C287A",
      "Intel 80387",
      "Intel 80387SX",
      "Intel 80387DX",
   };

   colorset(argc, argv);
   AskVideo(&_vinfo);
   if (_vinfo.vs_width < 80) {
      _l1 = _l2 = _vinfo.vs_width/2 - 20;
   } else {
      _l1 = (_l2 = _vinfo.vs_width/2) - 40;
   }
   _bottom  = _vinfo.vs_height - 1;
/* _scrpage = _vinfo.vs_page; */
   _cmostop = _vinfo.vs_height - 8;
#ifdef LOGGING
   logflag = !((i = ioctl(fileno(stdout), 0)) & 128 && i & 6);
#endif
   cursor(0);

   scrwipe(0, 0, _vinfo.vs_width-1, _bottom, BORDER);

   box(_l1);
   scrouts(_l1+13, 0, mainame); scrputs(version);
#ifdef LOGGING
   if (logflag) {
      (void)printf("\n          ----------%s\t\t\t%s\t    ----------\n",
                    mainame, version);
   }
#endif

   scrwipe(_l1+1, 1, _l1+38, _bottom-1, NORMAL);

   left = _l1+2; row = 1;

   mtype(left, row++);

   /* determine and output central and numeric processors info */
   cpu_type = processors();
   ndp_type = cpu_type >> 8;
   i        = cpu_type & 0x80; /* protection flag */
   cpu_type &= 127;
   j        = Is_Weitek();

   dupouts(left, row++, "Main processor: ");
   dupputs(cpu_type >= 0 && cpu_type < dim(cpu_name) ?
           cpu_name[cpu_type] : "(unknown)");
   if (i) dupputs(" (priv)");
   newline();
   if (cpu_type != cpu80486 || j) {
      dupouts(left, row++, "  Co-processor: ");
      if (j) {
         if (ndp_type > 0 && ndp_type < dim(ndp_name)) {
            dupputs(ndp_type == ndpXL287 ?
                    "Intel 80287XL" : ndp_name[ndp_type]);
            dupputs(" & ");
         }
         dupputs("Weitek");
      } else {
         dupputs(ndp_type < 0 || ndp_type >= dim(ndp_name) ?
                 "(unknown)" : ndp_name[ndp_type]);
      }
      newline();
   }

   VideoID(vid);
   dupouts(left, row++, "Video: ");
   onevideo(vid[0].VideoSubsystem, vid[0].VideoDisplay);
   if ((i = vchipset(left, row, vid[0].VideoSubsystem)) != 0) ++row;
   if (vid[1].VideoSubsystem) {
      dupouts(left, row++, "   +   ");
      onevideo(vid[1].VideoSubsystem, vid[1].VideoDisplay);
      if (!i && vchipset(left, row, vid[1].VideoSubsystem)) ++row;
   }

   _equip = biosequip();
   dupouts(left, row++, "Ports: ");
   dupputc(((_equip >>  9) & 7) | '0'); dupputs(" serial + ");
   dupputc(((_equip >> 14) & 3) | '0'); dupputs(" parallel");
   if (_equip & 0x1000) dupputs(" + game");
   newline();

   dupouts(left, row++, "Conv.mem: ");
   put3d(biosmemory()); dupputs("K by BIOS, ");
   put3d(FindCMem());   dupends("K found");

   dupouts(left, row++, "Display memory ");
   if (_vinfo.vs_segment) {
      dupputs("found: "); put3d(_vinfo.vs_blocks / 2);
      dupputs("K at ");   put4h(_vinfo.vs_segment);
      newline();
   } else {
      dupends("not found");
   }

   dupouts(left, row++, "BIOS ext.memory");
   _AX = 0x8800; geninterrupt(0x15); i = _AX;
   _AX = 0x88FF; geninterrupt(0x15); j = _AX;
   if (i!=j) {
      dupends(": unsupported");
   } else {
     put5d(i); dupends("K reported");
   }
   if (expmem(left, row)) { ++row; newline(); }

   if (cpu_type > cpu80286) {
      dupouts(left, row++, "SRAM cache ");
      if ((i = Is_Cache()) > 0) {
         dupputs("size"); put5d(i); dupends("K or more");
      } else {
         dupends("not found");
      }
   }

   dupouts(_l1+11, row++, "BIOS drive report: ");
   driverep(left, (i=row++), 0, drvsize(0));
   j = 0;
   if ((_equip & 0xC0) > 0x40) {/* floppies > 2 */
#ifdef LOGGING
      if (logflag) printf("   ");
#endif
      driverep(_l1+14, i, 2, drvsize(2));
      if ((_equip & 0xC0) > 0x80) {
#ifdef LOGGING
         if (logflag) printf("   ");
#endif
         driverep(_l1+14, i+1, 3, drvsize(3));
      }
      j = 1;
   }
   if ((l = drvsize(0x80)) > 0) {
#ifdef LOGGING
      if (logflag) printf("   ");
#endif
      driverep(_l1+26, i, 0x80, l);
      if ((l = drvsize(0x81)) > 0) {
#ifdef LOGGING
         if (logflag) printf("   ");
#endif
         driverep(_l1+26, i+1, 0x81, l);
         j = 1;
      }
   }
   newline();
   if ((_equip & 0xC0) > 0) {/* second floppy found */
#ifdef LOGGING
      if (logflag) printf("%-*s", 10+19, "");
#endif
      if (j) driverep(left,  i+1, 1, drvsize(1));
      else   driverep(_l1+14, i,  1, drvsize(1));
   }
   row += j;
   newline();

   if (bootlab(left, row) >= 0) { row++; newline(); }

   scrwipe(_l1, _cmostop, _l1+39, _cmostop, BORDER);
   scrouts(_l1, _cmostop, "╟──────────────────────────────────────╢");
   _cmostate = cmos(_l1, _cmostop);
   newline();

   if (_l1 == _l2) pause(TRUE);

   if (_l1==_l2) {
      scrouts(_l2, _cmostop, "║"); scrouts(_l2+39, _cmostop, "║");
   } else {
      box(_l2);
   }
   scrwipe(_l2+1,     1,     _l2+38, _bottom-2, NORMAL);
   scrwipe(_l2+1, _bottom-1, _l2+38, _bottom-1, BRIGHT);

   row = 1;

   dupouts(_l2+14, row++, "Chip Search: ");

   scrwipe(_l2+14, row, _l2+16, row+2, BRIGHT);
   scrwipe(_l2+35, row, _l2+37, row+2, BRIGHT);

   scrgoto(_l2+2,  row); dupputs("Slave DMA :");
   i = 0;
   do {
      u=inport(0xC0); v=inport(0xC2);
   } while (u==0xFFFF && v==0xFFFF && ++i<3);
   yes_no(u!=0xFFFF || v!=0xFFFF);
#ifdef LOGGING
   if (logflag) printf("\t");
#endif

   scrgoto(_l2+20, row); dupputs("  AT keyboard:");
   i = 0; do j=inportb(0x64); while (j==0xFF && ++i<3);
   yes_no(j!=0xFF);

   ++row; newline();

   if ((i = conflags()) != -1) {
      scrwipe(_l2+2,  row, _l2+38, row, NORMAL);
      scrouts(_l2+10, row++, "BIOS feature flags:");
#ifdef LOGGING
      if (logflag) printf("          %s", "BIOS flags : ");
#endif
      scrgoto(_l2+2,  row); dupputs("Slave 8259:");    yes_no(i & 0x40);
#ifdef LOGGING
   if (logflag) printf("\t");
#endif
      scrgoto(_l2+20, row); dupputs("Micro Channel:"); yes_no(i & 0x02);
      ++row; newline();
   }

   ++row; newline();
   scrwipe(_l2+1, row, _l2+38, row, BRIGHT);
   dupouts(_l2+2, row++, "Seg             Notice"); newline();
   dupouts(_l2+2, row++, "      Main BIOS dated ");
   biosmain(&d); row += biosview(_l2+2, row, &d);

   u = d.seg; d.seg = 0xC000; d.blocks = 0;
   i = FALSE;
   do {
      biosext(&d); if (d.blocks == 0) continue;
      if (!i) {
         dupouts(_l2+2, row++, "          BIOS extensions"); newline();
         i = TRUE;
      }
      if ((d.len ? (d.len+30)/31 : 1) >= _bottom-2-row) goto scroll;
      row += biosview(_l2+2, row, &d);
   } while (d.blocks && d.seg + (d.blocks << 5) < u);
   goto end;

   scroll: i = 1;
   do {
      j = d.len ? (d.len+30)/31 : 1;
      if (i+j >= _bottom-2) {
         scrouts(_l2+12, _bottom-1, "Press any key...");
         pause(_l1 != _l2);
         i = 1;
      }
      scrolup(_l2+1, 1, _l2+38, _bottom, NORMAL, j);
      (void)biosview(_l2+2, _bottom-j, &d);
      biosext(&d);
   } while (d.blocks && d.seg + (d.blocks << 5) < u);

end:
   scrouts(_l2+12, _bottom-1, "Press any key...");
   pause(_l1 != _l2);

   scrwipe(0, 0, _vinfo.vs_width-1, _bottom, EMPTY);
   scrgoto(0, 0);
   cursor(1);
   return 0;
}
