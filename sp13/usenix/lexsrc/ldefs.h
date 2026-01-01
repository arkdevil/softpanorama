#include <stdio.h>
#define PP 1
#define ediag(x, y) x
#define cfree(x,y,z) free(x)

#ifdef	__MSDOS__
#define CWIDTH 8
#define CMASK  0377
#define Ucode
#define NCH    256
#endif

#ifdef unix
# define CWIDTH 8
# define CMASK 0377
# if !defined(KOI8) && !defined(Ucode)
#  include <sys/code.h>
# endif
#endif

#ifdef gcos
# define CWIDTH 9
# define CMASK 0777
# define ASCII 1
#endif

#ifdef ibm
# define CWIDTH 8
# define CMASK 0377
# define EBCDIC 1
#endif

#ifdef ASCII
# define NCH 128
#endif

#if  defined(Ucode) || defined(KOI8)
# define NCH 256
#endif

#ifdef EBCDIC
# define NCH 256
#endif

#define U(x)            ((unsigned)(x))
#define C(x)            ((x)&CMASK)

#define TOKENSIZE       1000
#define DEFSIZE         40
#define DEFCHAR         1000
#define STARTCHAR       100
#define STARTSIZE       256
#define CCLSIZE         1000

#ifdef SMALL
# define TREESIZE       600
# define NTRANS         1500
# define NSTATES        300
# define MAXPOS         1500
# define NOUTPUT        1500
#else
# define TREESIZE       1000
# define NTRANS         2000
# define NSTATES        500
# define MAXPOS         2500
# define NOUTPUT        3000
#endif

#define NACTIONS        100
#define ALITTLEEXTRA    30

#define RCCL    NCH+ 90
#define RNCCL   NCH+ 91
#define RSTR    NCH+ 92
#define RSCON   NCH+ 93
#define RNEWE   NCH+ 94
#define FINAL   NCH+ 95
#define RNULLS  NCH+ 96
#define RCAT    NCH+ 97
#define STAR    NCH+ 98
#define PLUS    NCH+ 99
#define QUEST   NCH+100
#define DIV     NCH+101
#define BAR     NCH+102
#define CARAT   NCH+103
#define S1FINAL NCH+104
#define S2FINAL NCH+105

#define DEFSECTION      1
#define RULESECTION     2
#define ENDSECTION      5

#define TRUE    1
#define FALSE   0

#define PC      1
#define PS      1

#ifdef DEBUG
# define LINESIZE       110
extern   int     yydebug;
extern   int     debug;      /* 1 = on */
extern   int     charc;
#else
# define freturn(s)     s
#endif

extern   int     sargc;
extern   char  **sargv;
extern   char    buf[520];
extern   int     yyline;     /* line number of file */
extern   int     sect;
extern   int     Eof;
extern   int     lgatflg;
extern   int     divflg;
extern   int     funcflag;
extern   int     pflag;
extern   int     casecount;
extern   int     chset;      /* 1 = char set modified */
extern   FILE   *fin;
extern   FILE   *fout;
extern   FILE   *fother;
extern   FILE   *errorf;
extern   int     fptr;
extern   char   *cname;
extern   int     prev;       /* previous input character */
extern   int     pres;       /* present input character */
extern   int     Peek;       /* next input character */
extern   int    *name;
extern   int    *left;
extern   int    *right;
extern   int    *parent;
extern   char   *nullstr;
extern   int     tptr;
extern   char   *pushc;
extern   char   *pushptr;
extern   char    slist[STARTSIZE];
extern   char   *slptr;
extern   char  **def;
extern   char  **subs;
extern   char   *dchar;
extern   char  **sname;
extern   char   *schar;
extern   char   *ccl;
extern   char   *ccptr;
extern   char   *dp;
extern   char   *sp;
extern   int     dptr;
extern   int     sptr;
extern   char   *bptr;       /* store input position */
extern   char   *tmpstat;
extern   int     count;
extern   int   **foll;
extern   int    *nxtpos;
extern   int    *positions;
extern   int    *gotof;
extern   int    *nexts;
extern   char   *nchar;
extern   int   **state;
extern   int    *sfall;      /* fallback state num */
extern   char   *cpackflg;   /* true if state has been character packed */
extern   int    *atable;
extern   int     aptr;
extern   int     nptr;
extern   char    symbol[NCH];
extern   char    cindex[NCH];
extern   int     xstate;
extern   int     stnum;
extern   int     ctable[];
extern   int     ZCH;
extern   int     ccount;
extern   char    match[NCH];
extern   char    extra[NACTIONS];
extern   char   *pcptr;
extern   char   *pchar;
extern   int     pchlen;
extern   int     nstates;
extern   int     maxpos;
extern   int     yytop;
extern   int     report;
extern   int     ntrans;
extern   int     treesize;
extern   int     outsize;
extern   long    rcount;
extern   int     optim;
extern   int    *verify;
extern   int    *advance;
extern   int    *stoff;
extern   int     scon;
extern   char   *psave;

extern   char   *calloc();
extern   char   *myalloc();
extern   int     buserr();
extern   int     segviol();
