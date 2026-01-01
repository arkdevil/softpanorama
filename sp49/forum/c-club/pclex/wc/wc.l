
/*
        word count, WC - the program. simple standalone PCLEX application.
*/

%{

#include <stdio.h>

int nchar, nword, nline;

%}

%%

\n              ++nchar, ++nline;

[^ \t\n]+       ++nword, nchar += yyleng;

.               ++nchar;

%%

main()
{
        yylex();

        printf( "%d\t%d\t%d\n", nchar, nword, nline );

}
