/* unlzw.h - this is part of the Tar program (see file define.h) */

#include <stdio.h>
#include "modern.h"
#include "lzpipe.h"
#include "lzwbits.h"

#ifdef MODERN
#	include <stdlib.h>
#else
	char *malloc();
	void free();
#endif

static int d_n_bits;	/* number of bits/code */
static int hashbits  = BITS;
static int d_maxbits = BITS;	/* user settable max # bits/code */
static code_int d_maxcode;	/* maximum code, given n_bits */
/* should NEVER generate this code */
static code_int d_maxmaxcode = (code_int)1 << BITS;

#ifdef XENIX_16
  static unsigned short *decodet[MAXPAGES] = { NULL };
  static char_type *stab[NUMPAGES];

# define tab_prefixof(i) (decodet[(int)((i) >> PAGEXP)][(int)(i) & PAGEMASK])
# define tab_suffixof(i) (stab[(int)((i) >> PAGEXP)][(int)(i) & PAGEMASK])
#else
  static unsigned short *decodet = NULL;
  static char_type *stab;

# define tab_prefixof(i) decodet[i]
# define tab_suffixof(i) stab[i]
#endif

static char_type *de_stack = NULL; /* output stack */
static code_int d_free_ent = 0;

/* block compression parameters -- after all codes are */
/* used up, and compression rate changes, start over.  */
static int d_block_compress = BLOCK_MASK;
static int d_clear_flg = 0;
static count_int d_checkpoint = CHECK_GAP;

#ifdef LZFILE
	FILE *lzw_inp_port = NULL;
#	define getbyte() getc(lzw_inp_port)
#else
	int (*lzw_inp_port)__ARGS__((void)) = NULL;
#	define getbyte() (*lzw_inp_port)()
#endif

static int getpiece __ARGS__((char *, int));

static int getpiece(buf, nbytes)
char buf[]; int nbytes;
{
   register i, b;

   for (i=0; i<nbytes && (b=getbyte())!=EOF; i++) buf[i] = b;
   return i;
}

static code_int getcode __ARGS__((void))
/* Read one code, returns -1 on EOF */
{
#ifndef vax
   static char_type rmask[] = {0x00,0x01,0x03,0x07,0x0f,0x1f,0x3f,0x7f};
#endif
/* On the VAX, it is important to have the register declarations */
/* in exactly the order given, or the asm will break. */
   register code_int code;
   static int offset = 0, size = 0;
   static char_type buf[BITS];
   register int r_off, bits;
   register char_type *bp = buf;

   if (d_clear_flg > 0 || offset >= size || d_free_ent > d_maxcode ) {
      /*
       * If the next entry will be too big for the current code
       * size, then we must increase the size.  This implies reading
       * a new buffer full, too.
       */
      if (d_free_ent > d_maxcode) {
         d_maxcode = ++d_n_bits == d_maxbits ?
                        d_maxmaxcode : MAXCODE(d_n_bits);
      }
      if (d_clear_flg > 0) {
         d_maxcode = MAXCODE(d_n_bits = INIT_BITS);
         d_clear_flg = 0;
      }
      if ((size = getpiece((char *)buf, d_n_bits)) <= 0) return -1; /* EOF */
      offset = 0;
      /* Round size down to integral number of codes */
      size = (size << 3) - (d_n_bits - 1);
   }
   r_off = offset;
   bits = d_n_bits;
#ifdef vax
   asm( "extzv	  r10,r9,(r8),r11" );
#else
   /* Get to the first byte. */
   bp += (r_off >> 3);
   r_off &= 7;
   /* Get first part (low order bits) */
   code = char_to_byte((unsigned)(*bp++)) >> r_off;
   r_off = 8 - r_off;	/* now, offset into code word */
   if ((bits -= r_off) >= 8) {
      /* Get any 8 bit parts in the middle (<=1 for up to 16 bits). */
      code |= char_to_byte((unsigned)(*bp++)) << r_off;
       r_off += 8;
       bits -= 8;
   }
   /* high order bits. */
   code |= (unsigned)(*bp & rmask[bits]) << r_off;
#endif
   offset += d_n_bits;
   return code;
}

int lzwmark(wishbits)
int wishbits;
{
#ifdef XENIX_16
   register i, j; code_int l;
#endif
   code_int dhsize = _HSIZE;

   if (de_stack) return hashbits;
   if (wishbits > BITS) wishbits = BITS;
   hashbits = wishbits;

   de_stack = (char_type *)malloc(sizeof(char_type) * 8000);
   if (!de_stack) return -1;
   if      (wishbits >= 16) dhsize = 69001L;
   else if (wishbits >= 15) dhsize = 35023L;
   else if (wishbits >= 14) dhsize = 18013L;
   else if (wishbits >= 13) dhsize = 9001L;
   else                     dhsize = 5003L;
#ifdef XENIX_16
   for (l=(code_int)1<<wishbits, i=0; i<NUMPAGES && l>0; i++) {
      j = l<PAGESIZE ? (int)l : PAGESIZE;
      stab[i] = (char_type *)malloc(sizeof(char_type) * j);
      if (!stab[i]) return -1;
      l -= j;
   }
   for (l=dhsize, i=0; i<MAXPAGES && l>0; i++) {
      j = l > PAGESIZE ? PAGESIZE : (int)l;
      decodet[i] = (unsigned short *)malloc(sizeof(unsigned short)*j);
      if (!decodet[i]) break;
      l -= j;
   }
   l = dhsize - l;
   if      (l >= 69001L) { j = 16; dhsize = 69001L; }
   else if (l >= 35023L) { j = 15; dhsize = 35023L; }
   else if (l >= 18013)  { j = 14; dhsize = 18012L; }
   else if (l >= 9001)   { j = 13; dhsize =  9001L; }
   else if (l >= 5003)   { j = 12; dhsize =  5003L; }
   else return -1;
   if (hashbits > j) hashbits = j;
#else
   if ((decodet=(unsigned short*)malloc(sizeof(*decodet)*dhsize))==NULL ||
       (stab   =(char_type *)malloc(sizeof(*stab) * (1<<wishbits))) == NULL)
      return -1;
#endif
   return hashbits;
}

void lzwrelease()
{
#ifdef XENIX_16
   register i;
#endif

   if (de_stack != NULL) {
      free((char*)de_stack); de_stack = NULL;
#ifdef XENIX_16
      for (i=0; i<NUMPAGES && stab[i]!=NULL; i++) free((char*)(stab[i]));
      if (i >= NUMPAGES) {
         for (i=0; i<MAXPAGES && decodet[i]!=NULL; i++)
            free((char*)(decodet[i]));
      }
#else
      if (decodet != NULL) {
         free((char*)decodet);
         if (stab != NULL) free((char*)stab);
      }
#endif
   }
}

/* This routine adapts to the codes in the file building the "string" table */
/* on-the-fly; requiring no table to be stored in the compressed file.      */

static notfirst = 0;
static char_type *stackp;
static code_int oldcode;
static int finchar;

int lzwopen(lzw_inp)
#ifdef LZFILE
	FILE *lzw_inp;
#else
	int (*lzw_inp)__ARGS__((void));
#endif
{
   register k;

   lzw_inp_port = lzw_inp;
   d_clear_flg  = 0;
   d_checkpoint = CHECK_GAP;

   if (getbyte() != LZW_0TH_MAGIC || getbyte() != LZW_1ST_MAGIC) return -1;

   d_maxbits = getbyte(); /* set -b from file */
   d_block_compress = d_maxbits & BLOCK_MASK;
   d_maxbits &= BIT_MASK;
   if ((k = lzwmark(d_maxbits)) < d_maxbits) {
      lzw_inp_port = NULL;
      return k<INIT_BITS ? INIT_BITS-1 : k;
   }
   d_maxmaxcode = (code_int)1 << d_maxbits;
   /* As above, initialize the first 256 entries in the table. */
   d_maxcode = MAXCODE(d_n_bits = INIT_BITS);
   for (k = 255; k >= 0; k--) {
      tab_prefixof(k) = 0;
      tab_suffixof(k) = (char_type)k;
   }
   d_free_ent = d_block_compress ? FIRST : 256;
   stackp = de_stack;
   finchar = (int)(oldcode = getcode());
   notfirst = 0;
   return 0;
}

int lzwread(buf, len)
char buf[];
unsigned len;
{
   static code_int code, incode;
   register k = 0;

   if (!notfirst) {
      if (!lzw_inp_port) return (lzerror=ZNOPEN, -1);
      notfirst = 1;
      /* EOF already? Get out of here */
      if (oldcode == -1) goto end;
      /* first code must be 8 bits = char */
      ++k; *buf++ = (char)finchar;
   }
   for (;;) {
      if (stackp == de_stack) {
         if ((code = getcode()) < 0) break;
         if (code == CLEAR && d_block_compress) {
            for (code=255; code >= 0; code--) tab_prefixof(code) = 0;
            d_clear_flg = 1;
            d_free_ent = FIRST - 1;
            if ((code = getcode()) == -1) break; /* O, untimely death! */
         }
         incode = code;
         /* Special case for KwKwK string. */
         if (code >= d_free_ent) {
            if (code > d_free_ent) return (lzerror=ZMOULD, -1);
            *stackp++ = finchar;
            code = oldcode;
         }
         /* Generate output characters in reverse order */
#ifdef SIGNED_COMPARE_SLOW
         while ((unsigned long)code >= (unsigned long)256)
#else
         while (code >= 256)
#endif
         {
            *stackp++ = tab_suffixof(code);
            code = tab_prefixof(code);
         }
         *stackp++ = finchar = tab_suffixof(code);
      }
      /* And put them out in forward order */
      do {
         if (k >= len) goto end;
         ++k; *buf++ = *--stackp;
      } while (stackp > de_stack);

      /* Generate the new entry. */
      if ((code=d_free_ent) < d_maxmaxcode) {
         tab_prefixof(code) = (unsigned short)oldcode;
         tab_suffixof(code) = finchar;
         d_free_ent = code+1;
      }
      /* Remember previous code. */
      oldcode = incode;
   }
end:
   return k;
}
