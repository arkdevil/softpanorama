
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include "global.h"
#include "pascal.h"

char tokval[BUFSIZE];

extern FILE *fin;

yylex()
{
  int   i, c1, done;
  int   toktype, intval;
  float realval;

  while (isspace(c)) {
    c = getc(fin);
    if (c == '\n') lineno++;
  }
  if (c == EOF) return(0);
  if (c == '(') {		/* a possible comment */
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
          if (c1 == ')') done = TRUE;
        }
      }
      c = getc(fin);
      return(yylex());
    } else {			/* not a comment */
      toktype = '(';
      c = c1;
    }
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
    toktype = _STRING;
  } else if (c == ':') {		/* an assignment operator */
    c1 = getc(fin);
    if (c1 == '=') {
      toktype = _ASSIGN;
      c = getc(fin);
    } else {
      toktype = ':';
      c = c1;
    }
  } else if (c == '<') {
    c1 = getc(fin);
    if (c1 == '>') {
      toktype = _NE;
      c = getc(fin);
    } else if (c1 == '=') {
      toktype = _LE;
      c = getc(fin);
    } else {
      toktype = '<';
      c = c1;
    }
  } else if (c == '>') {
    c1 = getc(fin);
    if (c1 == '=') {
      toktype = _GE;
      c = getc(fin);
    } else {
      toktype = '>';
      c = c1;
    }
  } else if (c == '.') {
    c1 = getc(fin);
    if (c1 == '.') {
      toktype = _DOTDOT;
      c = getc(fin);
    } else {
      toktype = '.';
      c = c1;
    }
  } else if (isdigit(c)) {
    toktype = _INT;
    intval = 0;
    while (isdigit(c)) {
      intval = intval * 10 + (c - '0');
      c = getc(fin);
    }
    if (c == '.') {
      toktype = _REAL;
      realval = 0.0;
      i = 10.0;
      c = getc(fin);
      while (isdigit(c)) {
        realval = realval + (c - '0') / i;
        i = i * 10;
        c = getc(fin);
      }
    }
    if (toktype == _INT) {
      yylval.i = intval;
    } else {
      yylval.r = realval;
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
  } else {
    toktype = c;
    c = getc(fin);
  }
  return(toktype);
}

struct { char name[10];	int val; } names[] =
{		"and",		_AND,
		"array",	_ARRAY,
		"begin",	_BEGIN,
		"case",		_CASE,
		"const",	_CONST,
		"div",		_DIV,
		"do",		_DO,
		"downto",	_DOWNTO,
		"else",		_ELSE,
		"end",		_END,
		"file",		_FILE,
		"for",		_FOR,
		"forward",	_FORWARD,
		"function",	_FUNCTION,
		"goto",		_GOTO,
		"if",		_IF,
		"in",		_IN,
		"label",	_LABEL,
		"mod",		_MOD,
		"nil",		_NIL,
		"not",		_NOT,
		"of",		_OF,
		"or",		_OR,
		"packed",	_PACKED,
		"procedure",	_PROCEDURE,
		"program",	_PROGRAM,
		"record",	_RECORD,
		"repeat",	_REPEAT,
		"set",		_SET,
		"then",		_THEN,
		"to",		_TO,
		"type",		_TYPE,
		"until",	_UNTIL,
		"var",		_VAR,
		"while",	_WHILE,
		"with",		_WITH,
		"$eot$",	_IDENT,
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