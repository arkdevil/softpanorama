/* Compress - data compression program */
/* machine variants which require cc -Dmachine:	pdp11, z8000, pcxt */

/* The following code is derived from regular 'compress' program, */
/* revision 4.0 85/07/30 by Joe Orost (decvax!vax135!petsd!joe)   */

/*
 * Algorithm from "A Technique for High Performance Data Compression",
 * Terry A. Welch, IEEE Computer Vol 17, No 6 (June 1984), pp 8-19.
 *
 * Algorithm:
 *	Modified Lempel-Ziv method (LZW).  Basically finds common
 * substrings and replaces them with a variable size code.  This is
 * deterministic, and can be done on the fly.  Thus, the decompression
 * procedure needs no input table, but tracks the way the table was built.
 */
#include <stdio.h>
#include "modern.h"
#include "lzpipe.h"
#include "lzwbits.h"

#ifndef USG
#	ifdef i386
#		define SYS_V
#	endif
#	ifdef M_XENIX
#		define SYS_V
#	endif
#endif

#ifdef SYS_V
#	include <memory.h>
#	ifndef MEMSET
#		define MEMSET
#	endif
#endif

#ifdef MSC_VER
#	include <memory.h>
#	ifndef MEMSET
#		define MEMSET
#	endif
#endif

#ifdef __TURBOC__
#	include <mem.h>
#	ifndef MEMSET
#		define MEMSET
#	endif
#endif
#ifdef MEMSET
#	if ~0 != -1
#		undef MEMSET
#	endif
#endif
#ifdef MEMSET
#	define M1 (~0)
#else
#	define M1 (-1)
#endif

#ifdef XENIX_16
static code_int c_hashsize;
# define c_HSIZE c_hashsize
#else
# define c_HSIZE _HSIZE
#endif

#ifdef MODERN
#	include <stdlib.h>
#else
	char *malloc();
	void free();
#endif

static int c_n_bits;	/* number of bits/code */
static int c_maxbits = BITS;	/* user settable max # bits/code */
static code_int c_maxcode;	/* maximum code, given n_bits */
/* should NEVER generate this code */
static code_int c_maxmaxcode = (code_int)1 << BITS;

#define word_type unsigned short
#define WNIL (word_type)0
#define CNIL (count_int)0

#ifdef XENIX_16
  static count_int *htab[MAXPAGES];
  static word_type *codetab[MAXPAGES] = {WNIL};

# define htabof(i)       (htab[(int)((i) >> PAGEXP)][(int)(i) & PAGEMASK])
# define codetabof(i)    (codetab[(int)((i) >> PAGEXP)][(int)(i) & PAGEMASK])
#else
  static count_int *htab;
  static word_type *codetab = WNIL;
# define htabof(i)       htab[i]
# define codetabof(i)    codetab[i]
#endif
static code_int hsize = _HSIZE; /* for dynamic table sizing */

static code_int c_free_ent = 0; /* first unused entry */

/* block compression parameters -- after all codes are */
/* used up, and compression rate changes, start over.  */
static int c_block_compress = BLOCK_MASK;
static int c_clear_flg = 0;
static long int ratio = 0;
static count_int c_checkpoint = CHECK_GAP;

static void cl_hash __ARGS__((count_int));

static void cl_hash(clsize) /* reset code table */
register count_int clsize;
{
#ifdef XENIX_16
   register j, l;
# ifndef MEMSET
   register i;
# endif

   for (j=0; j<MAXPAGES && clsize>=0; j++, clsize-=PAGESIZE) {
       l = clsize<PAGESIZE ? (int)clsize : PAGESIZE;
# ifdef MEMSET
       (void)memset((char*)htab[j], M1, l*sizeof(**htab));
# else
       for (i=0; i<l; i++) htab[j][i] = M1;
# endif
   }
#else
# ifdef MEMSET
   (void)memset(htab, M1, clsize*sizeof(*htab));
# else
   register count_int i; for (i=0; i<clsize; i++) htab[i] = (count_int)M1;
# endif
#endif
}

static int  offset;
static long in_count=1;	/* length of input */
static long bytes_out;	/* length of compressed output */

#ifdef LZFILE
	static FILE *lzw_out_port = NULL;
#	define putbyte(b) putc((b), lzw_out_port)
#else
	static int (*lzw_out_port)__ARGS__((int)) = NULL;
#	define putbyte(b) (*lzw_out_port)(b)
#endif

static int putpiece __ARGS__((char *, int));

static int putpiece(p, n)
register char *p; register n;
{
   offset = 0;
   bytes_out += n;
   while (n-- > 0) {
      if (putbyte(*p++) == EOF) return -1;
   }
   return 0;
}

/* Output the given code.
 * Inputs:
 *	code:	A n_bits-bit integer.  If == -1, then EOF.  This assumes
 *		that n_bits =< (long)wordsize - 1.
 * Outputs:
 *	Outputs code to the file.
 * Assumptions:
 *	Chars are 8 bits long.
 * Algorithm:
 *	Maintain a BITS character long buffer (so that 8 codes will
 * fit in it exactly).	Use the VAX insv instruction to insert each
 * code in turn.  When the buffer fills up empty it and start over.
 */

static char outbuf[BITS];

static int output __ARGS__((word_type));

static int output(code)
word_type code;
{
#ifndef vax
   static char_type rmask[] = {0x00,0x01,0x03,0x07,0x0f,0x1f,0x3f,0x7f};
#endif
   /* On the VAX, it is important to have the register declarations */
   /* in exactly the order given, or the asm will break.            */
   register int r_off = offset, bits = c_n_bits;
   register char *bp = outbuf;

#ifdef vax
   /* VAX DEPENDENT!! Implementation on other machines is below.
    *
    * Translation: Insert BITS bits from the argument starting at
    * offset bits from the beginning of buf.
    */
   0;	/* Work around for pcc -O bug with asm and if stmt */
   asm( "insv	4(ap),r11,r10,(r9)" );
#else
   /* byte/bit numbering on the VAX is simulated by the following code */
   /* Get to the first byte. */
   bp += (r_off >> 3);
   r_off &= 7;
   /* Since code is always >= 8 bits, only     */
   /* need to mask the first hunk on the left. */
   *bp = (*bp & rmask[r_off]) | (code << r_off);
   bp++;
   code >>= (r_off = 8 - r_off);
   if ((bits -= r_off) >= 8) {
      /* Get any 8 bit parts in the middle (<=1 for up to 16 bits). */
      *bp++ = code;
      code >>= 8;
      bits -= 8;
   }
   /* Last bits. */
   if (bits) *bp = code;
#endif
   if ((offset += c_n_bits)==(c_n_bits << 3)) {
      if (putpiece(outbuf,c_n_bits) != 0) return -1;
   }
   /* If the next entry is going to be too big for  */
   /* the code size, then increase it, if possible. */
   if (c_free_ent > c_maxcode || c_clear_flg > 0) {
      /* Write the whole buffer, because the input side won't  */
      /* discover the size increase until after it has read it */
      if (offset > 0) {
         if (putpiece(outbuf, c_n_bits) != 0) return -1;
      }
      if (c_clear_flg) {
         c_maxcode = MAXCODE(c_n_bits = INIT_BITS);
         c_clear_flg = 0;
      } else {
         c_maxcode = ++c_n_bits == c_maxbits ?
            c_maxmaxcode : MAXCODE(c_n_bits);
      }
   }
   return 0;
}

static int cl_block __ARGS__((void)) /* table clear for block compress */
{
   register long int rat;

   c_checkpoint = in_count + CHECK_GAP;

   if (in_count > 0x007fffffL) { /* shift will overflow */
      if ((rat = bytes_out >> 8) == 0) {/* Don't divide by zero */
         rat = 0x7fffffffL;
      } else {
         rat = in_count / rat;
      }
   } else {
      rat = (in_count << 8) / bytes_out; /* 8 fractional bits */
   }
   if (rat > ratio) {
      ratio = rat;
   } else {
      ratio = 0;
      cl_hash((count_int)hsize);
      c_free_ent = FIRST;
      c_clear_flg = 1;
      if (output(CLEAR) != 0) return -1;
   }
   return 0;
}

int lzwalloc(bits)
int bits;
{
#ifdef XENIX_16
   register i, j; long l;
#endif
   if      (c_maxbits > bits)      c_maxbits = bits;
   else if (c_maxbits < INIT_BITS) c_maxbits = INIT_BITS;
#ifdef XENIX_16
   if (codetab[0]) return c_maxbits;
   if      (c_maxbits >= 16) c_hashsize = 69001L;
   else if (c_maxbits >= 15) c_hashsize = 35023L;
   else if (c_maxbits >= 14) c_hashsize = 18013L;
   else if (c_maxbits >= 13) c_hashsize = 9001L;
   else                      c_hashsize = 5003L;
   for (l=c_hashsize, i=0; i<MAXPAGES && l > 0; i++) {
      j = l > PAGESIZE ? PAGESIZE : (int)l;
      codetab[i] = (word_type *)malloc(sizeof(word_type)*j);
      if (!codetab[i]) break;
      htab[i] = (count_int *)malloc(sizeof(**htab) * j);
      if (!htab[i]) {
         free((char*)(codetab[i])); codetab[i]=WNIL; break;
      }
      l -= j;
   }
   c_hashsize -= l;
   if      (c_hashsize >= 69001L) { j = 16; c_hashsize = 69001L; }
   else if (c_hashsize >= 35023L) { j = 15; c_hashsize = 35023L; }
   else if (c_hashsize >= 18013)  { j = 14; c_hashsize = 18013;  }
   else if (c_hashsize >= 9001)   { j = 13; c_hashsize = 9001;   }
   else if (c_hashsize >= 5003)   { j = 12; c_hashsize = 5003;   }
   else return (lzerror = ZNOMEM, -1);
   if (c_maxbits > j) c_maxbits = j;
#else
   if (codetab) return c_maxbits;
   if ((codetab=(word_type *)malloc(sizeof(*codetab)*_HSIZE))==WNIL ||
       (htab   =(count_int *)malloc(sizeof(*htab)   *_HSIZE))==CNIL) {
      return (lzerror = ZNOMEM, -1);
   }
#endif
   c_maxmaxcode = (code_int)1 << c_maxbits;
   return c_maxbits;
}

void lzwfree()
{
#ifdef XENIX_16
   register i;

   for (i=0; i<MAXPAGES && codetab[i]!=WNIL; i++) {
      free((char*)(codetab[i])); free((char*)(htab[i]));
   }
   codetab[0] = WNIL;
#else
   if (codetab != WNIL) {
      free((char*)codetab); codetab = WNIL;
      if (htab != CNIL) free((char*)htab);
   }
#endif
}

/*
 * Algorithm:  use open addressing double hashing (no chaining) on the
 * prefix code / next character combination.  We do a variant of Knuth's
 * algorithm D (vol. 3, sec. 6.4) along with G. Knott's relatively-prime
 * secondary probe.  Here, the modular division first probe is gives way
 * to a faster exclusive-or manipulation.  Also do block compression with
 * an adaptive reset, whereby the code table is cleared when the compression
 * ratio decreases, but after the table fills.	The variable-length output
 * codes are re-sized at this point, and a special CLEAR code is generated
 * for the decompressor.  Late addition:  construct the table according to
 * file size for noticeable speed improvement on small files.  Please direct
 * questions about this implementation to ames!jaw.
 */

static int already = 0;
static int hshift;
static unsigned short ent;

int lzwcreat(lzw_out, fsize, wishbits)
#ifdef LZFILE
	FILE *lzw_out;
#else
	int (*lzw_out)__ARGS__((int));
#endif
int wishbits;
long fsize;
{
   register long fcode;

   if (lzwalloc(wishbits) < 0) return (lzerror = ZNOMEM, -1);
   c_block_compress = BLOCK_MASK;
   c_checkpoint = CHECK_GAP;

   lzw_out_port = lzw_out;
   hsize = _HSIZE;
   /* tune hash table size for small files -- ad hoc,      */
   /* but the sizes match earlier #defines, which          */
   /* serve as upper bounds on the number of output codes. */
   if      (fsize < (1<<12)) hsize = 5003;
   else if (fsize < (1<<13)) hsize = 9001;
   else if (fsize < (1<<14)) hsize = 18013;
   else if (fsize < (1<<15)) hsize = 35023L;
   else if (fsize < 47000L)  hsize = 50021L;
   if (hsize > c_HSIZE) hsize = c_HSIZE;

   offset = 0;
   c_clear_flg = 0;
   ratio = 0;
   in_count = 1;
   c_checkpoint = CHECK_GAP;
   c_maxcode = MAXCODE(c_n_bits = INIT_BITS);
   c_free_ent = c_block_compress ? FIRST : 256;

   hshift = 0;
   for (fcode = (long)hsize; fcode < 65536L; fcode *= 2L) hshift++;
   hshift = 8 - hshift; /* set hash code range bound */

   cl_hash((count_int)hsize); /* clear hash table */

   already = 0;

   return c_maxbits;
}

#define GETBYTE() (--len, char_to_byte(*(char_type *)buf++))

int lzwwrite(buf, length)
char *buf; unsigned length;
{
   register long fcode;
   register code_int i = 0;
   register int c;
   register code_int disp;
   register unsigned len = length;

   if (!already) {
      if (putbyte(LZW_0TH_MAGIC) != 0 || putbyte(LZW_1ST_MAGIC) != 0 ||
          putbyte((char)(c_maxbits | c_block_compress)) != 0) goto error;
      bytes_out = 3; already = 1; ent = GETBYTE();
   }
   while (len > 0) {
      c = GETBYTE(); in_count++;

      fcode = ((long)c << c_maxbits) + ent;
      i = ((code_int)c << hshift) ^ ent; /* xor hashing */
      disp = i ? hsize-i : 1; /* secondary hash (after G. Knott) */
      while (htabof(i) >= 0) {
         if (htabof(i) == fcode) {
            ent = codetabof(i); goto next;
         }
         if ((i -= disp) < 0) i += hsize;
      }
      if (output(ent) != 0) goto error;
      ent = c;
      if (to_compare(c_free_ent) < to_compare(c_maxmaxcode)) {
         codetabof(i) = c_free_ent++; /* code -> hashtable */
         htabof(i)    = fcode;
      }
      else if ((count_int)in_count >= c_checkpoint && c_block_compress) {
         if (cl_block() != 0) goto error;
      }
next: ;
   }
   return length - len;
error:
   lzerror = ZWRITE;
   return -1;
}

long lzwclose()
{
   /* Put out the final code & write the rest of the buffer. */
   if (output(ent) != 0 || putpiece(outbuf, (offset+7)/8) != 0)
      return (lzerror = ZWRITE, -1L);
   return bytes_out;
}
