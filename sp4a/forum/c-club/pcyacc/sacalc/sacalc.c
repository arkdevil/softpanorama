
# line 7 "sacalc.y"

#define YYSTYPE double    /* data type of yacc stack */
#define QUIT    101010
#define NUMBER 257
#define UNARYMINUS 258
#ifndef YYSTYPE
#define YYSTYPE int
#endif
YYSTYPE yylval, yyval;
#define YYERRCODE 256

# line 41 "sacalc.y"

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

FILE *yytfilep;
char *yytfilen;
int yytflag = 0;
int svdprd[2];
char svdnams[2][2];

int *yyxi;
int yyexca[] = {
  -1, 1,
  0, -1,
  -2, 0,
  0,
};

#define YYNPROD 12
#define YYLAST 248

int yyact[] = {
       2,       7,      13,      20,      11,       9,       6,      10,
       8,      12,      11,       1,       0,       0,       0,      12,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       0,       0,       0,       0,       7,       0,
       0,       0,       0,       6,       0,       0,       0,       3,
      11,       9,       0,      10,       0,      12,      14,      15,
       0,      16,      17,      18,      19,       0,       7,       9,
      10,      11,      12,       3,       0,       0,       0,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       5,       0,       0,       0,       0,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       0,       0,       0,       0,       4,       5,
};

int yypact[] = {
   -1000,     -10,   -1000,      -2,      -8,   -1000,     -39,     -39,
   -1000,     -39,     -39,     -39,     -39,   -1000,   -1000,     -38,
     -32,     -32,   -1000,   -1000,   -1000,
};

int yypgo[] = {
       0,      11,      39,
};

int yyr1[] = {
       0,       1,       1,       1,       1,       2,       2,       2,
       2,       2,       2,       2,
};

int yyr2[] = {
       2,       0,       2,       3,       3,       1,       2,       3,
       3,       3,       3,       3,
};

int yychk[] = {
   -1000,      -1,      10,      -2,     256,     257,      45,      40,
      10,      43,      45,      42,      47,      10,      -2,      -2,
      -2,      -2,      -2,      -2,      41,
};

int yydef[] = {
       1,      -2,       2,       0,       0,       5,       0,       0,
       3,       0,       0,       0,       0,       4,       6,       0,
       7,       8,       9,      10,      11,
};

/*****************************************************************/
/*      ABRAXAS SOFTWARE (R) PCYACC (C)COPYRIGHT 1986,1988       */
/* PCYACC LALR parser driver routine -- a table driven procedure */
/* for recognizing sentences of a language defined by the        */
/* grammar that PCYACC analyzes. An LALR parsing table is then   */
/* constructed for the grammar and the skeletal parser uses the  */
/* table when performing syntactical analysis on input source    */
/* programs. The actions associated with grammar rules are       */
/* inserted into a switch statement for execution.               */
/*****************************************************************/


#ifndef YYMAXDEPTH
#define YYMAXDEPTH 200
#endif
#ifndef YYREDMAX
#define YYREDMAX 1000
#endif
#define PCYYFLAG -1000
#define WAS0ERR 0
#define WAS1ERR 1
#define WAS2ERR 2
#define WAS3ERR 3
#define yyclearin pcyytoken = -1
#define yyerrok   pcyyerrfl = 0
YYSTYPE yyv[YYMAXDEPTH];     /* value stack */
int pcyyerrct = 0;           /* error count */
int pcyyerrfl = 0;           /* error flag */
int redseq[YYREDMAX];
int redcnt = 0;
int pcyytoken = -1;          /* input token */


yyparse()
{
  int statestack[YYMAXDEPTH]; /* state stack */
  int      j, m;              /* working index */
  YYSTYPE *yypvt;
  int      tmpstate, tmptoken, *yyps, n;
  YYSTYPE *yypv;


  tmpstate = 0;
  pcyytoken = -1;
#ifdef YYDEBUG
  tmptoken = -1;
#endif
  pcyyerrct = 0;
  pcyyerrfl = 0;
  yyps = &statestack[-1];
  yypv = &yyv[-1];


  enstack:    /* push stack */
#ifdef YYDEBUG
    printf("at state %d, next token %d\n", tmpstate, tmptoken);
#endif
    if (++yyps - &statestack[YYMAXDEPTH] > 0) {
      yyerror("pcyacc internal stack overflow");
      return(1);
    }
    *yyps = tmpstate;
    ++yypv;
    *yypv = yyval;


  newstate:
    n = yypact[tmpstate];
    if (n <= PCYYFLAG) goto defaultact; /*  a simple state */


    if (pcyytoken < 0) if ((pcyytoken=yylex()) < 0) pcyytoken = 0;
    if ((n += pcyytoken) < 0 || n >= YYLAST) goto defaultact;


    if (yychk[n=yyact[n]] == pcyytoken) { /* a shift */
#ifdef YYDEBUG
      tmptoken  = pcyytoken;
#endif
      pcyytoken = -1;
      yyval = yylval;
      tmpstate = n;
      if (pcyyerrfl > 0) --pcyyerrfl;
      goto enstack;
    }


  defaultact:


    if ((n=yydef[tmpstate]) == -2) {
      if (pcyytoken < 0) if ((pcyytoken=yylex())<0) pcyytoken = 0;
      for (yyxi=yyexca; (*yyxi!= (-1)) || (yyxi[1]!=tmpstate); yyxi += 2);
      while (*(yyxi+=2) >= 0) if (*yyxi == pcyytoken) break;
      if ((n=yyxi[1]) < 0) { /* an accept action */
        if (yytflag) {
          int ti; int tj;
          yytfilep = fopen(yytfilen, "w");
          if (yytfilep == NULL) {
            fprintf(stderr, "Can't open t file: %s\n", yytfilen);
            return(0);          }
          for (ti=redcnt-1; ti>=0; ti--) {
            tj = svdprd[redseq[ti]];
            while (strcmp(svdnams[tj], "$EOP"))
              fprintf(yytfilep, "%s ", svdnams[tj++]);
            fprintf(yytfilep, "\n");
          }
          fclose(yytfilep);
        }
        return (0);
      }
    }


    if (n == 0) {        /* error situation */
      switch (pcyyerrfl) {
        case WAS0ERR:          /* an error just occurred */
          yyerror("syntax error");
          yyerrlab:
            ++pcyyerrct;
        case WAS1ERR:
        case WAS2ERR:           /* try again */
          pcyyerrfl = 3;
	   /* find a state for a legal shift action */
          while (yyps >= statestack) {
	     n = yypact[*yyps] + YYERRCODE;
	     if (n >= 0 && n < YYLAST && yychk[yyact[n]] == YYERRCODE) {
	       tmpstate = yyact[n];  /* simulate a shift of "error" */
	       goto enstack;
            }
	     n = yypact[*yyps];


	     /* the current yyps has no shift on "error", pop stack */
#ifdef YYDEBUG
            printf("error: pop state %d, recover state %d\n", *yyps, yyps[-1]);
#endif
	     --yyps;
	     --yypv;
	   }


	   yyabort:
	     return(1);


	 case WAS3ERR:  /* clobber input char */
#ifdef YYDEBUG
          printf("error: discard token %d\n", pcyytoken);
#endif
          if (pcyytoken == 0) goto yyabort; /* quit */
	   pcyytoken = -1;
	   goto newstate;      } /* switch */
    } /* if */


    /* reduction, given a production n */
#ifdef YYDEBUG
    printf("reduce with rule %d\n", n);
#endif
    if (yytflag && redcnt<YYREDMAX) redseq[redcnt++] = n;
    yyps -= yyr2[n];
    yypvt = yypv;
    yypv -= yyr2[n];
    yyval = yypv[1];
    m = n;
    /* find next state from goto table */
    n = yyr1[n];
    j = yypgo[n] + *yyps + 1;
    if (j>=YYLAST || yychk[ tmpstate = yyact[j] ] != -n) tmpstate = yyact[yypgo[n]];
    switch (m) { /* actions associated with grammar rules */
      
      case 1:
# line 17 "sacalc.y"
      { prompt(); } break;
      case 2:
# line 19 "sacalc.y"
      { prompt(); } break;
      case 3:
# line 21 "sacalc.y"
      { if (yypvt[-1] == QUIT) {
                   return(0);
                 } else {
                   fprintf(stdout, "       RESULT ==========> %.8g\n", yypvt[-1]);
                   prompt();
                 }
               } break;
      case 4:
# line 29 "sacalc.y"
      { yyerrok;
                   prompt();
                 } break;
      case 5:
# line 33 "sacalc.y"
      { yyval = yypvt[-0]; } break;
      case 6:
# line 34 "sacalc.y"
      { yyval = -yypvt[-0]; } break;
      case 7:
# line 35 "sacalc.y"
      { yyval = yypvt[-2] + yypvt[-0]; } break;
      case 8:
# line 36 "sacalc.y"
      { yyval = yypvt[-2] - yypvt[-0]; } break;
      case 9:
# line 37 "sacalc.y"
      { yyval = yypvt[-2] * yypvt[-0]; } break;
      case 10:
# line 38 "sacalc.y"
      { yyval = yypvt[-2] / yypvt[-0]; } break;
      case 11:
# line 39 "sacalc.y"
      { yyval = yypvt[-1]; } break;    }
    goto enstack;
}
