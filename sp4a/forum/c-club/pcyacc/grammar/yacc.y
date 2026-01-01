/*================== PCYACC ==========================================

           ABRAXAS SOFTWARE (R) PCYACC 
       (C)PCYACC 1986-88, ABRAXAS SOFTWARE, INC.
               all rights reserved

======================================================================*/


%{

#include <stdio.h>
#include <ctype.h>

int debug = 0;
%}

%union {
  int  i;
  char s[NAMESIZE];
}

%token <s> S_IDENTIFIER
%token <s> C_IDENTIFIER
%token <i> S_NUMBER
%token S_LEFT S_RIGHT S_NONASSOC S_TOKEN S_PREC S_TYPE S_START S_UNION
%token S_MARK S_LCURL S_RCURL S_LACT LRACT

%start spec

%%

spec : defs S_MARK lcurls rules tail
       { if (debug) fprintf(stdout, "spec : defs S_MARK lcurls rules tail\n"); }
     ;

lcurls :
         { if (debug) fprintf(stdout, "lcurls : \n"); }
       | lcurls S_LCURL
         { if (debug) fprintf(stdout, "lcurls : lcurls S_LCURL\n"); }
       ;

tail :
       { if (debug) fprintf(stdout, "tail : \n"); }
     | S_MARK
       { skpall();
         if (debug) fprintf(stdout, "tail : S_MARK\n");
       }
     ;

defs :
       { if (debug) fprintf(stdout, "defs : \n"); }
     | defs def
       { if (debug) fprintf(stdout, "defs : defs def\n"); }
     ;

def  : '%' S_START S_IDENTIFIER
       { if (debug) fprintf(stdout, "def : S_START S_IDENTIFIER\n"); }
     | '%' S_UNION
       { if (debug) fprintf(stdout, "def : S_UNION\n"); }
     | S_LCURL
       { if (debug) fprintf(stdout, "def : S_LCURL\n"); }
     | rword tag nlist
       { if (debug) fprintf(stdout, "def : rword tag nlist\n"); }
     | error
       { yyerror("Syntax error"); } 
     ;

rword : '%' S_TOKEN
       { if (debug) fprintf(stdout, "rword : S_TOKEN\n"); }
      | '%' S_LEFT
       { if (debug) fprintf(stdout, "rword : S_LEFT\n"); }
      | '%' S_RIGHT
       { if (debug) fprintf(stdout, "rword : S_RIGHT\n"); }
      | '%' S_NONASSOC
       { if (debug) fprintf(stdout, "rword : S_NONASSOC\n"); }
      | '%' S_TYPE
       { if (debug) fprintf(stdout, "rword : S_TYPE\n"); }
      ;

tag   :
      | '<' S_IDENTIFIER '>'
        { if (debug) fprintf(stdout, "tag: < S_IDENTIFIER >\n"); }
      ;

nlist : nmno
        { if (debug) fprintf(stdout, "nlist : nmno\n"); }
      | nlist nmno
        { if (debug) fprintf(stdout, "nlist : nlist nmno\n"); }
      | nlist ',' nmno
        { if (debug) fprintf(stdout, "nlist : nlist , nmno\n"); }
      ;

nmno  : S_IDENTIFIER
        { if (debug) fprintf(stdout, "nmno : S_IDENTIFIER\n"); }
      | S_IDENTIFIER S_NUMBER
        {
          $2 = $2;
          if (debug) fprintf(stdout, "nmno : S_IDENTIFIER S_NUMBER\n");
        }
      ;

rules : S_IDENTIFIER ':' rbody ';'
        { if (debug) fprintf(stdout, "rules : S_IDENTIFIER : rbody ;\n"); }
      | rules S_IDENTIFIER ':' rbody ';'
        { if (debug) fprintf(stdout, "rules : rules S_IDENTIFIER : rbody ;\n"); }
      | error ';'
        { yyerror("Syntax error"); }
      ;

rbody : ralt
        { if (debug) fprintf(stdout, "rbody : ralt\n"); }
      | rbody '|' ralt
        { if (debug) fprintf(stdout, "rbody : rbody | ralt\n"); }
      ;

ralt  : rule prec
        { if (debug) fprintf(stdout, "ralt : rule prec\n"); }
      ;

rule  :
        { if (debug) fprintf(stdout, "rule :\n"); }
      | rule S_IDENTIFIER
        { if (debug) fprintf(stdout, "rule : rule S_IDENTIFIER\n"); }
      | rule act
        { if (debug) fprintf(stdout, "rule : rule act\n"); }
      ;

prec  :
        { if (debug) fprintf(stdout, "prec :\n"); }
      | '%' S_PREC S_IDENTIFIER
        { if (debug) fprintf(stdout, "prec : S_PREC S_IDENTIFIER\n"); }
      | '%' S_PREC S_IDENTIFIER act
        { if (debug) fprintf(stdout, "prec : S_PREC S_IDENTIFIER act\n"); }
      ;

act   : S_LACT
        { if (debug) fprintf(stdout, "act : S_LACT\n"); }
      ;

%%

extern int peekline;

yylex()
{ int delim, cc;
  int c, c1, tokentype, tokenend;

  lineno += peekline;
  peekline = 0;
  while (isspace(c=getc(finput))) if (c == '\n') lineno++; /* skip ws */
  if (c == EOF) return(0); /* end of file encounted */
  if (c == '/') {
    lineno += skipcom();
    return(yylex());
  }
  if (c == '{') { ungetc(c, finput); skpcode0(); return(S_LACT); } /* start of action */
  if (isdigit(c)) /* numerical token */ {
    yylval.i = c - '0';
    while (isdigit(c=getc(finput))) yylval.i = yylval.i * 10 + c - '0';
    ungetc(c, finput);
    return(S_NUMBER);
  }
  if (c == '%') {
    if ((c=getc(finput)) == '{') { skpcode1(); return(S_LCURL); }
    if (c == '%') return(S_MARK);
    ungetc(c, finput);
    return('%');
  }
  if (c == '"' || c == '\'') {
    delim = c;
    cc = 0;
    yylval.s[cc++] = ' ';
    while ((c=getc(finput)) != delim) {
      if (c == '\n' || c == EOF) {
        error("Lex Error: missing ' or \"");
        return(S_IDENTIFIER);
      }
      yylval.s[cc++] = c;
      if (c == '\\') {
        c = getc(finput);
        yylval.s[cc++] = c;
      }
    }
    yylval.s[cc++] = '\0';
    return(S_IDENTIFIER);
  }
  if (isalpha(c) || (c == '\_')) /* symbolic token */ {
    cc = 0;
    yylval.s[cc++] = c;
    while (isalnum(c=getc(finput)) || (c == '\_')) {
      yylval.s[cc++] = c;
    }
    ungetc(c, finput);
    yylval.s[cc++] = '\0';
    if (!strcmp("left",     yylval.s)) return(S_LEFT);
    if (!strcmp("nonassoc", yylval.s)) return(S_NONASSOC);
    if (!strcmp("prec",     yylval.s)) return(S_PREC);
    if (!strcmp("right",    yylval.s)) return(S_RIGHT);
    if (!strcmp("start",    yylval.s)) return(S_START);
    if (!strcmp("token",    yylval.s)) return(S_TOKEN);
    if (!strcmp("type",     yylval.s)) return(S_TYPE);
    if (!strcmp("union",    yylval.s)) { skpcode0(); return(S_UNION); }
    return(S_IDENTIFIER);
  }
  return(c);
}

skpcode0()
{

  int level, c;

  level = 0;
  for (;;) {
    if ((c=getc(finput)) < 0) error("EOF encountered inside c code");
    switch (c) {
      case '\n':
      	++lineno;
      	break;
      case '{':
      	++level;
      	break;
      case '}':
      	--level;
      	if (level == 0) return;
    }
  }
}

skpcode1()
{

  int c;

  c = getc(finput);
  if (c == '\n') {
    c = getc(finput);
    lineno++;
  }
  while (c>=0) {
    if (c=='\\')
      if ((c=getc(finput)) == '}') return;
    if (c=='%')
      if ((c=getc(finput)) == '}') return;
    if (c == '\n') ++lineno;
    c = getc(finput);
  }
  error("eof before %%}");
}

skpall()
{ int c;

  while ((c=getc(finput)) != EOF);
  return(c);
}

yyerror(s)
char *s;
{

  error(s);
}


