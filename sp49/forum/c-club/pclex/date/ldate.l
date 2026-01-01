
/*
     ABRAXAS SOFTWARE, PCLEX example

     ldate.l - lexical analyzer for date program

     this example program is from July 1978, Bell System Tech. Journal
     "Language develoment tools", pp.2155 by Johnson and Lesk.
     We believe this is an excellent example of the "marriage" 
     between PCYACC and PCLEX.
*/


%{

#include "ydate.h" /* from pcyacc (-D), token types + YYSTYPE */

#define MON(x) { yylval.in = x; return( MONTH ); }

%}

%%

Jan("."|uary)?                  MON(1);
Feb("."|uary)?                  MON(2);
Mar("."|ch)?                    MON(3);
Apr("."|il)?                    MON(4);
May                             MON(5);
Jun("."|e)?                     MON(6);
Jul("."|y)?                     MON(7);
Aug("."|ust)?                   MON(8);
Sep("."|"t"|"t."|tember)?       MON(9);
Oct("."|ober)?                  MON(10);
Nov("."|ember)?                 MON(11);
Dec("."|ember)?                 MON(12);

[0-9]   {
                yylval.in = yytext[0] - '0';

                return( DIGIT );
        }

[ \t]+  {       ;                        /* delete blanks */

        }

"\n"    |

.       {
                return( yytext[0] );    /* return single characters */
        }
%%
