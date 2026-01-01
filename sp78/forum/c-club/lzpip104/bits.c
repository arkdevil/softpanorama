#include <stdio.h>
#include "modern.h"
#include "stdinc.h"
#include "zalloc.h"
#include "zipdefs.h"
#include "zipguts.h"
#include "lzpipe.h"

static unsigned bitbuff;
static int boffset;

#ifdef DEBUG
ulg bits_sent;   /* bit length of the compressed data */
#endif

void bi_init() /* Initialize the bit string routines. */
{
   bitbuff = 0;
   boffset = 0;
#ifdef DEBUG
   bits_sent = 0L;
#endif
}

int send_bits(value, length) /* Send a value on a given number of bits. */
unsigned value; /* value to send */
int length;     /* number of bits: length =< 16 */
{
#ifdef DEBUG
   Tracevv((stderr," l %2d v %4x ", length, value));
   Assert(length > 0 && length <= 15, "invalid length");
   Assert(boffset < 8, "bad offset");
   bits_sent += (ulg)length;
#endif
   bitbuff |= value << boffset;
   if ((boffset += length) >= 8) {
      if (putbyte(bitbuff) == EOF) return -1;
      value >>= length - (boffset -= 8);
      if (boffset >= 8) {
         boffset -= 8;
         if (putbyte(value) == EOF) return -1;
         value >>= 8;
      }
      bitbuff = value;
   }
   return 0;
}

/* Write out any remaining bits in an incomplete byte. */
int bi_windup()
{
   Assert(boffset < 8, "bad offset");
   if (boffset) {
      if (putbyte(bitbuff) == EOF) return -1;
      boffset = 0;
      bitbuff = 0;
#ifdef DEBUG
      bits_sent = (bits_sent+7) & ~7;
#endif
   }
   return 0;
}

int bi_putsh(x)
unsigned short x;
{
   return (putbyte(x&255)==EOF || putbyte((x>>8)&255)==EOF) ? -1 : 0;
}

/* Copy a stored block to the zip file, storing first the length and its
   one's complement if requested. */
int copy_block(buf, len, header)
char far *buf; /* the input data */
unsigned len;  /* its length */
int header;    /* true if block header must be written */
{
   /* align on byte boundary */
   if (bi_windup() != 0) return -1;

   if (header) {
      if (bi_putsh(len) != 0 || bi_putsh(~len) != 0) return -1;
#ifdef DEBUG
      bits_sent += 2*16;
#endif
   }
   while (len--) {
      if (putbyte(*buf++) == EOF) return -1;
   }
#ifdef DEBUG
   bits_sent += (ulg)len<<3;
#endif
   return 0;
}
