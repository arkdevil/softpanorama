
/*
 * qsearch.c: fast substring matching in forward and backward direction
 * 9-Oct-1992, Guido Gronek
 */

#include <stdlib.h>
#include <string.h>
#include <limits.h>

#include "qsearch.h"

#define TEST

static size_t Plen;                      /* length of pattern */


/*
 * generate shift table from pattern string
 * out: address of the initialised shift table
 */
size_t *mktd1(pstr, reverse, td1)
const char *pstr;                   /* pattern string */
int reverse;                        /* reverse order TRUE/FALSE */
shifttab td1;                       /* the caller-supplied shift table */
{
  int c;
  size_t m;
  const char *p;
  size_t * shift;

  for (p = pstr; *p; ++p)
    ;
  Plen = m = p - pstr;              /* length of pattern */

  for( ++m, shift = td1, c = UCHAR_MAX+1; --c >=0; )
    *shift++ = m;         /* initialize shift table with Plen + 1 */

  if (reverse)
    for (shift = td1; p>pstr; )     /* scan pattern right to left */
      shift[*--p] = --m;
  else
    for (shift = td1, p = pstr; *p; ) /* scan pattern left to right */
      shift[*p++] = --m;

  return td1;
}


/* Quicksearch for a pattern in text
 * out: address of the substring in the text or 0 if none
 */
char *qsearch(pstr, text, td1, reverse, tlen)
const char *pstr;                 /* pattern string */
const char *text;                 /* text */
const size_t *td1;                /* shift table ASUMED INITIALISED */
int reverse;                      /* reverse order TRUE/FALSE */
size_t tlen;                      /* text string length if > 0 */
{
  register const char *p, *t, *tx;
  const char *txe;
  size_t m;

  if ( pstr==0 || text==0 )
    return 0;

  m = Plen;
  if (tlen > 0)               /* length of text string supported */
    txe = text + tlen;
  else
  {
    tx = text;
    while (*tx++)
      ;
    txe = --tx;
  }
  if (reverse)
  {
    tx = txe - m;                  /* rightmost possible match */
    while ( tx >= text )
    {
      p = pstr; t = tx;
      do
      {
        if (*p == 0)               /* pattern scanned completely */
          return (char *)tx;
      } while ( *p++ == *t++ );    /* break if mismatch */
      if ( tx>text )
          tx -= td1[*(tx-1)];      /* shift to previous text location */
      else
        break;
    }
  }
  else
  {
    tx = text;
    while ( tx + m <= txe )
    {
      p = pstr; t = tx;
      do
      {
        if (*p == 0)               /*  pattern scanned completely */
          return (char *)tx;
      } while ( *p++ == *t++ );    /* break if mismatch */
      tx += td1[*(tx+m)];          /* shift to next text location */
    }
  }
  return 0;
}


#ifdef TEST
#include <stdio.h>
#include <string.h>

#define USAGE "usage: qsearch [-r] text pattern\n"

char *strsearch(const char *pstr, const char *text, int reverse);


char *strsearch(text, pstr, reverse)
const char *text;
const char *pstr;
int reverse;
{
  static shifttab shift;

  return qsearch( pstr, text, mktd1(pstr,reverse,shift), reverse, 0 );
}


int main( argc, argv )
int  argc;
char *argv[];
{
  register char *p;
  int reverse;

  if ( argc < 3 )
  {
    fprintf(stderr, USAGE);
    exit(1);
  }
  if ( (reverse = strcmp(argv[1],"-r") ==0) !=0 && argc < 4 )
  {
    fprintf(stderr, USAGE);
    exit(1);
  }

  p = reverse ? strsearch(argv[2], argv[3], 1) :  
                strsearch(argv[1], argv[2], 0);
  if ( p == 0 )
    printf("pattern not found\n");
  else
    printf("pattern start: %s\n", p);
  return 0;
}

#endif
