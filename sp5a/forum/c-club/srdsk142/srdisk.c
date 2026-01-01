/*
**      ReSizeable RAMDisk formatter
**
**      Copyright (c) 1992 Marko Kohtala
**
**      Some documentation and license available in accompanying file
**      SRDISK.DOC. If not, contact author by sending E-mail from
**
**              Internet, Bitnet etc. to 'Marko.Kohtala@hut.fi'
**              CompuServe to '>INTERNET:Marko.Kohtala@hut.fi'
**
**      or by calling Airline QBBS, 24H, HST, V.32, V.42, MNP,
**      +358-0-8725380, and leaving mail to me, Marko Kohtala.
**
**      In general, this is FREEWARE.
**
**      Compilable with Borland C++ 3.0.
**
*/

#include "srdisk.h"
#include <stdio.h>
#include <conio.h>
#include <ctype.h>
#include <time.h>
#include <dos.h>

struct config_s far *mainconf;
struct config_s far *conf;

struct format_s f, newf;
int changed_format;   /* Differences between f and newf */

int root_files = 1;   /* Number of files in root directory */
int max_bps = 512;    /* Largest possible sector size on system */

/* To get enough stack */
unsigned _stklen = 0x2000;

/*
**  SYNTAX
*/

void print_syntax(void)
{
  fputs(
  "\n"
  "Syntax:  SRDISK [<drive letter>[:]] [<size>] [/F:<DOS disk type>]\n"
  "\t\t[/S:<sector size>] [/C:<cluster size>] [/D:<dir entries>]\n"
  "\t\t[/A:<FAT copies>] [/M:<size>[:<size>[...]]] [/W[-]]\n"
  "\t\t[/V:<verbose>] [/O] [/Y] [/E] [/?]\n\n"

  "Anything inside [] is optional, the brackets must not be typed.\n"
  "'<something>' must be replaced by what 'something' tells.\n\n"

  "<drive letter> specifies the drive that is the RAM disk.\n"
  "<size> determines the disk size in kilobytes.\n"
  "/F:<DOS disk type> may be one of 1, 160, 180, 320, 360, 720, 1200, 1440.\n"
  "/S:<sector size> is a power of 2 in range from 128 to 512 bytes.\n"
  "/C:<cluster size> is a power of 2 in range from 128 to 8192 bytes.\n"
  "/D:<dir entries> is the maximum number of entries in the root directory.\n"
  "/A:<FATs> number of File Allocation Tables on disk. 1 or 2. 1 is enough.\n"
  "/M List of max memory to allocate by each driver in driver chain\n"
  "/W Write protect disk, /W- enables writes.\n"
  "/V Verbose level from 1 (quiet) to 5 (verbose); default 2.\n"
  "/E Set environment variables SRDISKn (n=1,2,...) to SRDISK drive letters.\n"
  "/O Old format as default.               /Y Yes, destroy the contents.\n"
  "/? This help.\n"
  , stderr);
}


/*
**  ERROR HANDLING FUNCTIONS
*/

void syntax(char *err)
{
  fprintf(stderr, "\nSyntax error: %s\n", err);
  print_syntax();
  exit(3);
}

void fatal(char *err)
{
  fprintf(stderr, "\nFatal error: %s\n", err);
  exit(1);
}

void error(char *err)
{
  fprintf(stderr, "\nError: %s\n", err);
  return;
}

void warning(char *err)
{
  fprintf(stderr, "\nWarning: %s\n", err);
  return;
}


/*
**  Local allocation routine with error check
*/

void *xalloc(size_t s)
{
  void *b = malloc(s);
  if (!s) fatal("malloc() failed");
  return b;
}

/*
**  Get Y/N response
*/

int getYN(void)
{
  int reply;

  if (force_f) reply = 'Y';
  else {
    do reply = toupper(getch());
    while (reply != 'Y' && reply != 'N');
  }
  printf("%c\n", reply);
  if (reply == 'N') return 0;
  return 1;
}


/*
**  DOS time format conversions
*/

dword DOS_time(time_t time)
{
  struct tm *ltime;
  union {
    struct {
      unsigned int
           sec2 : 5,
           min : 6,
           hour : 5,
           day : 5,
           month : 4,
           year : 7;
    } f;
    dword l;
  } file_time;

  ltime = localtime(&time);
  file_time.f.sec2 = ltime->tm_sec;
  file_time.f.min = ltime->tm_min;
  file_time.f.hour = ltime->tm_hour;
  file_time.f.day = ltime->tm_mday;
  file_time.f.month = ltime->tm_mon + 1;
  file_time.f.year = ltime->tm_year - 80;

  return file_time.l;
}

/*
**  CONFIGURATION POINTER CHECKUP
*/

struct config_s far *conf_ptr(struct dev_hdr _seg *dev)
{
  struct config_s far *conf;
  if (!dev) return (void far *)NULL;
  conf = MK_FP(dev, dev->conf);
  if (dev->u.s.ID[0] != 'S'
   || dev->u.s.ID[1] != 'R'
   || dev->u.s.ID[2] != 'D'
   || dev->v_format != V_FORMAT
   || (conf->drive != '$'
      && !(   (conf->drive >= 'A' && conf->drive <= 'Z')
           || (conf->drive >= '1' && conf->drive <= '9')) )
   || !conf->disk_IO
   || !conf->malloc_off)
    fatal("SRDISK devices' internal tables are messed up!");
  return conf;
}


/*
**  SET WRITE PROTECT
*/

void set_write_protect(void)
{
  if (!(newf.RW_access & WRITE_ACCESS)) {
    conf->RW_access = READ_ACCESS;
    if (verbose > 1)
      printf("\nWrite protect enabled\n");
  }
  else {
    conf->RW_access = READ_ACCESS|WRITE_ACCESS;
    if (verbose > 1)
      printf("\nWrite protect disabled\n");
  }
}

/*
**  MAIN FUNCTION
*/

int main(int argc, char *argv[])
{
  printf("ReSizeable RAMDisk Formatter version "VERSION". "
         "Copyright (c) 1992 Marko Kohtala.\n");

  if (argc > 1) parse_cmdline(argc, argv);
  else if (verbose > 1) printf("\nFor help type 'SRDISK /?'.\n");

  if (verbose == -1) verbose = 2;

  init_drive();             /* Get pointer to driver configuration */

  if (f_set_env) set_env();

  if (format_f) format_disk();
  else if (changed_format & WRITE_PROTECTION) set_write_protect();
  else if (!f_set_env && verbose < 4 && verbose > 1) {
    if (f.size) print_format(&f);
    else printf("\nDrive %c: disabled\n", drive);
  }

  return 0;
}

