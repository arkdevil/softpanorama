
# line 15 "prolog.y"

#define   myDebug

#include  <stdio.h>
#include  <ctype.h>
#include  <string.h>

#define   maxTokenLength   64

char      outfn[] = "prolog.out";
FILE      *fopen(), *inpf, *outf;


# line 30 "prolog.y"
typedef union  {
       long   num;
       char   str[maxTokenLength];
       } YYSTYPE;
#define YYSUNION /* %union occurred */
#define NUMBER 257
#define ATOM 258
#define VAR 259
#define ERROR 260
#define IF 261
#define SPY 262
#define NOSPY 263
#define NOT 264
#define IS 265
#define UNIV 266
#define NE 267
#define LE 268
#define GE 269
#define SE 270
#define SNE 271
#define MOD 272
#define NEGATE 273
YYSTYPE yylval, yyval;
#define YYERRCODE 256

# line 190 "prolog.y"



int  c;

main( argc, argv )
   int    argc;
   char   *argv[];
   {

   if ( argc != 2 )
      {
      fprintf( stderr, "Usage:  prolog <source file> \n" );
      exit( 1 );
      }

   inpf = fopen( argv[1], "r" );

   if ( inpf == NULL )
      {
      fprintf( stderr, "Can't open file: \"%s\"\n", argv[1] );
      exit( 1 );
      }
/*
   outf = fopen( outfn, "w" );

   if ( outf == NULL )
      {
      fprintf( stderr, "Can't open file: \"%s\"\n", outfn );
      exit( 1 );
      }
*/
   c = getc( inpf );

   if ( yyparse() )
      fprintf( stderr, "Program not accepted.\n" );
   else
      fprintf( stderr, "Program accepted.\n" );

   fclose( inpf );
   fclose( outf );

   }

yyerror( s )
   char   *s;
   {
   fprintf( stderr, "%s\n", s );
   }


yymess( s )
   char   *s;
   {
#ifdef myDebug
   fprintf( stderr, "%s\n", s );
#endif
   }


#define  SQUOTE  ('\'')

int yylex()
   {
   int       k, max;
   char      result, capital, quoted;

   skipWhite();                    /*  skip whitespace & comments  */

   if ( c == EOF )                 /*  end of file  */
      return( EOF );

   if ( isdigit(c) )               /*  NUMBER  */
      {
      yylval.num = 0;
      while( isdigit(c) )
         {
         yylval.num += (c - '0');
         c = getc( inpf );
         }

#ifdef myDebug
fprintf( stderr, "NUMBER: %d\n", yylval.num );
#endif

      return( NUMBER );
      }

   if ( isalpha(c) || (c == SQUOTE) )   /*  ATOM or VARIABLE or keyword  */
      {
      if ( c == SQUOTE )
         {
         quoted = 1;
         capital = 0;
         c = getc( inpf );
         }
      else
         {
         quoted = 0;
         capital = isupper(c);
         }
      max = maxTokenLength - 1;
      k = 0;
      while ( isalnum(c) || (c == '_') )
         {
         if ( k < max )
            yylval.str[k] = c;
         k++;
         c = getc( inpf );
         }
      yylval.str[k] = '\0';
      if ( quoted )
         {
         if ( c == SQUOTE )
            c = getc( inpf );    /*  advance past the quote mark  */
         else
            {
            yyerror( "Closing single quote mark not found." );
            return( ERROR );
            }
         }            
      if ( capital )
         {

#ifdef myDebug
fprintf( stderr, "VARIABLE: %s\n", yylval.str );
#endif

         return( VAR );
         }

      if ( strcmp(yylval.str, "is") == 0 )     /*  keywords:  */
         {

#ifdef myDebug
fprintf( stderr, "OPER: is\n" );
#endif

         return( IS );
         }
      else if ( strcmp(yylval.str, "not") == 0 )
         {

#ifdef myDebug
fprintf( stderr, "OPER: not\n" );
#endif

         return( NOT );
         }
      else if ( strcmp(yylval.str, "mod") == 0 )
         {

#ifdef myDebug
fprintf( stderr, "OPER: mod\n" );
#endif

         return( MOD );
         }
      else if ( strcmp(yylval.str, "spy") == 0 )
         {

#ifdef myDebug
fprintf( stderr, "OPER: spy\n" );
#endif

         return( SPY );
         }
      else if ( strcmp(yylval.str, "nospy") == 0 )
         {

#ifdef myDebug
fprintf( stderr, "OPER: nospy\n" );
#endif

         return( NOSPY );
         }

#ifdef myDebug
fprintf( stderr, "ATOM: %s\n", yylval.str );
#endif

      return( ATOM );
      }

   switch( c )   /*** try to recognize this character ***/
      {
      case '/' :
         c = getc( inpf );
         if ( c == '*' )          /*  COMMENT  */
            skipComment();
         else
            result = '/';
         break;

      case ':' :
         c = getc( inpf );
         if ( c == '-' )          /*  IF  */
            {
            c = getc( inpf );

#ifdef myDebug
fprintf( stderr, "\nIF\n\n" );
#endif

            return( IF );
            }
         result = ':';
         break;

      case '=' :                  /*  UNIV or SE or LE  */
         c = getc( inpf );
         if ( c == '.' )
            {
            c = getc( inpf );
            if ( c == '.' )       /*  UNIV  */
               {
               c = getc( inpf );

#ifdef myDebug
fprintf( stderr, "UNIV\n" );
#endif

               return( UNIV );
               }
            else
               {
               ungetc( c, inpf );
               c = '.';
               result = '=';
               break;
               }
            }
         else if ( c == '=' )     /*  SE  */
            {
            c = getc( inpf );
            return( SE );
            }
         else if ( c == '<' )     /*  LE  */
            {
            c = getc( inpf );
            return( LE );
            }
         result = '=';
         break;
      
      case '>' :                  /*  GE  */
         c = getc( inpf );
         if ( c == '=' )
            {
            c = getc( inpf );
            return( GE );
            }
         result = '>';
         break;

      case '\\' :                 /*  NE or SNE  */
         c = getc( inpf );
         if ( c == '=' )
            {
            c = getc( inpf );
            if ( c == '=' )       /*  SNE  */
               {
               c = getc( inpf );
               return( SNE );
               }
            return( NE );         /*  NE  */
            }
         result = '\\';
         break;
      
      default:
         result = c;
         c = getc( inpf );
         break;
      }

#ifdef myDebug
fprintf( stderr, "CHAR: %c\n", result );
#endif

   return( result );
   }


skipComment()    /*  This function skips comments   */
   {             /*  even if they contain comments  */
   while ( 1 )
      {
      c = getc( inpf );
      if ( c == '/' )
         {
         c = getc( inpf );
         if ( c == '*' )
            skipComment();     /*  note recursion  */
         }
      else if ( c == '*' )
         {
         c = getc( inpf );
         if ( c == '/' )
            {
            c = getc( inpf );
            return;            /*  exit point  */
            }
         }
      }
   }


skipWhite()            /*  skip whitespace  */
   {
   while ( 1 )
      {
      if ( isspace(c) )
         c = getc( inpf );
      else if ( c == '/' )
         {
         c = getc( inpf );
         if ( c == '*' )
            {
            skipComment();
            continue;
            }
         else
            {
            ungetc( c, inpf );
            c = '/';
            break;
            }
         }
      else
         break;
      }
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
  -1, 82,
  44, 25,
  93, 25,
  124, 25,
  -2, 59,
  -1, 83,
  44, 26,
  93, 26,
  124, 26,
  -2, 60,
  -1, 84,
  44, 27,
  93, 27,
  124, 27,
  -2, 61,
  0,
};

#define YYNPROD 71
#define YYLAST 381

int yyact[] = {
     112,      65,      63,      65,      64,      67,      66,      52,
      66,      65,      63,     124,      64,      40,      66,      14,
       4,      42,      40,      59,      55,      61,      50,      40,
      78,       9,      50,      59,      55,      61,     112,      65,
      63,      13,      64,      31,      66,      65,      63,      20,
      64,     118,      66,     117,      92,      30,      24,      20,
     126,      35,      41,      26,      90,      80,      24,      20,
     125,      33,     111,      26,     119,      45,      24,      48,
      51,      74,      15,      26,      45,      71,      47,      21,
       3,       3,      26,      14,      46,      87,      76,      11,
      77,      77,      32,      46,      10,      27,      34,      34,
      16,      79,      81,      91,     116,      19,      29,      36,
     119,      40,      44,      78,      37,      85,      93,      95,
       1,      40,      21,      86,       0,      85,      75,       0,
       2,      68,       7,       0,      17,       0,       0,       0,
       2,       0,       0,     115,       0,      45,       0,      32,
       0,       0,       0,      35,      17,       0,       0,     114,
       0,       0,       0,       0,       0,       0,       0,      53,
       0,     115,       0,       0,       0,      34,       0,       0,
       0,      88,      89,      11,       0,      16,       0,       0,
       0,       0,       0,       0,     123,      81,       0,      81,
      92,     120,     122,     121,      33,      41,     117,      80,
       0,       0,      49,      43,      39,      38,       0,       6,
       5,       0,      96,       0,       0,      49,       0,      94,
       0,      49,       0,       0,      46,      86,       0,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
      54,       0,      57,      60,      62,      56,      58,      67,
      54,      67,      57,      60,      62,      56,      58,      67,
       8,      53,       0,       0,       0,       0,      12,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       0,       0,       0,      67,       0,      82,
      83,      84,      23,      67,      18,      19,       0,      82,
      83,      84,       0,       0,      18,      19,       0,      28,
      25,      22,       0,       0,      18,      19,      28,      72,
      73,       0,       0,      69,       0,      70,       0,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,      97,      98,      99,     100,     101,     102,     103,
     104,     105,     106,     107,     108,     109,     110,       0,
      26,      54,     113,       0,       0,       0,       0,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       0,       0,      55,      56,      57,      58,
      59,      60,      61,      62,      63,      64,      65,      66,
      67,      71,       0,       0,      23,
};

int yypact[] = {
     -75,     -75,   -1000,     -21,     -12,      35,      26,   -1000,
      22,   -1000,       1,   -1000,   -1000,    -223,     -78,     -78,
      24,   -1000,     -65,     -65,   -1000,    -259,     -25,     -33,
      22,      26,      29,   -1000,   -1000,      19,     -12,   -1000,
      37,   -1000,   -1000,   -1000,   -1000,   -1000,      35,      26,
       6,   -1000,   -1000,   -1000,      36,      22,      22,   -1000,
   -1000,       5,     -65,   -1000,     -68,     -73,      29,      29,
      29,      29,      29,      29,      29,      29,      29,      29,
      29,      29,      29,      29,      17,     -41,   -1000,      29,
   -1000,   -1000,   -1000,   -1000,   -1000,     -78,   -1000,      -1,
   -1000,   -1000,   -1000,      26,     -25,   -1000,   -1000,   -1000,
   -1000,   -1000,    -216,      16,   -1000,   -1000,   -1000,   -1000,
   -1000,      -5,      -5,      -5,      -5,      -5,      -5,      -5,
      -5,      -5,     -39,     -39,    -267,    -267,    -267,   -1000,
   -1000,     -11,   -1000,      14,   -1000,      14,   -1000,     -80,
     -37,   -1000,     -45,   -1000,     -69,   -1000,   -1000,
};

int yypgo[] = {
       0,     104,     100,      95,      71,      82,      57,      49,
      44,      91,      50,      89,      53,     107,     266,      88,
      85,     112,      84,      79,
};

int yyr1[] = {
       0,       2,       2,       3,       3,       4,       4,       5,
       5,       6,       6,       6,       6,       8,       8,       8,
       9,       9,      10,       7,       7,       7,      11,      11,
      12,      12,      12,      12,      12,      12,      13,      13,
      13,      13,      13,      13,      13,      13,      13,      13,
      13,      13,      13,      13,      13,      13,      13,      13,
      15,      15,      15,      14,      14,      14,      14,      14,
      14,      14,      16,      16,      16,      16,       1,       1,
      17,      17,      17,      18,      18,      19,      19,
};

int yyr2[] = {
       2,       1,       1,       1,       1,       4,       4,       3,
       1,       1,       1,       1,       1,       3,       1,       5,
       3,       1,       2,       5,       3,       1,       3,       1,
       1,       1,       1,       1,       1,       1,       2,       2,
       1,       1,       3,       3,       3,       3,       3,       3,
       3,       3,       3,       3,       3,       3,       3,       3,
       1,       3,       3,       3,       3,       3,       3,       3,
       2,       1,       3,       1,       1,       1,       2,       1,
       4,       2,       4,       3,       1,       1,       2,
};

int yychk[] = {
   -1000,      -1,     -17,      -4,      91,     259,     258,     -17,
     261,      46,     -18,     -19,     258,      45,      40,      40,
     -15,     -13,     262,     263,      33,      -4,     259,     -14,
      40,     258,      45,     -16,     257,      93,      44,     258,
      -5,      -6,      -4,      -7,      -3,      -2,     259,     258,
      91,     -10,      95,     257,      -5,      44,      59,      46,
      -8,     258,      91,      -8,     266,     266,     265,      61,
     270,     267,     271,      60,     268,      62,     269,      43,
      45,      42,      47,     272,     -15,     -14,     -14,      40,
     258,     259,      46,     -19,      41,      44,      93,     -11,
     -12,      -7,     257,     258,     259,      95,     -13,      41,
     -13,     -13,      47,      -9,      -8,      -7,     259,      -7,
     259,     -14,     -14,     -14,     -14,     -14,     -14,     -14,
     -14,     -14,     -14,     -14,     -14,     -14,     -14,      41,
      41,     -14,      -6,     124,      93,      44,     257,      44,
     -12,     -12,     -10,      -8,      91,      93,      93,
};

int yydef[] = {
       0,      -2,      63,       0,       0,       0,       0,      62,
       0,      65,       0,      68,      69,       0,       0,       0,
       0,      48,       0,       0,      32,      33,      61,       0,
       0,      60,       0,      57,      59,       0,       0,      70,
       0,       8,       9,      10,      11,      12,       3,       1,
       0,      21,       4,       2,       0,       0,       0,      64,
      30,      14,       0,      31,       0,       0,       0,       0,
       0,       0,       0,       0,       0,       0,       0,       0,
       0,       0,       0,       0,       0,       0,      56,       0,
      60,      61,      66,      67,       5,       0,      18,       0,
      23,      24,      -2,      -2,      -2,      28,      29,       6,
      49,      50,       0,       0,      17,      34,      35,      36,
      37,      38,      39,      40,      41,      42,      43,      44,
      45,      46,      51,      52,      53,      54,      55,      47,
      58,       0,       7,       0,      20,       0,      13,       0,
       0,      22,       0,      16,       0,      19,      15,
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
      
      case 19:
# line 108 "prolog.y"
      { yymess( "list [|]" ); } break;
      case 20:
# line 110 "prolog.y"
      { yymess( "list" ); } break;
      case 21:
# line 112 "prolog.y"
      { yymess( "empty list" ); } break;
      case 32:
# line 130 "prolog.y"
      { yymess( "cut" ); } break;
      case 33:
# line 132 "prolog.y"
      { yymess( "goal" ); } break;
      case 49:
# line 151 "prolog.y"
      { yymess( "conjunction\n" ); } break;
      case 50:
# line 153 "prolog.y"
      { yymess( "disjunction\n" ); } break;
      case 64:
# line 176 "prolog.y"
      { yymess( "clause\n" ); } break;
      case 65:
# line 178 "prolog.y"
      { yymess( "fact\n" ); } break;    }
    goto enstack;
}
