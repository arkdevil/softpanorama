/* doz.c: 'Do Z' test/demo program for UNIX-like compression */

#ifndef __TURBOC__
#	include <sys/types.h>
#else
#	include <io.h>
#endif
#include <sys/stat.h>
#include <stdlib.h>
#include <stdio.h>

#include "lzpipe.h"

FILE *inp, *out;
struct stat s;
long this;

static int getbyte()
{
   register b;
   b = getc(inp);
   if (ferror(inp)) {
      perror("Read error"); exit(-1);
   }
   return b;
}

static int putbyte(int b)
{
   if (putc(b, out) == EOF) {
      perror("Write error"); exit(-1);
   }
   return 0;
}

static void prratio(num, den)
long num, den;
{
   register long q;	/* permits |result| > 655.36% */

   if (num > 214748L) { /* 2147483647/10000 */
      q = (int)(num / (den / 10000L));
   } else {
      q = (int)(10000L * num / den); /* Long calculations, though */
   }
   if (q < 0) {
      fprintf(stderr, "-");
      q = -q;
   }
   fprintf(stderr, "%d.%02d%%", (int)(q / 100), (int)(q % 100));
}

static char todo = ' ';
static int bits = 16;

main(argc, argv)
char *argv[];
{
   char buf[1024];
   register char *p;
   register i;
   long l;

   for (i=1; i<argc && *(p=argv[i]) == '-'; i++) {
      while (*++p) {
         switch (*p) {
            case 'C': case 'c':
               if (todo != ' ') goto ambiguos;
               todo = 'c';
               break;
            case 'D': case 'd':
               if (todo != ' ') goto ambiguos;
               todo = 'd';
               break;
            ambiguos:
               (void)fprintf(stderr, "The only \'c\' or \'d\' is allowed\n");
               return -1;
            case 'B': case 'b':
               bits = atoi(argv[++i]);
               if (bits < 9 || bits > 16) {
                  (void)fprintf(stderr, "Invalid bits factor\n");
                  return -1;
               }
               break;
            default :
               (void)fprintf(stderr, "Unknown option \'%c\'\n", *p);
               return -1;
         }
      }
   }
   if (i+2 != argc) {
      (void)fprintf(stderr, "Usage: doz -c|d [-b nn] <input> <output>\n");
      return -1;
   }
   if ((inp = fopen(argv[i], "rb")) == NULL) {
      perror(argv[i]); exit(-1);
   }
   if ((out = fopen(argv[i+1], "wb")) == NULL) {
      perror(argv[i+1]); exit(-1);
   }
   this = 0;
   if (fstat(fileno(inp), &s) != 0) {
      perror(argv[i]); return -1;
   }
   switch (todo) {
      case 'c':
         if ((i = lzwcreat(putbyte, s.st_size, bits)) < bits) {
            if (i > 0) (void)fprintf(stderr, "Can only handle %d bits\n", i);
            lzwfree();
            return -1;
         }
         l = s.st_size;
         while (l > 0) {
            i = l > sizeof(buf) ? sizeof(buf) : (int)l;
            if (read(fileno(inp), buf, i) != i) {
               perror("Read error"); return -1;
            }
            (void)lzwwrite(buf, i);
            l -= i;
         }
         l = lzwclose();
         prratio(l, s.st_size);
         i = l >= s.st_size;
         break;
      case 'd':
         if ((i = lzwopen(getbyte)) != 0) {
            if (i == -1) {
               (void)fprintf(stderr, "File is not in compressed format\n");
            } else {
               (void)fprintf(stderr, "Not enough memory");
               if (i >= 12) (void)fprintf(stderr," to process %d bits",i);
               (void)fprintf(stderr, "\n");
            }
            return -1;
         }
         do {
            i = lzwread(buf, sizeof(buf));
            if (i > 0 && write(fileno(out), buf, i) != i) {
               (void)fprintf(stderr, "Write error\n");
               return -1;
            }
         } while (i == sizeof(buf));
         break;
      default :
         (void)fprintf(stderr, "Either \'c\' or \'d\' must be specified\n");
         return -1;
   }
   return i;
}
