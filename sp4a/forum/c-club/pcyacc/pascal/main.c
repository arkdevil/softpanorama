
#include <stdio.h>
#include "pascal.h"

FILE *fopen(), *fin;
int  c, lineno;

int lexdebug = 0;

main(argc, argv)
int   argc;
char *argv[];
{
  int ttype;

  if (argc < 2) {
    yyerror("Usage: pascal <program>");
    exit(1);
  }
  
  fin = fopen(argv[1], "r");
  if (fin == NULL) {
    yyerror("Can't open source program file");
    exit(1);
  }

  c = getc(fin);

  if (lexdebug) {
    ttype = yylex();
    while (ttype != 0) {
      switch(ttype) {
        case _STRING: fprintf(stdout, "string: %s\n", yylval.s);
        break;
        case _ASSIGN: fprintf(stdout, "assign: %s\n", ":=");
        break;
        case _NE:     fprintf(stdout, "notequ: %s\n", "<>");
        break;
        case _LE:     fprintf(stdout, "lessth: %s\n",  "<=");
        break;
        case _GE:     fprintf(stdout, "geq: %s\n", ">=");
        break;
        case _DOTDOT: fprintf(stdout, "dots: %s\n", "..");
        break;
        case _INT:    fprintf(stdout, "int: %d\n", yylval.i);
        break;
        case _REAL:   fprintf(stdout, "real: %f\n", yylval.r);
        break;
        case _AND:    fprintf(stdout, "key: AND\n");
        break;
        case _ARRAY:  fprintf(stdout, "key: ARRAY\n");
        break;
        case _BEGIN:  fprintf(stdout, "key: BEGIN\n");
        break;
        case _CASE:   fprintf(stdout, "key: CASE\n");
        break;
        case _CONST:  fprintf(stdout, "key: CONST\n");
        break;
        case _DIV:    fprintf(stdout, "key: DIV\n");
        break;
        case _DO:     fprintf(stdout, "key: DO\n");
        break;	 
        case _DOWNTO: fprintf(stdout, "key: DOWNTO\n");
        break;
        case _ELSE:   fprintf(stdout, "key: ELSE\n");
        break;
        case _END:    fprintf(stdout, "key: END\n");
        break;
        case _FILE:   fprintf(stdout, "key: FILE\n");
        break;
        case _FOR:    fprintf(stdout, "key: FOR\n");
        break;
        case _FORWARD:  fprintf(stdout, "key: FORWARD\n");
        break;
        case _FUNCTION: fprintf(stdout, "key: FUNCTION\n");
        break;
        case _GOTO:     fprintf(stdout, "key: GOTO\n");
        break;
        case _IF:       fprintf(stdout, "key: IF\n");
        break;
        case _IN:       fprintf(stdout, "key: IN\n");
        break;
        case _LABEL:    fprintf(stdout, "key: LABEL\n");
        break;
        case _MOD:      fprintf(stdout, "key: MOD\n");
        break;
        case _NIL:      fprintf(stdout, "key: NIL\n");
        break;
        case _NOT:      fprintf(stdout, "key: NOT\n");
        break;
        case _OF:       fprintf(stdout, "key: OF\n");
        break;
        case _OR:       fprintf(stdout, "key: OR\n");
        break;
        case _PACKED:   fprintf(stdout, "key: PACKED\n");
        break;
        case _PROCEDURE:fprintf(stdout, "key: PROCEDURE\n");
        break;
        case _PROGRAM:  fprintf(stdout, "key: PROGRAM\n");
        break;
        case _RECORD:   fprintf(stdout, "key: RECORD\n");
        break;
        case _REPEAT:   fprintf(stdout, "key: REPEAT\n");
        break;
        case _SET:      fprintf(stdout, "key: SET\n");
        break;
        case _THEN:     fprintf(stdout, "key: THEN\n");
        break;
        case _TO:       fprintf(stdout, "key: TO\n");
        break;
        case _TYPE:     fprintf(stdout, "key: TYPE\n");
        break;
        case _UNTIL:    fprintf(stdout, "key: UNTIL\n");
        break;
        case _VAR:      fprintf(stdout, "key: VAR\n");
        break;
        case _WHILE:    fprintf(stdout, "key: WHILE\n");
        break;
        case _WITH:     fprintf(stdout, "key: WITH\n");
        break;
        case _IDENT:    fprintf(stdout, "identifier: %s\n", yylval.s);
        break;
        default:        fprintf(stdout, "single char: %c\n", ttype);
      }
      ttype = yylex();
    }
  }

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