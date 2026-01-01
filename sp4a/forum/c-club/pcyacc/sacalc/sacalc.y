
/*
 * SACALC EXAMPLE
 */

%{

#define YYSTYPE double    /* data type of yacc stack */
#define QUIT    101010
%}
%token NUMBER
%left '+' '-'   /* left associative, same precedence */
%left '*' '/'   /* left associative, higher precedence */
%left UNARYMINUS  
%%
list:    /* nothing */
         { prompt(); }
       | list '\n'
         { prompt(); }
       | list expr '\n'
         { if ($2 == QUIT) {
             return(0);
           } else {
             fprintf(stdout, "       RESULT ==========> %.8g\n", $2);
             prompt();
           }
         }
       | list error '\n'
           { yyerrok;
             prompt();
           }
       ;
expr:    NUMBER              { $$ = $1; }
       | '-' expr %prec UNARYMINUS { $$ = -$2; }
       | expr '+' expr       { $$ = $1 + $3; }
       | expr '-' expr       { $$ = $1 - $3; }
       | expr '*' expr       { $$ = $1 * $3; }
       | expr '/' expr       { $$ = $1 / $3; }
       | '(' expr ')'        { $$ = $2; }
       ;
%%
#include <stdio.h>
#include <ctype.h>
char *progname;       /* for error messages */
int  lineno = 1;

main(argc, argv)
char *argv[];
{
     if (argc > 1) fprintf(stderr, "nonmeaningful arguments\n");
     progname = argv[0];
     fprintf(stdout, "\n****************************************************\n");
     fprintf(stdout, "*      SACALC: a Simple Arithmetic Calculator      *\n");
     fprintf(stdout, "*                                                  *\n");
     fprintf(stdout, "*      1)at the prompt READY>                      *\n");
     fprintf(stdout, "*        you type in an expression, e.g. 1+2*3<CR> *\n");
     fprintf(stdout, "*        SACALC will evaluate the expression       *\n");
     fprintf(stdout, "*        and the result is displayed               *\n");
     fprintf(stdout, "*      2)to terminate the program                  *\n");
     fprintf(stdout, "*        type QUIT                                 *\n");
     fprintf(stdout, "*      3)if you make a mistake                     *\n");
     fprintf(stdout, "*        SACALC will complain and start over again *\n");
     fprintf(stdout, "*                                                  *\n");
     fprintf(stdout, "****************************************************\n\n\n");
     yyparse();
     fprintf(stdout, "\n****************************************************\n");
     fprintf(stdout, "*       SACALC: a Simple Arithmetic Calculator     *\n");
     fprintf(stdout, "*                                                  *\n");
     fprintf(stdout, "*       normal termination -- bye!                 *\n");
     fprintf(stdout, "****************************************************\n");
}

yylex()
{
     int c;

     while ((c=getchar()) == ' ' || c == '\t' )
          ;
     if (c == EOF)
         return 0;
     if (c == '.' || isdigit(c)) {          /* number */
         ungetc(c, stdin);
         scanf("%lf", &yylval);
         return NUMBER;
     }
     if (c == '\n')
         lineno++;
     if (c == 'Q' || c == 'q')              /* ugly code */
         if ((c=getchar()) == 'U' || c == 'u')
             if ((c=getchar()) == 'I' || c == 'i')
                 if ((c=getchar()) == 'T' || c == 't') {
                     yylval = QUIT;
                     return NUMBER;
                 }
                 else return '?';
     return c;
}

yyerror(s)             /* called for yacc syntax error */
char *s;
{
     warning (s, (char *) 0);
}

warning(s,t)            /* print warning message */
char *s, *t;
{
    fprintf(stderr, "%s: %s", progname, s);
    if (t)
        fprintf(stderr, " %s", t);
    fprintf(stderr, " near line %d\n", lineno);
}

prompt()
{

  fprintf(stdout, "READY> ");
}

