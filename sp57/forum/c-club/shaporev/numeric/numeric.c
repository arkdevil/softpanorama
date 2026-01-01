/* The program is written by Tim V.Shaporev */
/* and considered to be in a public domain  */

#define LOGGING

#ifndef DEBUG
	void _setenvp(void) {}
#endif

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#ifdef LOGGING
#	include <io.h>
#endif

#include "procesor.h"
#include "console.h"
#include "define.h"

static char mainame[] = " Coprocessor Test ";
static char version[] = " v1.1 ";

static struct VideoSettings _vinfo;
static _left, _bottom, _row;

#ifdef LOGGING
	static char logflag;

        static void dupouts(short x, short y, char *s)
        {
           scrouts(x,y,s); if (logflag) printf("          %s", s);
        }

        static void dupends(char *s)
        {
           scrputs(s); if (logflag) printf("%s\n", s);
        }
#else
#	define dupouts(x,y,s)	scrouts((x),(y),(s))
#	define dupends(s)	scrputs(s)
#endif

extern int  int11h(void);
extern long ndpspeed(int);
extern int  errline(int);
extern int  rdwr87(void);
extern int  click(void);

static int cpuflag, ndpflag;

static void scrnumb(int n)
{
   char b[5]; register i = 5;
   do b[--i] = (char)(n%10 + '0'); while (i>0 && (n/=10)!=0);
   while (i<5) scrputc(b[i++]);
}

union { unsigned char c[sizeof(double)]; double d; }
xe = { 0x16, 0x56, 0xE7, 0x9E, 0xAF, 0x03, 0xD2, 0x3C },
s1 = { 0x16, 0x55, 0xB5, 0xBB, 0xB1, 0x6B, 0x02, 0x40 },
s2 = { 0x69, 0x57, 0x14, 0x8B, 0x0A, 0xBF, 0x05, 0x40 },
s3 = { 0xA6, 0xC7, 0x10, 0xE1, 0xE6, 0x70, 0x02, 0x42 },
t1 = { 0xEE, 0x0C, 0x09, 0x8F, 0x54, 0xED, 0xEA, 0x3F },
t2 = { 0x8C, 0x06, 0xB5, 0x0F, 0x28, 0x4A, 0xE1, 0x3F },
t3 = { 0xA5, 0xE3, 0xBE, 0x5C, 0x24, 0xEB, 0xF8, 0x3F },
t4 = { 0x18, 0x2D, 0x44, 0x54, 0xFB, 0x21, 0xE9, 0x3F },
zz = { 0x9F, 0xB0, 0x11, 0x80, 0x75, 0x3C, 0x14, 0x3E },
it = { 0x00, 0x00, 0x00, 0x00, 0x20, 0x6C, 0xA1, 0x37 };

main(argc, argv)
char *argv[];
{
   register i, j, n;
   register retcode = 0;
   short errcount;
   short npass[7];
   short l2;
   long l;
   register double x;
   int dig, sig; register char *p;
   static char *cpuname[] = {
      "Intel 8088",  "Intel 8086", "NEC V20", "NEC V30",
      "Intel 80188", "Intel 80186", "Intel 80286",
      "Intel 80386", "Intel 80386SX", "Intel 80386DX",
      "Intel 80486", "Intel 80486SX",
   };
   static char *ndpname[] = {
      "(none)",
      "Intel 8087",
      "Intel 80287",
      "Intel 80287XL/T",
      "Intel 80387",
      "Intel 80387SX",
      "Intel 80387DX",
   };
   static int   precisn[] = { 0, 1, 10, 17 };
   static char  passed[] = "passed", failed[] = "failed";

   colorset(argc, argv);
   AskVideo(&_vinfo);
   _left =   _vinfo.vs_width / 2 - 20;
   _bottom = _vinfo.vs_height - 1;

   fillside(_vinfo.vs_width, _vinfo.vs_height);

   scrwipe(_left, 0, _left+39, _bottom, BORDER);
   scrouts(_left,   0, "╔══════════════════════════════════════╗");
   scrouts(_left+8, 0, mainame); scrputs(version);
   for (i=1; i<_bottom; i++) {
      scrouts(_left, i,    "║");
      scrouts(_left+39, i, "║");
   }
   scrouts(_left, _bottom, "╚══════════════════════════════════════");
   scrpoke((BORDER<<8) + 188);
#ifdef LOGGING
   logflag = !((i = ioctl(fileno(stdout), 0)) & 128 && i & 6);
   if (logflag) {
      printf("\n          ----------%s\t\t%s\t    ----------\n",
                    mainame, version);
   }
#endif
   scrwipe(_left+1, 1, _left+38, _bottom-2, NORMAL);

   _row = 1; l2 = _left+2;

   ndpflag = (cpuflag = processors()) >> 8; cpuflag &= 127;

   dupouts(l2, ++_row, "       Main processor: ");
   dupends(cpuname[cpuflag]);
   if (cpuflag != cpu80486) {
      dupouts(l2, ++_row, "Numerical coprocessor: ");
      dupends(ndpname[ndpflag]);
   }
   dupouts(l2, ++_row, "       Install switch: ");
   dupends((i = int11h() & 2) != 0 ? "enable" : "disable");

   if (!ndpflag) {
      retcode = i ? ERROR : 0; goto end;
   } else if (ndpflag < ndp80287) {
      ndpflag = 1;
   } else if (ndpflag > ndp80287) {
      ndpflag = 3;
   } else {
      ndpflag = 2;
   }
   errcount = 0;

   dupouts(l2, ++_row, "    Coprocessor speed: ");
   l = ndpspeed(ndpflag) + 5;
   scrnumb((int)(l / 1000)); scrputc('.');
   scrputc((char)((int)(l % 1000) / 100 + '0'));
   scrputc((char)((int)(l % 100)  / 10  + '0'));
   scrputs(" MHz \361"); scrnumb(precisn[ndpflag]); scrputc('%');
#ifdef LOGGING
   if (logflag) {
      printf("%.3f MHz, %d%% accuracy\n", l/1000.0, precisn[ndpflag]);
   }
#endif
   dupouts(l2, ++_row, "       Exception line: ");
   i = errline(cpuflag >= cpu80286);
   dupends(i ? "Inoperative" : "Operative");
   errcount += i;

   dupouts(l2, (_row+=2),  "       Accuracy tests:");
   scrouts(l2,     ++_row, "       log exp pow sin cos tan atan");
   scrouts(l2, n = ++_row, passed);
   scrouts(l2,     ++_row, failed);
   scrwipe(_left+9, n, _left+38, n+1, BRIGHT);

   npass[0]=npass[1]=npass[2]=npass[3]=npass[4]=npass[5]=npass[6]=0;
   for (i=0; i<100; i++) {
      if (fabs(log(10.0) - s1.d) > xe.d) errcount++; else npass[0]++;
      if (fabs(exp(1.0) - s2.d) > xe.d)  errcount++; else npass[1]++;

      x = pow(9.99, 10.0); /* fix compiler bug */
      if (fabs(x - s3.d) > xe.d)         errcount++; else npass[2]++;

      if (fabs(sin(1.0) - t1.d) > xe.d)  errcount++; else npass[3]++;
      if (fabs(cos(1.0) - t2.d) > xe.d)  errcount++; else npass[4]++;
      if (fabs(tan(1.0) - t3.d) > xe.d)  errcount++; else npass[5]++;
      if (fabs(atan(1.0) - t4.d) > xe.d) errcount++; else npass[6]++;

      for (j=0; j<7; j++) {
         if (npass[j]) {
            scrgoto(_left+ (npass[j] > 9 ? 9 : 10) + 4*j, n);
            scrnumb(npass[j]);
         }
         if (npass[j] <= i) {
            scrgoto(_left+ (i-npass[j] >= 9 ? 9 : 10) + 4*j, n+1);
            scrnumb(i-npass[j]+1);
         }
      }
   }
#ifdef LOGGING
   if (logflag) {
      for (i=0, j=0; i<7; i++) j += 100 - npass[i];
      printf("%s\n", j ? failed : passed);
   }
#endif
   dupouts(l2, (_row+=2), "          Stress test: ");
   scrwipe(_left+25, _row, _left+38, _row, BRIGHT);
   for (x=1.0, i=1; i<2500; i++) {
      x = tan(atan(exp(log(sqrt(x*x))))) + 1.0;
   }
   if (x - 2500.0 > zz.d) {
      dupends(failed); ++errcount;
   } else {
      dupends(passed);
   }

   dupouts(l2, (_row+=2), "      Integrity tests: ");
   scrouts(l2,  ++_row,   "   Test 1  Test 2  Test 3  Test 4");
   ++_row;
   scrwipe(l2, _row, _left+38, _row, BRIGHT);

   for (j=rdwr87(), i=0; i<4; i++) {
      scrouts(_left+5+8*i, _row, ((j>>i)&1 ? passed : failed));
   }
#ifdef LOGGING
   if (logflag) {
      printf("%s\n", (j&15) == 15 ? passed : failed);
   }
#endif
   _row+=2; i=0; scrwipe(_left+25, _row, _left+38, _row, BRIGHT);
#ifdef LOGGING
   dupouts(l2, _row, "    Interference test: ");
#endif
   scrputs("..........\b\b\b\b\b\b\b\b\b\b");
   do {
#if 0
      scrouts(l2, _row, "    Interference test: ");
#endif
      p = ecvt(it.d, 7, &dig, &sig);
      j = dig != -40 || sig != 0 || strcmp(p, "9999946");
#if 0
      scrnumb(++i);
#else
      if ((++i % 10) == 0) click();
#endif
   } while (i<100 && !j);
#if 0
   scrgoto(_left+25, _row);
#else
   scrputs("\b \b\b \b\b \b\b \b\b \b\b \b\b \b\b \b\b \b\b \b");
#endif
   if (j) {
      dupends(failed); errcount += 101 - i;
   } else {
      dupends(passed);
   }

   dupouts(l2, (_row+=2), "         Total errors: ");
   scrwipe(_left+25, _row, _left+38, _row, BRIGHT);
   scrnumb(errcount);
#ifdef LOGGING
   if (logflag) printf("%d\n", errcount);
#endif
   if (errcount > 0) retcode = ERROR;
end:
   scrgoto(_left+12, _bottom-1);
   scrwipe(_left+12, _bottom-1, _left+27, _bottom-1, BRIGHT);
   scrputs("Press any key...");
   scrgoto(0, _vinfo.vs_height);
   (void)keyserv(4);
   scrgoto(0, 0); scrwipe(0, 0, _vinfo.vs_width-1, _bottom, EMPTY);
   return retcode;
}
