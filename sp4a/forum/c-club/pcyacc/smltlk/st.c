
# line 12 "st.y"
typedef union  {
  float n;
  char  c;
  char *s;
} YYSTYPE;
#define YYSUNION /* %union occurred */
#define CHARACTER 257
#define IDENTIFIER 258
#define LEFTARROW 259
#define NUMBER 260
#define STRING 261
#define UPARROW 262
#define ADD 263
#define SLSH 264
#define BSLSH 265
#define MUL 266
#define TLD 267
#define LT 268
#define GT 269
#define EQ 270
#define AT 271
#define MOD 272
#define OR 273
#define AND 274
#define QMK 275
#define NOT 276
#define KWMSG 277
#define BIMSG 278
#define UNMSG 279
#define ONESP 280
#define TWOSP 281
#ifndef YYSTYPE
#define YYSTYPE int
#endif
YYSTYPE yylval, yyval;
#define YYERRCODE 256

#include <stdio.h>
FILE *yytfilep;
char *yytfilen;
int yytflag = 0;
int svdprd[2];
char svdnams[2][2];

int yyexca[] = {
  -1, 1,
  0, -1,
  -2, 0,
  0,
};

#define YYNPROD 76
#define YYLAST 390

int yyact[] = {
      73,      99,       7,      56,      98,       7,      96,      88,
      53,      29,      75,      28,      87,       5,      54,       6,
      90,      27,       3,      67,      73,      24,       2,      54,
      32,       7,      84,       8,      41,      37,      89,      49,
      48,      66,      65,      52,      30,      40,      38,      73,
      43,      42,      39,       3,       7,      25,      31,      33,
      23,       1,       0,       0,      58,       0,      59,      62,
      94,      63,       8,       0,       0,      97,      95,       7,
       0,      71,       0,      72,       0,       0,       0,       0,
      89,       0,       0,      89,      51,      60,      86,      51,
      35,       0,       7,      81,       0,       5,      77,      71,
       6,      72,      85,      82,      83,      58,      58,      59,
      59,      79,      80,       0,      24,       7,      76,      71,
       2,      72,     100,      37,      69,       0,      32,      63,
      41,       0,      68,      55,       0,      90,      59,      38,
       7,       0,       0,       0,      33,      64,      94,       0,
       0,       0,       0,      95,       0,       0,       0,       0,
      44,       0,       0,       7,       0,       0,       0,       0,
       0,      35,       0,       0,       0,      51,       0,       0,
       0,       0,      44,      51,       0,       0,       0,       0,
      44,       0,       0,      51,       0,       0,       0,       0,
      44,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       0,       0,       0,      50,       0,       0,
       0,       0,       0,      50,       0,       0,       0,      57,
       0,      93,      70,      50,      91,      92,       0,       9,
      10,      11,      12,      13,      14,      15,      16,      17,
      18,      19,      20,      21,      22,      93,      70,      74,
      91,      92,       0,       9,      10,      11,      12,      13,
      14,      15,      16,      17,      18,      19,      20,      21,
      22,      70,       0,       0,       0,       0,       9,      10,
      11,      12,      13,      14,      15,      16,      17,      18,
      19,      20,      21,      22,      57,       0,       0,       0,
       0,       9,      10,      11,      12,      13,      14,      15,
      16,      17,      18,      19,      20,      21,      22,       4,
       0,       0,       0,       0,       9,      10,      11,      12,
      13,      14,      15,      16,      17,      18,      19,      20,
      21,      22,      57,       0,       0,       0,       0,       9,
      10,      11,      12,      13,      14,      15,      16,      17,
      18,      19,      20,      21,      22,      61,       0,       0,
       0,       0,       9,      10,      11,      12,      13,      14,
      15,      16,      17,      18,      19,      20,      21,      22,
       4,       0,       0,       0,       0,       9,      10,      11,
      12,      13,      14,      15,      16,      17,      18,      26,
      20,      21,      22,      47,      36,       0,      45,      46,
      34,      47,      78,       0,      45,      46,       0,       0,
       0,      47,      36,       0,      45,      46,
};

int yypact[] = {
      37,   -1000,      94,   -1000,     -41,    -247,    -249,   -1000,
   -1000,   -1000,   -1000,   -1000,   -1000,   -1000,   -1000,   -1000,
   -1000,   -1000,   -1000,   -1000,   -1000,   -1000,   -1000,     114,
   -1000,   -1000,    -250,   -1000,   -1000,   -1000,   -1000,   -1000,
     -23,   -1000,     128,   -1000,    -256,   -1000,      18,   -1000,
   -1000,      75,   -1000,   -1000,     128,   -1000,   -1000,   -1000,
   -1000,   -1000,     -39,      -1,     -34,   -1000,     114,   -1000,
     120,     -41,     120,     120,      37,     -41,     120,     120,
     -15,     114,     -46,    -251,   -1000,   -1000,     -41,   -1000,
   -1000,     -20,   -1000,    -252,   -1000,   -1000,   -1000,     -43,
      56,      37,   -1000,   -1000,   -1000,     -32,   -1000,    -254,
   -1000,     -40,   -1000,   -1000,   -1000,   -1000,   -1000,   -1000,
   -1000,   -1000,   -1000,   -1000,   -1000,
};

int yypgo[] = {
       0,      49,      22,      48,      46,      45,      24,      18,
      13,      15,      47,      80,      29,      38,      42,      28,
      41,      40,      37,      35,      34,      33,      27,      32,
      31,      62,      56,      30,      16,
};

int yyr1[] = {
       0,       1,       3,       3,       4,       4,       2,       2,
       7,       7,       7,       6,       6,      10,      10,      11,
      11,      12,      12,      15,      15,      15,      15,      13,
      13,      13,      13,      18,      18,      18,      18,      14,
       5,      17,      20,      20,      21,      21,       8,       8,
       8,      22,      22,      22,      22,      22,      22,      22,
      22,      22,      22,      22,      22,      22,      22,       9,
      16,      16,      16,      16,      16,      23,      25,      25,
      25,      24,      26,      27,      27,      28,      28,      28,
      28,      28,      19,      19,
};

int yyr2[] = {
       2,       3,       0,       1,       0,       1,       1,       2,
       1,       2,       2,       1,       3,       2,       1,       3,
       1,       1,       1,       1,       1,       1,       3,       1,
       2,       3,       3,       1,       2,       3,       3,       3,
       3,       4,       0,       2,       2,       3,       1,       1,
       2,       1,       1,       1,       1,       1,       1,       1,
       1,       1,       1,       1,       1,       1,       1,       2,
       1,       1,       1,       1,       1,       2,       1,       1,
       1,       2,       3,       1,       2,       1,       1,       1,
       1,       1,       1,       3,
};

int yychk[] = {
   -1000,      -1,      -2,      -7,     258,      -8,      -9,      45,
     -22,     263,     264,     265,     266,     267,     268,     269,
     270,     271,     272,     273,     274,     275,     276,      -3,
      -7,      -5,     273,      58,     258,     258,     -22,      -4,
      -6,     -10,     262,     -11,     258,     -12,     -13,     -14,
     -18,     -15,     -16,     -17,      40,     260,     261,     257,
     -23,     -24,      91,      35,     -19,     258,      46,     -11,
     259,     258,      -8,      -9,      59,     258,      -8,      -9,
     -11,     -20,     -21,      58,     -25,     -26,     258,      -8,
      -9,      40,     273,      44,     -10,     -12,     258,     -13,
     -13,      -2,     -15,     -15,      41,      -6,     124,      58,
     258,     -27,     -28,     260,     261,     257,     -26,     -25,
     258,      93,     258,      41,     -28,
};

int yydef[] = {
       0,      -2,       2,       6,       8,       0,       0,      38,
      39,      41,      42,      43,      44,      45,      46,      47,
      48,      49,      50,      51,      52,      53,      54,       4,
       7,       3,      51,      55,       9,      10,      40,       1,
       5,      11,       0,      14,      19,      16,      17,      18,
      23,      27,      20,      21,       0,      56,      57,      58,
      59,      60,      34,       0,       0,      74,       0,      13,
       0,      24,       0,       0,       0,      28,       0,       0,
       0,       0,       0,       0,      61,      65,      62,      63,
      64,       0,      32,       0,      12,      15,      19,      25,
      26,      31,      29,      30,      22,       0,      35,       0,
      36,       0,      67,      69,      70,      71,      72,      73,
      75,      33,      37,      66,      68,
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
  int     *yyxi;


  tmpstate = 0;
  pcyytoken = tmptoken = -1;
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
      tmptoken  = pcyytoken;
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
          }
    goto enstack;
}
