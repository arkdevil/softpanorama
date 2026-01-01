
/*
=====================================================================
  LEX.C: lexical analyzer for POSTSCRIPT parser
  Verion 1.0
  By Xing Liu
  Copyright(c) Abraxas Software Inc. (R), 1988, All rights reserved

=====================================================================
*/

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include "global.h"
#include "pscript.h"

char tokval[BUFSIZE];

extern FILE *fin;

int lexdebug = 0;

char names[][20] = {
  "pop",
  "exch",
  "dup",
  "copy",
  "index",
  "roll",
  "clear",
  "count",
  "mark",
  "cleartomark",
  "counttomark",
  "add",
  "div",
  "idiv",
  "mod",
  "mul",
  "sub",
  "abs",
  "neg",
  "ceiling",
  "floor",
  "round",
  "truncate",
  "sqrt",
  "atan",
  "cos",
  "sin",
  "exp",
  "ln",
  "log",
  "rand",
  "srand",
  "rrand",
  "array",
  "length",
  "get",
  "put",
  "getinterval",
  "putinterval",
  "aload",
  "astore",
  "forall",
  "dict",
  "maxlength",
  "begin",
  "end",
  "def",
  "load",
  "store",
  "known",
  "where",
  "errordict",
  "systemdict",
  "userdict",
  "currentdict",
  "countdictstack",
  "dictstack",
  "string",
  "anchorsearch",
  "search",
  "token",
  "eq",
  "ne",
  "ge",
  "gt",
  "le",
  "lt",
  "and",
  "not",
  "or",
  "xor",
  "true",
  "false",
  "bitshift",
  "exec",
  "if",
  "ifelse",
  "for",
  "repeat",
  "loop",
  "exit",
  "stop",
  "stopped",
  "countexecstack",
  "execstack",
  "quit",
  "start",
  "type",
  "cvlit",
  "cvx",
  "xcheck",
  "executeonly",
  "noaccess",
  "readonly",
  "rcheck",
  "wcheck",
  "cvi",
  "cvn",
  "cvr",
  "cvrs",
  "cvs",
  "file",
  "closefile",
  "read",
  "write",
  "readhexstring",
  "writehexstring",
  "readstring",
  "writestring",
  "readline",
  "bytesavailable",
  "flush",
  "resetfile",
  "status",
  "run",
  "currentfile",
  "print",
  "=",
  "stack",
  "==",
  "pstack",
  "prompt",
  "echo",
  "save",
  "restore",
  "vmstatus",
  "bind",
  "null",
  "usertime",
  "version",
  "gsave",
  "grestore",
  "grestoreall",
  "initgraphics",
  "setlinewidth",
  "currentlinewidth",
  "setlinecap",
  "currentlinecap",
  "setlinejoin",
  "currentlinejoin",
  "setmiterlimit",
  "currentmiterlimit",
  "setdash",
  "currentdash",
  "setflat",
  "currentflat",
  "setgray",
  "currentgray",
  "sethscolor",
  "currenthscolor",
  "setrgbcolor",
  "currentrgbcolor",
  "setscreen",
  "currentscreen",
  "settransfer",
  "currenttransfer",
  "matrix",
  "initmatrix",
  "identmatrix",
  "defaultmatrix",
  "currentmatrix",
  "setmatrix",
  "translate",
  "scale",
  "rotate",
  "concat",
  "concatmatrix",
  "transform",
  "dtransform",
  "itransform",
  "idtransform",
  "invertmatrix",
  "newpath",
  "currentpoint",
  "moveto",
  "rmoveto",
  "lineto",
  "rlineto",
  "arc",
  "arcn",
  "arcto",
  "curveto",
  "rcurveto",
  "closepath",
  "flattenpath",
  "reversepath",
  "strokepath",
  "charpath",
  "clippath",
  "pathbox",
  "pathforall",
  "initclip",
  "clip",
  "eoclip",
  "erasepage",
  "fill",
  "eofill",
  "stroke",
  "image",
  "showpage",
  "copypage",
  "banddevice",
  "framedevice",
  "nulldevice",
  "renderbands",
  "definefont",
  "findfont",
  "scalefont",
  "makefont",
  "setfont",
  "currentfont",
  "show",
  "ashow",
  "widthshow",
  "awidthshow",
  "kshow",
  "stringwidth",
  "FontDirectory",
  "StandardEncoding",
  "cachestatus",
  "setcachedevice",
  "setcharwidth",
  "setcachelimit",
  "dictfull",
  "dictstackoverflow",
  "dictstackunderflow",
  "execstackoverflow",
  "handleerror",
  "interrupt",
  "invalidaccess",
  "invalidexit",
  "invalidfont",
  "invalidrestore",
  "ioerror",
  "limitcheck",
  "nocurrentpoint",
  "rangecheck",
  "stackoverflow",
  "stackunderflow",
  "syntaxerror",
  "timeout",
  "typecheck",
  "undefined",
  "undefinedfilename",
  "undefinedresult",
  "unmatchedmark",
  "unregistered",
  "VMerrir",
  "$eot$",
};

findname(s)
char *s;
{
  int i;

  i = 0;
  while (strcmp(names[i], "$eot$")) {
    if (!strcmp(names[i], s)) return (OPERATOR);
    i++;
  }
  return (IDENTIFIER);
}

delimiter(c)
int c;
{
  return (isspace(c) ||
            c == '/' ||
            c == '{' ||
            c == '}' ||
            c == '[' ||
            c == ']' ||
            c == '(' ||
            c == ')' ||
            c == '<' ||
            c == '>' ||
            c == '+' ||
            c == '-');
}
 
hexchar(c, c1)
int c;
int c1;
{
  int hexval, higit;

  if (isdigit(c)) higit = c - '0'; else
  if ('a' <= c && c <= 'f') higit = 10 + c - 'a'; else
  if ('A' <= c && c <= 'F') higit = 10 + c - 'A'; else
    return (-1);
  hexval = higit * 16;
  if (isdigit(c1)) higit = c1 - '0'; else
  if ('a' <= c1 && c1 <= 'f') higit = 10 + c1 - 'a'; else
  if ('A' <= c1 && c1 <= 'F') higit = 10 + c1 - 'A'; else
    return (-1);
  hexval += higit;
  return (higit);
}

yylex()
{
  int   i, c1, done;
  int   toktype, intval, charval, realflag, sign;
  float realval;

  while (isspace(c)) {
    c = getc(fin);
    if (c == '\n') lineno++;
  }
  if (c == EOF) return(0);
  if (c == '%') {		/* a comment until end of line */
    c = getc(fin);
    while (c != EOF && c != '\n') c = getc(fin);
    if (c == EOF) {
      yyerror("EOF inside comments");
      exit(1);
    }
    yylval.i = 0;
    toktype = (COMMENT);
  } else if (c == '(') {	/* a string literal, escape sequences to be added */
    i = 0;
    c = getc(fin);
    while (c != EOF && c != ')') {
      if (c != '\\') {
        tokval[i++] = c;
        c = getc(fin);
      }
    }
    if (c == EOF) {
      yyerror("EOF inside string literal");
      exit(1);
    }
    tokval[i++] = '\0';
    yylval.s = tokval;
    toktype = STRING;
    c = getc(fin);
  } else if (c == '<') {       /* a hex string literal */
    i = 0;
    c = getc(fin);
    while (c != EOF && c != '>') {
      c1 = getc(fin);
      charval = hexchar(c, c1);
      if (charval < 0) {
        yyerror("illegal hex value inside string literal");
        exit(1);
      }
      tokval[i++] = charval;
      c = getc(fin);
    }
    if (c == EOF) {
      yyerror("EOF inside string literal");
      exit(1);
    }
    tokval[i++] = '\0';
    yylval.s = tokval;
    toktype = STRING;
    c = getc(fin);
  } else if (isdigit(c) || c == '+' || c == '-') {  /* bases, exponents to be added */
    if (isdigit(c)) {
      sign = 1;
    } else {
      if (c == '+') sign = 1; else sign = -1;
      c = getc(fin);
    }
    toktype = INTEGER;
    intval = 0;
    while (isdigit(c)) {
      intval = intval * 10 + (c - '0');
      c = getc(fin);
    }
    if (c == '.') {
      toktype = FLOAT;
      realval = 0.0;
      i = 10.0;
      c = getc(fin);
      while (isdigit(c)) {
        realval = realval + (c - '0') / i;
        i = i * 10;
        c = getc(fin);
      }
    }
    if (toktype == INTEGER) {
      yylval.i = sign * intval;
    } else {
      yylval.r = sign * (realval + intval);
    }
  } else if (c == '/' || c == '{' || c == '}' || c == '[' || c == ']') {
    toktype = c;
    c = getc(fin);
  } else {                               /* a name */
    i = 0;
    while (! delimiter(c)) {
      tokval[i++] = c;
      c = getc(fin);
    }
    tokval[i++] = '\0';
    yylval.s = tokval;
    toktype = findname(tokval);
  }
  if (lexdebug) printf("token type: %d\n", toktype);
  return(toktype);
}

