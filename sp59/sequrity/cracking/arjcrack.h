#ifndef _ARH_DEF_
#define _ARH_DEF_

#include <stdio.h>
#include <limits.h>

typedef void           voidp;
typedef unsigned char  uchar;   /*  8 bits or more */
typedef unsigned int   uint;    /* 16 - 32 bits or more */
typedef unsigned short ushort;  /* 16 bits or more */
typedef unsigned long  ulong;   /* 32 bits or more */

#define USHRT_BIT   (CHAR_BIT * sizeof(ushort))

/* ********************************************************* */
/* Environment definitions (implementation dependent)        */
/* ********************************************************* */

#define PATH_SEPARATORS     "\\:"
#define PATH_CHAR           '\\'
#define MAXSFX              25000L
#define ARJ_SUFFIX          ".ARJ"
#define ARJ_DOT             '.'
#define FNAME_MAX           512
#define SWITCH_CHARS        "-"
#define FIX_PARITY(c)       c &= ASCII_MASK
#define DEFAULT_DIR         ""

/*------------------------ Error levels ---------------------*/

#define ERROR_OK        0       /* success */
#define ERROR_WARN      1       /* minor problem (file not found) */
#define ERROR_FAIL      2       /* fatal error */
#define ERROR_CRC       3       /* CRC error */
#define ERROR_SECURE    4       /* ARJ security invalid or not found */
#define ERROR_WRITE     5       /* disk full */
#define ERROR_OPEN      6       /* can't open file */
#define ERROR_USER      7       /* user specified bad parameters */
#define ERROR_MEMORY    8       /* not enough memory */

/* ********************************************************* */
/* end of environmental defines                              */
/* ********************************************************* */

#define CODE_BIT          16
#define NULL_CHAR       '\0'
#define MAXMETHOD          4
#define ARJ_VERSION        3
#define ARJ_X_VERSION      3    /* decoder version */
#define ARJ_X1_VERSION     1
#define DEFAULT_METHOD     1
#define DEFAULT_TYPE       0    /* if type_sw is selected */
#define HEADER_ID     0xEA60
#define HEADER_ID_HI    0xEA
#define HEADER_ID_LO    0x60
#define FIRST_HDR_SIZE    30
#define FIRST_HDR_SIZE_V  34
#define COMMENT_MAX     2048
#define HEADERSIZE_MAX   (FIRST_HDR_SIZE + 10 + FNAME_MAX + COMMENT_MAX)
#define BINARY_TYPE        0    /* This must line up with binary/text strings */
#define TEXT_TYPE          1
#define COMMENT_TYPE       2
#define DIR_TYPE           3
#define LABEL_TYPE         4

#define GARBLE_FLAG     0x01
#define VOLUME_FLAG     0x04
#define EXTFILE_FLAG    0x08
#define PATHSYM_FLAG    0x10
#define BACKUP_FLAG     0x20

typedef ulong UCRC;     /* CRC-32 */
#define CRC_MASK        0xFFFFFFFFL
#define ARJ_PATH_CHAR   '/'

#define FA_RDONLY       0x01            /* Read only attribute */
#define FA_HIDDEN       0x02            /* Hidden file */
#define FA_SYSTEM       0x04            /* System file */
#define FA_LABEL        0x08            /* Volume label */
#define FA_DIREC        0x10            /* Directory */
#define FA_ARCH         0x20            /* Archive */

#define HOST_OS_NAMES1 "MS-DOS","PRIMOS","UNIX","AMIGA","MAC-OS","OS/2"
#define HOST_OS_NAMES2 "APPLE GS","ATARI ST","NEXT","VAX VMS"
#define HOST_OS_NAMES  { HOST_OS_NAMES1, HOST_OS_NAMES2, NULL }

/*------------------------- Timestamp macros ----------------------*/

#define get_tx(m,d,h,n) (((ulong)m<<21)+((ulong)d<<16)+((ulong)h<<11)+(n<<5))
#define get_tstamp(y,m,d,h,n,s) ((((ulong)(y-1980))<<25)+get_tx(m,d,h,n)+(s/2))

#define ts_year(ts)  ((uint)((ts >> 25) & 0x7f) + 1980)
#define ts_month(ts) ((uint)(ts >> 21) & 0x0f)      /* 1..12 means Jan..Dec */
#define ts_day(ts)   ((uint)(ts >> 16) & 0x1f)      /* 1..31 means 1st..31st */
#define ts_hour(ts)  ((uint)(ts >> 11) & 0x1f)
#define ts_min(ts)   ((uint)(ts >> 5) & 0x3f)
#define ts_sec(ts)   ((uint)((ts & 0x1f) * 2))

/* unarj.c */

extern long origsize;
extern long compsize;
extern UCRC crc;
extern ushort bitbuf;
extern uchar subbitbuf;
extern uchar header [HEADERSIZE_MAX];
extern char arc_name [FNAME_MAX];
extern int bitcount;
extern int file_type;
extern int error_count;

/*--------------------------- Global functions -----------------------*/

/* unarj.c */

void   strlower    (char *);
void   strupper    (char *);
int    fillbuf     (int);
void   crc_buf     (char *,int);
ushort getbits     (int,int *);
int    init_getbits   (void);

/* decode.c */

void   decode   (void);
void   decode_f (void);

#endif

/* end UNARJ.H */
