/* The program is written by Tim V.Shaporev */
/* and considered to be in a public domain  */

#define LOGGING
#ifdef LOGGING
#	include <stdio.h>
#	include <io.h>
#endif

#ifdef __TURBOC__
#   include <alloc.h>
#else
#   include <malloc.h>
#endif
#include <string.h>

#include "console.h"
#include "define.h"

#ifndef DEBUG
	void _setenvp() {}
	void atof    () {}
#endif

static char mainame[] = " Rating Measurement ";
static char version[] = " v1.1 ";

static short _left = 2, _bottom = 24, _last = 23, _row = 0, _middle = 12, _l2;
static struct VideoSettings _vinfo;

static void newline(void)
{
   if (_row >= _last) {
      scrolup(_left+2, 1, _left+38, _last, NORMAL, 1);
   } else {
      ++_row;
   }
   scrgoto(_left+2, _row);
}

static void scrnumb(int l, int n)
{
   register i; char b[5];
   i = 5;
   do {
      b[--i] = (char)(n % 10 + '0');
   } while (i>0 && (n /= 10)!=0);
   while (5-i < l--) scrputc(' ');
   while (i<5) scrputc(b[i++]);
}

static void percent(double a, double b)
{
   register i;

   if ((a = 100 * a/b) >= 99999.5) {
      scrputs("*****");
   } else if (a >= 9.5) {
      scrnumb(5, (int)(a+0.5));
   } else {
      scrputc(' '); scrputc((char)((i = (int)(a+=0.05)) + '0'));
      scrputc('.'); scrputc((char)((int)(10*(a-i)) + '0'));
   }
   scrputc('%');
}

static void printick(double a)
{
   register i;

   if (a >= 99999.5) {
      scrputs(" **** ");
   } else if (a >= 99.5) {
      scrnumb(5, (int)(a+0.5));
      scrputc(' ');
   } else if (a >= 9.5)  {
      scrnumb(3, (i = (int)(a+=0.05)));
      scrputc('.');
      scrputc((char)((int)(10*(a-i)) + '0'));
      scrputc(' ');
   } else if (a >= 0.0095) {
      a = a+0.005;  i = (int)a; scrnumb(2, i);
      scrputc('.');
      a = 10*(a-i); i = (int)a; scrputc((char)(i+'0'));
      a = 10*(a-i); i = (int)a; scrputc((char)(i+'0'));
      scrputc(' ');
   } else {
      scrputs(" 0.00");
      i = (int)(1000*a+0.5); scrputc((char)(i+'0'));
   }
}

#define NTEST 100
#define NLOOP 1000
#define NLNDP 100
#define BIOS  ((0xFFFF - 4*NLOOP/16) & ~15) /* 0xFC00 */

/* Access times for standard AT (in microseconds) */
#define AT_CPU 0.125
#define AT_NDP 0.125
#define AT_MEM 0.401
#define AT_EMS 0.402
#define AT_ROM 0.401
#define AT_VID 2.415
#define AT_COM 0.403

static cpuflag, ndpflag, x88flag, minwait;
static unsigned core, vmem, emem;
static handle;

static double cputick, ndptick;
static double insbyte, insword, inslong, instest,
              rdmbyte, rdmword, rdmlong, wrmbyte, wrmword, wrmlong,
              rdebyte, rdeword, rdelong, wrebyte, wreword, wrelong,
              rombyte, romword, romlong, vidbyte, vidword, vidlong;

int      find87  (void);
int      cputype (void);
unsigned rep_mul (int);
unsigned rep_cld (int);
unsigned repmovr (int);
unsigned repmovsb(int, unsigned, unsigned);
unsigned repmovsw(int, unsigned, unsigned);
unsigned reppusha(int);
unsigned repstosb(int, unsigned);
unsigned repstosw(int, unsigned);
unsigned repfdiv (int);
unsigned repmovim(int);
unsigned repushla(int);
unsigned repmovsd(int, unsigned, unsigned);
unsigned repstosd(int, unsigned);
unsigned rep_daa (int);
unsigned mempusha(int, unsigned);
unsigned mempushl(int, unsigned);
void     endems  (int);
void     cursor  (unsigned);
unsigned long getems(void);

static void test_x86(void)
{
   register i;

   cputick = 0;
   for (i=0; i<NTEST; i++) {
      cputick += (((118L * NLOOP) + (16 * NLOOP / 100) + 31) * 1.19318) /
                 rep_mul(NLOOP);
   }
   cputick = NTEST / cputick;

   insbyte = insword = instest = 0;
   for (i=0; i<NTEST; i++) {
      insbyte += NLOOP / (rep_cld(NLOOP) / 1.19318 -
                          (16 * NLOOP / 100 + 31) * cputick);
      insword += NLOOP / (repmovr(NLOOP) / 1.19318 -
                          (16 * NLOOP / 100 + 31) * cputick);
      inslong += NLOOP / (repmovim(NLOOP) / 1.19318 -
                          (16 * NLOOP / 100 + 31) * cputick);
      instest += NLOOP / (rep_daa(NLOOP) / 1.19318 -
                          (16 * NLOOP / 100 + 31) * cputick);
   }
   insbyte = NTEST / insbyte; insword = NTEST / insword;
   inslong = NTEST / inslong; instest = NTEST / instest;

   if (ndpflag) {
      ndptick = 0;
      for (i=0; i<NTEST; i++) {
         ndptick += NLNDP /((repfdiv(NLNDP) / 1.19318 - 200 * cputick) / 197);
      }
      ndptick = NTEST / ndptick;
   }
   x88flag = insbyte > 0.9*instest;
}

static void test_286(void)
{
   register i;

   cputick = 0;
   for (i=0; i<NTEST; i++) {
      cputick += (((21.0 * NLOOP) + (14 * NLOOP / 100) + 15.0) * 1.19318) /
                 rep_mul(NLOOP);
   }
   cputick = NTEST / cputick;

   insbyte = insword = rdmbyte = rdmword =
   wrmbyte = wrmword = rombyte = romword =
   vidbyte = vidword = 0;
   for (i=0; i<NTEST; i++) {
      insbyte += NLOOP / (rep_cld(NLOOP) / 1.19318 -
                          (14 * NLOOP / 100 + 15) * cputick);
      insword += NLOOP / (repmovr(NLOOP) / 1.19318 -
                          (14 * NLOOP / 100 + 15) * cputick);
      inslong += NLOOP / (repmovim(NLOOP) / 1.19318 -
                          (14 * NLOOP / 100 + 15) * cputick);
      rdmbyte += NLOOP * 1.19318 / repmovsb(NLOOP, core, core);
      rombyte += NLOOP * 1.19318 / repmovsb(NLOOP, BIOS, core);
      wrmword += NLOOP / (reppusha(NLOOP) / 1.19318 -
                          (9 * NLOOP / 200 + 15) * cputick);
      rdmword += NLOOP * 1.19318 / repmovsw(NLOOP, core, core);
      romword += NLOOP * 1.19318 / repmovsw(NLOOP, BIOS, core);
      if (emem) {
         rdebyte += NLOOP * 1.19318 / repmovsb(NLOOP, emem, emem);
         wreword += NLOOP / (mempusha(NLOOP, emem) / 1.19318 -
                             (9 * NLOOP / 200 + 15) * cputick);
         rdeword += NLOOP * 1.19318 / repmovsw(NLOOP, emem, emem);
      }
      vidbyte += NLOOP * 1.19318 / repstosb(NLOOP, vmem);
      vidword += NLOOP * 1.19318 / repstosw(NLOOP, vmem);
   }
   insbyte = NTEST/insbyte; insword = NTEST/insword; inslong = NTEST/inslong;
   rdmbyte = NTEST/rdmbyte; rdmword = NTEST/rdmword;
   rombyte = NTEST/rombyte; romword = NTEST/romword;
                            wrmword = NTEST/wrmword;
   if (emem) {
      rdebyte=NTEST/rdebyte; rdeword=NTEST/rdeword; wreword=NTEST/wreword;
   }
   vidbyte = NTEST/vidbyte; vidword = NTEST/vidword;

   wrmword -= insword / 16;
   if (3.375 * cputick > wrmword) wrmword -= cputick / 8;
   wrmbyte =  rdmbyte * wrmword / rdmword;
   rdmbyte -= wrmbyte;
   rdmword -= wrmword;
   rombyte -= wrmbyte;
   romword -= wrmword;
   if (emem) {
      wreword -= insword / 16;
      if (3.375 * cputick > wreword) wreword -= cputick / 8;
      wrebyte =  rdebyte * wreword / rdeword;
      rdebyte -= wrebyte;
      rdeword -= wreword;
   }

   if (ndpflag) {
      ndptick = 0;
      for (i=0; i<NTEST; i++) {
         ndptick += NLNDP / ((repfdiv(NLNDP) / 1.19318 - 900*cputick) / 203);
      }
      ndptick = NTEST / ndptick;
   }
   /* dummy */
   rdmlong = 2 * rdmword;
   wrmlong = 2 * wrmword;
   rdelong = 2 * rdeword;
   wrelong = 2 * wreword;
   romlong = 2 * romword;
   vidlong = 2 * vidword;
}

static void test_386(void)
{
   register i;

   cputick = 0;
   for (i=0; i<NTEST; i++) {
      cputick += (((25.0 * NLOOP) + (14 * NLOOP / 100) + 15.0) * 1.19318) /
                 rep_mul(NLOOP);
   }
   cputick = NTEST / cputick;

   insbyte = insword = inslong =
   rdmbyte = rdmword = rdmlong =
   wrmbyte = wrmword = wrmlong =
   rombyte = romword = romlong =
   vidbyte = vidword = vidlong = 0;
   for (i=0; i<NTEST; i++) {
      insbyte += NLOOP / (rep_cld (NLOOP) / 1.19318 -
                          (14 * NLOOP / 100 + 15) * cputick);
      insword += NLOOP / (repmovr (NLOOP) / 1.19318 -
                          (14 * NLOOP / 100 + 15) * cputick);
      inslong += NLOOP / (repmovim(NLOOP) / 1.19318 -
                          (14 * NLOOP / 100 + 15) * cputick);
      rdmbyte += NLOOP * 1.19318 / repmovsb(NLOOP, core, core);
      rombyte += NLOOP * 1.19318 / repmovsb(NLOOP, BIOS, core);
      wrmword += NLOOP / (reppusha(NLOOP) / 1.19318 -
                          (9 * NLOOP / 200 + 15) * cputick);
      wrmlong += NLOOP / (repushla(NLOOP) / 1.19318 -
                          (9 * NLOOP / 200 + 15) * cputick);
      rdmword += NLOOP * 1.19318 / repmovsw(NLOOP, core, core);
      romword += NLOOP * 1.19318 / repmovsw(NLOOP, BIOS, core);
      rdmlong += NLOOP * 1.19318 / repmovsd(NLOOP, core, core);
      romlong += NLOOP * 1.19318 / repmovsd(NLOOP, BIOS, core);
      if (emem) {
         rdebyte += NLOOP * 1.19318 / repmovsb(NLOOP, emem, emem);
         wreword += NLOOP / (mempusha(NLOOP, emem) / 1.19318 -
                             (9 * NLOOP / 200 + 15) * cputick);
         wrelong += NLOOP / (mempushl(NLOOP, emem) / 1.19318 -
                             (9 * NLOOP / 200 + 15) * cputick);
         rdeword += NLOOP * 1.19318 / repmovsw(NLOOP, emem, emem);
         rdelong += NLOOP * 1.19318 / repmovsd(NLOOP, emem, emem);
      }
      vidbyte += NLOOP * 1.19318 / repstosb(NLOOP, vmem);
      vidword += NLOOP * 1.19318 / repstosw(NLOOP, vmem);
      vidlong += NLOOP * 1.19318 / repstosd(NLOOP, vmem);
   }
   insbyte = NTEST/insbyte; insword = NTEST/insword; inslong = NTEST/inslong;
   rdmbyte = NTEST/rdmbyte; rdmword = NTEST/rdmword; rdmlong = NTEST/rdmlong;
   rombyte = NTEST/rombyte; romword = NTEST/romword; romlong = NTEST/romlong;
   wrmword = NTEST/wrmword; wrmlong = NTEST/wrmlong;
   if (emem) {
      rdebyte=NTEST/rdebyte; rdeword=NTEST/rdeword; rdelong=NTEST/rdelong;
      wreword=NTEST/wreword; wrelong=NTEST/wrelong;
   }
   vidbyte = NTEST/vidbyte; vidword = NTEST/vidword; vidlong = NTEST/vidlong;

   wrmword -= insword / 16;
   wrmlong -= insword / 8;
   if (3.375 * cputick > wrmword) wrmword -= cputick;
   if (3.375 * cputick > wrmlong) wrmlong -= cputick;
   wrmbyte = rdmbyte * wrmword / rdmword;
   rdmbyte -= wrmbyte;
   rdmword -= wrmword;
   rdmlong -= wrmlong;
   rombyte -= wrmbyte;
   romword -= wrmword;
   romlong -= wrmlong;
   if (emem) {
      wreword -= insword / 16;
      wrelong -= insword / 8;
      if (3.375 * cputick > wreword) wreword -= cputick;
      if (3.375 * cputick > wrelong) wrelong -= cputick;
      wrebyte = rdebyte * wreword / rdeword;
      rdebyte -= wrebyte;
      rdeword -= wreword;
      rdelong -= wrelong;
   }

   if (ndpflag) {
      ndptick = 0;
      for (i=0; i<NTEST; i++) {
         ndptick += NLNDP / ((repfdiv(NLNDP) / 1.19318 - 900 * cputick) / 200);
      }
      ndptick = NTEST / ndptick /* this is simply dirty fitting */ * 25 / 12;
   }
}

static void prtime(char *n, double b, double w, double l, double e)
{
   register i;

   newline();
   for (i=0; i<12 && n[i]; i++) scrputc(n[i]);
   while (i++ < 12) scrputc(' ');

   printick(b); printick(w);
   if (cpuflag < 3) scrputs("      "); else printick(l);
   percent(e, w);
}

static void prstat(char *n, double b, double w, double l)
{
   double *m; register i;

   newline();
   for (i=0; i<13 && n[i]; i++) scrputc(n[i]);
   while (i++ < 13) scrputc(' ');
   if (0.66*l < w && 1.33*l > w) {
      scrputs("  long   "); m = &l;
   } else if (2*w > 0.66*l && 2*w < 1.33*l && 0.66*w < b && 1.33*w > b) {
      scrputs("  word   "); m = &w;
   } else if (2*b > 0.66*w && 2*b < 1.33*w) {
      scrputs("  byte   "); m = &b;
   } else {
      scrputs("something"); m = &b;
   }
   if ((i = (int)(*m / cputick - minwait)) < 0) i = 0;
   scrputs("   "); scrnumb(2, i);
}

static unsigned readkey(void)
{
   scrgoto(0, _vinfo.vs_width); return keyserv(4);
}

static int _done(int k)
{
   scrgoto(0, 0);
   scrwipe(0, 0, _vinfo.vs_width-1, _vinfo.vs_height-1, EMPTY);
   cursor(_vinfo.vs_cursor.x);
   return k;
}

static int done(int k)
{
   (void)readkey(); return _done(k);
}

static void box(int left)
{
   register i;

   scrwipe(left, 0, left+39, _bottom, BORDER);
   scrouts(left, 0, "╔══════════════════════════════════════╗");
   for (i=1; i<_bottom; i++) {
      scrouts(left,    i, "║");
      scrouts(left+39, i, "║");
   }
   scrouts(left, _bottom, "╚══════════════════════════════════════");
   scrpoke((BORDER << 8) | 188 /* '╝' */);
   scrwipe(left+1, 1, left+38, _last, NORMAL);
}

static void perbar(short y, char *name, double t, double a, double m)
{
   register i;

   scrwipe(_l2+6, y, _l2+6, y+3, BRIGHT);
   scrouts(_l2+6,  y,  "│");
   scrouts(_l2+6, y+1, "│");
   scrouts(_l2+6, y+2, "┤");
   scrouts(_l2+6, y+3, "│");
   scrouts(_l2+(7-strlen(name))/2, y+2, name);

   i = (int)(31*a/t/m + 0.5);

   scrgoto(_l2+7 + (i > 29 ? 25 : i < 4 ? 0 : i-4), y+1);
   percent(a, t);

   scrwipe(_l2+7, y+2, _l2+38, y+2, BRIGHT);
   scrgoto(_l2+7, y+2); while (i-- > 0) scrputc(219);

   i = (int)(31/m + 0.5);
/* scrwipe(_l2+7, y+3, _l2+7+i-1, y+3, INVERT); */
   scrgoto(_l2+7, y+3); while (i-- > 0) scrputc(177);
}

#ifdef LOGGING
static void prlog(char *n, double b, double w, double l, double a)
{
   register i;
   register double *m;
   register char *s;

   if (0.66*l < w && 1.33*l > w) {
      m = &l; s = "  long";
   } else if (2*w > 0.66*l && 2*w < 1.33*l && 0.66*w < b && 1.33*w > b) {
      m = &w; s = "  word";
   } else if (2*b > 0.66*w && 2*b < 1.33*w) {
      m = &b; s = "  byte";
   } else {
      m = &b; s = "something"; m = &b;
   }
   if ((i = (int)(*m / cputick - minwait)) < 0) i = 0;
   printf("          %-12s  %5.2f  %5.2f  %5.2f  %4.0f%%    %-9s   %2d\n",
          n, b, w, l, 100*a/w, s, i);
}
#endif

main(argc, argv)
char *argv[];
{
   register char *p; register char far *q;
   register unsigned long l;
   register i; double d, m;
   static char *cpuname[] = {" 808", "8018", "8028", "8038"};

   colorset(argc, argv);
   AskVideo(&_vinfo);
   _middle = _vinfo.vs_height / 2;
   if (_vinfo.vs_width >= 80) {
      _left = (_l2 = _vinfo.vs_width / 2) - 40;
   } else {
      _left = (_l2 = _vinfo.vs_width / 2 - 20);
   }
   _last   = (_bottom = _vinfo.vs_height - 1) - 1;
   _row    = 1;
   cursor(NOCURSOR);

   p = malloc(4 * NLOOP + 15);
   if (!p) {
      scrwipe(0, 0, _vinfo.vs_width-1, _bottom, ITALIC);
      scrouts(_vinfo.vs_width/2-8, _middle, "\007No enough memory");
      return done(-1);
   }

   scrwipe(0, 0, _vinfo.vs_width-1, _bottom, BRIGHT+BLINK);
   scrouts(_vinfo.vs_width/2-10, _middle, "One moment please...");

   q = (char far *)(p + 15);
   core = (unsigned)((unsigned long)q >> 16) + ((unsigned)q >> 4);
/* core = FP_SEG(q) + (FP_OFF(q) >> 4); */

   ndpflag = find87();
   cpuflag = cputype();
/* vmem    = (_vinfo.vs_segment + 32*_vinfo.vs_blocks - 4*NLOOP/16)&0xFFC0; */
   vmem    = _vinfo.vs_segment;
   if (_vinfo.vs_blocks >= 8+(4*NLOOP+511)/512) vmem += 0x100;
   emem    = (unsigned)(l = getems()); handle  = (int)(l >> 16);
   x88flag = 0;

   switch (cpuflag) {
      case 0 :
      case 1 : minwait = 4; test_x86(); break;
      case 2 : minwait = 2; test_286(); break;
      case 3 : minwait = 2; test_386(); break;
      default: scrwipe(0, 0, _vinfo.vs_width-1, _bottom, ITALIC);
               scrouts(_vinfo.vs_width/2-15, _middle,
                       "\007Unsupported CPU type");
               return done(-1);
   }

   if (emem) endems(handle);

   box(_left); scrouts(_left+7, 0, mainame); scrputs(version);

   newline(); scrputs("       Percentages realate to");
   newline(); scrputs("      IBM AT model 339 (8 MHz) ──┐");
   newline(); scrouts(_left+35, _row, "\037");

   newline();
   scrputs(cpuname[cpuflag]);
   scrputc((char)(x88flag ? '8' : '6'));
   scrputs(" CPU clock rate:");
   printick(1/cputick);
   scrputs("MHz");
   percent(AT_CPU, cputick);

   if (ndpflag) {
      newline(); scrputs("Math unit clock rate:");
      printick(1/ndptick);
      scrputs("MHz");
      percent(AT_NDP, ndptick);
   }

   i = (int)(d = insword / cputick);
   newline(); scrputs("Refresh overhead:"); percent(d-i, /* (double)i */ d);

   newline();
   newline(); scrputs("             Access time (\346s)");
   newline(); scrputs("             byte  word  long  Speed");
   newline(); scrputs("Instruction:");
   printick(insbyte);
   printick(insword);
   printick(inslong);
   percent (AT_COM, insword);

   if (cpuflag >= 2) {
      prtime("RAM read:",     rdmbyte, rdmword, rdmlong, AT_MEM);
      prtime("RAM write:",    wrmbyte, wrmword, wrmlong, AT_MEM);
      if (emem) {
         prtime("EMS read:",  rdebyte, rdeword, rdelong, AT_EMS);
         prtime("EMS write:", wrebyte, wreword, wrelong, AT_EMS);
      }
      prtime("ROM read:",     rombyte, romword, romlong, AT_ROM);
      prtime("Video write:",  vidbyte, vidword, vidlong, AT_VID);

      newline();
      newline(); scrputs("             Access by   W/S\n");
      prstat("RAM read:",     rdmbyte, rdmword, rdmlong);
      prstat("RAM write:",    wrmbyte, wrmword, wrmlong);
      if (emem) {
         prstat("EMS read:",  rdebyte, rdeword, rdelong);
         prstat("EMS write:", wrebyte, wreword, wrelong);
      }
      prstat("ROM read:",     rombyte, romword, romlong);
      prstat("Video write:",  vidbyte, vidword, vidlong);
   }

#ifdef LOGGING
   if (!((i = ioctl(fileno(stdout), 0)) & 128 && i & 6)) {
      printf("\n          ----------%s\t%s\t    ----------\n",
                    mainame, version);
      printf("          Percentages realate to IBM AT model 339\n");
      printf("          %s%c CPU clock rate: %5.2g MHz    %4.0f%%\n",
             cpuname[cpuflag], (char)(x88flag ? '8' : '6'),
             1/cputick, 100*AT_CPU/cputick);
      if (ndpflag) {
         printf("          Math unit clock rate:  %5.2g MHz    %4.0f%%\n",
                1/ndptick, 100*AT_NDP/ndptick);
      }
      i = (int)(d = insword / cputick);
      printf("          Refresh overhead: %4.0f%%\n", 100*(d-i)/d);
      printf("                          Access time (us)\n");
      printf("                         byte   word   long   Speed   Access by   W/S\n");
      prlog("Instruction:",  insbyte, insword, inslong, AT_COM);
      if (cpuflag >= 2) {
         prlog("RAM read:",     rdmbyte, rdmword, rdmlong, AT_MEM);
         prlog("RAM write:",    wrmbyte, wrmword, wrmlong, AT_MEM);
         if (emem) {
            prlog("EMS read:",  rdebyte, rdeword, rdelong, AT_EMS);
            prlog("EMS write:", wrebyte, wreword, wrelong, AT_EMS);
         }
         prlog("ROM read:",     rombyte, romword, romlong, AT_ROM);
         prlog("Video write:",  vidbyte, vidword, vidlong, AT_VID);
      }
   }
#endif

   if (_left == _l2) {
      if ((readkey() & 255) == 27) return _done(0);
   }

   box(_l2);

   rdmword = (rdmword + wrmword) / 2;

   m = 1; /* Max ratio */
   if       ((d = AT_CPU / cputick) > m) m = d;
   if (ndpflag) {
      if    ((d = AT_NDP / ndptick) > m) m = d;
   }
   if (cpuflag >= 2) {
      if    ((d = AT_MEM / rdmword) > m) m = d;
      if (emem) {
         rdeword = (rdeword + wreword) / 2;
         if ((d = AT_EMS / rdeword) > m) m = d;
      } else {
         if ((d = AT_ROM / romword) > m) m = d;
      }
      if    ((d = AT_VID / vidword) > m) m = d;
   }
   _row = 1;
                  perbar(_row,  "CPU",  cputick, AT_CPU, m); _row += 4;
   if (ndpflag) { perbar(_row,  "NDP",  cputick, AT_NDP, m); _row += 4; }
   if (cpuflag >= 2) {
                  perbar(_row,  "RAM",  rdmword, AT_MEM, m); _row += 4;
      if (emem)   perbar(_row,  "EMS",  rdeword, AT_EMS, m);
      else        perbar(_row,  "ROM",  romword, AT_ROM, m); _row += 4;
                  perbar(_row, "Video", vidword, AT_VID, m); _row += 4;
   }
   scrwipe(_l2+6, _row, _l2+37, _row, BRIGHT);
   scrouts(_l2+6, _row, "└───────────────────────────────");

   if (_row < _last) {
      scrwipe(_l2+2,  _last, _l2+37, _last, BRIGHT);
      scrouts(_l2+12, _last, "Press any key...");
   }
   return done(0);
}
