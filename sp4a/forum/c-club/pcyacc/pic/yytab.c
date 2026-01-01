
# line 3 "pic.y"
#include "defs.h"
extern Object *new_object();

# line 7 "pic.y"
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
#define yyclearin yychar = -1
#define yyerrok yyerrflag = 0
extern int yychar;
extern short yyerrflag;
#ifndef YYMAXDEPTH
#define YYMAXDEPTH 150
#endif
YYSTYPE yylval, yyval;
#define YYERRCODE 256
short yyexca[] ={
-1, 1,
	0, -1,
	-2, 0,
	0 };
#define YYNPROD 28
#define YYLAST 234
short yyact[]={

  12,  13,  14,  15,  16,  20,  33,  38,  17,  19,
   9,  12,  13,  14,  15,  16,   8,  34,  35,   5,
   6,   7,  36,  32,  10,  37,  24,  23,  22,  21,
  31,  18,  11,   4,   3,   2,   1,   0,   0,   0,
   0,   0,   0,   0,  30,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,  39,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,  27,
  28,  25,  26,  29 };
short yypact[]={

-1000,-238,-1000, -38, -43,-259,-261,-1000,-1000,-1000,
-1000,-1000,-1000,-1000,-1000,-1000,-1000, -52, -35,-248,
-264,-1000,-1000,-1000,-1000,-1000,-1000,-1000,-1000,-247,
-1000, -19,-1000,-263,-1000,-1000,-1000,-264,-1000,-1000 };
short yypgo[]={

   0,  36,  35,  34,  33,  24,  32,  31,  30,  29,
  28,  27,  26,  23 };
short yyr1[]={

   0,   1,   1,   2,   2,   3,   3,   4,   5,   6,
   6,   6,   6,   6,   7,   7,   9,   9,   9,  10,
  10,  11,  11,  12,  12,   8,   8,  13 };
short yyr2[]={

   0,   0,   2,   2,   2,   2,   2,   4,   5,   1,
   1,   1,   1,   1,   0,   2,   1,   1,   1,   1,
   1,   1,   1,   2,   2,   1,   3,   2 };
short yychk[]={

-1000,  -1,  -2,  -3,  -4, 257, 258,  59,  59, 269,
  -5,  -6, 259, 260, 261, 262, 263, 269,  -7,  61,
  40,  -9, -10, -11, -12, 266, 267, 264, 265, 268,
  -5,  -8, -13, 270, 264, 265,  41,  44, 270, -13 };
short yydef[]={

   1,  -2,   2,   0,   0,   0,   0,   3,   4,   5,
   6,  14,   9,  10,  11,  12,  13,   0,   0,   0,
   0,  15,  16,  17,  18,  19,  20,  21,  22,   0,
   7,   0,  25,   0,  23,  24,   8,   0,  27,  26 };


/* beginning of yacc parser file */


#ifndef INITIALIZE
#define INITIALIZE
#endif


# define YYFLAG -1000
# define YYERROR goto yyerrlab
# define YYACCEPT return(0)
# define YYABORT return(1)


/*	parser for yacc output	*/


#ifdef YYDEBUG
int yydebug = 0; /* 1 for debugging */
#endif
YYSTYPE yyv[YYMAXDEPTH]; /* where the values are stored */
int yychar = -1; /* current input token number */
int yynerrs = 0;  /* number of errors */
short yyerrflag = 0;  /* error recovery flag */


yyparse() {


	short yys[YYMAXDEPTH];
	short yyj, yym;
	YYSTYPE *yypvt;
	short yystate, *yyps, yyn;
	YYSTYPE *yypv;
	short *yyxi;


	yystate = 0;
	yychar = -1;
	yynerrs = 0;
	yyerrflag = 0;
	yyps= &yys[-1];
	yypv= &yyv[-1];


 yystack:    /* put a state and value onto the stack */


#ifdef YYDEBUG
	if( yydebug  ) printf( "state %d, char 0%o\n", yystate, yychar );
#endif
		if( ++yyps> &yys[YYMAXDEPTH] ) { yyerror( "yacc stack overflow" ); return(1); }
		*yyps = yystate;
		++yypv;
		*yypv = yyval;


 yynewstate:


	yyn = yypact[yystate];


	if( yyn<= YYFLAG ) goto yydefault; /* simple state */


	if( yychar<0 ) if( (yychar=yylex())<0 ) yychar=0;
	if( (yyn += yychar)<0 || yyn >= YYLAST ) goto yydefault;


	if( yychk[ yyn=yyact[ yyn ] ] == yychar ){ /* valid shift */
		yychar = -1;
		yyval = yylval;
		yystate = yyn;
		if( yyerrflag > 0 ) --yyerrflag;
		goto yystack;
		}


 yydefault:
	/* default state action */


	if( (yyn=yydef[yystate]) == -2 ) {
		if( yychar<0 ) if( (yychar=yylex())<0 ) yychar = 0;
		/* look through exception table */


		for( yyxi=yyexca; (*yyxi!= (-1)) || (yyxi[1]!=yystate) ; yyxi += 2 ) ; /* VOID */


		while( *(yyxi+=2) >= 0 ){
			if( *yyxi == yychar ) break;
			}
		if( (yyn = yyxi[1]) < 0 ) return(0);   /* accept */
		}


	if( yyn == 0 ){ /* error */
		/* error ... attempt to resume parsing */


		switch( yyerrflag ){


		case 0:   /* brand new error */


			yyerror( "syntax error" );
		yyerrlab:
			++yynerrs;


		case 1:
		case 2: /* incompletely recovered error ... try again */


			yyerrflag = 3;


			/* find a state where "error" is a legal shift action */


			while ( yyps >= yys ) {
			   yyn = yypact[*yyps] + YYERRCODE;
			   if( yyn>= 0 && yyn < YYLAST && yychk[yyact[yyn]] == YYERRCODE ){
			      yystate = yyact[yyn];  /* simulate a shift of "error" */
			      goto yystack;
			      }
			   yyn = yypact[*yyps];


			   /* the current yyps has no shift onn "error", pop stack */


#ifdef YYDEBUG
			   if( yydebug ) printf( "error recovery pops state %d, uncovers %d\n", *yyps, yyps[-1] );
#endif
			   --yyps;
			   --yypv;
			   }


			/* there is no state on the stack with an error shift ... abort */


	yyabort:
			return(1);




		case 3:  /* no shift yet; clobber input char */


#ifdef YYDEBUG
			if( yydebug ) printf( "error recovery discards char %d\n", yychar );
#endif


			if( yychar == 0 ) goto yyabort; /* don't discard EOF, quit */
			yychar = -1;
			goto yynewstate;   /* try again in the same state */


			}


		}


	/* reduction by production yyn */


#ifdef YYDEBUG
		if( yydebug ) printf("reduce %d\n",yyn);
#endif
		yyps -= yyr2[yyn];
		yypvt = yypv;
		yypv -= yyr2[yyn];
		yyval = yypv[1];
		yym=yyn;
			/* consult goto table to find next state */
		yyn = yyr1[yyn];
		yyj = yypgo[yyn] + *yyps + 1;
		if( yyj>=YYLAST || yychk[ yystate = yyact[yyj] ] != -yyn ) yystate = yyact[yypgo[yyn]];
		switch(yym){

case 5:
# line 34 "pic.y"
{ append_objlst(lookup(yypvt[-0].ch)); } break;
case 6:
# line 36 "pic.y"
{ append_objlst(new_object(&anObject)); } break;
case 7:
# line 41 "pic.y"
{ install(yypvt[-2].ch, new_object(&anObject)); } break;
case 9:
# line 49 "pic.y"
{ anObject.shape = LINE; } break;
case 10:
# line 50 "pic.y"
{ anObject.shape = BOX;  } break;
case 11:
# line 51 "pic.y"
{ anObject.shape = POLYGON; } break;
case 12:
# line 52 "pic.y"
{ anObject.shape = CIRCLE; } break;
case 13:
# line 53 "pic.y"
{ anObject.shape = ELLIPSE; } break;
case 19:
# line 68 "pic.y"
{ anObject.style = SOLID; } break;
case 20:
# line 69 "pic.y"
{ anObject.style = DOTTED; } break;
case 21:
# line 73 "pic.y"
{ anObject.color = BLACK; } break;
case 22:
# line 74 "pic.y"
{ anObject.color = WHITE; } break;
case 23:
# line 78 "pic.y"
{ anObject.fill = BLACK; } break;
case 24:
# line 79 "pic.y"
{ anObject.fill = WHITE; } break;
case 27:
# line 89 "pic.y"
{ anObject.x_coord[anObject.npoints] = yypvt[-1].in;
      anObject.y_coord[anObject.npoints++] = yypvt[-0].in;
    } break;		}
		goto yystack;  /* stack new state and value */


	}


