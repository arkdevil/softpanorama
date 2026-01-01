
/*
     ABRAXAS SOFTWARE, PCLEX example

     ydate.y - pcyacc grammar for date program

     this example program is from July 1978, Bell System Tech. Journal
     "Language develoment tools", pp.2155 by Johnson and Lesk.
     We believe this is an excellent example of the "marriage" 
     between yacc and lex.
*/


%{

/* #define YYDEBUG */

%}

%union {        /* define YYSTYPE */
  int   in;
  char *ch;
}

%token DIGIT MONTH      /* define token types */

%%

input   :       /* empty file is legal */

        |       input '\n'

        |       input date '\n'

        |       input error '\n'                { yyerrok; /* line error */ }

        ;

date    :       MONTH day ',' year             { showday( $1, $2, $4 ); }

        |       day MONTH year                  { showday( $2, $1, $3 ); }

        |       number '/' number '/' number    { showday( $1, $3, $5 ); }

        ;

day     :       number
        
        ;

year    :       number

        ;

number  :       DIGIT                           { $$ = $1; }

        |       number DIGIT                    { $$ = 10 * $1 + $2; }

        ;
%%


yyerror(s)             /* called for pcyacc syntax error */
char *s;
{
     printf( "YYERROR:%s\n", s );
}

