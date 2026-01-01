/* The following is derived from 'funzip' utility sources
 * (funzip.c & inflate.c files) which are written and
 * gracefully put into public domain by Mark Adler.
 * You can find original texts in Info-Zip 'unzip' distribution.
 */

/*#define PKZIP_BUG_WORKAROUND*/
#define V100_BUG_WORKAROUND

#include <stdio.h>
#include "modern.h"
#include "stdinc.h"
#ifdef MODERN
#  include <string.h>
#else
   char *malloc();
#endif
#include "zipdefs.h"
#include "lzpipe.h"
#include "crc32.h"

#ifndef max
#  define max(a,b) (((a) > (b)) ? (a) : (b))
#endif
#define RETURN(n) return (lzerror=(n), ERROR)

#define AT_EOF 0x80 /* End of data achieved */
#define INITED 0x40 /* Header processed */
#define METHOD 0x03 /* Inflate method mask */
#define IBEGIN 0x20 /* Trees (or stored length) processed */
#define ICFLAG 0x10 /* Copy pending */

static uch zipstate = 0;
#ifdef LZFILE
	static FILE *zip_inp_port = NULL;
#       define readbyte() getc(zip_inp_port)
#       define nextbyte() getc(zip_inp_port)
#else
	static int (*zip_inp_port)__ARGS__((void)) = (int(*)())0;
#	define readbyte() (*zip_inp_port)()
#	define nextbyte() (*zip_inp_port)()
#endif

#define PF_CRYPT 1 /* PKWare flag fields */
#define PF_ATEOF 8
#define PF_ERROR 0x1ff0

#define GF_ASCII   1 /* GNU flag fields */
#define GF_CONT    2
#define GF_EXTRA   4
#define GF_FNAME   8
#define GF_COMMENT 0x10
#define GF_CRYPT   0x20
#define GF_ERROR   0xC0

static char ziptype = 0;
static ush zipflags, zmethod;
static ulg crc32val, pkdsize, srcsize;
static uch *slide = (uch*)0;
static ulg outsiz;  /* total bytes written to out */
static char *outbuf;
static ush  outpos; /* output posiztion in slide */

/*
   Inflate deflated (PKZIP's method 8 compressed) data.  The compression
   method searches for as much of the current string of bytes (up to a
   length of 258) in the previous 32K bytes.  If it doesn't find any
   matches (of at least length 3), it codes the next byte.  Otherwise, it
   codes the length of the matched string and its distance backwards from
   the current position.  There is a single Huffman code that codes both
   single bytes (called "literals") and match lengths.  A second Huffman
   code codes the distance information, which follows a length code.  Each
   length or distance code actually represents a base value and a number
   of "extra" (sometimes zero) bits to get to add to the base value.  At
   the end of each deflated block is a special end-of-block (EOB) literal/
   length code.  The decoding process is basically: get a literal/length
   code; if EOB then done; if a literal, emit the decoded byte; if a
   length then get the distance and emit the referred-to bytes from the
   sliding window of previously emitted data.

   There are (currently) three kinds of inflate blocks: stored, fixed, and
   dynamic.  The compressor outputs a chunk of data at a time, and decides
   which method to use on a chunk-by-chunk basis.  A chunk might typically
   be 32K to 64K, uncompressed.  If the chunk is uncompressible, then the
   "stored" method is used.  In this case, the bytes are simply stored as
   is, eight bits per byte, with none of the above coding.  The bytes are
   preceded by a count, since there is no longer an EOB code.

   If the data is compressible, then either the fixed or dynamic methods
   are used.  In the dynamic method, the compressed data is preceded by
   an encoding of the literal/length and distance Huffman codes that are
   to be used to decode this block.  The representation is itself Huffman
   coded, and so is preceded by a description of that code.  These code
   descriptions take up a little space, and so for small blocks, there is
   a predefined set of codes, called the fixed codes.  The fixed method is
   used if the block ends up smaller that way (usually for quite small
   chunks), otherwise the dynamic method is used.  In the latter case, the
   codes are customized to the probabilities in the current block, and so
   can code it much better than the pre-determined fixed codes can.

   The Huffman codes themselves are decoded using a mutli-level table
   lookup, in order to maximize the speed of decoding plus the speed of
   building the decoding tables.  See the comments below that precede the
   lbits and dbits tuning parameters.
 */

/*
   Notes beyond the 1.93a appnote.txt:

   1. Distance pointers never point before the beginning of the output
      stream.
   2. Distance pointers can point back across blocks, up to 32k away.
   3. There is an implied maximum of 7 bits for the bit length table and
      15 bits for the actual data.
   4. If only one code exists, then it is encoded using one bit.  (Zero
      would be more efficient, but perhaps a little confusing.)  If two
      codes exist, they are coded using one bit each (0 and 1).
   5. There is no way of sending zero distance codes--a dummy must be
      sent if there are none.  (History: a pre 2.0 version of PKZIP would
      store blocks with no distance codes, but this was discovered to be
      too harsh a criterion.)  Valid only for 1.93a.  2.04c does allow
      zero distance codes, which is sent as one code of zero bits in
      length.
   6. There are up to 286 literal/length codes.  Code 256 represents the
      end-of-block.  Note however that the static length tree defines
      288 codes just to fill out the Huffman codes.  Codes 286 and 287
      cannot be used though, since there is no length base or extra bits
      defined for them.  Similarily, there are up to 30 distance codes.
      However, static trees define 32 codes (all 5 bits) to fill out the
      Huffman codes, but the last two had better not show up in the data.
   7. Unzip can check dynamic Huffman blocks for complete code sets.
      The exception is that a single code would not be complete (see #4).
   8. The five bits following the block type is really the number of
      literal codes sent minus 257.
   9. Length codes 8,16,16 are interpreted as 13 length codes of 8 bits
      (1+6+6).  Therefore, to output three times the length, you output
      three codes (1+1+1), whereas to output four times the same length,
      you only need two codes (1+3).  Hmm.
  10. In the tree reconstruction algorithm, Code = Code + Increment
      only if BitLength(i) is not zero.  (Pretty obvious.)
  11. Correction: 4 Bits: # of Bit Length codes - 4     (4 - 19)
  12. Note: length code 284 can represent 227-258, but length code 285
      really is 258.  The last length deserves its own, short code
      since it gets used a lot in very redundant files.  The length
      258 is special since 258 - 3 (the min match length) is 255.
  13. The literal/length and distance code bit lengths are read as a
      single stream of lengths.  It is possible (and advantageous) for
      a repeat code (16, 17, or 18) to go across the boundary between
      the two sets of lengths.
 */
/* Huffman code lookup table entry--this entry is four bytes for machines
   that have 16-bit pointers (e.g. PC's in the small or medium model).
   Valid extra bits are 0..13.  e == 15 is EOB (end of block), e == 16
   means that v is a literal, 16 < e < 32 means that v is a pointer to
   the next table, which codes e - 16 bits, and lastly e == 99 indicates
   an unused code.  If a code with e == 99 is looked up, this implies an
   error in the data. */

#define EOB     15
#define LITERAL 16
#define BAD     99

typedef struct _huft {
  uch e; /* number of extra bits or operation */
  uch b; /* number of bits in this code or subcode */
  union {
    ush n; /* literal, length base, or distance base */
    struct _huft *t; /* pointer to next level of table */
  } v;
} huft;

/* Function prototypes */
static void huft_free  __ARGS__((huft **));
static int  huft_build __ARGS__((unsigned *, unsigned, unsigned, ush *, ush *,
                                 huft **, int *));
static void copyout __ARGS__((void));
static ush getbits __ARGS__((ush));
static int decode  __ARGS__((unsigned *, huft *, int));
static int inflate_codes __ARGS__((unsigned));
static int inflate_dynamic __ARGS__((unsigned));
static int inflate_fixed   __ARGS__((unsigned));
static int inflate_stored  __ARGS__((unsigned));
static ush getsh __ARGS__((void));
static ulg getlg __ARGS__((void));
static int skip __ARGS__((int));

/* The inflate algorithm uses a sliding 32K byte window on the uncompressed
   stream to find repeated byte strings.  This is implemented here as a
   circular buffer.  The index is updated simply by incrementing and then
   and'ing with 0x7fff (32K-1). */
/* It is left to other modules to supply the 32K area.  It is assumed
   to be usable as if it were declared "uch slide[32768];" or as just
   "uch *slide;" and then malloc'ed in the latter case.  The definition
   must be in unzip.h, included above. */
unsigned wp;            /* current position in slide */

/* Tables for deflate from PKZIP's appnote.txt. */
static unsigned border[] = {    /* Order of the bit length code lengths */
        16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15};
static ush cplens[] = {         /* Copy lengths for literal codes 257..285 */
        3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 15, 17, 19, 23, 27, 31,
        35, 43, 51, 59, 67, 83, 99, 115, 131, 163, 195, 227, 258, 0, 0};
        /* note: see note #13 above about the 258 in this list. */
static ush cplext[] = {         /* Extra bits for literal codes 257..285 */
        0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2,
        3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 0, 99, 99}; /* 99==invalid */
static ush cpdist[] = {         /* Copy offsets for distance codes 0..29 */
        1, 2, 3, 4, 5, 7, 9, 13, 17, 25, 33, 49, 65, 97, 129, 193,
        257, 385, 513, 769, 1025, 1537, 2049, 3073, 4097, 6145,
        8193, 12289, 16385, 24577};
static ush cpdext[] = {         /* Extra bits for distance codes */
        0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6,
        7, 7, 8, 8, 9, 9, 10, 10, 11, 11,
        12, 12, 13, 13};

/* Macros for inflate() bit peeking and grabbing.
   The usage is:

        NEEDBITS(j)
        x = b & mask_bits[j];
        DUMPBITS(j)

   where NEEDBITS makes sure that b has at least j bits in it, and
   DUMPBITS removes the bits from b.  The macros use the variable k
   for the number of bits in b.  Normally, b and k are register
   variables for speed, and are initialized at the begining of a
   routine that uses these macros from a global bit buffer and count.

   If we assume that EOB will be the longest code, then we will never
   ask for bits with NEEDBITS that are beyond the end of the stream.
   So, NEEDBITS should not read any more bytes than are needed to
   meet the request.  Then no bytes need to be "returned" to the buffer
   at the end of the last block.

   However, this assumption is not true for fixed blocks--the EOB code
   is 7 bits, but the other literal/length codes can be 8 or 9 bits.
   (The EOB code is shorter than other codes becuase fixed blocks are
   generally short.  So, while a block always has an EOB, many other
   literal/length codes have a significantly lower probability of
   showing up at all.)  However, by making the first table have a
   lookup of seven bits, the EOB code will be found in that first
   lookup, and so will not require that too many bits be pulled from
   the stream.
 */

static ulg bb;      /* bit buffer */
static unsigned bk; /* bits in bit buffer */

#define NEEDBITS(n) {while(k<(n)){b|=((ulg)nextbyte())<<k;k+=8;}}
#define DUMPBITS(n) {b>>=(n);k-=(n);}
/* A reasonable optimization for 16-bits computers */
#define NEEDTINY(n) {if(k<(n)){b|=(unsigned)nextbyte()<<k;k+=8;}}
#define DUMPTINY(n) {b=(unsigned)b>>(n);k-=(n);}

static ush mask_bits[] = {
   0x0000,
   0x0001, 0x0003, 0x0007, 0x000f, 0x001f, 0x003f, 0x007f, 0x00ff,
   0x01ff, 0x03ff, 0x07ff, 0x0fff, 0x1fff, 0x3fff, 0x7fff, 0xffff
};

/*
   Huffman code decoding is performed using a multi-level table lookup.
   The fastest way to decode is to simply build a lookup table whose
   size is determined by the longest code.  However, the time it takes
   to build this table can also be a factor if the data being decoded
   is not very long.  The most common codes are necessarily the
   shortest codes, so those codes dominate the decoding time, and hence
   the speed.  The idea is you can have a shorter table that decodes the
   shorter, more probable codes, and then point to subsidiary tables for
   the longer codes.  The time it costs to decode the longer codes is
   then traded against the time it takes to make longer tables.

   This results of this trade are in the variables lbits and dbits
   below.  lbits is the number of bits the first level table for literal/
   length codes can decode in one step, and dbits is the same thing for
   the distance codes.  Subsequent tables are also less than or equal to
   those sizes.  These values may be adjusted either when all of the
   codes are shorter than that, in which case the longest code length in
   bits is used, or when the shortest code is *longer* than the requested
   table size, in which case the length of the shortest code in bits is
   used.

   There are two different values for the two tables, since they code a
   different number of possibilities each.  The literal/length table
   codes 286 possible values, or in a flat code, a little over eight
   bits.  The distance table codes 30 possible values, or a little less
   than five bits, flat.  The optimum values for speed end up being
   about one bit more than those, so lbits is 8+1 and dbits is 5+1.
   The optimum values may differ though from machine to machine, and
   possibly even between compilers.  Your mileage may vary.
 */
#if 0
int lbits = 9; /* bits in base literal/length lookup table */
int dbits = 6; /* bits in base distance lookup table */
#else
#define lbits 9
#define dbits 6
#endif

static void huft_free(t)
huft **t; /* table to free */
/* Free the malloc'ed tables built by huft_build(), which makes a linked
   list of the tables it made, with the links in a dummy first entry of
   each table. */
{
   register huft *p, *q;

   /* Go through linked list, freeing from the malloced (t[-1]) address. */
   p = *t;
   while (p) {
      q = (--p)->v.t;
      free(p);
      p = q;
   }
   *t = NULL;
}

/* If BMAX needs to be larger than 16, then h and x[] should be ulg. */
#define BMAX 16   /* maximum bit length of any code (16 for explode) */
#define N_MAX 288 /* maximum number of codes in any set */
#ifdef DEBUG
unsigned hufts;   /* track memory usage */
#endif

static int huft_build(b, n, s, d, e, t, m)
unsigned *b; /* code lengths in bits (all assumed <= BMAX) */
unsigned n;  /* number of codes (assumed <= N_MAX) */
unsigned s;  /* number of simple-valued codes (0..s-1) */
ush *d;      /* list of base values for non-simple codes */
ush *e;      /* list of extra bits for non-simple codes */
huft **t;    /* result: starting table */
int *m;      /* maximum lookup bits, returns actual */
/* Given a list of code lengths and a maximum table size, make a set of
   tables to decode that set of codes.  Return zero on success, one if
   the given code set is incomplete (the tables are still built in this
   case), two if the input is invalid (all zero length codes or an
   oversubscribed set of lengths), and three if not enough memory. */
{
  unsigned a;           /* counter for codes of length k */
  unsigned c[BMAX+1];   /* bit length count table */
  unsigned f;           /* i repeats in table every f entries */
  int g;                /* maximum code length */
  int h;                /* table level */
  register unsigned i;  /* counter, current code */
  register unsigned j;  /* counter */
  register int k;       /* number of bits in current code */
  int l;                /* bits per table (returned in m) */
  register unsigned *p; /* pointer into c[], b[], or v[] */
  register huft *q;     /* points to current table */
  huft r;               /* table entry for structure assignment */
  huft *u[BMAX];        /* table stack */
  unsigned v[N_MAX];    /* values in order of bit length */
  register int w;       /* bits before this table == (l * h) */
  unsigned x[BMAX+1];   /* bit offsets, then code stack */
  unsigned *xp;         /* pointer into x */
  int y;                /* number of dummy codes added */
  unsigned z;           /* number of entries in current table */

  /* Generate counts for each bit length */
  for (i=0; i<=BMAX; i++) c[i] = 0;
  p = b;  i = n;
  do {
    c[*p++]++;     /* assume all entries <= BMAX */
  } while (--i);
  if (c[0] == n) { /* null input--all zero length codes */
    *t = (huft *)NULL;
    *m = 0;
    return 0;
  }

  /* Find minimum and maximum length, bound *m by those */
  l = *m;
  for (j = 1; j <= BMAX && !c[j]; j++);
  k = j; /* minimum code length */
  if ((unsigned)l < j) l = j;
  for (i = BMAX; i && !c[i]; i--);
  g = i; /* maximum code length */
  if ((unsigned)l > i) l = i;
  *m = l;

  /* Adjust last length count to fill out codes, if needed */
  for (y = 1 << j; j < i; j++, y <<= 1)
    if ((y -= c[j]) < 0) return 2; /* bad input: more codes than bits */
  if ((y -= c[i]) < 0) return 2;
  c[i] += y;

  /* Generate starting offsets into the value table for each length */
  x[1] = j = 0;
  p = c + 1;  xp = x + 2;
  while (--i) {                 /* note that i == g from above */
    *xp++ = (j += *p++);
  }

  /* Make a table of values in order of bit lengths */
  p = b;  i = 0;
  do {
    if ((j = *p++) != 0) v[x[j]++] = i;
  } while (++i < n);

  /* Generate the Huffman codes and for each, make the table entries */
  x[0] = i = 0;        /* first Huffman code is zero */
  p = v;               /* grab values in bit order */
  h = -1;              /* no tables yet--level -1 */
  w = -l;              /* bits decoded == (l * h) */
  u[0] = (huft *)NULL; /* just to keep compilers happy */
  q = (huft *)NULL;    /* ditto */
  z = 0;               /* ditto */

  /* go through the bit lengths (k already is bits in shortest code) */
  for (; k <= g; k++) {
    a = c[k];
    while (a--) {
      /* here i is the Huffman code of length k bits for value *p */
      /* make tables up to required level */
      while (k > w + l) {
        h++;
        w += l;                 /* previous table always l bits */

        /* compute minimum size table less than or equal to l bits */
        z = (z = g - w) > (unsigned)l ? l : z;  /* upper limit on table size */
        if ((f = 1 << (j = k - w)) > a + 1) {   /* try a k-w bit table */
          f -= a + 1;           /* too few codes for k-w bit table */
          xp = c + k;           /* deduct codes from patterns left */
          while (++j < z) {     /* try smaller tables up to z bits */
            if ((f <<= 1) <= *++xp)
              break;            /* enough codes to use up j bits */
            f -= *xp;           /* else deduct codes from patterns */
          }
        }
        z = 1 << j;             /* table entries for j-bit table */

        /* allocate and link in new table */
        q = (huft *)malloc((z + 1)*sizeof(huft));
        if (!q) {/* not enough memory */
          if (h) huft_free(u); return (lzerror=ZNOMEM, ERROR);
        }
#ifdef DEBUG
        hufts += z + 1;         /* track memory usage */
#endif
        *t = q + 1;             /* link to list for huft_free() */
        *(t = &(q->v.t)) = (huft *)NULL;
        u[h] = ++q;             /* table starts after link */

        /* connect to last table, if there is one */
        if (h) {
          x[h] = i;             /* save pattern for backing up */
          r.b = (uch)l;         /* bits to dump before this table */
          r.e = (uch)(16 + j);  /* bits in this table */
          r.v.t = q;            /* pointer to this table */
          j = i >> (w - l);     /* (get around Turbo C bug) */
          u[h-1][j] = r;        /* connect to last table */
        }
      }

      /* set up table entry in r */
      r.b = (uch)(k - w);
      if (p >= v + n) {
        r.e = 99;               /* out of values--invalid code */
      } else if (*p < s) {
        r.e = (uch)(*p < 256 ? 16 : 15);    /* 256 is end-of-block code */
        r.v.n = *p++;           /* simple code is just the value */
      } else {
        r.e = (uch)e[*p - s];   /* non-simple--look up in lists */
        r.v.n = d[*p++ - s];
      }

      /* fill code-like entries with r */
      f = 1 << (k - w);
      for (j = i >> w; j < z; j += f) q[j] = r;

      /* backwards increment the k-bit code i */
      for (j = 1 << (k - 1); i & j; j >>= 1) i ^= j;
      i ^= j;

      /* backup over finished tables */
      while ((i & ((1 << w) - 1)) != x[h]) {
        h--; /* don't need to update q */
        w -= l;
      }
    }
  }
  /* Return true (1) if we were given an incomplete table */
  return y != 0 && g != 1;
}

static void copyout()
{
   register unsigned length;

   if ((length = wp - outpos) != 0) {
      updcrc(slide+outpos, length);
#ifdef NOMEMCPY
      while (length--) *outbuf++ = (char)slide[outpos++];
#else
      (void)memcpy(outbuf, slide+outpos, length);
      outbuf += length;
      outpos += length;
#endif
      outsiz += length;
   }
}

static ush getbits(n)
ush n; /* number of bits to get */
{
   register ulg b;      /* bit buffer */
   register unsigned k; /* number of bits in bit buffer */
   register unsigned j;

   /* make local copies of globals */
   b = bb; k = bk;
   NEEDBITS(n);
   j = (unsigned)b & mask_bits[n];
   DUMPBITS(n);
   /* restore the globals from the locals */
   bk = k; bb = b;
   return j;
}

static int decode(np, t, bn)
unsigned *np; /* decoded value */
huft *t;      /* tree to decode */
int bn;       /* bits number */
/* Returns number of extra bits (BAD on error). */
{
   register ulg b;      /* bit buffer */
   register unsigned k; /* number of bits in bit buffer */

   /* make local copies of globals */
   b = bb; k = bk;
   for (;;) {
      NEEDBITS((unsigned)bn)
      t += ((unsigned)b & mask_bits[bn]);
      if ((bn = t->e) == BAD) goto end;
      DUMPBITS(t->b)
      if (bn <= 16) break;
      t = t->v.t;
      bn -= 16;
   }
   *np = t->v.n;
   /* restore the globals from the locals */
   bk = k; bb = b;
end:
   return bn;
}

static huft *tl = NULL; /* literal/length code table */
static huft *td = NULL; /* distance code table */
static int bl;          /* lookup bits for tl */
static int bd;          /* lookup bits for td */

static int inflate_codes(length)
unsigned length;
/* inflate (decompress) the codes in a deflated (compressed) block.
   Return an number of bytes decompressed or ERROR. */
{
   register unsigned i;
   register unsigned e; /* number of extra bits */
   static unsigned n,d; /* length and index for copy */

   for (i=0; i<length;) {
      if (!(zipstate & ICFLAG)) {
         if ((e = decode(&n, tl, bl)) == BAD)
            return (lzerror=ZMOULD, ERROR);
         if (e == LITERAL) {
            slide[wp++] = (uch)n;
            if (wp >= WSIZE) {
               copyout(); outpos = wp = 0;
            }
            ++i;
            continue;
         }
         if (e == EOB) {
            /* clear all unneccesary flags & exit */
            zipstate &= AT_EOF|INITED; break;
         }
         /* Length code encountered, get length of block to copy */
         n += getbits(e);
         /* decode distance of block to copy */
         if ((e = decode(&d, td, bd)) == BAD)
            return (lzerror=ZMOULD, ERROR);
         d = wp - (d + getbits(e));
      }
      zipstate &= ~ICFLAG;
      /* do the copy */
      do {
         d &= WSIZE-1;
         if ((e = WSIZE - max(d,wp)) > n) e = n;
         if (i+e > length) {
            zipstate |= ICFLAG; e = length-i;
         }
         i += e;
         n -= e;
#ifndef NOMEMCPY
         if (wp - d >= e) {/* (this test assumes unsigned comparison) */
            memcpy(slide + wp, slide + d, e);
            wp += e;
            d += e;
         } else /* do it slow to avoid memcpy() overlap */
#endif /* !NOMEMCPY */
            do slide[wp++] = slide[d++]; while (--e);
         if (wp >= WSIZE) {
            copyout(); outpos = wp  = 0;
         }
      } while (n && !(zipstate & ICFLAG));
   }
   copyout();
   return i;
}

static int inflate_dynamic(length)
unsigned length;
/* decompress an inflated type 2 (dynamic Huffman codes) block. */
/* Returns number of bytes decompressed or ERROR. */
{
   register i;

   if (!(zipstate & IBEGIN)) {
      unsigned j;
      unsigned l;  /* last length */
      unsigned m;  /* mask for bit lengths table */
      unsigned n;  /* number of lengths to get */
      unsigned nb; /* number of bit length codes */
      unsigned nl; /* number of literal/length codes */
      unsigned nd; /* number of distance codes */
#ifdef PKZIP_BUG_WORKAROUND
      unsigned ll[288+32]; /* literal/length and distance code lengths */
#else
      unsigned ll[286+30]; /* literal/length and distance code lengths */
#endif
      register ulg b;      /* bit buffer */
      register unsigned k; /* number of bits in bit buffer */

      /* make local bit buffer */ b = bb; k = bk;

      /* read in table lengths */
      NEEDTINY(5)
      nl = 257 + ((unsigned)b & 0x1f); /* number of literal/length codes */
      DUMPTINY(5)
      NEEDTINY(5)
      nd = 1 + ((unsigned)b & 0x1f);   /* number of distance codes */
      DUMPTINY(5)
      NEEDTINY(4)
      nb = 4 + ((unsigned)b & 0xf);    /* number of bit length codes */
      DUMPTINY(4)
#ifdef PKZIP_BUG_WORKAROUND
      if (nl > 288 || nd > 32)
#else
      if (nl > 286 || nd > 30)
#endif
        return (lzerror=ZMOULD, ERROR); /* bad lengths */

      /* read in bit-length-code lengths */
      for (j = 0; j < nb; j++) {
        NEEDTINY(3)
        ll[border[j]] = (unsigned)b & 7;
        DUMPTINY(3)
      }
      for (; j < 19; j++) ll[border[j]] = 0;

      /* build decoding table for trees--single level, 7 bit lookup */
      bl = 7;
      if ((i = huft_build(ll, 19, 19, NULL, NULL, &tl, &bl)) != 0) {
         if (i != ERROR) /* all save memory lack */ lzerror = ZMOULD;
         if (i == TRUE) /* incomplete code set */ huft_free(&tl);
         return ERROR;
      }

      /* read in literal and distance code lengths */
      n = nl + nd;
      m = mask_bits[bl];
      i = l = 0;
      while ((unsigned)i < n) {
        NEEDBITS((unsigned)bl)
        j = (td = tl + ((unsigned)b & m))->b;
        DUMPBITS(j)
        j = td->v.n;
        if (j < 16) {      /* length of code in bits (0..15) */
          ll[i++] = l = j; /* save last length in l */
        } else {
          if (j == 16) {/* repeat last length 3 to 6 times */
            NEEDTINY(2)
            j = 3 + ((unsigned)b & 3);
            DUMPTINY(2)
          } else {
            l = 0;
            if (j == 17) {/* 3 to 10 zero length codes */
              NEEDTINY(3)
              j = 3 + ((unsigned)b & 7);
              DUMPTINY(3)
            } else {/* j == 18: 11 to 138 zero length codes */
              NEEDTINY(7)
              j = 11 + ((unsigned)b & 0x7f);
              DUMPTINY(7)
            }
          }
          if ((unsigned)i + j > n) return (lzerror=ZMOULD, ERROR);
          while (j--) ll[i++] = l;
        }
      }

      /* free decoding table for trees */
      huft_free(&tl);

      /* restore the global bit buffer */
      bb = b;
      bk = k;

      /* build the decoding tables for literal/length and distance codes */
      bl = lbits;
      if ((i = huft_build(ll, nl, 257, cplens, cplext, &tl, &bl)) != 0) {
         if (i != ERROR) /* all save memory lack */ lzerror = ZMOULD;
         if (i == TRUE) /* incomplete literal tree */ huft_free(&tl);
         return ERROR;
      }
      bd = dbits;
      if ((i = huft_build(ll + nl, nd, 0, cpdist, cpdext, &td, &bd)) != 0) {
#ifndef PKZIP_BUG_WORKAROUND
         if (i == TRUE) huft_free(&td); /* incomplete distance tree */
#else
         if (i != TRUE)
#endif
         {
            huft_free(&tl);
            if (i != ERROR) lzerror = ZMOULD;
            return ERROR;
         }
      }
      zipstate |= IBEGIN;
   }
   if ((i = inflate_codes(length)) == ERROR || !(zipstate & IBEGIN)) {
      huft_free(&tl); huft_free(&td);
   }
   return i;
}

static int inflate_fixed(length)
unsigned length;
/* decompress an inflated type 1 (fixed Huffman codes) block.  We should
   either replace this with a custom decoder, or at least precompute the
   Huffman tables. */
/* Returns number of bytes decompressed or ERROR. */
{
   register i;

   if (!(zipstate & IBEGIN)) {
      unsigned l[288]; /* length list for huft_build */

      i = 0;
      /* set up literal table; make a complete, but wrong code set */
      do l[i] = 8; while (++i < 144);
      do l[i] = 9; while (++i < 256);
      do l[i] = 7; while (++i < 280);
      do l[i] = 8; while (++i < 288);

      bl = 7;
      if ((i = huft_build(l, 288, 257, cplens, cplext, &tl, &bl)) != 0) {
         if (i != ERROR) /* all save memory lack */ lzerror = ZERROR;
         if (i == TRUE) /* incomplete code set */ huft_free(&tl);
         return ERROR;
      }

      /* set up distance table */
      for (i=0; i<30; i++) l[i] = 5; /* make an incomplete code set */

      bd = 5;
      if ((i = huft_build(l, 30, 0, cpdist, cpdext, &td, &bd)) & ~1) {
         if (i != ERROR) lzerror = ZERROR;
         huft_free(&tl);
         return ERROR;
      }
      zipstate |= IBEGIN;
   }
   if ((i = inflate_codes(length)) == ERROR || !(zipstate & IBEGIN)) {
      huft_free(&tl); huft_free(&td);
   }
   return i;
}

static int inflate_stored(length)
unsigned length;
/* "decompress" an inflated type 0 (stored) block. */
/* Returns number of bytes restored or ERROR. */
{
   static unsigned n; /* number of bytes to copy */
   register unsigned i;

   if (!(zipstate & IBEGIN)) {
      if (bk > 7) /* fail to align bit buffer */
         return (lzerror=ZERROR, ERROR);
      /* go to byte boundary */
      bb = 0; /* bit buffer */
      bk = 0; /* number of bits in bit buffer */

      /* get the length and its complement */
      n = nextbyte(); n |= nextbyte() << 8;
      i = nextbyte(); i |= nextbyte() << 8;
      if (n != (i ^ 0xffff)) /* data error */
         return (lzerror=ZMOULD, ERROR);
      zipstate |= IBEGIN;
   }
   /* read and output the "compressed" data */
   for (i=0; i<length; i++) {
      if (n-- == 0) {
         /* End of block - clear method and other unneccesary flags */
         zipstate &= AT_EOF|INITED;
         break;
      }
      slide[wp++] = (uch)nextbyte();
      if (wp >= WSIZE) {
         copyout(); outpos = wp = 0;
      }
   }
   copyout();
   return i;
}

static int skip(n)
register int n;
{
   while (n--) if (readbyte()==EOF) return EOF; return 0;
}

static ush getsh()
{
   register ush i; i = readbyte(); return i | (readbyte() << 8);
}

static ulg getlg()
{
   register ush i = 0;
   register ulg l = 0;

   if (bk) {
      i = bk & ~7;
      l = bb >> (bk & 7);
      bb = 0;
      bk = 0;
   }
   for (; i<32; i+=8) l |= (ulg)readbyte() << i;
   return l;
}

int unzalloc()
{
   if (!slide) slide = (uch*)malloc(WSIZE); return !slide;
}

int unzopen(inp_port, ztype)
#ifdef LZFILE
	FILE *inp_port;
#else
	int (*inp_port)__ARGS__((void));
#endif
int ztype;
{
   lzerror = 0;
   if (unzalloc()) return (lzerror = ZNOMEM);
   zip_inp_port = inp_port;
   zipstate = 0;
   ziptype = ztype;
   outsiz = 0L;
   /* Initialise CRC calculations */
   crcbegin();
   /* Initialise deflate */
   wp = 0; bb = 0; bk = 0;
   outpos = 0;
   return 0;
}

int unzread(buffer, length)
char *buffer; unsigned length;
{
   register i;
   register unsigned j, k;
   register ulg b;

   if (!(zipstate & INITED)) {/* Read and decode header */
      if (!slide || !zip_inp_port) RETURN(ZNOPEN);

      /* Check for zip type */
      k = getsh();
      if        (ziptype == ZIP_GNU) {
         if (k != GZIP_MAGIC) RETURN(ZMAGIC);
      } else if (ziptype == ZIP_PKW) {
         if (k!=PKW_01_MAGIC || getsh()!=PKW_23_MAGIC) RETURN(ZMAGIC);
      } else {
         if (k==PKW_01_MAGIC && getsh()==PKW_23_MAGIC) ziptype=ZIP_PKW;
         else if (k == GZIP_MAGIC)                     ziptype=ZIP_GNU;
         else RETURN(ZMAGIC);
      }
      /* Decode header */
      if (ziptype == ZIP_GNU) {
         zmethod  = readbyte();
         if ((zipflags = readbyte()) & (GF_ERROR|GF_CRYPT|GF_CONT))
            RETURN(ZUNSUP);
         /* Skip file time, extra flags and OS type */
         if (skip(6)) RETURN(ZHDEOF);
#if 0
         if (zipflags & GF_CONT) {
            /* Skip the part number */ if (skip(2)) RETURN(ZHDEOF);
         }
#endif
         if (zipflags & GF_EXTRA) {/* Skip the extra field */
            k = getsh(); if (skip(k)) RETURN(ZHDEOF);
         }
         if (zipflags & GF_FNAME) {/* Skip the file name */
            do if ((i=readbyte()) == EOF) RETURN(ZHDEOF); while (i);
         }
         if (zipflags & GF_COMMENT) {/* Skip comment */
            do if ((i=readbyte()) == EOF) RETURN(ZHDEOF); while (i);
         }
      } else {/* PKWARE */
         if (skip(2)) RETURN(ZHDEOF); /* version to extract */
         if ((zipflags = getsh()) & (PF_ERROR|PF_CRYPT)) RETURN(ZUNSUP);
         zmethod  = getsh();
         if (skip(4)) RETURN(ZHDEOF); /* skip file time/date */
         crc32val = getlg();
         pkdsize  = getlg();
         srcsize  = getlg();
         k = getsh(); /* file name length */
         j = getsh(); /* extra field length */
         if (/* header length */30L + k + j > 65535L || skip(k+j))
            RETURN(ZHDEOF);
      }
      /* Header decoded */
      zipstate |= INITED;
   }
   if (zmethod == DEFLATED) {
      outbuf = buffer;
      j = 0;
      do {
         if (!(zipstate & METHOD)) {
            if (zipstate & AT_EOF) break;

            /* make local bit buffer */
            b = bb; k = bk;

            /* read in last block bit */
            NEEDTINY(1)
            if ((int)b & 1) zipstate |= AT_EOF;
            DUMPTINY(1)

            /* read in block type */
            NEEDTINY(2)
            if ((i = ((int)b & 3) + 1) & ~METHOD) RETURN(ZMOULD);
            DUMPTINY(2)
            zipstate |= i;

            /* restore the global bit buffer */
            bb = b; bk = k;
         }
         k = length - j;
         switch (zipstate & METHOD) {
            case 3 : i = inflate_dynamic(k); break;
            case 2 : i = inflate_fixed  (k); break;
            case 1 : i = inflate_stored (k); break;
            default: RETURN(ZMOULD);
         }
         if (i == ERROR) return i;
      } while ((i || !(zipstate & AT_EOF)) && (j+=i) < length);
      return j;
   } else if (ziptype == ZIP_PKW && zmethod == STORED) {
      zipstate |= 1; /* Dummy 'stored' flag */
      k = length > pkdsize ? (unsigned)pkdsize : length;
      for (j=0; j<k && (i=readbyte())!=EOF; j++) buffer[j] = i;
      if (j) {
         pkdsize -= j;
         updcrc((unsigned char*)buffer, j);
         outsiz += j;
      }
      if (!pkdsize) {
         zipstate &= ~METHOD; zipstate |= AT_EOF;
      }
      return i == EOF ? (lzerror=ZMOULD, ERROR) : j;
   }
   RETURN(ZUNSUP);
}

void unzfree()
{
   if (slide) { free(slide); slide = (uch*)0; }
   if (tl) huft_free(&tl);
   if (td) huft_free(&td);
}

int unzclose()
{
   int k = ERROR;  /* return value */
   int i = 0;      /* bytes rest */
   register ulg l; /* working variable */

   lzerror = ZNOPEN;
   if (!slide || !zip_inp_port || !(zipstate & INITED)) goto end;

   if (!(zipstate & AT_EOF)) {
      /* Indicate warning message */ k = (lzerror=ZNOEOF); goto end;
   }
   if (zipstate & METHOD) {
      char b[16]; register j;
      /* skip the rest of data */
      while ((j=unzread(b, sizeof(b))) == sizeof(b)) i += j;
      if (j == ERROR) goto end;
   }
   if        (ziptype == ZIP_GNU) {
      crc32val = getlg();
      srcsize  = getlg();
   } else if (ziptype == ZIP_PKW) {
      if (zipflags & PF_ATEOF) {
#ifdef V100_BUG_WORKAROUND
         if ((l = getlg()) == PKW_EXT) {
            if ((crc32val = getlg()) == getcrc()) {
               (void)    getlg(); /* Skip the packed size */
               srcsize = getlg();
               goto crc_ok;
            }
         } else {
            (void)getlg(); /* Skip the packed size */
         }
         crc32val = l;
#else
         if (getlg() != PKW_EXT) { lzerror = ZMOULD; goto end; }
         crc32val = getlg();
         (void)     getlg(); /* Ignore packed size */
#endif
         srcsize  = getlg();
      }
   } else {
      lzerror = ZNOPEN; goto end;
   }
   if (crc32val != getcrc()) { lzerror = BADCRC; goto end; }
crc_ok:
   if (outsiz   !=  srcsize) { lzerror = ZBADSZ; goto end; }

   if (ziptype == ZIP_PKW) {
      /* Test for the end of archive */
      if ((l = getlg()) != PKW_CENTRAL) {
         /* Indicate warning message */
         k = (lzerror = l==PKW_LOCAL ? ZNOEOF : ZMOULD);
         goto end;
      }
   }
   k = 0; /* Indicate normal close */
   if (i) k = (lzerror = ZNOEOF);
end:
   unzfree();
   zipstate = 0;
   zip_inp_port = NULL;
   return k;
}
