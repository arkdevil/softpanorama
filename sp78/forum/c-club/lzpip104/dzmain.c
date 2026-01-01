#include <stdio.h>
#include "modern.h"
#ifdef MODERN
#	include <stdlib.h>
#else
	void exit();
#endif
#ifdef __TURBOC__
#	include <io.h>
#endif
#include "lzpipe.h"

FILE *inp, *out;

#ifdef LZFILE
#	define INP_PORT inp
#	define OUT_PORT out
#else
#	define INP_PORT getchr
#	define OUT_PORT putchr

int getchr(void)
{
   register c = getc(inp);
   if (ferror(inp)) {
      perror("Read error"); exit(-1);
   }
   return c;
}

int putchr(int c)
{
   (void)putc(c, out);
   if (ferror(out)) {
      perror("Write error"); exit(-1);
   }
   return 0;
}
#endif

main(argc, argv)
int argc; char *argv[];
{
   char buf[1024];
   register i;
   register char *p;
   char todo = '\0';
   int level = 6;
   int ztype = ZIP_ANY;

   if (argc < 2) {
      (void)fprintf(stderr,
         "Usage: dogzip -c|d [-1-9] [-p|g] infile outfile\n");
      return -1;
   }
   for (i=1; i<argc && *(p = argv[i]) == '-'; i++) {
      ++p;
      switch (*p<'A' || *p>'Z' ? *p : *p+('z'-'Z')) {
         case '1': case '2': case '3':
         case '4': case '5': case '6':
         case '7': case '8': case '9':
            level = *p - '0';
            break;
         case 'c':
            if (todo) goto ambiguous;
            todo = 'c';
            break;
         case 'd':
            if (todo) goto ambiguous;
            todo = 'd';
            break;
         case 'g':
            if (ztype != ZIP_ANY) goto ambiguous;
            ztype = ZIP_GNU;
            break;
         case 'p':
            if (ztype != ZIP_ANY) goto ambiguous;
            ztype = ZIP_PKW;
            break;
         default :
            (void)fprintf(stderr, "Invalid option \'%c\'\n", *p);
            return -1;
      }
   }
   if (ztype == ZIP_ANY) ztype = ZIP_GNU;
   if (!todo) {
      (void)fprintf(stderr, "Either \'c\' or \'d\' must be specified\n");
      return -1;
   }
   if (i+1 >= argc) {
      (void)fprintf(stderr,
         "No %sput file specified\n", i<argc ? "out" : "in");
      return -1;
   }
   if ((inp = fopen(p=argv[ i ], "rb")) == NULL ||
       (out = fopen(p=argv[i+1], "wb")) == NULL) {
      perror(p); return -1;
   }
   if (todo != 'd') {
      if (zipcreat(OUT_PORT, ztype, level)) {
         (void)fprintf(stderr, "Zip error: %s\n", lzerrlist[lzerror]);
         return -1;
      }
      do {
         if ((i = read(fileno(inp), buf, sizeof(buf))) == -1) {
            perror("Read error");
            return -1;
         }
         if (i > 0 && zipwrite(buf, i) != i) {
            (void)fprintf(stderr, "Zip error: %s\n", lzerrlist[lzerror]);
            return -1;
         }
      } while (i == sizeof(buf));
      i = 0;
      if (zipclose() == -1L) {
         (void)fprintf(stderr, "Zip error: %s\n", lzerrlist[lzerror]);
         i = -1;
      }
      if (fclose(out) != 0) {
         perror("Close error"); i = -1;
      }
   } else {
      if (unzopen(INP_PORT, ZIP_ANY)) {
         (void)fprintf(stderr, "Unzip error: %s\n", lzerrlist[lzerror]);
         return -1;
      }
      do {
         if ((i = unzread(buf, sizeof(buf))) == -1) {
            (void)fprintf(stderr, "Unzip error: %s\n", lzerrlist[lzerror]);
            return -1;
         }
         if (i > 0 && write(fileno(out), buf, i) != i) {
            perror("Write error"); return -1;
         }
      } while (i == sizeof(buf));
      if ((i = unzclose()) != 0) {
         (void)fprintf(stderr, "Unzip %s: %s\n",
            i == -1 ? "error" : "warning", lzerrlist[lzerror]);
      }
   }
   return i;
ambiguous:
   (void)fprintf(stderr, "Ambiguous options\n");
   return -1;
}
