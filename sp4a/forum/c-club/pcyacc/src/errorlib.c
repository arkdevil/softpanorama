
#include <stdio.h>

FILE *yyerrfile = stderr;
char  yyerrsrc[64] = "";
int   yylineno  = -1;
	        
char  yylocerrtok[];

errprefix()
{ int punct = 0;

  if (strcmp(yyerrsrc, "")) {
    fprintf(yyerrfile, "file %s", yyerrsrc);
    punct = 1;
  }
  if (yylineno >= 0) {
    if (punct) {
      fprintf(yyerrfile, ", ");
    }
    fprintf(yyerrfile, "line %d", yylineno);
    punct = 1;
  }
  if (strlen(yyerrtok) > 0) {
    if (punct) {
      fprintf(yyerrfile, " ");
    }
    fprintf(yyerrfile, "near \"%s\"", yyerrtok);
    punct = 1;
  }
  if (punct) fprintf(yyerrfile, ": ");
}

poscatch()
{

  sscanf(yytext, "# %d %s", &yylineno, yyerrsrc);
}

extern int yynerrs;

yyerror(s, t)
char *s;
char *t;
{ static int list = 0;

  if (s != NULL || !list) {
    fprintf(yyerrfile, "[error %d] ", yynerrs+1);
    errprefix();
    if (s != NULL) {
      fprintf(yyerrfile, "%s\n", s);
      return;
    }
    if (t != NULL) {
      fprintf(yyerrfile, "expecting: %s", t);
      list = 1;
      return;
    }
    fprintf(yyerrfile, "syntax error\n");
    return;
  }

  if (t != NULL) {
    fprintf(yyerrfile, " %s", t);
    return;
  }

  fprintf(yyerrfile, "\n");
  list = 0;
}

static char *
yydisplay(ch)
int ch;
{ static char buf[64];
  static char tok[] = {
#include "yytok.h"
                       0 };

  switch (ch) {
    case         0: return ("[end of file]");
    case YYERRCODE: return ("[error]");
    case      '\b': return ("'\\b'");
    case      '\f': return ("'\\f'");
    case      '\n': return ("'\\n'");
    case      '\r': return ("'\\r'");
    case      '\t': return ("'\\t'");
  }
  if (ch > 256 && ch < 256 + DIM(tok)) return (tok[ch-257]);
  if (isascii(ch) && isprint(ch)) sprintf(buf, "'%c'", ch);
  else if (ch < 256) sprintf(buf, "char %d", ch);
  return(buf);
}


