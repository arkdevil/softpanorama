#ifndef WSIZE
#  define WSIZE 0x8000
#endif
/* Maximum window size = 32K. If you are really short of memory, you may
 * compile with a smaller WSIZE but this reduces the compression ratio for
 * files of size > WSIZE.
 * Note, the above notice valid for deflation (compression) process only.
 * Inflation (decompression) process always requires at least 32K window.
 * WSIZE must be a power of two in the current implementation.
 */

#define STORED   0 /* compression methods */
#define DEFLATED 8

#define GZIP_MAGIC   0x8b1f
#define PKW_01_MAGIC 0x4b50
#define PKW_23_MAGIC 0x0403
#define PKW_LOCAL    (PKW_01_MAGIC+((ulg)PKW_23_MAGIC<<16))
#define PKW_CENTRAL  (PKW_01_MAGIC+0x02010000L)
#define PKW_END      (PKW_01_MAGIC+0x06050000L)
#define PKW_EXT      (PKW_01_MAGIC+0x08070000L)

/* Types centralized here for easy modification */
typedef unsigned char uch;  /* unsigned 8-bit value */
typedef unsigned short ush; /* unsigned 16-bit value */
typedef unsigned long ulg;  /* unsigned 32-bit value */

#define ERROR (-1)
#define FALSE 0
#define TRUE  1
