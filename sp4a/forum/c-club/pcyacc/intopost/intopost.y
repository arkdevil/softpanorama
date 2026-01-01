
%{
#include <stdio.h>
#include <ctype.h>
char outfn[] = "postfix.txt";
FILE *fopen(), *inf, *outf;
%}

%union {
  char *oprnd;
}
%token CONSTANT
%token VARIABLE
%type  <oprnd> CONSTANT VARIABLE
%start infix_prog

%%

infix_prog : infix_expr ';'
             { fprintf(outf, " ;\n"); }
           | infix_prog infix_expr ';'
             { fprintf(outf, " ;\n"); }
           ;

infix_expr : infix_term
           | infix_expr '+' infix_term
             { fprintf(outf, " +"); }
           | infix_expr '-' infix_term
             { fprintf(outf, " -"); }
           ;

infix_term : infix_fact
           | infix_term '*' infix_fact
             { fprintf(outf, " *"); }
           | infix_term '/' infix_fact
             { fprintf(outf, " /"); }
           ;

infix_fact : CONSTANT
             { fprintf(outf, " %s", $1); }
           | VARIABLE
             { fprintf(outf, " %s", $1); }
           | '(' infix_expr ')'
           ;

%%

int nxtch;

main(argc, argv)
int argc;
char *argv[];
{

  fprintf(stdout, "\n*********************************************************\n");
  fprintf(stdout,   "*   INTOPOST: INfix TO POSTfix expression translator    *\n");
  fprintf(stdout,   "*                                                       *\n");
  fprintf(stdout,   "*     Usage: intopost <infixfile>                       *\n");
  fprintf(stdout,   "*     1) prepare a infix source file                    *\n");
  fprintf(stdout,   "*        e.g. egfile                                    *\n");
  fprintf(stdout,   "*        1+2*3;                                         *\n");
  fprintf(stdout,   "*        9+8*7-6/5;                                     *\n");
  fprintf(stdout,   "*        a+b*100;                                       *\n");
  fprintf(stdout,   "*        use semicolon ; to terminate an expression     *\n");
  fprintf(stdout,   "*     2) invoke intopost                                *\n");
  fprintf(stdout,   "*        intopost egfile                                *\n");
  fprintf(stdout,   "*     3) the result of translation is saved in          *\n");
  fprintf(stdout,   "*        the file postfix.txt                           *\n");
  fprintf(stdout,   "*                                                       *\n");
  fprintf(stdout,   "*********************************************************\n\n\n");
  if (argc != 2) {
    fprintf(stderr, "not enough arguments, abort \n");
    exit(1);
  }
  if ((inf=fopen(argv[1], "r")) == NULL) {
    fprintf(stderr, "Can't open file: \"%s\"\n", argv[1]);
    exit(1);
  }
  if ((outf=fopen(outfn, "w")) == NULL) {
    fprintf(stderr, "Can't open file: \"%s\"\n", outfn);
    exit(1);
  }

  fprintf(stdout, "translation in progress ... \n");

  nxtch = getc(inf);
  if (yyparse()) {
      fprintf(stdout, "\n*********************************************************\n");
      fprintf(stdout,   "*   INTOPOST: INfix TO POSTfix expression translator    *\n");
      fprintf(stdout,   "*                                                       *\n");
      fprintf(stdout,   "*     abnormal termination                              *\n");
      fprintf(stdout,   "*     error in translation                              *\n");
      fprintf(stdout,   "*     bye!                                              *\n");
      fprintf(stdout,   "*                                                       *\n");
      fprintf(stdout,   "*********************************************************\n");
      exit(1);
  }
  
  fprintf(stdout, "\n*********************************************************\n");
  fprintf(stdout,   "*   INTOPOST: INfix TO POSTfix expression translator    *\n");
  fprintf(stdout,   "*                                                       *\n");
  fprintf(stdout,   "*     normal termination                                *\n");
  fprintf(stdout,   "*     see file postfix.txt for result                   *\n");
  fprintf(stdout,   "*     bye!                                              *\n");
  fprintf(stdout,   "*                                                       *\n");
  fprintf(stdout,   "*********************************************************\n");
  fclose(inf);
  fclose(outf);
}

yyerror(s)
char *s;
{
  fprintf(stderr, "%s\n", s);
}

#define POOLSZ 2048
char chpool[POOLSZ];
int  avail = 0;

yylex() {
int i, j, toktyp;

  while ((nxtch==' ') || (nxtch=='\t') || (nxtch=='\n')) nxtch = getc(inf);
  if (nxtch == EOF) return(0);
  if (isdigit(nxtch)) {
    toktyp = CONSTANT;
    yylval.oprnd = chpool + avail;
    chpool[avail++] = nxtch;
    while (isdigit(nxtch=getc(inf))) chpool[avail++] = nxtch;
    chpool[avail++] = '\0';
  } else if (isalpha(nxtch)) {
    toktyp = VARIABLE;
    yylval.oprnd = chpool + avail;
    chpool[avail++] = nxtch;
    while (isalnum(nxtch=getc(inf))) chpool[avail++] = nxtch;
    chpool[avail++] = '\0';
  } else {
    toktyp = nxtch;
    nxtch = getc(inf);
  }
  return(toktyp);
}



  
