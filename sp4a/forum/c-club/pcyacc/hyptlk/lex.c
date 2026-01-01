
/*
=====================================================================
  LEX.C: lexical analyzer for HYPERTALK parser
  Verion 1.0
  By Xing Liu
  Copyright(c) Abraxas Software Inc. (R), 1988, All rights reserved

=====================================================================
*/

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include "global.h"
#include "ht.h"

char tokval[BUFSIZE];

extern FILE *fin;

yylex()
{
  int   i, c1, done;
  int   toktype, intval;
  float realval, realflag;

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
        yylval.s = tokval;
      }
    }
    tokval[i++] = '\0';
    toktype = STRING;
  } else if (c == '<') {
    c1 = getc(fin);
    if (c1 == '>') {
      toktype = NE;
      c = getc(fin);
    } else if (c1 == '=') {
      toktype = LE;
      c = getc(fin);
    } else {
      toktype = '<';
      c = c1;
    }
  } else if (c == '>') {
    c1 = getc(fin);
    if (c1 == '=') {
      toktype = GE;
      c = getc(fin);
    } else {
      toktype = '>';
      c = c1;
    }
  } else if (c == '&') {
    c1 = getc(fin);
    if (c1 == '&') {
      toktype = AND2;
      c = getc(fin);
    } else {
      toktype = '&';
      c = c1;
    }
  } else if (isdigit(c)) {
    realflag = FALSE;
    toktype = NUMBER;
    intval = 0;
    while (isdigit(c)) {
      intval = intval * 10 + (c - '0');
      c = getc(fin);
    }
    if (c == '.') {
      realflag = TRUE;
      realval = 0.0;
      i = 10.0;
      c = getc(fin);
      while (isdigit(c)) {
        realval = realval + (c - '0') / i;
        i = i * 10;
        c = getc(fin);
      }
    }
    if (realflag) {
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
  } else {
    toktype = c;
    c = getc(fin);
  }
  return(toktype);
}

struct { char name[16];	int val; } names[] =
{		"ADD",		ADD,
		"add",		ADD,
		"AFTER",	AFTER,
		"after",	AFTER,
		"ALL",		ALL,
		"all",		ALL,
		"AND",		AND,
		"and",		AND,
		"ANSWER",	ANSWER,
		"ASCENDING",	ASCENDING,
		"ASK",		ASK,
		"AT",		AT,
		"BARN",		BARN,
		"BEEP",		BEEP,
		"BEFORE",	BEFORE,
		"BLACK",	BLACK,
		"BLINDS",	BLINDS,
		"BUTTON",	BUTTON,
		"BY",		BY,
		"CARD",		CARD,
		"CARDS",	CARDS,
		"CHAR",		CHAR,
		"CHARACTERS",	CHARACTERS,
		"CHARS",	CHARS,
		"CHECKERBOARD",	CHECKERBOARD,
		"CHOOSE",	CHOOSE,
		"CHUNK",	CHUNK,
		"CLICK",	CLICK,
		"CLOSE",	CLOSE,
		"COMMANDKEY",	COMMANDKEY,
		"CONTAINS",	CONTAINS,
		"CONVERT",	CONVERT,
		"DATEITEMS",	DATEITEMS,
		"DATETIME",	DATETIME,
		"DELETE",	DELETE,
		"DESCENDING",	DESCENDING,
		"DIAL",		DIAL,
		"DISSOLVE",	DISSOLVE,
		"DIV",		DIV,
		"DIVIDE",	DIVIDE,
		"DO",		DO,
		"DOMENU",	DOMENU,
		"DOOR",		DOOR,
		"DOWNTO",	DOWNTO,
		"DRAG",		DRAG,
		"EDIT",		EDIT,
		"EFFECT",	EFFECT,
		"ELSE",		ELSE,
		"END",		END,
		"EXIT",		EXIT,
		"FAST",		FAST,
		"FIELD",	FIELD,
		"FILE",		_FILE,
		"FIND",		FIND,
		"FOR",		FOR,
		"FROM",		FROM,
		"FUNCTION",	FUNCTION,
		"GET",		GET,
		"GLOBAL",	GLOBAL,
		"GO",		GO,
		"GRAY",		GRAY,
		"HELP",		HELP,
		"HIDE",		HIDE,
		"HYPERCARD",	HYPERCARD,
		"IF",		IF,
		"IN",		IN,
		"INTERNATIONAL",INTERNATIONAL,
		"INTO",		INTO,
		"INVERSE",	INVERSE,
		"IRIS",		IRIS,
		"IS",		IS,
		"ISNOTIN",	ISNOTIN,
		"LINE",		LINE,
		"MOD",		MOD,
		"MODEM",	MODEM,
		"MULTIPLY",	MULTIPLY,
		"NEXT",		NEXT,
		"NOT",		NOT,
		"NUMBER",	NUMBER,
		"NUMERIC",	NUMERIC,
		"OF",		OF,
		"ON",		ON,
		"OPEN",		OPEN,
		"OPTIONKEY",	OPTIONKEY,
		"OR",		OR,
		"PAINT",	PAINT,
		"PASS",		PASS,
		"PASSWORD",	PASSWORD,
		"PLAIN",	PLAIN,
		"PLAY",		PLAY,
		"POINT",	POINT,
		"POP",		POP,
		"PRINT",	PRINT,
		"PRINTING",	PRINTING,
		"PUSH",		PUSH,
		"PUT",		PUT,
		"READ",		READ,
		"REPEAT",	REPEAT,
		"RESET",	RESET,
		"RETURN",	RETURN,
		"SCRIPT",	SCRIPT,
		"SCROLL",	SCROLL,
		"SECONDS",	SECONDS,
		"SEND",		SEND,
		"SET",		SET,
		"SHIFTKEY",	SHIFTKEY,
		"SHOW",		SHOW,
		"SLOW",		SLOW,
		"SLOWLY",	SLOWLY,
		"SORT",		SORT,
		"STACK",	STACK,
		"STOP",		STOP,
		"STRING",	STRING,
		"SUBTRACT",	SUBTRACT,
		"TEXT",		TEXT,
		"THEN",		THEN,
		"TIMES",	TIMES,
		"TO",		TO,
		"TOOL",		TOOL,
		"TYPE",		TYPE,
		"UNTIL",	UNTIL,
		"VENETIAN",	VENETIAN,
		"VERY",		VERY,
		"VISUAL",	VISUAL,
		"WAIT",		WAIT,
		"WHILE",	WHILE,
		"WHITE",	WHITE,
		"WIPE",		WIPE,
		"WITH",		WITH,
		"WORD",		WORD,
		"WRITE",	WRITE,
		"ZOOM",		ZOOM,
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