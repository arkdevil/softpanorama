#include "arjcrack.h"
#include <stdlib.h>

extern int bound;
extern unsigned char cmin,cmax;
extern unsigned char only[];
extern int onlylen;

#define THRESHOLD    3
#define DDICSIZ      26624
#define MAXDICBIT   16
#define MATCHBIT     8
#define MAXMATCH   256
#define NC          (UCHAR_MAX + MAXMATCH + 2 - THRESHOLD)
#define NP          (MAXDICBIT + 1)
#define CBIT         9
#define NT          (CODE_BIT + 3)
#define PBIT         5
#define TBIT         5

#if NT > NP
#define NPT NT
#else
#define NPT NP
#endif

#define CTABLESIZE  4096

#define STRTP          9
#define STOPP         13

#define STRTL          0
#define STOPL          7

/* Local functions */

static int    make_table  (int,uchar *,int,ushort *,uint);
static int    read_pt_len (int,int,int);
static int    read_c_len  (void);
static ushort decode_c    (int *);
static ushort decode_p    (int *);
static int    decode_start(void);
static short  decode_ptr  (int *);
static short  decode_len  (int *);

/* Local variables */

uchar *text;          //*  uchar text [DDICSIZ];
static short  getlen;
static short  getbuf;

static ushort left  [2 * NC];
static ushort right [2 * NC];
static uchar  c_len [NC];
static uchar  pt_len[NPT];

static ushort c_table[CTABLESIZE];
static ushort pt_table[256];
static ushort blocksize;

/* Huffman decode routines */

int make_table (int nchar, uchar *bitlen, int tablebits,
                ushort *table, uint tablesize)
{
ushort count[17], weight[17], start[18], *p;
uint i, k, len, ch, jutbits, avail, nextcode, mask;

for (i=1; i<=16; i++)          count [i] = 0;
for (i=0; (int)i < nchar; i++) count [bitlen[i]]++;

start [1] = 0;
for (i=1; i<=16; i++)
   start [i+1] = start [i] + (count[i] << (16-i));
if (start [17]) return (1);

jutbits = 16 - tablebits;
for (i=1; (int)i <= tablebits; i++)
   {
   start [i] >>= jutbits;
   weight[i] = 1 << (tablebits-i);
   }
while (i <= 16)
   {
   weight[i] = 1 << (16-i);
   i++;
   }
i = start[tablebits + 1] >> jutbits;
if (i != (ushort) (1 << 16))
   {
   k = 1 << tablebits;
   while (i != k) table[i++] = 0;
   }
avail = nchar;
mask = 1 << (15 - tablebits);
for (ch=0; (int)ch < nchar; ch++)
   {
   if ((len = bitlen[ch]) == 0) continue;
   if (len > 16) return (1);
   k = start [len];
   nextcode = k + weight[len];
   if ((int)len <= tablebits)
      {
      if (nextcode > tablesize) return (1);
      for (i=start [len]; i < nextcode; i++)
          table[i] = ch;
      }
   else
      {
      i = k >> jutbits;
      if (i >= tablesize) return (1);
      p = &table[i];
      i = len - tablebits;
      while (i != 0)
         {
         if (*p == 0)
            {
            if (avail >= 2*NC) return (1);
            right [avail] = left [avail] = 0;
            *p = avail++;
            }
         if (k & mask) p = right+(*p);
         else          p = left +(*p);
         k <<= 1;
         i--;
         }
      *p = ch;
      }
   start[len] = nextcode;
   }
return (0);
}

static int read_pt_len (int nn, int nbit, int i_special)
{
register int i, n;
int error=0;
short c;
ushort mask;

n = getbits(nbit,&error);
if (error) return (1);
if (n == 0)
   {
   c = getbits(nbit,&error);
   if (error) return (1);
   for (i=0; i <  nn; i++) pt_len  [i] = 0;
   for (i=0; i < 256; i++) pt_table[i] = c;
   }
else
   {
   i = 0;
   while (i < n)
      {
      c = (bitbuf >> (13)) & 0x7;
      if (c == 7)
         {
         mask = 1 << (12);
         while (mask & bitbuf)
            {
            mask >>= 1;
            c++;
            }
         }
      if (fillbuf((c < 7) ? 3 : (int)(c-3))) return (1);
      pt_len[i++] = (uchar)c;
      if (i == i_special)
         {
         c = getbits(2,&error);
         if (error) return (1);
         while (--c >= 0) pt_len[i++] = 0;
         }
      }
   while (i < nn) pt_len[i++] = 0;
   if (make_table(nn, pt_len, 8, pt_table, 256)) return (1);
   }
return (0);
}

static int read_c_len(void)
{
register short i, c, n;
int error=0;
ushort mask;

n = getbits (CBIT,&error);
if (error) return (1);
if (n == 0)
   {
   c = getbits (CBIT,&error);
   if (error) return (1);
   for (i=0; i < NC; i++)         c_len  [i] = 0;
   for (i=0; i < CTABLESIZE; i++) c_table[i] = c;
   }
else
   {
   i = 0;
   while (i < n)
      {
      c = pt_table[bitbuf >> (8)];
      mask = 0x80;
      while (c >= NT)
         {
         if (bitbuf & mask) c = right[c];
         else               c = left [c];
         mask >>= 1;
         }
      if (fillbuf((int)(pt_len[c]))) return (1);
      if (c <= 2)
         {
         if (c == 0) c = 1; else
         if (c == 1) c = getbits(4,&error) + 3; else
                     c = getbits(CBIT,&error) + 20;
         if (error) return (1);
         while (--c >= 0)
            c_len[i++] = 0;
         }
      else
         c_len[i++] = (uchar)(c - 2);
      }
   while (i < NC)
      c_len[i++] = 0;
   if (make_table (NC, c_len, 12, c_table, CTABLESIZE)) return(1);
   }
return (0);
}

static ushort decode_c(int *error)
{
    register ushort j, mask;
    
    if (blocksize == 0)
       {
       blocksize = getbits(16,error);
       if (*error)
          return (0);
       if ((*error)=read_pt_len (NT, TBIT, 3))
          return (0);
       if ((*error)=read_c_len  ())
          return (0);
       if ((*error)=read_pt_len (NP, PBIT, -1))
          return (0);
       }
    blocksize--;
    j = c_table[bitbuf >> 4];
    mask = 0x08;
    while (j >= NC)
       {
       if (bitbuf & mask) j = right[j];
       else               j = left [j];
       mask >>= 1;
       };
    (*error) = fillbuf ((int)(c_len[j]));
    if (*error)
       return (0);
    return j;
}

static ushort decode_p(int *error)
{
    register ushort j, mask;

    j = pt_table[bitbuf >> (8)];
    mask = 0x80;
    while (j >= NP)
       {
       if (bitbuf & mask) j = right[j];
       else               j = left [j];
       mask >>= 1;
       };
    if ((*error) = fillbuf((int)(pt_len[j]))) return j;
    if (j != 0)
       { j--; j = (1 << j) + getbits ((int)j,error); }
    return j;
}

static int decode_start()
{
blocksize=0;
return init_getbits();
}

void decode()
{
short i;
short j;
short c;
short r;
long count;
int error;
unsigned char t;

if (decode_start()) return;
count = 0L;
r = 0;

while (count < origsize)
   {
   c = decode_c(&error);
   if (error)
      return;
   if (c <= UCHAR_MAX)
      {
      t = text[r] = (uchar) c;
      if (bound > 0)       { if (t<cmin || t>cmax) return; }
      if (count < onlylen) { if (t != only [count]) return; }
      count++;
      if (++r >= DDICSIZ)
         { r=0; crc_buf (text, DDICSIZ); }
      }
   else
      {
      j = c - (UCHAR_MAX + 1 - THRESHOLD);
      //*count += j;
      i = decode_p(&error);
      if (error)
         return;
      if ((i=r-i-1) < 0)
         i += DDICSIZ;
      if (r > i && r < DDICSIZ-MAXMATCH-1)
         {
         while (--j >= 0)
            {
            t = text[r++] = text[i++];
            if (bound > 0)       { if (t<cmin || t>cmax) return; }
            if (count < onlylen) { if (t != only [count]) return; }
            count++;
            }
         }
      else
         {
         while (--j >= 0)
            {
            t = text[r] = text[i];
            if (bound > 0)       { if (t<cmin || t>cmax) return; }
            if (count < onlylen) { if (t != only [count]) return; }
            count++;
            if (++r >= DDICSIZ) { r=0; crc_buf (text, DDICSIZ); }
            if (++i >= DDICSIZ) i=0;
            }
         }
      }
   }
if (r != 0) crc_buf (text, r);
return;
}

static short decode_ptr(int *error)
{
    short c;
    short width;
    short plus;
    short pwr;

    plus = 0;
    pwr = 1 << (STRTP);
    for (width = (STRTP); width < (STOPP) ; width++)
    {
        if (getlen<=0)
           {
           getbuf |= bitbuf>>getlen;
           if ((*error)=fillbuf (CODE_BIT-getlen)) return (0);
           getlen=CODE_BIT;
           }
        c=(getbuf & 0x8000) != 0;
        getbuf<<=1;
        getlen--;
        if (c==0) break;
        plus += pwr;
        pwr <<= 1;
    }
    if (width != 0)
       {
       if (getlen<width)
          {
          getbuf |= bitbuf>>getlen;
          if ((*error)=fillbuf (CODE_BIT-getlen)) return (0);
          getlen=CODE_BIT;
          }
       c = (ushort)getbuf >> (CODE_BIT-width);
       getbuf <<= width;
       getlen -= width;
       }
    c += plus;
    return c;
}

static short decode_len(int *error)
{
    short c;
    short width;
    short plus;
    short pwr;

    plus = 0;
    pwr = 1 << (STRTL);
    for (width = (STRTL); width < (STOPL) ; width++)
    {
        if (getlen<=0)
           {
           getbuf |= bitbuf>>getlen;
           if ((*error)=fillbuf (CODE_BIT-getlen)) return (0);
           getlen=CODE_BIT;
           }
        c=(getbuf & 0x8000) != 0;
        getbuf<<=1;
        getlen--;
        if (c==0) break;
        plus += pwr;
        pwr <<= 1;
    }
    if (width != 0)
        {
        if (getlen<width)
           {
           getbuf |= bitbuf>>getlen;
           if ((*error)=fillbuf (CODE_BIT-getlen)) return (0);
           getlen=CODE_BIT;
           }
        c = (ushort)getbuf >> (CODE_BIT-width);
        getbuf <<= width;
        getlen -= width;
        }
    c += plus;
    return c;
}

void decode_f()
{
short i;
short j;
short c;
short r;
short pos;
long count;
int error;
unsigned char t;

if (init_getbits()) return;
getlen = getbuf = 0;
count = 0;
r = 0;

while (count < origsize)
   {
   c = decode_len(&error);
   if (error)
      return;
   if (c == 0)
      {
      if (getlen < CHAR_BIT)
         {
         getbuf |= bitbuf>>getlen;
         if (fillbuf (CODE_BIT-getlen))
            return;
         getlen=CODE_BIT;
         }
      c = (ushort)getbuf >> (CODE_BIT-CHAR_BIT);
      getbuf <<= CHAR_BIT;
      getlen -= CHAR_BIT;
      t = text[r] = (uchar)c;
      if (bound > 0)       { if (t<cmin || t>cmax) return; }
      if (count < onlylen) { if (t != only [count]) return; }
      count++;
      if (++r >= DDICSIZ)
         { r=0; crc_buf (text, DDICSIZ); }
      }
   else
      {
      j = c-1+THRESHOLD;
      //*count += j;
      pos = decode_ptr(&error);
      if (error)
         return;
      if ((i=r-pos-1) < 0)
         i += DDICSIZ;
      while (j-- > 0)
         {
         t = text[r] = text[i];
         if (bound > 0)       { if (t<cmin || t>cmax) return; }
         if (count < onlylen) { if (t != only [count]) return; }
         count++;
         if (++r >= DDICSIZ) { r=0; crc_buf (text, DDICSIZ); }
         if (++i >= DDICSIZ) i=0;
         }
      }
   }
if (r != 0) crc_buf (text, r);
return;
}

/* end DECODE.C */
