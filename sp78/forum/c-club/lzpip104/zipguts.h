#ifdef __ALLOCEXT__
#	define EXTERN
#	define INI(x) = x
#else
#	define EXTERN extern
#	define INI(x)
#endif
#ifndef __ARGS__
#	include "modern.h"
#endif
#define OF __ARGS__
#ifndef WSIZE
#	include "zipdefs.h"
#endif
#ifndef zfree
#	include "zalloc.h"
#endif

#define MIN_MATCH  3
#define MAX_MATCH  258
/* The minimum and maximum match lengths */

#define MIN_LOOKAHEAD (MAX_MATCH+MIN_MATCH+1)
/* Minimum amount of lookahead, except at the end of the input file.
   See deflate.c for comments about the MIN_MATCH+1. */

#define MAX_DIST  (WSIZE-MIN_LOOKAHEAD)
/* In order to simplify the code, particularly on 16 bit machines, match
   distances are limited to MAX_DIST instead of WSIZE. */

EXTERN int deflate_level INI(6);
extern ulg compressed_len;
#ifdef LZFILE
#	ifdef EOF
		EXTERN FILE *zip_out_port INI(NULL);
#		define putbyte(b) putc(b, zip_out_port)
#	endif
#else
	EXTERN int (*zip_out_port)__ARGS__((int)) INI(NULL);
#	define putbyte(b) (*zip_out_port)(b)
#endif

#ifdef __OS2__
#  ifndef OS2
#    define OS2
#   endif
#endif
/* Diagnostic functions */
#ifdef DEBUG
# ifdef MSDOS
#  undef  stderr
#  define stderr stdout
# endif
# ifdef OS2
#  undef  stderr
#  define stderr stdout
# endif
#  define Assert(cond,msg) {if(!(cond)) error(msg);}
#  define Trace(x) fprintf x
#  define Tracev(x) {if (verbose) fprintf x ;}
#  define Tracevv(x) {if (verbose>1) fprintf x ;}
#  define Tracec(c,x) {if (verbose && (c)) fprintf x ;}
#  define Tracecv(c,x) {if (verbose>1 && (c)) fprintf x ;}
#else
#  define Assert(cond,msg)
#  define Trace(x)
#  define Tracev(x)
#  define Tracevv(x)
#  define Tracec(c,x)
#  define Tracecv(c,x)
#endif

/* Public function prototypes */

void warn  OF((char *, char *));
void err   OF((int c, char *h));
void error OF((char *h));

int file_read OF((char *buf, unsigned size));

        /* in deflate.c */
#ifdef DYN_ALLOC
int  lm_alloc OF((void));
void lm_free  OF((void));
#endif
int lm_init OF((void));
int fast_deflate OF((char*, unsigned));
int lazy_deflate OF((char*, unsigned));

        /* in trees.c */
#ifdef DYN_ALLOC
int  ct_alloc OF((void));
void ct_free  OF((void));
#endif
int  ct_init  OF((void));
int  ct_tally OF((int dist, int lc));
ulg  flush_block OF((char far *buf, ulg stored_len, int eof));

        /* in bits.c */
void bi_init   OF((void));
int send_bits  OF((unsigned value, int length));
int bi_windup  OF((void));
int bi_putsh   OF((unsigned short));
int copy_block OF((char far *buf, unsigned len, int header));
