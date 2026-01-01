#include <stdio.h>
#include "modern.h"
#include "lzpipe.h"
#include "zalloc.h"
#include "oscode.h"
#include "crc32.h"
#define __ALLOCEXT__
#include "zipguts.h"
#ifndef UNIX
#	ifdef M_XENIX
#		define UNIX
#	endif
#	ifdef unix
#		define UNIX
#	endif
#endif
#ifdef UNIX
#	include <time.h>
#endif
#ifdef MSDOS
#	include <dos.h>
#	ifdef __TURBOC__
#		include <io.h>
#	endif
#endif

static unsigned long dostime __ARGS__((void))
{
#ifdef MSDOS
# ifdef __TURBOC__
   union { struct date d; struct time t; } u;
   struct ftime f;

   getdate(&u.d);
   f.ft_year  = u.d.da_year - 1980;
   f.ft_month = u.d.da_mon;
   f.ft_day   = u.d.da_day;

   gettime(&u.t);
   f.ft_hour  = u.t.ti_hour;
   f.ft_min   = u.t.ti_min;
   f.ft_tsec  = u.t.ti_sec;

   return *(unsigned long *)&f;
# else
   uninon REGS r;
   unsigned d;

   r.h.ah = 0x2A; /* get date */ intdos(&r, &r);
   d = ((r.x.cx - 1980) << 9) | (r.h.dh << 5) | r.h.dl;

   r.h.ah = 0x2C; /* get time */ intdos(&r, &r);
   return ((unsigned long)d << 16) |
      (r.h.ch << 11) | (r.h.cl << 5) | (r.h.dh >> 1);
# endif
#else
# ifdef UNIX
   extern long time();
   struct tm *s;
   long t;

   (void)time(&t);
   s = localtime(&t);
   if (s->tm_year < 80) return 0L;
   return ((unsigned long)(s->tm_year - 80) << 25) |
      ((unsigned long)s->tm_mon << 21) | ((unsigned long)s->tm_mday << 16) |
      ((unsigned)s->tm_hour << 11) | (s->tm_min << 5) | (s->tm_sec >> 1);
# else
   /* dummy time stamp */ return 0L;
# endif
#endif
}

#ifndef zalloc
/* Turbo C malloc() does not allow dynamic allocation of 64K bytes
 * and farmalloc(64K) returns a pointer with nonzero offset, so we
 * must fix the pointer. Warning: the pointer must be saved in its
 * original form in order to free it, use farfree().
 * For MSC, use halloc instead of this function.
 */
void far *zalloc(void far **p, unsigned n, unsigned s)
{
   register unsigned long l;
   l = (unsigned long)(*p = farmalloc((unsigned long)n*s + 15));
   return (void far *)
      ((0xffff0000L & l) + (0xffff0000L & (((0xffffL & l) + 15) << 12)));
}
#endif

int zipalloc()
{
#ifdef DYN_ALLOC
   if (ct_alloc() != 0) return ZNOMEM;
   if (lm_alloc() != 0) {
      ct_free(); return ZNOMEM;
   }
#endif
   return 0;
}

void zipfree()
{
#ifdef DYN_ALLOC
   lm_free();
   ct_free();
#endif
}

#define putword(x) bi_putsh(x)
static int putlong __ARGS__((ulg));

static int putlong(l)
ulg l;
{
   return (putword((unsigned)l)!=0 ||
           putword((unsigned)(l >> 16))!=0) ? ZWRITE : 0;
}

static ulg inpsize;
#ifdef DEBUG
       ulg isize;
#endif
static int ziptype;
static ulg timestamp;
static ush flags;

/* speed options for the general purpose bit flag */
#define FAST 4
#define SLOW 2

int zipcreat(out_port, ztype, dlevel)
#ifdef LZFILE
	FILE *out_port;
#else
	int (*out_port)__ARGS__((int));
#endif
int ztype, dlevel;
{
   register k;

   if (dlevel<1  || dlevel>9 || (ztype!=ZIP_PKW && ztype!=ZIP_GNU))
      return (lzerror = ZUNSUP);
   deflate_level = dlevel;
   flags = dlevel <= 1 ? FAST : dlevel >= 9 ? SLOW : 0;
   ziptype = ztype;

   crcbegin();
   bi_init();
   if (ct_init() != 0) return (lzerror = ZNOMEM);
   if ((k=lm_init()) != 0) {
#ifdef DYN_ALLOC
      ct_free();
#endif
      return (lzerror = k);
   }
   zip_out_port = out_port;
   /* Write the header to the gzip file */
   /* No extra field, file name or comment; no encryption */
   if (ziptype == ZIP_GNU) {
      if (putword(GZIP_MAGIC) != 0 || /* magic header */
          putbyte(DEFLATED) == EOF || /* compression method */
          putbyte(0) == EOF        || /* general flags: nothing */
          putlong(0L) != 0         || /* dummy time stamp */
          putbyte((int)flags)==EOF || /* extra flags */
          putbyte(OS_CODE) == EOF)    /* OS identifier */
         return (lzerror = ZWRITE);
   } else {
      if (putlong(PKW_LOCAL) != 0 || /* magic header */
          putword(19)        != 0 || /* version to extract */
          putword(flags|=8)  != 0 ||
          putword(DEFLATED)  != 0 || /* compression method */
      /* Who, the hell, needs in this time stamp? */
          putlong(timestamp = dostime()) != 0 ||
          putlong(0L) != 0 || /* dummy CRC */
          putlong(0L) != 0 || /* dummy compressed size */
          putlong(0L) != 0 || /* dummy original size */
          putlong(0L) != 0)   /* null file name & extra fields */
         return (lzerror = ZWRITE);
   }
   inpsize = 0L;
   return 0;
}

int zipwrite(buffer, length)
char *buffer; unsigned length;
{
   register k;

   if (!zip_out_port) return (lzerror=ZNOPEN, -1);
   if (length) {
      updcrc((unsigned char *)buffer, length);
      inpsize += length;
   }
   k = deflate_level > 3 ?
          lazy_deflate(buffer, length) :
          fast_deflate(buffer, length);
   if (k == -1) lzerror = ZWRITE;
   return k;
}

long zipclose()
{
   extern unsigned minlookahead;
   register long l = -1;
   ulg clen, crc;

   minlookahead = 0; /* indicate end of input */
   /* Flush out any remaining bytes */
   if (zipwrite(NULL,0) != 0) goto end;
   clen = (compressed_len >> 3);
   crc = getcrc();
   if (ziptype == ZIP_GNU) {
      /* Write the crc. & uncompressed size */
      if (putlong(crc) != 0 || putlong(inpsize) != 0) {
         lzerror = ZWRITE; goto end;
      }
      l = 10 + clen + 8;
   } else {
      /* Write the /data descriptor/ extended local header */
      if (putlong(PKW_EXT)    != 0 || /* signature */
          putlong(crc)        != 0 || /* CRC */
          putlong(clen)       != 0 || /* compressed size */
          putlong(inpsize)    != 0 || /* uncompressed size */
      /* Write the central directory entry */
          putlong(PKW_CENTRAL)!= 0 ||
          putword((OS_CODE<<8)|20) != 0 || /* version made by */
          putword(19)         != 0 || /* version to extract */
          putword(flags)      != 0 ||
          putword(DEFLATED)   != 0 || /* compression method */
          putlong(timestamp)  != 0 ||
          putlong(crc)        != 0 || /* CRC */
          putlong(clen)       != 0 || /* compressed size */
          putlong(inpsize)    != 0 || /* original size */
          putlong(0L)         != 0 || /* filename & extra field length */
          putword(0)          != 0 || /* file comment length */
          putword(0)          != 0 || /* disk number start */
          putword(0)          != 0 || /* internal file attributes */
          putlong(0L)         != 0 || /* external file attributes */
          putlong(0L)         != 0 || /* relative offset of local header */
      /* Finish the central directory */
          putlong(PKW_END)    != 0 ||
	  putlong(0L)         != 0 || /* disk numbers - don't care */
	  putword(1) != 0 || /* total number of CD entries on this disk */
	  putword(1) != 0 || /* total number of CD entries */
          putlong(46L)        != 0 || /* size of the central directory */
	  putlong(30+clen+16) != 0 || /* offset of start of CD */
          putword(0) != 0) { /* zipfile comment length */
         lzerror = ZWRITE; goto end;
      }
      l = 30 + clen + 84;
   }
end:
   zip_out_port = NULL;
   zipfree();
   return l;
}
