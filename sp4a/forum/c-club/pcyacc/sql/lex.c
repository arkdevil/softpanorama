
/*
=====================================================================
  LEX.C: lexical analyzer for SQL parser
  Verion 1.0
  By Xing Liu
  Copyright(c) Abraxas Software Inc. (R), 1988, All rights reserved

=====================================================================
*/

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include "global.h"
#include "sql.h"

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
        yylval.s = tokval;
      }
    }
    tokval[i++] = '\0';
    toktype = STRING_CONST;
  } else if (c == '=') {		/* an assignment operator */
      toktype = EQ;
      c = getc(fin);
  } else if (c == '+') {
      toktype = ADD;
      c = getc(fin);
  } else if (c == '-') {
      toktype = SUB;
      c = getc(fin);
  } else if (c == '*') {
      toktype = MUL;
      c = getc(fin);
  } else if (c == '/') {
      toktype = DIV;
      c = getc(fin);
  } else if (c == '<') {
    c1 = getc(fin);
    if (c1 == '>') {
      toktype = NE;
      c = getc(fin);
    } else if (c1 == '=') {
      toktype = LE;
      c = getc(fin);
    } else {
      toktype = LT;
      c = c1;
    }
  } else if (c == '>') {
    c1 = getc(fin);
    if (c1 == '=') {
      toktype = GE;
      c = getc(fin);
    } else {
      toktype = GT;
      c = c1;
    }
  } else if (isdigit(c)) {
    toktype = INTEGER_CONST;
    intval = 0;
    while (isdigit(c)) {
      intval = intval * 10 + (c - '0');
      c = getc(fin);
    }
    if (c == '.') {
      toktype = REAL_CONST;
      realval = 0.0;
      i = 10.0;
      c = getc(fin);
      while (isdigit(c)) {
        realval = realval + (c - '0') / i;
        i = i * 10;
        c = getc(fin);
      }
    }
    if (toktype == INTEGER_CONST) {
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
{		"ALL",		ALL,
		"all",		ALL,
		"AND",		AND,
		"and",		AND,
		"ANY",		ANY,
		"any",		ANY,
		"AS",		AS,
		"as",		AS,
		"ASC",		ASC,
		"asc",		ASC,
		"AUTHORIZATION",AUTHORIZATION,
		"authorization",AUTHORIZATION,
		"BETWEEN",	BETWEEN,
		"between",	BETWEEN,
		"BY",		BY,
		"by",		BY,
		"CHAR",		CHAR,
		"char",		CHAR,
		"CHECK",	CHECK,
		"check",	CHECK,
		"CLOSE",	CLOSE,
		"close",	CLOSE,
		"COMMIT",	COMMIT,
		"commit",	COMMIT,
		"COBOL",	COBOL,
		"cobol",	COBOL,
		"CREATE",	CREATE,
		"create",	CREATE,
		"CURRENT",	CURRENT,
		"CURSOR",	CURSOR,
		"cursor",	CURSOR,
		"DECIMAL",	DECIMAL,
		"decimal",	DECIMAL,
		"DECLARE",	DECLARE,
		"declare",	DECLARE,
		"DELETE",	DELETE,
		"delete",	DELETE,
		"DESC",		DESC,
		"desc",		DESC,
		"DISTINCT",	DISTINCT,
		"distinct",	DISTINCT,
		"ESCAPE",	ESCAPE,
		"escape",	ESCAPE,
		"EXISTS",	EXISTS,
		"exists",	EXISTS,
		"FETCH",	FETCH,
		"fetch",	FETCH,
		"FOR",		FOR,
		"for",		FOR,
		"FORTRAN",	FORTRAN,
		"fortran",	FORTRAN,
		"FROM",		FROM,
		"from",		FROM,
		"GRANT",	GRANT,
		"grant",	GRANT,
		"GROUP",	GROUP,
		"group",	GROUP,
		"HAVING",	HAVING,
		"having",	HAVING,
		"IN",		IN,
		"in",		IN,
		"INDICATOR",	INDICATOR,
		"indicator",	INDICATOR,
		"INSERT",	INSERT,
		"insert",	INSERT,
		"INTO",		INTO,
		"into",		INTO,
		"IS",		IS,
		"is",		IS,
		"LANGUAGE",	LANGUAGE,
		"language",	LANGUAGE,
		"LIKE",		LIKE,
		"like",		LIKE,
		"MODULE",	MODULE,
		"module",	MODULE,
		"NOT",		NOT,
		"not",		NOT,
		"NULL",		_NULL,
		"null",		_NULL,
		"OF",		OF,
		"of",		OF,
		"ON",		ON,
		"on",		ON,
		"OPEN",		OPEN,
		"open",		OPEN,
		"OPTION",	OPTION,
		"option",	OPTION,
		"OR",		OR,
		"or",		OR,
		"ORDER",	ORDER,
		"order",	ORDER,
		"PASCAL",	PASCAL,
		"pascal",	PASCAL,
		"PL1",		PL1,
		"pl1",		PL1,
		"PRIVILEGES",	PRIVILEGES,
		"privileges",	PRIVILEGES,
		"PROCEDURE",	PROCEDURE,
		"procedure",	PROCEDURE,
		"PUBLIC",	PUBLIC,
		"public",	PUBLIC,
		"ROLLBACK",	ROLLBACK,
		"rollback",	ROLLBACK,
		"SCHEMA",	SCHEMA,
		"schema",	SCHEMA,
		"SELECT",	SELECT,
		"select",	SELECT,
		"SET",		SET,
		"set",		SET,
		"SOME",		SOME,
		"some",		SOME,
		"SQLCODE",	SQLCODE,
		"sqlcode",	SQLCODE,
		"TABLE",	TABLE,
		"table",	TABLE,
		"TO",		TO,
		"to",		TO,
		"VALUES",	VALUES,
		"values",	VALUES,
		"VIEW",		VIEW,
		"view",		VIEW,
		"UNION",	UNION,
		"union",	UNION,
		"UNIQUE",	UNIQUE,
		"unique",	UNIQUE,
		"UPDATE",	UPDATE,
		"update",	UPDATE,
		"USER",		USER,
		"user",		USER,
		"WHERE",	WHERE,
		"where",	WHERE,
		"WITH",		WITH,
		"with",		WITH,
		"WORK",		WORK,
		"work",		WORK,
		"AVG",		AVG,
		"avg",		AVG,
		"MAX",		MAX,
		"max",		MAX,
		"MIN",		MIN,
		"min",		MIN,
		"SUM",		SUM,
		"sum",		SUM,
		"COUNT",	COUNT,
		"count",	COUNT,
		"INTEGER",	INTEGER,
		"integer",	INTEGER,
		"REAL",		REAL,
		"real",		REAL,
		"STRING",	STRING,
		"string",	STRING,
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