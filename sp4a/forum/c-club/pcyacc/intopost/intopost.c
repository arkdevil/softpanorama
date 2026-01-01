
# line 3 "intopost.y"
#include <stdio.h>
#include <ctype.h>
char outfn[] = "postfix.txt";
FILE *fopen(), *inf, *outf;

# line 9 "intopost.y"
typedef union  {
  char *oprnd;
} YYSTYPE;
#define YYSUNION /* %union occurred */
#define CONSTANT 257
#define VARIABLE 258
YYSTYPE yylval, yyval;
#define YYERRCODE 256

# line 46 "intopost.y"


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
#define YYLAST 219

int yyact[] = {
       7,      10,      10,      11,      11,      12,       4,      20,
       1,      10,      13,      11,       3,       2,       0,       8,
       0,      15,       9,      18,      19,      14,       7,      16,
      17,      13,       4,       0,       2,      11,       3,       0,
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
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       5,       6,
};

int yypact[] = {
     -40,     -40,     -41,     -37,   -1000,   -1000,   -1000,     -40,
     -42,   -1000,     -40,     -40,     -40,     -40,     -34,   -1000,
     -37,     -37,   -1000,   -1000,   -1000,
};

int yypgo[] = {
       0,       8,      13,      12,       6,
};

int yyr1[] = {
       0,       1,       1,       2,       2,       2,       3,       3,
       3,       4,       4,       4,
};

int yyr2[] = {
       2,       2,       3,       1,       3,       3,       1,       3,
       3,       1,       1,       3,
};

int yychk[] = {
   -1000,      -1,      -2,      -3,      -4,     257,     258,      40,
      -2,      59,      43,      45,      42,      47,      -2,      59,
      -3,      -3,      -4,      -4,      41,
};

int yydef[] = {
       0,      -2,       0,       3,       6,       9,      10,       0,
       0,       1,       0,       0,       0,       0,       0,       2,
       4,       5,       7,       8,      11,
};

/*****************************************************************/
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
# line 20 "intopost.y"
      { fprintf(outf, " ;\n"); } break;
      case 2:
# line 22 "intopost.y"
      { fprintf(outf, " ;\n"); } break;
      case 4:
# line 27 "intopost.y"
      { fprintf(outf, " +"); } break;
      case 5:
# line 29 "intopost.y"
      { fprintf(outf, " -"); } break;
      case 7:
# line 34 "intopost.y"
      { fprintf(outf, " *"); } break;
      case 8:
# line 36 "intopost.y"
      { fprintf(outf, " /"); } break;
      case 9:
# line 40 "intopost.y"
      { fprintf(outf, " %s", yypvt[-0].oprnd); } break;
      case 10:
# line 42 "intopost.y"
      { fprintf(outf, " %s", yypvt[-0].oprnd); } break;    }
    goto enstack;
}
