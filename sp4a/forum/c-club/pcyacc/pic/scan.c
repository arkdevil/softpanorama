
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include "pic.h"

extern FILE *inf;
extern char *infn;
extern int   nxtch;

static struct {
  char *kw;
  int   ltp;
} kwtable[] = {
  {"black",   BLACK},
  {"box",     BOX},
  {"circle",  CIRCLE},
  {"define",  DEFINE},
  {"dotted",  DOTTED},
  {"draw",    DRAW},
  {"ellipse", ELLIPSE},
  {"filled",  FILL},
  {"line",    LINE},
  {"polygon", POLYGON},
  {"solid",   SOLID},
  {"white",   WHITE},
  {"eot",     IDENTIFIER},
};

kwsearch(s)
char *s;
{ register i;

  for (i=0; strcmp("eot", kwtable[i].kw); i++) if ( !strcmp(s, kwtable[i].kw) ) break;
  return(kwtable[i].ltp);
}

#define POOLSZ 2048
char chpool[POOLSZ];
int  avail = 0;

yylex() {
register int sign, tktyp;

  while (nxtch==' ' || nxtch=='\t' || nxtch=='\n') nxtch = getc(inf);
  if (nxtch==EOF) return(0);
  if (isdigit(nxtch) || nxtch=='+' || nxtch=='-') {
    if (nxtch=='+') {
      sign = 1;
      yylval.in = 0;
    } else if (nxtch=='-') {
      sign = -1;
      yylval.in = 0;
    } else {
      sign = 1;
      yylval.in = nxtch - '0';
    }
    while (isdigit(nxtch=getc(inf))) yylval.in = (yylval.in * 10) + nxtch - '0';
    yylval.in = sign * yylval.in;
    tktyp = INTEGER;
  } else if (isalpha(nxtch)) {
    yylval.ch = chpool + avail;
    chpool[avail++] = nxtch;
    while (isalnum(nxtch=getc(inf))) chpool[avail++] = nxtch;
    chpool[avail++] = '\0';
    tktyp = kwsearch(yylval.ch);
  } else {
    tktyp = nxtch;
    nxtch = getc(inf);
  }
  return (tktyp);
}
    

  
  
