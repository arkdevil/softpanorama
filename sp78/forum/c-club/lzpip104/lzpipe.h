#define ZIP_ANY 0
#define ZIP_PKW 1
#define ZIP_GNU 2

#define LZW_ANYSIZE 0x7fffffffL

#ifndef __ARGS__
#  include "modern.h"
#endif

#ifdef LZFILE
#	ifdef EOF
#		define LZ_INP_TYPE FILE*
#		define LZ_OUT_TYPE FILE*
#	else
#		define LZ_INP_TYPE void*
#		define LZ_OUT_TYPE void*
#	endif
#else
#	define LZ_INP_TYPE int(*)(void)
#	define LZ_OUT_TYPE int(*)(int)
#endif

int  unzalloc __ARGS__((void));
int  unzopen  __ARGS__((LZ_INP_TYPE, int));
int  unzread  __ARGS__((char *, unsigned));
void unzfree  __ARGS__((void));
int  unzclose __ARGS__((void));

int  zipalloc __ARGS__((void));
int  zipcreat __ARGS__((LZ_OUT_TYPE, int, int));
int  zipwrite __ARGS__((char *, unsigned));
void zipfree  __ARGS__((void));
long zipclose __ARGS__((void));

int  lzwalloc __ARGS__((int));
int  lzwcreat __ARGS__((LZ_OUT_TYPE, long, int));
int  lzwwrite __ARGS__((char *, unsigned));
void lzwfree  __ARGS__((void));
long lzwclose __ARGS__((void));

int  lzwmark  __ARGS__((int));
int  lzwopen  __ARGS__((LZ_INP_TYPE));
int  lzwread  __ARGS__((char *, unsigned));
void lzwrelease __ARGS__((void));

extern int lzerror;
extern char *lzerrlist[];

#define ZNOPEN 0
#define ZNOMEM 1 /* Not enough memory */
#define ZMAGIC 2 /* Bad magic header */
#define ZUNSUP 3 /* Reserved field or compression method */
#define ZHDEOF 4 /* EOF while processing header */
#define ZMOULD 5 /* Invalid compressed data */
#define ZNOEOF 6 /* More data to process at close */
#define ZBADSZ 7 /* Real size differs from recorded */
#define BADCRC 8 /* It is */
#define ZWRITE 9 /* Error writing output file */
#define ZERROR 10 /* Generic/internal error */
