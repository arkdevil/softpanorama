
/*================== PCYACC ==========================================

            ABRAXAS SOFTWARE (R) PCYACC
      (C)COPYRIGHT PCYACC 1986-88, ABRAXAS SOFTWARE, INC.
               ALL RIGHTS RESERVED

======================================================================*/


#include <stdio.h>

#include "const.h"
#include "yylex.h"

extern int pcyytoken;
int errpos;
int errflag;
int errcount;
int errtoken;

void errinit() {

  errflag  = FALSE;
  errtoken = NONTK;
  errcount = 0;
  errpos = 1;
}

void
errproc() {

  errflag = TRUE;
  errtoken = pcyytoken;
  errcount ++;
  errpos  = charno;
}

void
error(typ, msg)
int typ;
char *msg;
{

  if (typ == FATAL) {
    fprintf(stderr, "Fatal error: %s\n", msg);
    exit(1);
  } else {
    fprintf(stderr, "Error: %s\n", msg);
  }
}

void
yyerror(s)
char *s;
{
  error(NONFATAL, s);
}


