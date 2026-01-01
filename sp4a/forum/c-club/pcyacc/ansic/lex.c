
/*
=====================================================================
  LEX.C: lexical analyzer for ANSIC parser
  Verion 1.0
  By Xing Liu
  Copyright(c) Abraxas Software Inc. (R), 1988, All rights reserved

=====================================================================
*/

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include "global.h"
#include "ansic.h"

char tokval[BUFSIZE];

extern FILE *fin;

#define TABLESZ 256
#define IDENTSZ 64

char types[TABLESZ][IDENTSZ];
char enums[TABLESZ][IDENTSZ];
int  ntypes = 0;
int  nenums = 0;

finddef(tab, limit, ident)
char **tab;
int  limit;
char *ident;
{
  int i, found;

  found = FALSE;
  for (i=0; i<limit && !found; i++) if (! strcmp(ident, tab[i])) found = TRUE;
  if (found) return (TRUE);
  return (FALSE);
}

adddef(tab, count, ident)
char **tab;
int count;
char *ident;
{
  if (count >= TABLESZ) {
    printf("internal name table overflow, abort\n");
    exit(1);
  }
  if (! finddef(tab, count, ident)) strcpy(tab[count++], ident);
}

yylex()
{
  int   i, c1, c2, done;
  int   toktype, intval;
  float realval;

  while (isspace(c)) {
    c = getc(fin);
    if (c == '\n') lineno++;
  }
  if (c == EOF) return(0);
  if (c == '/') {		/* a possible comment */
    c1 = getc(fin);
    if (c1 == '*') {		/* is a comment, skip it */
      done = FALSE;
      while (! done) {
        c1 = getc(fin);
        if (c1 == EOF) {
          yyerror("EOF inside comments");
          exit(1);
        } else if (c1 == '*') {
          c1 = getc(fin);
          if (c1 == '/') done = TRUE;
        }
      }
      c = getc(fin);
      return(yylex());
    } else if (c1 == '=') {	/* not a comment, is it a DIVEQ? */
      toktype = DIVEQ;
      c = getc(fin);
    } else {			/* not a DIVEQ either */
      toktype = '/';
      c = c1;
    }
  } else if (c == '\"') {	/* a string literal, need to add char literal */
    i = 0;
    done = FALSE;
    while (! done) {
      c = getc(fin);
      if (c == '\"') {
        c = getc(fin);
        if (c == '\"') {
          tokval[i++] = '\"';
          c = getc(fin);
        } else {
          done = TRUE;
        }
      } else {
        tokval[i++] = c;
        yylval.s = tokval;
      }
    }
    tokval[i++] = '\0';
    toktype = STRING;
  } else if (c == '<') {
    c1 = getc(fin);
    if (c1 == '=') {
      toktype = LEQ;
      c = getc(fin);
    } else if (c1 == '<') {
      c2 = getc(fin);
      if (c2 == '=') {
        toktype = SHLEQ;
        c = getc(fin);
      } else {
        toktype = SHL;
        c = c2;
      }
    } else {
      toktype = '<';
      c = c1;
    }
  } else if (c == '>') {
    c1 = getc(fin);
    if (c1 == '=') {
      toktype = GEQ;
      c = getc(fin);
    } else if (c1 == '>') {
      c2 = getc(fin);
      if (c2 == '=') {
        toktype = SHREQ;
        c = getc(fin);
      } else {
        toktype = SHR;
        c = c2;
      }
    } else {
      toktype = '>';
      c = c1;
    }
  } else if (c == '&') {
    c1 = getc(fin);
    if (c1 == '&') {
      toktype = ANDAND;
      c = getc(fin);
    } else if (c1 == '=') {
      toktype = ANDEQ;
      c = getc(fin);
    } else {
      toktype = '&';
      c = c1;
    }
  } else if (c == '|') {
    c1 = getc(fin);
    if (c1 == '|') {
      toktype = OROR;
      c = getc(fin);
    } else if (c1 == '=') {
      toktype = IOREQ;
      c = getc(fin);
    } else {
      toktype = '|';
      c = c1;
    }
  } else if (c == '^') {
    c1 = getc(fin);
    if (c1 == '=') {
      toktype = XOREQ;
      c = getc(fin);
    } else {
      toktype = '^';
      c = c1;
    }
  } else if (c == '!') {
    c1 = getc(fin);
    if (c1 == '=') {
      toktype = NEQ;
      c = getc(fin);
    } else {
      toktype = '!';
      c = c1;
    }
  } else if (c == '=') {
    c1 = getc(fin);
    if (c1 == '=') {
      toktype = EQU;
      c = getc(fin);
    } else {
      toktype = '=';
      c = c1;
    }
  } else if (c == '+') {
    c1 = getc(fin);
    if (c1 == '+') {
      toktype = ADDADD;
      c = getc(fin);
    } else if (c1 == '=') {
      toktype = ADDEQ;
      c = getc(fin);
    } else {
      toktype = '+';
      c = c1;
    }
  } else if (c == '-') {
    c1 = getc(fin);
    if (c1 == '-') {
      toktype = SUBSUB;
      c = getc(fin);
    } else if (c1 == '=') {
      toktype = SUBEQ;
      c = getc(fin);
    } else if (c1 == '>') {
      toktype = PTR;
      c = getc(fin);
    } else {
      toktype = '-';
      c = c1;
    }
  } else if (c == '*') {
    c1 = getc(fin);
    if (c1 == '=') {
      toktype = MULEQ;
      c = getc(fin);
    } else {
      toktype = '*';
      c = c1;
    }
  } else if (c == '%') {
    c1 = getc(fin);
    if (c1 == '=') {
      toktype = MODEQ;
      c = getc(fin);
    } else {
      toktype = '%';
      c = c1;
    }
  } else if (c == '.') {
    c1 = getc(fin);
    if (c1 == '.') {
      c2 = getc(fin);
      if (c2 == '.') {
        toktype = DDD;
        c = getc(fin);
      } else {
        ungetc(c2, fin);
        toktype = '.';
        c = c1;
      }
    } else {
      toktype = '.';
      c = c1;
    }
  } else if (isdigit(c)) {
    toktype = INTEGER_CONSTANT;
    intval = 0;
    while (isdigit(c)) {
      intval = intval * 10 + (c - '0');
      c = getc(fin);
    }
    if (c == '.') {
      toktype = FLOAT_CONSTANT;
      realval = 0.0;
      i = 10.0;
      c = getc(fin);
      while (isdigit(c)) {
        realval = realval + (c - '0') / i;
        i = i * 10;
        c = getc(fin);
      }
    }
    if (toktype == INTEGER_CONSTANT) {
      yylval.i = intval;
    } else {
      yylval.r = realval + intval;
    }
  } else if (isalpha(c)) {
    i = 0;
    while (isalnum(c)) {
      tokval[i++] = c;
      c = getc(fin);
    }
    tokval[i++] = '\0';
    yylval.s = tokval;
    toktype = findname(tokval);
    if (toktype == IDENTIFIER) {
      if (finddef(types, ntypes, tokval)) toktype = TYPENAME; else
      if (finddef(enums, nenums, tokval)) toktype = ENUMERATION_CONSTANT;
    }
  } else {
    toktype = c;
    c = getc(fin);
  }
  return(toktype);
}

struct { char name[16];	int val; } names[] =
{		"auto",		Auto,
		"break",	Break,
		"case",		Case,
		"char",		Char,
		"const",	Const,
		"continue",	Continue,
		"default",	Default,
		"do",		Do,
		"double",	Double,
		"else",		Else,
		"enum",		Enum,
		"extern",	Extern,
		"float",	Float,
		"for",		For,
		"goto",		Goto,
		"if",		If,
		"int",		Int,
		"long",		Long,
		"register",	Register,
		"return",	Return,
		"short",	Short,
		"signed",	Signed,
		"sizeof",	Sizeof,
		"static",	Static,
		"struct",	Struct,
		"switch",	Switch,
		"typedef",	Typedef,
		"void",		Void,
		"volatile",	Volatile,
		"union",	Union,
		"unsigned",	Unsigned,
		"while",	While,
		"$eot$",	IDENTIFIER,
};

findname(s)
char *s;
{
  int i, found;

  i = 0;
  found = FALSE;
  while (!found && strcmp(names[i].name, "$eot$"))
    if (!strcmp(names[i].name, s))
      found = TRUE;
    else i++;
  return (names[i].val);
}



