
# line 3 "pic.y"
#include <stdio.h>
#include "defs.h"
extern Object *new_object();

# line 8 "pic.y"
typedef union  {
  int   in;
  char *ch;
} YYSTYPE;
#define YYSUNION /* %union occurred */
#define DRAW 257
#define DEFINE 258
#define LINE 259
#define BOX 260
#define POLYGON 261
#define CIRCLE 262
#define ELLIPSE 263
#define BLACK 264
#define WHITE 265
#define SOLID 266
#define DOTTED 267
#define FILL 268
#define IDENTIFIER 269
#define INTEGER 270
YYSTYPE yylval, yyval;
#define YYERRCODE 256
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

#define YYNPROD 28
#define YYLAST 234

int yyact[] = {
      12,      13,      14,      15,      16,      20,      33,      38,
      17,      19,       9,      12,      13,      14,      15,      16,
       8,      34,      35,       5,       6,       7,      36,      32,
      10,      37,      24,      23,      22,      21,      31,      18,
      11,       4,       3,       2,       1,       0,       0,       0,
       0,       0,       0,       0,      30,       0,       0,       0,
       0,       0,       0,       0,       0,       0,       0,      10,
       0,       0,       0,       0,       0,      39,       0,      32,
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
       0,       0,       0,       0,       0,      27,      28,      25,
      26,      29,
};

int yypact[] = {
   -1000,    -238,   -1000,     -38,     -43,    -259,    -261,   -1000,
   -1000,   -1000,   -1000,   -1000,   -1000,   -1000,   -1000,   -1000,
   -1000,     -52,     -35,    -248,    -264,   -1000,   -1000,   -1000,
   -1000,   -1000,   -1000,   -1000,   -1000,    -247,   -1000,     -19,
   -1000,    -263,   -1000,   -1000,   -1000,    -264,   -1000,   -1000,
};

int yypgo[] = {
       0,      36,      35,      34,      33,      24,      32,      31,
      30,      29,      28,      27,      26,      23,
};

int yyr1[] = {
       0,       1,       1,       2,       2,       3,       3,       4,
       5,       6,       6,       6,       6,       6,       7,       7,
       9,       9,       9,      10,      10,      11,      11,      12,
      12,       8,       8,      13,
};

int yyr2[] = {
       2,       0,       2,       2,       2,       2,       2,       4,
       5,       1,       1,       1,       1,       1,       0,       2,
       1,       1,       1,       1,       1,       1,       1,       2,
       2,       1,       3,       2,
};

int yychk[] = {
   -1000,      -1,      -2,      -3,      -4,     257,     258,      59,
      59,     269,      -5,      -6,     259,     260,     261,     262,
     263,     269,      -7,      61,      40,      -9,     -10,     -11,
     -12,     266,     267,     264,     265,     268,      -5,      -8,
     -13,     270,     264,     265,      41,      44,     270,     -13,
};

int yydef[] = {
       1,      -2,       2,       0,       0,       0,       0,       3,
       4,       5,       6,      14,       9,      10,      11,      12,
      13,       0,       0,       0,       0,      15,      16,      17,
      18,      19,      20,      21,      22,       0,       7,       0,
      25,       0,      23,      24,       8,       0,      27,      26,
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
#define WAS0ERR 0
#define WAS1ERR 1
#define WAS2ERR 2
#define WAS3ERR 3
#define yyclearin pcyytoken = -1
#define yyerrok   pcyyerrfl = 0
YYSTYPE yyv[YYMAXDEPTH];     /* value stack */
int pcyyerrct = 0;           /* error count */
int pcyyerrfl = 0;           /* error flag */
int redseq[1000];
int redcnt = 0;
int pcyytoken = -1;          /* input token */


yyparse()
{
  int statestack[YYMAXDEPTH]; /* state stack */
  int      j, m;              /* working index */
  YYSTYPE *yypvt;
  int      tmpstate, *yyps, n;
  YYSTYPE *yypv;
  int     *yyxi;


  tmpstate = 0;
  pcyytoken = -1;
  pcyyerrct = 0;
  pcyyerrfl = 0;
  yyps = &statestack[-1];
  yypv = &yyv[-1];


  enstack:    /* push stack */
    if (++yyps > &statestack[YYMAXDEPTH]) {
      yyerror("pcyacc internal stack overflow");
      return(1);
    }
    *yyps = tmpstate;
    ++yypv;
    *yypv = yyval;


  newstate:
    n = yypact[tmpstate];
    if (n <= -1000) goto defaultact; /*  a simple state */


    if (pcyytoken < 0) if ((pcyytoken=yylex()) < 0) pcyytoken = 0;
    if ((n += pcyytoken) < 0 || n >= YYLAST) goto defaultact;


    if (yychk[n=yyact[n]] == pcyytoken) { /* a shift */
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


	     --yyps;
	     --yypv;
	   }


	   yyabort:
	     return(1);


	 case WAS3ERR:  /* clobber input char */
          if (pcyytoken == 0) goto yyabort; /* quit */
	   pcyytoken = -1;
	   goto newstate;      } /* switch */
    } /* if */


    /* reduction, given a production n */
    if (yytflag && redcnt<1000) redseq[redcnt++] = n;
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
      
      case 5:
# line 35 "pic.y"
      { append_objlst(lookup(yypvt[-0].ch)); } break;
      case 6:
# line 37 "pic.y"
      { append_objlst(new_object(&anObject)); } break;
      case 7:
# line 42 "pic.y"
      { install(yypvt[-2].ch, new_object(&anObject)); } break;
      case 9:
# line 50 "pic.y"
      { anObject.shape = LINE; } break;
      case 10:
# line 51 "pic.y"
      { anObject.shape = BOX;  } break;
      case 11:
# line 52 "pic.y"
      { anObject.shape = POLYGON; } break;
      case 12:
# line 53 "pic.y"
      { anObject.shape = CIRCLE; } break;
      case 13:
# line 54 "pic.y"
      { anObject.shape = ELLIPSE; } break;
      case 19:
# line 69 "pic.y"
      { anObject.style = SOLID; } break;
      case 20:
# line 70 "pic.y"
      { anObject.style = DOTTED; } break;
      case 21:
# line 74 "pic.y"
      { anObject.color = BLACK; } break;
      case 22:
# line 75 "pic.y"
      { anObject.color = WHITE; } break;
      case 23:
# line 79 "pic.y"
      { anObject.fill = BLACK; } break;
      case 24:
# line 80 "pic.y"
      { anObject.fill = WHITE; } break;
      case 27:
# line 90 "pic.y"
      { anObject.x_coord[anObject.npoints] = yypvt[-1].in;
            anObject.y_coord[anObject.npoints++] = yypvt[-0].in;
          } break;    }
    goto enstack;
}
