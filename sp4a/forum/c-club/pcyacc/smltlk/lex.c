
/*
=====================================================================
  LEX.C: lexical analyzer for SMALLTALK method parser
  Verion 1.0
  By Xing Liu
  Copyright(c) Abraxas Software Inc. (R), 1988, All rights reserved

=====================================================================
*/

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include "global.h"
#include "st.h"

char tokval[BUFSIZE];
int  lexdebug = 0;
extern FILE *fin;

yylex()
{ int t;

  t = yylex1();
  if (lexdebug) printf("tok: %d\n", t);
  return(t);
}

yylex1()
{
  int   i, c1, done;
  int   toktype;
  float realval, numval;

  while (isspace(c)) {
    c = getc(fin);
    if (c == '\n') lineno++;
  }
  if (c == EOF) return(0);
  if (c == '\"') {		/* a comment */
    done = FALSE;
    while (! done) {
      c = getc(fin);
      if (c == EOF) {
        yyerror("EOF inside comments");
        exit(1);
      } else if (c == '\"') {
        c = getc(fin);
        if (c != '\"') done = TRUE;
      }
    }
    return(yylex1());
  } else if (c == '\'') {	/* a string literal */
    i = 0;
    done = FALSE;
    while (! done) {
      c = getc(fin);
      if (c == '\'') {
        c = getc(fin);
        if (c == '\'') {
          tokval[i++] = '\'';
          c = getc(fin);
        } else {
          done = TRUE;
        }
      } else {
        tokval[i++] = c;
      }
    }
    tokval[i++] = '\0';
    yylval.s = tokval;
    toktype = STRING;
  } else if (c == '$') {               /* character literal */
    toktype = CHARACTER;
    yylval.c = getc(fin);
    c = getc(fin);
  } else if (c == '=') {		/* an assignment operator */
      toktype = EQ;
      c = getc(fin);
  } else if (c == '+') {
      toktype = ADD;
      c = getc(fin);
  } else if (c == '-') {
      toktype = '-';
      c = getc(fin);
  } else if (c == '*') {
      toktype = MUL;
      c = getc(fin);
  } else if (c == '/') {
      toktype = SLSH;
      c = getc(fin);
  } else if (c == '<') {
      c1 = getc(fin);
      if (c1 == '-') {
        toktype = LEFTARROW;
        c = getc(fin);
      } else {
        toktype = LT;
        c = c1;
      }
  } else if (c == '>') {
      toktype = GT;
      c = getc(fin);
  } else if (c == '\\') {
      toktype = BSLSH;
      c = getc(fin);
  } else if (c == '~') {
      toktype = TLD;
      c = getc(fin);
  } else if (c == '@') {
      toktype = AT;
      c = getc(fin);
  } else if (c == '%') {
      toktype = MOD;
      c = getc(fin);
  } else if (c == '|') {
      toktype = OR;
      c = getc(fin);
  } else if (c == '&') {
      toktype = AND;
      c = getc(fin);
  } else if (c == '?') {
      toktype = QMK;
      c = getc(fin);
  } else if (c == '!') {
      toktype = NOT;
      c = getc(fin);
  } else if (c == '^') {
      toktype = UPARROW;
      c = getc(fin);
  } else if (isdigit(c)) {
    toktype = NUMBER;
    numval = 0;
    realval = 0.0;
    while (isdigit(c)) {
      numval = numval * 10 + (c - '0');
      c = getc(fin);
    }
    if (c == '.') {
      i = 10.0;
      c = getc(fin);
      while (isdigit(c)) {
        realval = realval + (c - '0') / i;
        i = i * 10;
        c = getc(fin);
      }
    }
    yylval.n = numval + realval;
  } else if (isalpha(c)) {
    i = 0;
    while (isalnum(c)) {
      tokval[i++] = c;
      c = getc(fin);
    }
    tokval[i++] = '\0';
    yylval.s = tokval;
    toktype = IDENTIFIER;
  } else {
    toktype = c;
    c = getc(fin);
  }
  return(toktype);
}
