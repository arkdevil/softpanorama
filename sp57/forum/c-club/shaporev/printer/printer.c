/* Problem description & consulting by Dmitry S.Severov */
/* Original coding by Tim V.Shaporev & Serge V.Popov    */
/* Interface design & debugging by Tim V.Shaporev       */
/* The pogram is considered to be in a public domain    */

#define LOGGING

#ifndef DEBUG
	void _setenvp(void) {}
#endif

#include "console.h"
#include "define.h"

#include <setjmp.h>
#include <string.h>
#include <stdio.h>
#include <fcntl.h>
#include <bios.h>
#include <dos.h>
#include <io.h>

/* Printer control codes data base */
struct regim {
               struct regim * next;
               char         * title;
               char         * set;
               int            len;
               unsigned       dpi;
             } ;

struct printer {
                 struct printer * next;
                 char           * init;
                 char           * title;
                 struct regim   * list;
               } ;

struct regim eps7 = {NULL,  "One-to-two plotter",        "\033*\007", 3, 144};
struct regim eps6 = {&eps7, "High res CRT-screen",       "\033*\006", 3,  90};
struct regim eps5 = {&eps6, "One-to-one plotter",        "\033*\005", 3,  72};
struct regim eps4 = {&eps5, "CRT-screen",                "\033*\004", 3,  80};
struct regim epsz = {&eps4, "Quadruple density",         "\033*\003", 3, 240};
struct regim epsy = {&epsz, "High-speed double density", "\033*\002", 3, 120};
struct regim epsl = {&epsy, "Double density",            "\033*\001", 3, 120};
struct regim epsk = {&epsl, "Single density",            "\033*\000", 3,  60};

struct regim epsZ = {NULL,  "Quadruple density",         "\033Z",     2, 240};
struct regim epsY = {&epsZ, "High-speed double density", "\033Y",     2, 120};
struct regim epsL = {&epsY, "Double density",            "\033L",     2, 120};
struct regim epsK = {&epsL, "Single density",            "\033K",     2,  60};

struct regim eps1 = {NULL,  "Double density",            "\033^\001", 3, 120};
struct regim eps0 = {&eps1, "Single density",            "\033^\000", 3,  60};

struct regim nec4 = {NULL,  "High density",              "\033*\050", 3, 360};
struct regim nec3 = {&nec4, "Triple density",            "\033*\047", 3, 180};
struct regim nec2 = {&nec3, "Other CRT-screens",         "\033*\046", 3,  90};
struct regim nec1 = {&nec2, "Double density",            "\033*\041", 3, 120};
struct regim nec0 = {&nec1, "Single density",            "\033*\040", 3,  60};

struct regim lq53 = {NULL,  "Triple density",            "\033*\047", 3, 180};
struct regim lq52 = {&lq53, "Other CRT-screens",         "\033*\046", 3,  90};
struct regim lq51 = {&lq52, "Double density",            "\033*\041", 3, 120};
struct regim lq50 = {&lq51, "Single density",            "\033*\040", 3,  60};

struct printer epsonm = {NULL,    "\033@", "Epson FX",          &epsk};
struct printer epsonc = {&epsonm, "\033@", "Epson compatible",  &epsK};

struct printer epson9 = {NULL,    "\033@", "Epson compatible",  &eps0};

struct printer necpin = {NULL,    "\034@\033#\033x\200\033P",
                                  "NEC PinWriter",              &nec0};
struct printer lq5000 = {&necpin, "\033@\033#\033x\200\033P",
                                  "LQ 5000",                    &lq50};

struct printer *items[] = {&epsonc, &epson9, &lq5000};
short          pins[]   = {      8,       9,      24};

#define BC_0 1
#define BC_1 2
#define BC_2 4
#define BC_3 8
#define BC_4 16
#define BC_5 32
#define BC_6 64
#define BC_7 128

#define GINT 0x10
#define B_1 8
#define B_2 16
#define B_3 32
#define B_4 64
#define B_5 128
#define STROB 1
#define INIC 8
#define REINIC 12

/* Printer Status Register Bits 0x379 */
#define READY    0x40
#define BUSY     0x80

#define MENU_TOP 4
#define BEG_TEST 2

static char mainame[] = " Printer Check";
static char version[] = " v1.1 ";

static struct VideoSettings _vinfo;
static char _left, _bottom, _middle;
static char _menu_left, _diag_left;
static int  status, current;
#ifdef LOGGING
	static char logflag;

        static void dupouts(short x, short y, char *s)
        {
           scrouts(x, y, s); if (logflag) printf("          %s\n", s);
        }
#else
#	define dupouts(x,y,s)	scrouts((x),(y),(s))
#endif

struct settings { unsigned char inch, level, type, port, comm; } tset;
static int handle;
static void interrupt (*oldvect)();
static jmp_buf dosret;

struct _menu_auto { char hi, ins, row, run, res; };
struct _menu_data { char *text; int (*fun)(void); };

#define LEV_DOS  0
#define LEV_BIOS 1
#define LEV_Port 2
#define PAR_EVEN 030
#define PAR_ODD  010

static int lpt_stat=0;
static int byfport;

static int cdate = 0x3f8;
#define cspead1    cdate
#define cspead2   (cdate+1)
#define cint      (cdate+1)
#define cidint    (cdate+2)
#define cmenedg   (cdate+3)
#define clinestat (cdate+5)

static int dateport = 0x378;
#define errorp   (dateport+1)
#define contport (dateport+2)

static void interrupt (*oldint)();

static char *leveltab[] = {
   " DOS", "BIOS", "Port"
};
static char *baudtab [] = {
   " 110", " 150", " 300", " 600",
   "1200", "2400", "4800", "9600"
};

static void cursor(int k)
{
   _CX = k ? _vinfo.vs_cursor.x : NOCURSOR; _AH = 1; geninterrupt(0x10);
}

static int readkey(void)
{
   scrgoto(0, _vinfo.vs_height); return keyserv(0);
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
      "│ GRAY +/- mark/unmark all tests   │",
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

static void prstat(int k, short y)
{
   static char *doserrlist[] = {
      "No error occurred",
      "Invalid function number",
      "File not found",
      "Path not found",
      "Too many open files",
      "Access denied",
      "Invalid handle",
      "MCB destroyed",
      "Insufficient memory",
      "Invalid memory block address",
      "Invalid environment",
      "Invalid format",
      "Invalid access code",
      "Invalid data",
      "(not used)",
      "Invalid drive specified",
      "Can't remove current dir",
      "Not same device",
      "No more matching files",
      "Write protection",
      "Unknown unit ID",
      "Drive not ready",
      "Unknown command",
      "Disk data error",
      "Bad request",
      "Disk seek error",
      "Unknown media type",
      "Sector not found",
      "Out of paper",
      "Write fault",
      "Read fault",
      "General failure",
      "File sharing violation",
      "File locking violation",
      "Invalid disk change",
      "FCB unavailable",
      "Sharing buffer overflow",
   };
   static char *bioslpterr[] = {
      "Timeout",
      "",
      "",
      "I/O error",
      "Off line",
      "Out of paper",
      "Detached",
      "Busy",
   };
   static char *bioscomerr[] = {
      "Timeout",
      "Trans shift reg empty",
      "Trans holding reg empty",
      "Break detect",
      "Framing error",
      "Parity error",
      "Overrun",
      "Data not ready",
   };
   static char *errorlpt[]    = {
      "No error occured",
      "No interrupt occured",
      "Printer signals an error",
      "Busy or offline or error",
      "Out of paper",
      "Timeout error",
      "No adapter",
   };
   static char *errorcom[] = {
      "No error occured",
      "Detached",
      "Fraiming error ",
      "Break indicated",
      "Parity error",
      "Timeout error",
      "No adapter",
   };

   static char h[] = "0123456789ABCDEF";
   register char *e;
   register i, j;

   e = (char *)0;
   if (tset.level == LEV_DOS) {
      if (k>=0 && k<dim(doserrlist)) e = doserrlist[k];
   } else if (tset.level == LEV_BIOS) {
      if (tset.type) {
         for (i=0, j=(k^1) & 255; i<8 && (j&0x80)==0; i++) ;
         if (i < 8) e = bioscomerr[i];
      } else {
         for (i=0, j=(k^0x90)&0xF9; j && (j&1)==0; ++i, j>>=1) ;
         if (j & 1) e = bioslpterr[i];
      }
   } else {
      if (tset.type){
         e=errorcom[k];
      } else{
         e=errorlpt[k];
      }
   }
   scrwipe(_left+1, y, _left+38, y, ITALIC);
   if (e) {
      scrouts(_left+(33-strlen(e))/2, y, "\007Error: ");
      scrputs(e);
#ifdef LOGGING
      if (logflag) printf("          Error: %s\n", e);
#endif
   } else {
      scrouts(_left+15, k, "\007Error: ");
      scrputc(h[(k >> 4) & 15]);
      scrputc(h[k&15]);
      scrputc('h');
#ifdef LOGGING
      if (logflag) printf("          Error: %2.2Xh\n", k);
#endif
   }
}

static int catch()
{
   longjmp(dosret, (_DI&127)+19); /* dummy */ return 0;
}

static void enprnint(void)
{
   disable();
   outport(0x21,(inport(0x21) & 127));
   enable();
}

static void diprnint(void)
{
   disable();
   outport(0x21, (inport(0x21) | 128));
   enable();
}

static void interrupt intrport()
{
   int e;
   register unsigned i;

   /* diprnint(); */
   e=inportb(errorp);

   if (!(e & READY)) {
      if (!(e & B_1)) {
         lpt_stat = 2;
         goto end_intr;
      }
      if(!(e & B_5)){
         lpt_stat = 3;
         goto end_intr;
      }
      if(e & B_3){
         lpt_stat = 4;
         goto end_intr;
      }
   }

   lpt_stat = 1;
   outportb(dateport,byfport);

   for(i=0; i<0xFFFF; i++) {
      e = inportb(errorp);
      if(e & READY) break;
   }
   if(i==0xFFFF){
      lpt_stat = 5;
      goto end_intr;
   }

   outport(contport,inport(contport) | STROB);
   outport(contport,inport(contport) & ~STROB);

end_intr:
   diprnint();
   byfport=0;
   outportb(0x20,0x20); /* End of Interrupt for 8259 */
}

static int prinit(void)
{
   char buf[5];
   unsigned k;

   if (tset.level == LEV_DOS) {
      if (tset.type) {
         (void)bioscom(0, tset.comm, tset.port);
         buf[0] = 'C'; buf[1] = 'O'; buf[2] = 'M';
      } else {
         buf[0] = 'L'; buf[1] = 'P'; buf[2] = 'T';
      }
      buf[3] = '1'+ tset.port;
      buf[4] = 0;
      if ((handle = open(buf, O_WRONLY+O_BINARY)) < 0) return _doserrno;
   } else if (tset.level == LEV_BIOS) {
      if (tset.type) {
         k = (unsigned)bioscom(0, tset.comm, tset.port);
         if (k & 0x8000) return k >> 8;
      } else {
         k = (unsigned)biosprint(1, 0, tset.port);
         if ((k & 0x39) != 0x10) return k;
      }
   } else {
      if (tset.type) {
         if ((cdate = *(int far *)MK_FP(0x0040, 2*tset.port)) == 0) return 6;

         outportb(cmenedg, inportb(cmenedg) | BC_7);

         if((tset.comm & BC_5)==0 || (tset.comm & BC_5)==0 || (tset.comm & BC_5)==0 )
         {
            outportb(cspead2,0x04);
            outportb(cspead1,0x17);
         }

         if((tset.comm & BC_5)==1 || (tset.comm & BC_5)==0 || (tset.comm & BC_5)==0 )
         {
            outport(cspead1,768);
         }

         if((tset.comm & BC_5)==0 || (tset.comm & BC_5)==1 || (tset.comm & BC_5)==0 )
         {
            outportb(cspead2,0x01);
            outportb(cspead1,0x80);/*break;*/
         }

         if((tset.comm & BC_5)==1 || (tset.comm & BC_5)==1 || (tset.comm & BC_5)==0 )
         {
            outportb(cspead2,0x00);
            outportb(cspead1,0xc0);/*break;*/
         }

         if((tset.comm & BC_5)==0 || (tset.comm & BC_5)==0 || (tset.comm & BC_5)==1 )
         {
            outportb(cspead2,0x00);
            outportb(cspead1,0x60);/*break;*/
         }

         if((tset.comm & BC_5)==1 || (tset.comm & BC_5)==0 || (tset.comm & BC_5)==1 )
         {
            outportb(cspead2,0x00);
            outportb(cspead1,0x30);/*break;*/
         }

         if((tset.comm & BC_5)==0 || (tset.comm & BC_5)==1 || (tset.comm & BC_5)==1 )
         {
            outportb(cspead2,0x00);
            outportb(cspead1,0x18);/*break;*/
         }

         if((tset.comm & BC_5)==1 || (tset.comm & BC_5)==1 || (tset.comm & BC_5)==1 )
         {
            outportb(cspead2,0x00);
            outportb(cspead1,0x0c);/*break;*/
         }

         outportb(cmenedg,inportb(cmenedg) & ~BC_7);

         outportb(cmenedg,inportb(cmenedg) | (BC_0 + BC_1));

         if((tset.comm & BC_2)==0)outportb(cmenedg,inportb(cmenedg) & ~BC_2);
         if((tset.comm & BC_2)==1)outportb(cmenedg,inportb(cmenedg) | BC_2);

         if((tset.comm & BC_4)==1 ||  (tset.comm & BC_3)==1)
         {
            outportb(cmenedg,inportb(cmenedg) | BC_3);
            outportb(cmenedg,inportb(cmenedg) | BC_4);
         }

         if((tset.comm & BC_4)==0 || (tset.comm & BC_3)==1)
         {
            outportb(cmenedg,inportb(cmenedg) | BC_3);
            outportb(cmenedg,inportb(cmenedg) & ~BC_4);
         }

         if((tset.comm & BC_4)==0 || (tset.comm & BC_3)==0)
         {
            outportb(cmenedg,inportb(cmenedg) & ~BC_3);
            outportb(cmenedg,inportb(cmenedg) & ~BC_4);
         }

         outportb(cmenedg,inportb(cmenedg) & ~BC_7);
      } else {
         enable();
         dateport = *(int far *)MK_FP(0x0040, 2*tset.port+8);
         if (dateport == 0) return 6;

         oldint=getvect(0x0F);	setvect(0x0F,intrport);
         outportb(contport,INIC); 	delay(1000);
         outportb(contport,REINIC);	delay(1000);
         outport(contport,inport(contport) & ~STROB);
      }
   }
   return 0;
}

static void intgood(void)
{
   outport(contport,inport(contport) | GINT);
}

static int prchar(int c)
{
   unsigned k;

   if        (tset.level == LEV_DOS ) {
      if (write(handle, &c, 1) != 1) return _doserrno;
   } else if (tset.level == LEV_BIOS) {
      if (tset.type) {
         k = (unsigned)bioscom(1, c, tset.port);
         if (k & 0x8000) return k >> 8;
      } else {
         k = (unsigned)biosprint(0, c, tset.port);
         if (k & 0xA9) return k;
      }
   } else {
      if (tset.type) {
         int e,i;

         for (i=0; i<10000; i++) {
            e=inportb(clinestat);

            if (e & BC_7) return 1;
            if (e & BC_3) return 2;
            if (e & BC_4) return 3;
         /* if (e & BC_2) return 4; */

            if (e & BC_5) {
               outportb(cdate,c);
               return 0;
            }
         }
         return 5;
      } else {
         long i;

         lpt_stat=0;
         byfport=c;

         intgood();
         enprnint();

         for(i=0; i<327670L && !lpt_stat; i++) ;
         diprnint();

         if(i>=32760L) return 1;

         if (lpt_stat >= 2 && lpt_stat <= 5) return lpt_stat;
      }
   }
   return 0;
}

static void intbad(void)
{
   outport(contport,inport(contport) & ~GINT);
}

static int prexit(void)
{
   if (tset.level == LEV_DOS) {
      if (close(handle) < 0) return _doserrno;
   }
   if (tset.level == LEV_DOS) {
      intbad();
      diprnint();
      setvect(0x0F,oldint);
   }
   return 0;
}

#define POZ_END  3
#define POZ_WID  4
#define POZ_LEV  5
#define POZ_TYPE 6
#define POZ_NUM  7
#define POZ_BAUD 8
#define POZ_PAR  9
#define POZ_STOP 10

static void viewpar(struct settings *s, int poz, int a, int maxlpt, int maxcom)
{
   register i;

   scrwipe(_left+1, _middle+2, _left+38, _middle+2, ITALIC);
   if (!(s->type) && s->port > maxlpt || s->type && s->port > maxcom)
      scrouts(_left+5, _middle+2, "Warning: device number too big");
   scrwipe(_left+22, _middle+POZ_WID, _left+38, _middle+POZ_STOP, NORMAL);
   i = _left + (s->inch == 4 ? 22 : s->inch == 8 ? 28 : 34);
   scrwipe(i, _middle+POZ_WID,  i+2, _middle+POZ_WID,
       poz == POZ_WID ? a : INVERT);
   scrouts(_left+22, _middle+POZ_WID, "4\042    8\042    16\042");
   i = _left + 22 + 6*s->level;
   scrwipe(i, _middle+POZ_LEV,  i+3, _middle+POZ_LEV,
       poz == POZ_LEV ? a : INVERT);
   scrouts(_left+22, _middle+POZ_LEV, "DOS   BIOS  Port");
   i = _left + (s->type ? 28 : 22);
   scrwipe(i, _middle+POZ_TYPE, i+2, _middle+POZ_TYPE,
       poz == POZ_TYPE ? a : INVERT);
   scrouts(_left+22, _middle+POZ_TYPE, "LPT   COM");
   if (poz == POZ_NUM) {
      scrwipe(_left+22, _middle+POZ_NUM, _left+22, _middle+POZ_NUM, a);
   }
   scrgoto(_left+22, _middle+POZ_NUM);
   scrputc('1' + (s->port));
   if (s->type) {
      if (poz == POZ_BAUD) {
         scrwipe(_left+22, _middle+POZ_BAUD, _left+25, _middle+POZ_BAUD, a);
      }
      scrouts(_left+22, _middle+POZ_BAUD, baudtab[s->comm >> 5]);
      i = _left + ((s->comm & 030) == PAR_EVEN ? 22 :
          (s->comm & 030) == PAR_ODD  ? 28 : 34);
      scrwipe(i, _middle+POZ_PAR,  i+3, _middle+POZ_PAR,
          poz == POZ_PAR ? a : INVERT);
      scrouts(_left+22, _middle+POZ_PAR, "even  odd   none");
      if (poz == POZ_STOP) {
         scrwipe(_left+22, _middle+POZ_STOP, _left+22, _middle+POZ_STOP, a);
      }
      scrouts(_left+22, _middle+POZ_STOP, s->comm & 4 ? "2" : "1");
   }
}

static void setport(struct settings *s, int com)
{
   if (com) {
      s->type = 1;
      scrouts(_left+4, _middle+POZ_BAUD, "5)     Baud rate:");
      scrouts(_left+4, _middle+POZ_PAR,  "6)        Parity:");
      scrouts(_left+4, _middle+POZ_STOP, "7)     Stop bits:");
   } else {
      s->type = 0;
      scrwipe(_left+1, _middle+POZ_BAUD, _left+38, _middle+POZ_STOP, NORMAL);
   }
}

static void prparams(void)
{
   register c, i;
   int maxcom, maxlpt, poz;
   struct settings tmps;
   tmps = tset;

   scrwipe(_left+1,  _middle+1, _left+38, _middle+1, BRIGHT);
   scrouts(_left+11, _middle+1, "Printer parameters");

   scrwipe(_left+1, _middle+2, _left+37, _bottom-2, NORMAL);
   scrouts(_left+4, _middle+POZ_END,  "0)        End");
   scrouts(_left+4, _middle+POZ_WID,  "1)   Paper width:");
   scrouts(_left+4, _middle+POZ_LEV,  "2)    Handle via:");
   scrouts(_left+4, _middle+POZ_TYPE, "3)   Device type:");
   scrouts(_left+4, _middle+POZ_NUM,  "4) Device number:");

   scrline(_left+8, _bottom-1, "Use arrow and SPACE keys", BRIGHT);

   i = biosequip();
   maxcom = (i >>  9) & 7;
   maxlpt = (i >> 14) & 3;

   for (poz = POZ_WID; ;) {
      if (poz == POZ_END) {
         scrwipe(_left+1,  _bottom-1, _left+38, _bottom-1, BRIGHT);
         scrouts(_left+11, _bottom-1, "Changes ok? (y/n) ");
         cursor(2);
         do {
            i = keyserv(4) & (255 ^ ('z'^'Z'));
         } while (i!=ESC && i!='Y' && i!='N');
         cursor(0);
         if (i == 'Y') tset = tmps;
         if (i != ESC) {
            viewpar(&tmps, poz, INVERT, maxlpt, maxcom);
            scrwipe(_left+1,  _bottom-1, _left+38, _bottom-1, BRIGHT);
            return;
         }
         scrouts(_left+8, _bottom-1, "Use arrow and SPACE keys");
         ++poz;
      }

      viewpar(&tmps, poz, INVERT+BLINK, maxlpt, maxcom);

      c = (i = keyserv(4)) & 255;
      if        (i == 0x4800) {/*  Up arrow  */
         if (--poz < POZ_END) poz = tmps.type ? POZ_STOP : POZ_NUM;
      } else if (i == 0x5000) {/* Down arrow */
         if (++poz > (tmps.type ? POZ_STOP : POZ_NUM)) poz=POZ_END;
      } else if (i == 0x4B00 || i == 0x0F00) {/* Left arrow */
         switch (poz) {
         case POZ_WID :
            if ((tmps.inch /= 2) < 4) tmps.inch = 16;
            break;
         case POZ_LEV :
            if (--(tmps.level) > 2) tmps.level = 2;
            break;
         case POZ_TYPE:
            setport(&tmps, !tmps.type);
            break;
         case POZ_NUM :
            tmps.port = (tmps.port - 1) & 7;
            break;
         case POZ_BAUD:
            if ((i = (tmps.comm >> 5) - 1) < 0) i = 7;
            tmps.comm = (tmps.comm & 0x1F) | (i << 5);
            break;
         case POZ_PAR :
            if        ((tmps.comm & 030) == PAR_EVEN) {
               tmps.comm = (tmps.comm & ~030);
            } else if ((tmps.comm & 030) == PAR_ODD ) {
               tmps.comm = (tmps.comm & ~030) | PAR_EVEN;
            } else {
               tmps.comm = (tmps.comm & ~030) | PAR_ODD;
            }
            break;
         case POZ_STOP:
            tmps.comm ^= 4;
            break;
         }
      } else if (i == 0x4D00 || c == ' ' || c == '\t') {/* Right arrow */
         switch (poz) {
         case POZ_WID :
            if ((tmps.inch *= 2) > 16) tmps.inch = 4;
            break;
         case POZ_LEV :
            if (++tmps.level > 2) tmps.level = 0;
            break;
         case POZ_TYPE:
            setport(&tmps, !tmps.type);
            break;
         case POZ_NUM :
            tmps.port = (tmps.port + 1) & 7;
            break;
         case POZ_BAUD:
            if ((i = (tmps.comm >> 5) + 1) > 7) i = 0;
            tmps.comm = (tmps.comm & 0x1F) | (i << 5);
            break;
         case POZ_PAR :
            if        ((tmps.comm & 030) == PAR_EVEN) {
               tmps.comm = (tmps.comm & ~030) | PAR_ODD;
            } else if ((tmps.comm & 030) == PAR_ODD ) {
               tmps.comm = (tmps.comm & ~030);
            } else {
               tmps.comm = (tmps.comm & ~030) | PAR_EVEN;
            }
            break;
         case POZ_STOP:
            tmps.comm ^= 4;
            break;
         }
      } else if (c == '\r' || c == ESC) {
         if (c != ESC) tset = tmps;
         viewpar(&tmps, poz, INVERT, maxlpt, maxcom);
         scrwipe(_left+1,  _bottom-1, _left+38, _bottom-1, BRIGHT);
         return;
      } else if (poz == POZ_STOP && (c == '1' || c == '2')) {
         if (c == '1') tmps.comm &= ~4;
         else          tmps.comm |=  4;
      } else if (poz == POZ_NUM && (c>='1' && c<='8')) {
         tmps.port = c - '1';
      } else if (c>='0' && c<='7') {
         if (c-('0'-POZ_END) != poz) {
            poz = c - ('0'-POZ_END);
         } else {
            switch (poz) {
            case POZ_WID :
               if ((tmps.inch *= 2) > 16) tmps.inch = 4;
               break;
            case POZ_LEV :
               if (++tmps.level > 2) tmps.level = 0;
               break;
            case POZ_TYPE:
               setport(&tmps, !tmps.type);
               break;
            case POZ_NUM :
               tmps.port = (tmps.port + 1) & 7;
               break;
            case POZ_BAUD:
               if ((i = (tmps.comm >> 5) + 1) > 7) i = 0;
               tmps.comm = (tmps.comm & 0x1F) | (i << 5);
               break;
            case POZ_PAR :
               if        ((tmps.comm & 030) == PAR_EVEN) {
                  tmps.comm = (tmps.comm & ~030) | PAR_ODD;
               } else if ((tmps.comm & 030) == PAR_ODD ) {
                  tmps.comm = (tmps.comm & ~030);
               } else {
                  tmps.comm = (tmps.comm & ~030) | PAR_EVEN;
               }
               break;
            case POZ_STOP:
               tmps.comm ^= 4;
               break;
            }
         }
      }
   }
}

#define ROW_BEG 4
#define ROW_END 5
#define ROW_REP 6
#define COL_NUM 19
#define COL_LET 26

static void scrnumb(short x, short y, int n)
{
   char b[5]; register i = 5;
   do b[--i] = n%10 + '0'; while (i>0 && (n/=10)!=0);
   scrgoto(x, y); while (i<5) scrputc(b[i++]);
}

static int outchart(void)
{
   register k;
   register i, j, n;
   register short m, s;
   short cs, ce, nr, row, col;
   register c; int end;
   register short o, *p;

   m = (_middle+ROW_REP + _bottom) / 2;
   if ((s = 10*(tset.inch)) > 80) s -= 28;

   scrwipe(_left+1, _middle+1, _left+38, _middle+1, BRIGHT);
   dupouts(_left+9, _middle+1, "Character Table Output");
   scrwipe(_left+1, _middle+2, _left+38, _bottom-1, NORMAL);
   scrouts(_left+11,_middle+ROW_BEG, " Start:     = ' '");
   scrouts(_left+11,_middle+ROW_END, "   End:     = ' '");
   scrouts(_left+11,_middle+ROW_REP, "Repeat:");
   scrouts(_left+10, m, "Press ENTER to print");

   oldvect = getvect(0x24);
   if ((k = setjmp(dosret)) == 0) {
      harderr(catch);
   } else {
      prstat(k, m);
   }

   cs = 32; ce = 126; nr = 5;
   row = ROW_BEG;
   col = COL_NUM;
   end = FALSE;
   p   = (short*)0;
   o   = 0;
   do {
      if (p != &ce && ce < cs) ce = ((cs + 32) & ~31) - 1;

      scrwipe(_left+COL_NUM,   _middle+ROW_BEG,
              _left+COL_NUM+2, _middle+ROW_REP, NORMAL);
      scrnumb(_left+COL_NUM, _middle+ROW_BEG, cs);
      scrnumb(_left+COL_NUM, _middle+ROW_END, ce);
      scrnumb(_left+COL_NUM, _middle+ROW_REP, nr);
      scrgoto(_left+COL_LET, _middle+ROW_BEG); scrpoke((NORMAL<<8) | cs);
      scrgoto(_left+COL_LET, _middle+ROW_END); scrpoke((NORMAL<<8) | ce);

      if        (row == ROW_BEG) {
         if (col == COL_NUM) {
            scrwipe(_left+COL_NUM,   _middle+ROW_BEG,
                    _left+COL_NUM+2, _middle+ROW_BEG, INVERT);
            scrnumb(_left+COL_NUM,   _middle+ROW_BEG, cs);
         } else {
            scrgoto(_left+COL_LET, _middle+ROW_BEG); scrpoke((INVERT<<8)|cs);
         }
      } else if (row == ROW_END) {
         if (col == COL_NUM) {
            scrwipe(_left+COL_NUM,   _middle+ROW_END,
                    _left+COL_NUM+2, _middle+ROW_END, INVERT);
            scrnumb(_left+COL_NUM,   _middle+ROW_END, ce);
         } else {
            scrgoto(_left+COL_LET, _middle+ROW_END); scrpoke((INVERT<<8)|ce);
         }
      } else if (row == ROW_REP) {
         scrwipe(_left+COL_NUM,   _middle+ROW_REP,
                 _left+COL_NUM+2, _middle+ROW_REP, INVERT);
         scrnumb(_left+COL_NUM,   _middle+ROW_REP, nr);
         col = COL_NUM;
      }

      cursor(2); c = keyserv(4); cursor(0);

      if (p) {
         if        (c == 0x011B) {
            *p = o; p = (short*)0;
            continue;
         } else if (c == 0x0E08) {
            *p /= 10;
            continue;
         }
      }
      i = c & 255;
      if (col == COL_NUM && i >= '0' && i <= '9') {
         if (!p) {
            switch (row) {
               case ROW_BEG: p = &cs; break;
               case ROW_END: p = &ce; break;
               case ROW_REP: p = &nr; break;
            }
            o = *p; *p = 0;
         }
         if (*p * 10 + i - '0'< 256) {
            *p = *p * 10 + i - '0';
         }
         continue;
      }
      if (i != 0 && (row == ROW_BEG || row == ROW_REP) &&
          (c >= 0x0200 && c <= 0x0DFF || c >= 0x1600 && c <= 0x1BFF ||
           c >= 0x1E00 && c <= 0x35FF || c == 0x3920)) {
         p = row == ROW_BEG ? &cs : &ce; o = *p; *p = i;
         col = COL_LET;
         continue;
      }
      p = (short*)0;
      if        (c == 0x4800) {/* Up */
         if      (row == ROW_BEG) row = ROW_REP;
         else if (row == ROW_END) row = ROW_BEG;
         else                     row = ROW_END;
      } else if (c == 0x4B00 /* Left */ || c == 0x4D00 /* Right */ ||
                (c & 0xFF00) == 0x0F00 /* Tab */) {
         col == COL_NUM ? COL_LET : COL_NUM;
      } else if (c == 0x5000) {/* Down */
         if      (row == ROW_BEG) row = ROW_END;
         else if (row == ROW_END) row = ROW_REP;
         else                     row = ROW_BEG;
      } else if ((c & 0xFF00) == 0x0100) {/* Esc */
         end = TRUE;
      } else if ((c & 0xFF00) == 0x1C00) {/* Enter */
         if ((k = prinit()) != 0) { prstat(k, m); continue; }

         scrwipe(_left+1,  m, _left+38, m, NORMAL+BLINK);
         scrouts(_left+15, m, "Printing...");

         if ((k = prchar('\n')) != 0) {
            prstat(k, m); continue;
         }
         for (j=0, n=0; j<nr; j++) {
            for (i=cs; i<=ce; i++) {
               if ((k = prchar(i)) != 0) {
                  prstat(k, m); continue;
               }
               if (++n >= s) {
                  if ((k = prchar('\n')) != 0) {
                     prstat(k, m); continue;
                  }
                  n = 0;
               }
            }
         }

         if ((k = prchar('\n')) != 0 || (k = prexit()) != 0) {
            prstat(k, m); continue;
         }
         if (!k) {
            scrwipe(_left+1,  m, _left+38, m, NORMAL+BLINK);
            scrouts(_left+10, m, "Press ENTER to print");
         }
         k = 0;
      }
   } while (!end);

   setvect(0x24, oldvect);
   return k;
}

static int cr_width(void)
{
   register k, i;
   register short m, s;
   m = (_middle+1 + _bottom) / 2;
   if ((s = 10*(tset.inch)) > 80) s -= 28;

   scrwipe(_left+1,  _middle+1, _left+38, _middle+1, BRIGHT);
   dupouts(_left+9, _middle+1, "Character Table Output");
   scrwipe(_left+1, _middle+2, _left+38, _bottom-2, NORMAL+BLINK);

   oldvect = getvect(0x24);
   harderr(catch);
   if ((k = setjmp(dosret)) != 0) goto end;

   if ((k = prinit()) != 0) goto end;

   scrouts(_left+15, m, "Printing...");

   if ((k = prchar('\n')) != 0) goto end;
   for (i=0; i<256; i++) {
      if ((k = prchar(i%10 + '0')) != 0) goto end;
   }
   if ((k = prchar('\n')) != 0) goto end;
   if ((k = prchar('\n')) != 0) goto end;
   for (i=0; i<256; i++) {
      if ((k = prchar(i%10 ? '.' : i/10%10 + '0')) != 0) goto end;
   }
   if ((k = prchar('\n')) != 0) goto end;
   if ((k = prchar('\n')) != 0) goto end;
   for (i=0; i<256; i++) {
      if ((k = prchar(i%10 ? '.' : i/100 + '0')) != 0) goto end;
   }
   if ((k = prchar('\n')) != 0) goto end;
   if ((k = prchar('\n')) != 0) goto end;

   if ((k = prexit()) != 0) goto end;
   scrwipe(_left+1, _middle+2, _left+38, _bottom-2, NORMAL);
   k = 0;

end:
   if (k) prstat(k, m);
   setvect(0x24, oldvect);
   return k;
}

static int prtputs(char *s)
{
   register k;
   while (*s) if ((k = prchar(*(s++))) != 0) return k;
   return 0;
}

static int prtputl(char *s, short l)
{
   register k;
   while (l--) if ((k = prchar(*(s++))) != 0) return k;
   return 0;
}

static int prt_por(unsigned long u, short item)
{
   register i, k;
   for (i=pins[item]; i>0; i-=8) {
      if ((k = prchar((int)(i>=8 ? u>>(i-8) : u<<(8-i)) & 255)) != 0) return k;
   }
   return 0;
}

static long tsin(long x)
{
   static int t[] = {
      0,   12,   25,   37,   49,   61,   74,   86,
      98,  110,  122,  135,  147,  159,  171,  183,
      195,  207,  219,  231,  243,  255,  267,  279,
      290,  302,  314,  325,  337,  348,  360,  371,
      383,  394,  405,  416,  428,  439,  450,  461,
      471,  482,  493,  504,  514,  525,  535,  545,
      556,  566,  576,  586,  596,  606,  615,  625,
      634,  644,  653,  662,  672,  681,  690,  698,
      707,  716,  724,  733,  741,  749,  757,  765,
      773,  781,  788,  796,  803,  810,  818,  825,
      831,  838,  845,  851,  858,  864,  870,  876,
      882,  888,  893,  899,  904,  909,  914,  919,
      924,  929,  933,  937,  942,  946,  950,  953,
      957,  960,  964,  967,  970,  973,  976,  978,
      981,  983,  985,  987,  989,  991,  992,  994,
      995,  996,  997,  998,  999,  999, 1000, 1000,
      1000
   };
   register i;
   long m, n, k;

   x %= 2*3142L;
   if      (x < -3142)   x = -x - 3142;
   else if (x >  3142)   x = -x + 3142;
   if      (x < -3142/2) x = -x - 3142;
   else if (x >  3142/2) x = -x + 3142;
   m = x<0 ? -x : x;
   n = 128 * m % (3142/2);
   i = (int)(m*128/(3142/2));
   k = (t[i] * (3142/2*128 - n) + n * t[i+1]) / (3142/2*128);
   return x<0 ? -k : k;
}

#define OMEGA   (2*3142L)

static int onetest(struct regim *inf, short item)
{
   static char newline[] = "\r\n";
   register i, j;
   register k;
   int last;
   long x;

   if ((k = prtputs(newline))    != 0) return k;
   if ((k = prtputs(inf->title)) != 0) return k;
   if ((k = prtputs(newline))    != 0) return k;
   for (i=0; i<pins[item]-1; i++) {
      if ((k = prchar(i%10 ? '.' : i/10+'0')) != 0) return k;
   }
   if ((k=prchar((pins[item]%10 ? pins[item]%10 : pins[item]/10) + '0'))!=0)
      return k;
   if ((k = prtputs(newline)) != 0) return k;
   if ((k = prtputl(inf->set, inf->len)) != 0) return k;
   last = tset.inch * (inf->dpi);
   if ((k = prchar(last%256)) != 0) return k;
   if ((k = prchar(last/256)) != 0) return k;
   i = 0;
   for (j=0; j<pins[item]; j++) {
      while (i < (j+1)*(inf->dpi)/10) {
         if ((k = prt_por(1L << j, item)) != 0) return k;
         ++i;
      }
   }
   if ((k = prt_por(0L, item)) != 0) return k;
   x = (pins[item] - 1) * 500;
   for (++i; i<last; i++) {
      if ((k =
          prt_por(1L << (unsigned)(
          ((tsin(OMEGA*i/(inf->dpi)) + 1000) * x /1000 + 500) /1000),
          item)) != 0) return k;
   }
   if ((k = prtputs(newline)) != 0) return k;
   return 0;
}

static int pincount(void)
{
   register c, i;
   struct printer *p;
   register struct regim *q;
   int k, item;
   short m;

   m = (_middle+1 + _bottom) / 2;

   scrwipe(_left+1,  _middle+1, _left+38, _bottom-1, BRIGHT);
   dupouts(_left+14, _middle+1, "Pin Counting");

   scrwipe(_left+1,  _middle+2, _left+38, _bottom-2, NORMAL);
   scrouts(_left+4,  _middle+3, "Number of pins (8, 9, or 24): ");

   cursor(2);
   do {
      c = keyserv(4) & 255;
   } while (c!=033 && c!='8' && c!='9' && c!='2' && c!=015);
   cursor(0);
   switch (c) {
   case 033:
      return 0;
   case '2':
      scrputs("24");
      item = 2;
      break;
   case '9':
      scrputs("9");
      item = 1;
      break;
   default :
      scrputs("8");
      item = 0;
      break;
   }

   scrouts(_left+12, _middle+4, "Test printer as");
   for (i=0, p=items[item]; p; ++i, p=p->next) {
      scrgoto(_left+3, _middle+5+i);
      scrputc(i+'0');
      scrputs(". ");
      scrputs(p->title);
   }
   scrouts(_left+9,  _bottom-1, "Enter # of the item: ");
   cursor(2);
   do {
      c = keyserv(0) & 255;
      if (c == 27) {
         c = -1;
      } else if (c>='0' && c<='9') {
         c -= '0';
      } else {
         c = i;
      }
   } while (c >= i);
   cursor(0);
   if (c == -1) return 0;
   scrwipe(_left+1,  _middle+2, _left+38, _bottom-1, NORMAL+BLINK);

   oldvect = getvect(0x24);
   harderr(catch);
   if ((k = setjmp(dosret)) != 0) goto end;

   if ((k = prinit()) != 0) goto end;

   scrouts(_left+15, m, "Printing...");

   for (i=0, p=items[item]; i<c; ++i, p=p->next) ;

   if ((k = prtputs(p->init)) != 0) goto end;

   for (q=p->list; q; q=q->next) if ((k = onetest(q, item)) != 0) goto end;

   if ((k = prexit()) != 0) goto end;
   scrwipe(_left+1, _middle+2, _left+38, _bottom-2, NORMAL);
   k = 0;

end:
   if (k) prstat(k, m);
   setvect(0x24, oldvect);
   return k;
}

static int loadfont(void)
{
   register k, i;
   register short m;
   static unsigned char font_FX[] = {
      0x1B, 'l',  0x00, 0x1B, 'A',  0x0C, 0x1B, 0x21,
      0x00, 0x1B, '6',  0x1B, 0x3A, 0x00, 0x00, 0x00,
      0x1B, 0x25, 0x01, 0x00, 0x1B, 0x26, 0x00, 0x80,
      0xFF, 0x8B, 0x1E, 0x20, 'H',  0x80, 0x08, 0x80,
      'H',  0x20, 0x1E, 0x00, 0x00, 0x8B, 0x82, 0x7C,
      0x82, 0x10, 0x82, 0x10, 0x82, 0x10, 0xCC, 0x00,
      0x00, 0x8B, 0x82, 0x7C, 0x82, 0x10, 0x82, 0x10,
      0x82, 'l',  0x00, 0x00, 0x00, 0x8B, 0x82, 0x7C,
      0x82, 0x00, 0x80, 0x00, 0x80, 0x00, 0xC0, 0x00,
      0x00, 0x8B, 0x03, 0x00, 0x06, 'x',  0x82, 0x00,
      0x82, 0x00, 0xFE, 0x00, 0x03, 0x8B, 0x82, 0x7C,
      0x82, 0x10, 0x82, 0x10, 0x82, 0x00, 0xC6, 0x00,
      0x00, 0x8B, 0x82, 'D',  0x28, 0x10, 0x82, 0x7C,
      0x82, 0x10, 0x28, 'D',  0x82, 0x8B, 0x00, 'D',
      0x82, 0x00, 0x92, 0x00, 0x92, 'l',  0x00, 0x00,
      0x00, 0x8B, 0xFE, 0x00, 0x04, 0x08, 0x10, 0x20,
      0x00, 0xFE, 0x00, 0x00, 0x00, 0x8B, 0x7E, 0x00,
      0x84, 0x08, 0x10, 0xA0, 0x00, 0x7E, 0x00, 0x00,
      0x00, 0x8B, 0xFE, 0x00, 0x10, 0x00, 0x10, 'l',
      0x82, 0x00, 0x82, 0x00, 0x00, 0x8B, 0x02, 0x04,
      '8',  0x40, 0x80, 0x00, 0x80, 0x00, 0xFE, 0x00,
      0x00, 0x8B, 0xFE, 0x00, 0x40, 0x20, 0x10, 0x20,
      0x40, 0x00, 0xFE, 0x00, 0x00, 0x8B, 0xFE, 0x00,
      0x10, 0x00, 0x10, 0x00, 0x10, 0x00, 0xFE, 0x00,
      0x00, 0x8B, '8',  'D',  0x82, 0x00, 0x82, 0x00,
      0x82, 'D',  '8',  0x00, 0x00, 0x8B, 0xFE, 0x00,
      0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0xFE, 0x00,
      0x00, 0x8B, 0xFE, 0x00, 0x88, 0x00, 0x88, 0x00,
      0x88, 0x00, 'p',  0x00, 0x00, 0x8B, '8',  'D',
      0x82, 0x00, 0x82, 0x00, 0x82, 'D',  0x00, 0x00,
      0x00, 0x8B, 0xC0, 0x00, 0x80, 0x00, 0xFE, 0x00,
      0x80, 0x00, 0xC0, 0x00, 0x00, 0x8B, 0x80, 0x40,
      0x22, 0x10, 0x0A, 0x00, 0x0A, 0x04, 0xF8, 0x00,
      0x00, 0x8B, 'p',  0x88, 0x00, 0x88, 0x00, 0xFE,
      0x00, 0x88, 0x00, 0x88, 'p',  0x8B, 0x82, 0x00,
      'D',  0x28, 0x10, 0x28, 'D',  0x00, 0x82, 0x00,
      0x00, 0x8B, 0xFE, 0x00, 0x02, 0x00, 0x02, 0x00,
      0xFE, 0x00, 0x03, 0x00, 0x00, 0x8B, 0xE0, 0x10,
      0x00, 0x10, 0x00, 0x10, 0x00, 0xFE, 0x00, 0x00,
      0x00, 0x8B, 0xFE, 0x00, 0x02, 0x00, 0x1E, 0x00,
      0x02, 0x00, 0xFE, 0x00, 0x00, 0x8B, 0xFE, 0x00,
      0x02, 0x00, 0x1E, 0x00, 0x02, 0x00, 0xFE, 0x00,
      0x03, 0x8B, 0xC0, 0x00, 0x80, 0x00, 0xFE, 0x00,
      0x12, 0x00, 0x12, 0x0C, 0x00, 0x8B, 0xFE, 0x00,
      0x12, 0x00, 0x12, 0x00, 0x12, 0x0C, 0x00, 0xFE,
      0x00, 0x8B, 0xFE, 0x00, 0x12, 0x00, 0x12, 0x00,
      0x12, 0x00, 0x0C, 0x00, 0x00, 0x8B, 'D',  0x82,
      0x00, 0x92, 0x00, 0x92, 'D',  '8',  0x00, 0x00,
      0x00, 0x8B, 0xFE, 0x00, 0x10, 0x00, 0x7C, 0x82,
      0x00, 0x82, 0x00, 0x82, 0x7C, 0x8B, 'b',  0x90,
      0x02, 0x94, 0x08, 0x90, 0x00, 0xFE, 0x00, 0x00,
      0x00, 0x8B, 0x04, 0x0A, 0x20, 0x0A, 0x20, 0x0A,
      0x20, 0x1C, 0x02, 0x00, 0x00, 0x8B, 0x3C, 0x40,
      0x12, 0x40, 0x12, 0x40, 0x12, 0x40, 0x8C, 0x00,
      0x00, 0x8B, 0x3E, 0x00, 0x2A, 0x00, 0x2A, 0x00,
      0x2A, 0x14, 0x00, 0x00, 0x00, 0x8B, 0x3E, 0x00,
      0x20, 0x00, 0x20, 0x00, 0x20, 0x00, '0',  0x00,
      0x00, 0x8B, 0x03, 0x00, 0x0E, 0x10, 0x22, 0x00,
      0x22, 0x1C, 0x03, 0x00, 0x00, 0x8B, 0x1C, 0x22,
      0x08, 0x22, 0x08, 0x22, 0x08, 0x22, 0x18, 0x00,
      0x00, 0x8B, 0x22, 0x14, 0x08, 0x00, 0x3E, 0x00,
      0x08, 0x14, 0x22, 0x00, 0x00, 0x8B, 0x00, 0x22,
      0x00, 0x22, 0x00, 0x2A, 0x00, 0x2A, 0x14, 0x00,
      0x00, 0x8B, 0x3E, 0x00, 0x04, 0x08, 0x10, 0x00,
      0x3E, 0x00, 0x00, 0x00, 0x00, 0x8B, 0x3E, 0x00,
      'D',  0x08, 'P',  0x00, 0x3E, 0x00, 0x00, 0x00,
      0x00, 0x8B, 0x22, 0x1E, 0x20, 0x08, 0x00, 0x08,
      0x14, 0x22, 0x22, 0x00, 0x00, 0x8B, 0x02, 0x04,
      0x18, 0x20, 0x00, 0x20, 0x00, 0x3E, 0x00, 0x00,
      0x00, 0x8B, 0x3E, 0x00, 0x10, 0x08, 0x10, 0x00,
      0x3E, 0x00, 0x00, 0x00, 0x00, 0x8B, 0x3E, 0x00,
      0x08, 0x00, 0x08, 0x00, 0x3E, 0x00, 0x00, 0x00,
      0x00, 0x8B, 0x1C, 0x22, 0x00, 0x22, 0x00, 0x22,
      0x00, 0x22, 0x1C, 0x00, 0x00, 0x8B, 0x3E, 0x00,
      0x20, 0x00, 0x20, 0x00, 0x3E, 0x00, 0x00, 0x00,
      0x00, 0x8B, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x8B, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x8B, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x8B, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00,
      0x00, 0x8B, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08,
      0xFF, 0x00, 0x00, 0x00, 0x00, 0x8B, 0x08, 0x08,
      0x08, 0x08, 0x08, 0x08, 0xFF, 0x00, 0x00, 0x00,
      0x00, 0x8B, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08,
      0xFF, 0x00, 0x00, 0x00, 0x00, 0x8B, 0x08, 0x08,
      0x08, 0x08, 0x08, 0x08, 0x0F, 0x00, 0x00, 0x00,
      0x00, 0x8B, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08,
      0x0F, 0x00, 0x00, 0x00, 0x00, 0x8B, 0x08, 0x08,
      0x08, 0x08, 0x08, 0x08, 0xFF, 0x00, 0x00, 0x00,
      0x00, 0x8B, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0xFF, 0x00, 0x00, 0x00, 0x00, 0x8B, 0x08, 0x08,
      0x08, 0x08, 0x08, 0x08, 0x0F, 0x00, 0x00, 0x00,
      0x00, 0x8B, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08,
      0xF8, 0x00, 0x00, 0x00, 0x00, 0x8B, 0x08, 0x08,
      0x08, 0x08, 0x08, 0x08, 0xF8, 0x00, 0x00, 0x00,
      0x00, 0x8B, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08,
      0xF8, 0x00, 0x00, 0x00, 0x00, 0x8B, 0x08, 0x08,
      0x08, 0x08, 0x08, 0x08, 0x0F, 0x00, 0x00, 0x00,
      0x00, 0x8B, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0xF8, 0x08, 0x08, 0x08, 0x08, 0x8B, 0x08, 0x08,
      0x08, 0x08, 0x08, 0x08, 0xF8, 0x08, 0x08, 0x08,
      0x08, 0x8B, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08,
      0x0F, 0x08, 0x08, 0x08, 0x08, 0x8B, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0xFF, 0x08, 0x08, 0x08,
      0x08, 0x8B, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08,
      0x08, 0x08, 0x08, 0x08, 0x08, 0x8B, 0x08, 0x08,
      0x08, 0x08, 0x08, 0x08, 0xFF, 0x08, 0x08, 0x08,
      0x08, 0x8B, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0xFF, 0x08, 0x08, 0x08, 0x08, 0x8B, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0xFF, 0x08, 0x08, 0x08,
      0x08, 0x8B, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0xF8, 0x08, 0x08, 0x08, 0x08, 0x8B, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x0F, 0x08, 0x08, 0x08,
      0x08, 0x8B, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08,
      0xF8, 0x08, 0x08, 0x08, 0x08, 0x8B, 0x08, 0x08,
      0x08, 0x08, 0x08, 0x08, 0x0F, 0x08, 0x08, 0x08,
      0x08, 0x8B, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0xFF, 0x08, 0x08, 0x08, 0x08, 0x8B, 0x08, 0x08,
      0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08,
      0x08, 0x8B, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08,
      0xFF, 0x08, 0x08, 0x08, 0x08, 0x8B, 0x08, 0x08,
      0x08, 0x08, 0x08, 0x08, 0xF8, 0x08, 0x08, 0x08,
      0x08, 0x8B, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08,
      0xF8, 0x08, 0x08, 0x08, 0x08, 0x8B, 0x08, 0x08,
      0x08, 0x08, 0x08, 0x08, 0x0F, 0x08, 0x08, 0x08,
      0x08, 0x8B, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08,
      0x0F, 0x08, 0x08, 0x08, 0x08, 0x8B, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0xF8, 0x08, 0x08, 0x08,
      0x08, 0x8B, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0xF8, 0x08, 0x08, 0x08, 0x08, 0x8B, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x0F, 0x08, 0x08, 0x08,
      0x08, 0x8B, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x0F, 0x08, 0x08, 0x08, 0x08, 0x8B, 0x08, 0x08,
      0x08, 0x08, 0x08, 0x08, 0xFF, 0x08, 0x08, 0x08,
      0x08, 0x8B, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08,
      0xFF, 0x08, 0x08, 0x08, 0x08, 0x8B, 0x08, 0x08,
      0x08, 0x08, 0x08, 0x08, 0xF8, 0x00, 0x00, 0x00,
      0x00, 0x8B, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x0F, 0x08, 0x08, 0x08, 0x08, 0x8B, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x8B, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x8B, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x8B, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x8B, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x8B, 0x3F, 0x00, 0x24, 0x00, 0x24, 0x00,
      0x24, 0x18, 0x00, 0x00, 0x00, 0x8B, 0x1C, 0x22,
      0x00, 0x22, 0x00, 0x22, 0x00, 0x22, 0x14, 0x00,
      0x00, 0x8B, 0x20, 0x00, 0x20, 0x00, 0x3E, 0x00,
      0x20, 0x00, 0x20, 0x00, 0x00, 0x8B, 0x20, 0x11,
      0x08, 0x05, 0x02, 0x04, 0x08, 0x10, 0x20, 0x00,
      0x00, 0x8B, 0x18, 0x24, 0x00, 0x24, 0x5B, 0x24,
      0x00, 0x24, 0x18, 0x00, 0x00, 0x8B, 0x22, 0x00,
      0x14, 0x00, 0x08, 0x00, 0x14, 0x00, 0x22, 0x00,
      0x00, 0x8B, 0x3C, 0x02, 0x00, 0x02, 0x00, 0x02,
      0x00, 0x3E, 0x00, 0x03, 0x00, 0x8B, '0',  0x08,
      0x00, 0x08, 0x00, 0x08, 0x00, 0x3E, 0x00, 0x00,
      0x00, 0x8B, 0x3E, 0x00, 0x02, 0x00, 0x1E, 0x00,
      0x02, 0x00, 0x3E, 0x00, 0x00, 0x8B, 0x3E, 0x00,
      0x02, 0x00, 0x1E, 0x00, 0x02, 0x00, 0x3E, 0x00,
      0x03, 0x8B, 0x10, 0x20, 0x00, 0x3E, 0x00, 0x0A,
      0x00, 0x0A, 0x04, 0x00, 0x00, 0x8B, 0x3E, 0x00,
      0x0A, 0x00, 0x0A, 0x00, 0x0A, 0x04, 0x00, 0x3E,
      0x00, 0x8B, 0x3E, 0x00, 0x0A, 0x00, 0x0A, 0x00,
      0x0A, 0x04, 0x00, 0x00, 0x00, 0x8B, 0x22, 0x00,
      0x22, 0x08, 0x22, 0x08, 0x22, 0x1C, 0x00, 0x00,
      0x00, 0x8B, 0x3E, 0x00, 0x08, 0x00, 0x1C, 0x22,
      0x00, 0x22, 0x00, 0x1C, 0x00, 0x8B, 0x12, 0x28,
      0x02, 0x2C, 0x00, 0x28, 0x00, 0x3E, 0x00, 0x00,
      0x00, 0x8B, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x8B, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x8B, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x8B, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x8B, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x8B, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x8B, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x8B, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x8B, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x8B, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x8B, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x8B, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x8B, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x8B, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x8B, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x8B, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00,
   };

   m = (_middle+1 + _bottom) / 2;

   scrwipe(_left+1,  _middle+1, _left+38, _bottom-1, BRIGHT);
   dupouts(_left+13, _middle+1, "Load Kyrillic");

   scrwipe(_left+1,  _middle+2, _left+38, _bottom-2, NORMAL);
   scrouts(_left+14, _middle+3, "Load font as");
   scrouts(_left+8,  _middle+5, "0) Epson FX");

   scrouts(_left+9,  _bottom-1, "Enter # of the item: ");
   cursor(2);
   do i = keyserv(0) & 255; while (i!='0' && i!=27);
   cursor(0);
   scrwipe(_left+1, _bottom-1, _left+38, _bottom-1, NORMAL);
   if (i == 27) return 0;

   scrwipe(_left+1,  _middle+2, _left+38, _bottom-2, NORMAL+BLINK);

   oldvect = getvect(0x24);
   harderr(catch);
   if ((k = setjmp(dosret)) != 0) goto end;

   if ((k = prinit()) != 0) goto end;

   scrouts(_left+15, m, "Loading...");

   for (i=0; i<sizeof(font_FX); i++) {
      if ((k = prchar(font_FX[i])) != 0) goto end;
   }

   if ((k = prexit()) != 0) goto end;
   scrwipe(_left+1, _middle+2, _left+38, _bottom-2, NORMAL);
   k = 0;

end:
   if (k) prstat(k, m);
   setvect(0x24, oldvect);
   return k;
}

static struct _menu_data menudata[] = {
   { "Quit",                   NULL   },
   { "Printer parameters",     NULL   },
   { "Output chart",         outchart },
   { "check carriage Width", cr_width },
   { "Count pins",           pincount },
   { "Load kyrillic",        loadfont },
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
   if ((menuauto[item].res = (menudata[item].fun)()) != 0) {
      scrwipe(_diag_left,     menuauto[item].row,
              _diag_left+2,   menuauto[item].row, ITALIC);
      scrouts(_diag_left,     menuauto[item].row, "err");
      status = ERROR;
   } else {
      scrwipe(_diag_left,     menuauto[item].row,
              _diag_left+2,   menuauto[item].row, NORMAL);
      scrouts(_diag_left,     menuauto[item].row, " √ ");
   }
}

main(argc, argv)
char *argv[];
{
   register i, j, k, h; register c;
   register ins, run;
   struct _menu_auto menuauto[dim(menudata)];

   colorset(argc, argv);
   AskVideo(&_vinfo);
   _left    = _vinfo.vs_width/2 - 20;
   _bottom  = _vinfo.vs_height - 1;
   _middle  = _bottom / 2;

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

   _menu_left = (_vinfo.vs_width - k - 6) / 2 + 2;
   _diag_left = _menu_left + k + 1;

   current = 0;

   cursor(0);
   fillside(_vinfo.vs_width, _vinfo.vs_height);
   scrwipe(_left, 0, _left+39, _bottom, BORDER);
   scrouts(_left, 0, "╔══════════════════════════════════════╗");
   scrouts(_left+11, 0, mainame); scrputs(version);
   for (i=1; i<_bottom; i++) {
      scrouts(_left,    i, "║");
      scrouts(_left+39, i, "║");
   }
   scrouts(_left, _bottom, "╚══════════════════════════════════════");
   scrpoke((BORDER<<8) + 188);
   scrouts(_left, _middle, "╟──────────────────────────────────────╢");
#ifdef LOGGING
   logflag = !(ioctl(fileno(stdout), 0) & 128);
   if (logflag) {
      printf("\n          ----------%s\t\t%s\t    ----------\n",
                    mainame, version);
   }
#endif
   scrwipe(_menu_left, 1, _diag_left-2, _middle-1, NORMAL);
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

   tset.inch  = 8;
   tset.level = LEV_DOS;
   tset.type  = 0;
   tset.port  = 0;
   tset.comm  = 0xE3; /* 9600, none, 1 stop, 8 data */

   status = 0;

   while (1) {
      /* output parameters */
      scrwipe(_left+3, 2, _left+36, 2, INVERT);
      scrgoto(_left+3, 2);
      scrputc(tset.inch > 9 ? tset.inch / 10 + '0' : ' ');
      scrputc(tset.inch % 10 + '0');
      scrputc(042);
      scrouts(_left+8, 2, leveltab[tset.level]);
      scrputs(": ");
      scrputs(tset.type ? "COM" : "LPT");
      scrputc('1' + tset.port);
      if (tset.type) {
         scrputc(' ');
         scrputs(baudtab[tset.comm >> 5]);
         scrputs(", ");
         scrputs((tset.comm & 030) == PAR_EVEN ? "even,  " :
             (tset.comm & 030) == PAR_ODD  ? "odd,   " : "none, ");
         scrputc(tset.comm & 4 ? '2' : '1');
         scrputs(" stop");
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
               touchitem(menuauto, INVERT);
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
               for (i=BEG_TEST; i<dim(menudata); i++) {
                  markitem(menuauto, i, FALSE, i==current ? INVERT : NORMAL);
               }
               break;
            case 0x4E:
               for (i=BEG_TEST; i<dim(menudata); i++) {
                  markitem(menuauto, i, TRUE, i==current ? INVERT : NORMAL);
               }
               break;
            case 0x1C:
               for (ins=FALSE, i=BEG_TEST; i<dim(menudata); i++) {
                  if (menuauto[i].ins) ins = TRUE;
               }
               run = TRUE;
               break;
         }
      } while (!run);

      if (ins) {
         for (i=BEG_TEST; i<dim(menudata); i++) {
            if (menuauto[i].ins) {
               runtest(menuauto, i);
               markitem(menuauto, i, FALSE, i==current ? INVERT : NORMAL);
               if (menuauto[i].res) goto fault;
            }
         }
fault:   ;
      } else if (current == 0) {
         goto e;
      } else if (current == 1) {
         touchitem(menuauto, INVERT); prparams();
      } else {
         runtest(menuauto, current);
      }
   }
e: scrwipe(0, 0, _vinfo.vs_width-1, _bottom, EMPTY);
   scrgoto(0, 0);
#ifdef LOGGING
   if (logflag && !status) printf("          No I/O errors while printing\n");
#endif
   return status;
}
