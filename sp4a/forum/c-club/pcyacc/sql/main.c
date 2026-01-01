
/*
=====================================================================
  MAIN.C: main routine for SQL parser
  Verion 1.0
  By Xing Liu
  Copyright(c) Abraxas Software Inc. (R), 1988, All rights reserved

=====================================================================
*/


#include <stdio.h>

FILE *fopen(), *fin;
int  c, lineno;

int lexdebug = 0;

main(argc, argv)
int   argc;
char *argv[];
{
  int ttype;

  if (argc < 2) {
    yyerror("Usage: sql <program>");
    exit(1);
  }
  
  fin = fopen(argv[1], "r");
  if (fin == NULL) {
    yyerror("Can't open source program file");
    exit(1);
  }

  c = getc(fin);

  if (yyparse()) {
    yyerror("Error(s) in parsing");
    exit(1);
  } else {
    fprintf(stdout, "No error was found\n");
  }

  fclose(fin);
}

yyerror(s)
{
  fprintf(stderr, "%s\n", s);
}



    

