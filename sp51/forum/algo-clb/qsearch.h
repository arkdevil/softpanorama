/*
 * qsearch.h: header file for qsearch.c
 * 9-Oct-1992, Guido Gronek
 */

typedef size_t shifttab[UCHAR_MAX+1];   /* shift table */

extern size_t qs_tlen;

size_t * mktd1(const char *pstr, int reverse, shifttab td1);
char *qsearch(const char *pstr, const char *text, const size_t *td1, int reverse, size_t tlen);
