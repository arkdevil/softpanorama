# define CHAR 257
# define CCL 258
# define NCCL 259
# define STR 260
# define DELIM 261
# define SCON 262
# define ITER 263
# define NEWE 264
# define NULLS 265
# define CAT 266

# line 11 "parser.y"
#include "ldefs.h"
#define yyclearin yychar = -1
#define yyerrok yyerrflag = 0
extern int yychar;
extern short yyerrflag;
#ifndef YYMAXDEPTH
#define YYMAXDEPTH 150
#endif
#ifndef YYSTYPE
#define YYSTYPE int
#endif
YYSTYPE yylval, yyval;

# line 17 "parser.y"
int      i;
int      j;
int      k;
int      g;
char    *p;
# define YYERRCODE 256

# line 237 "parser.y"

yylex()
{
	register char   *p;
	register int     c;
	register int     i;
		 char   *t;
		 char   *xp;
		 int     n;
		 int     j;
		 int     k;
		 int     x;
	static   int     sectbegin;
	static   char    token[TOKENSIZE];
	static   int     iter;

#ifdef DEBUG
	yylval = 0;
#endif DEBUG

	if( sect == DEFSECTION ){                /* definitions section */
		while( !Eof ){
			if( prev == '\n' ){               /* next char is at beginning of line */
				getl( p = buf );
				switch( *p ){
				  case '%':
						switch( c = *( p + 1 ) ){
						  case '%':
								lgate();
								fprintf( fout, "#define YYNEWLINE %d\n", ctable[C('\n')] );
								fprintf( fout, "yylex(){\nint nstr; extern int yyprevious;\n" );
								sectbegin = TRUE;
								i = treesize*( sizeof( *name ) + sizeof( *left )+
									sizeof(*right) + sizeof( *nullstr ) + sizeof( *parent ) )+ALITTLEEXTRA;
								c = myalloc( i, 1 );
								if( c == 0 )
									error( "Not enough memory for parsing", "    " );
								p = c;
								cfree( p, i, 1 );
								name = myalloc( treesize, sizeof( *name ) );
								left = myalloc( treesize, sizeof( *left ) );
								right = myalloc( treesize, sizeof( *right ) );
								nullstr = myalloc( treesize, sizeof( *nullstr ) );
								parent = myalloc( treesize, sizeof( *parent ) );
								if( name == 0 || left == 0 || right == 0 || parent == 0 || nullstr == 0 )
									error( "Not enough memory for parsing", "    " );
								return( freturn( DELIM ) );
						  case 'p':  /* has overridden number of positions */
						  case 'P':
								while( *p && !digit( *p ) )
									p++;
								maxpos = siconv( p );
#ifdef DEBUG
								if( debug )
									printf( "positions (%%p) now %d\n", maxpos );
#endif DEBUG
								if( report == 2 )
									report = 1;
								continue;
						  case 'n':
						  case 'N':     /* has overridden number of states */
								while( *p && !digit( *p ) )
									p++;
								nstates = siconv( p );
#ifdef DEBUG
								if( debug )
									printf( " no. states (%%n) now %d\n", nstates );
#endif DEBUG
								if( report == 2 )
									report = 1;
								continue;
						  case 'e':
						  case 'E':             /* has overridden number of tree nodes */
								while( *p && !digit( *p ) )
									p++;
								treesize = siconv( p );
#ifdef DEBUG
								if( debug )
									printf( "treesize (%%e) now %d\n", treesize );
#endif DEBUG
								if( report == 2 ){
									report = 1;
								}
								continue;
						  case 'o':
						  case 'O':
								while( *p && !digit( *p ) )
									p++;
								outsize = siconv( p );
								if( report == 2 )
									report = 1;
								continue;
						  case 'a':
						  case 'A':             /* has overridden number of transitions */
								while( *p && !digit( *p ) )
									p++;
								if( report == 2 )
									report = 1;
								ntrans = siconv( p );
# ifdef DEBUG
								if( debug )
									printf( "N. trans (%%a) now %d\n", ntrans );
# endif
								continue;
						  case 'k':
						  case 'K': /* overriden packed char classes */
								while( *p && !digit( *p ) )
									p++;
								if( report == 2 )
									report = 1;
								cfree( pchar, pchlen, sizeof( *pchar ) );
								pchlen = siconv( p );
# ifdef DEBUG
								if( debug )
									printf( "Size classes (%%k) now %d\n", pchlen );
# endif
								pchar = pcptr = myalloc( pchlen, sizeof( *pchar ) );
								continue;
						  case 't': case 'T':     /* character set specifier */
								ZCH = atoi(p+2);
								if (ZCH < NCH) ZCH = NCH;
								if (ZCH > 2*NCH) error("char table redefining is necessary",
										       "  . ");
								chset = TRUE;
								for(i = 0; i<ZCH; i++)
									ctable[i] = 0;
								while(getl(p) && scomp(p,"%T") != 0 && scomp(p,"%t") != 0 ){
									if((n = siconv(p)) <= 0 || n > ZCH){
										warning("Bad value of char %d", "   %d",n);
										continue;
									}
									while(!space(*p) && *p) p++;
									while(space(*p)) p++;
									t = p;
									while(*t){
										c = ctrans(&t);
										if( ctable[c] ){
											if( printable( c ) )
												warning( "Char '%c' used twice",
													 " '%c'  ", c );
											else
												warning( "Char %3o used twice",
													 " %3o  ", c );
										}
										else ctable[c] = n;
										t++;
									}
									p = buf;
								}
								{
									char chused[2*NCH]; int kr;

									for(i=0; i<ZCH; i++)
										chused[i]=0;
									for(i=0; i<NCH; i++)
										chused[ctable[i]]=1;
									for(kr=i=1; i<NCH; i++)
										if (ctable[i]==0){
											while (chused[kr] == 0)
												kr++;
											ctable[i]=kr;
											chused[kr]=1;
										}
								}
								lgate();
								continue;
						  case 'c': case 'C':
								continue;
						  case '{':
								lgate();
								while(getl(p) && scomp(p,"%}") != 0)
									fprintf(fout, "%s\n",p);
								if(p[0] == '%') continue;
								error("Unexpected EOF", " EOF");
						 case 's': case 'S':             /* start conditions */
								lgate();
								while(*p && index(*p," \t,") < 0) p++;
								n = TRUE;
								while(n){
									while(*p && index(*p," \t,") >= 0) p++;
									t = p;
									while(*p && index(*p," \t,") < 0)p++;
									if(!*p) n = FALSE;
									*p++ = 0;
									if (*t == 0) continue;
									i = sptr*2;
									fprintf(fout,"#define %s %d\n",t,i);
									scopy(t,sp);
									sname[sptr++] = sp;
									sname[sptr] = 0;        /* required by lookup */
									if(sptr >= STARTSIZE)
										error("Too many start conditions",
										      "   ");
									sp += slength(sp) + 1;
									if(sp >= schar+STARTCHAR)
										error("Start conditions too long",
										      "   ");
								}
								continue;
						  default:
								warning("Illegal request %s",
									"  %s",p);
								continue;
						}       /* end of switch after seeing '%' */
				    case ' ': case '\t':            /* must be code */
						lgate();
						fprintf(fout, "%s\n",p);
						continue;
				    default:                /* definition */
						while(*p && !space(*p)) p++;
						if(*p == 0)
							continue;
						prev = U(*p);
						*p = 0;
						bptr = p+1;
						yylval = buf;
						if(digit(buf[0]))
							warning("Substitution strings can't have leading digit",
								"      ");
						return(freturn(STR));
				}
			}else{       /* still sect 1, but prev != '\n' */
				p = bptr;
				while(*p && space(*p)) p++;
				if(*p == 0)
					warning("Translation not defined - empty string",
						"   -  ");
				scopy(p,token);
				yylval = token;
				prev = '\n';
				return(freturn(STR));
			}
		}
		/* end of section one processing */
	}else if(sect == RULESECTION){           /* rules and actions */
		while(!Eof){
			switch( c = gch() ){
			  case '\0':
					return( freturn( 0 ) );
			  case '\n':
					if( prev == '\n' ) continue;
					x = NEWE;
					break;
			  case ' ':
			  case '\t':
					if( sectbegin == TRUE ){
						cpyact();
						while( ( c = gch() ) && c != '\n' );
						continue;
					}
					if( !funcflag ) phead2();
					funcflag = TRUE;
					fprintf( fout, "case %d:\n", casecount );
					if( cpyact() )
						fprintf( fout, "break;\n" );
					while( ( c = gch() ) && c != '\n' );
					if( Peek == ' ' || Peek == '\t' || sectbegin == TRUE ){
						warning( "Executable operators must be after %% in string",
							 "      %%" );
						continue;
					}
					x = NEWE;
					break;
			  case '%':
					if( prev != '\n' ) goto character;
					if( Peek == '{' ){        /* included code */
						getl( buf );
						while( !Eof && getl( buf ) && scomp( "%}", buf ) != 0 )
							fprintf( fout, "%s\n", buf );
						continue;
					}
					if( Peek == '%' ){
						c = gch();
						c = gch();
						x = DELIM;
						break;
					}
					goto character;
			  case '|':
					if( Peek == ' ' || Peek == '\t' || Peek == '\n' ){
						fprintf( fout, "case %d:\n", casecount++ );
						continue;
					}
					x = '|';
					break;
			  case '$':
					if( Peek == '\n' || Peek == ' ' || Peek == '\t' || Peek == '|' || Peek == '/' ){
						x = c;
						break;
					}
					goto character;
			  case '^':
					if( prev != '\n' && scon != TRUE ) goto character;        /* valid only at line begin */
					x = c;
					break;
			  case '?':
			  case '+':
			  case '.':
			  case '*':
			  case '(':
			  case ')':
			  case ',':
			  case '/':
					x = c;
					break;
			  case '}':
					iter = FALSE;
					x = c;
					break;
			  case '{':       /* either iteration or definition */
					if( digit( c = gch() ) ){     /* iteration */
						iter = TRUE;
					ieval:
						i = 0;
						while( digit( c ) ){
							token[i++] = c;
							c = gch();
						}
						token[i] = 0;
						yylval = siconv( token );
						munput( 'c', c );
						x = ITER;
						break;
					}else{          /* definition */

						i = 0;
						while( c && c != '}' ){
							token[i++] = c;
							c = gch();
						}
						token[i] = 0;
						i = lookup( token, def );
						if( i < 0 )
							warning( "Definition %s not found", " %s  ", token );
						else
							munput( 's', subs[i] );
						continue;
					}
			  case '<':               /* start condition ? */
					if( prev != '\n' )                /* not at line begin, not start */
						goto character;
					t = slptr;
					do{
						i = 0;
						c = gch();
						while( c != ',' && c && c != '>' ){
							token[i++] = c;
							c = gch();
						}
						token[i] = 0;
						if( i == 0 )
							goto character;
						i = lookup( token, sname );
						if( i < 0 ){
							warning( "Undefined start condition %s", "   %s", token );
							continue;
						}
						*slptr++ = i+1;
					}while( c && c != '>' );
					*slptr++ = 0;
					/* check if previous value re-usable */
					for( xp = slist; xp < t; ){
						if( strcmp( xp, t ) == 0 )
							break;
						while( *xp++ )
							;
					}
					if( xp < t ){
						/* re-use previous pointer to string */
						slptr = t;
						t = xp;
					}
					if( slptr > slist + STARTSIZE )             /* note not packed ! */
						error( "Too many start conditions used", "    " );
					yylval = t;
					x = SCON;
					break;
			  case '"':
					i = 0;
					while( ( c = gch() ) && c != '"' && c != '\n' ){
						if( c == '\\' )
							c = usescape( c = gch() );
						token[i++] = c;
						if( i > TOKENSIZE ){
							warning( "String too long", "  " );
							i = TOKENSIZE-1;
							break;
						}
					}
					if( c == '\n' ){
						yyline--;
						warning( "Nonterminated string", " " );
						yyline++;
					}
					token[i] = 0;
					if( i == 0 ){
						x = NULLS;
					}else if( i == 1 ){
						yylval = U( token[0] );
						x = CHAR;
					}else{
						yylval = token;
						x = STR;
					}
					break;
			  case '[':
					for( i = 1; i < NCH; i++ )
						symbol[C(i)] = 0;
					x = CCL;
					if( ( c = gch() ) == '^' ){
						x = NCCL;
						c = gch();
					}
					while( c != ']' && c ){
						if( c == '\\' )
							c = usescape( c = gch() );
						symbol[C(c)] = 1;
						j = C(c);
						if( ( c = gch() ) == '-' && Peek != ']' ){            /* range specified */
							c = gch();
							if( c == '\\' )
								c = usescape( c = gch() );
							k = C(c);
#ifndef KOI8
							if( j > k ){
#else
							if( KtoU(j) > KtoU(k) ){
#endif KOI8
								warning( "Inverted range", " " );
								n = j;
								j = k;
								k = n;
								symbol[C(j)] = 1;
							}
							if( !( ( 'A' <= j && k <= 'Z' ) ||
							       ( 'a' <= j && k <= 'z' ) ||
							       ( '0' <= j && k <= '9' )
#ifdef Ucode

							    || ( C('')<=j && k<=C('') )
							    || ( C('')<=j && k<=C('') )
#endif
#ifdef KOI8
							    || ( 0300<=KtoU(j) && KtoU(k)<=0337 )
							    || ( 0340<=KtoU(j) && KtoU(k)<=0377 )
#endif
											   ) )

								warning( "Nonportable char class '%c'-'%c'", "   '%c'-'%c'", j, k );
#ifndef KOI8
							for( n = j + 1; n <= k; n++ )
								symbol[C(n)] = 1;          /* implementation dependent */
#else
							i = KtoU(k);
							for( n = KtoU(j+1); n <= i; n++ )
								symbol[UtoK(n)] = 1;
#endif KOI8
							c = gch();
						}
					}
					/* try to pack ccl's */
					i = 0;
					for( j = 0; j < NCH; j++ )
						if( symbol[C(j)] )
							token[i++] = j;
					token[i] = 0;
					p = ccptr;
					if( optim ){
						p = ccl;
						while( p < ccptr && scomp( token, p ) != 0 )
							p++;
					}
					if( p < ccptr ){   /* found it */
						yylval = p;
					}else{
						yylval = ccptr;
						scopy( token, ccptr );
						ccptr += slength(token) + 1;
						if( ccptr >= ccl + CCLSIZE )
							error( "Char classes too long",
							       "   " );
					}
					cclinter( x == CCL );
					break;
			  case '\\':
					c = usescape( c = gch() );
			  default:
			  character:
					if( iter ){       /* second part of an iteration */
						iter = FALSE;
						if( '0' <= c && c <= '9' )
							goto ieval;
					}
					if( alpha( Peek ) ){
						i = 0;
						yylval = token;
						token[i++] = c;
						while( alpha( Peek ) )
							token[i++] = gch();
						if( Peek == '?' || Peek == '*' || Peek == '+' )
							munput( 'c', token[--i] );
						token[i] = 0;
						if( i == 1 ){
							yylval = U(token[0]);
							x = CHAR;
						}else
							x = STR;
					}else{
						yylval = c;
						x = CHAR;
					}
				}
				scon = FALSE;
				if( x == SCON )
					scon = TRUE;
				sectbegin = FALSE;
				return( freturn( x ) );
		}
	}
	/* section three */
	ptail();
#ifdef DEBUG
	if( debug )
		fprintf( fout, "\n/*this comes from section three - debug */\n" );
#endif
	while( getl( buf ) && !Eof )
		fprintf( fout, "%s\n", buf );
	return( freturn( 0 ) );
}
/* end of yylex */

#ifdef DEBUG
freturn(i)
  int i; {
	if(yydebug) {
		printf("now return ");
		if(i < NCH) allprint(i);
		else printf("%d",i);
		printf("   yylval = ");
		switch(i){
			case STR: case CCL: case NCCL:
				strpt(yylval);
				break;
			case CHAR:
				allprint(yylval);
				break;
			default:
				printf("%d",yylval);
				break;
			}
		putchar('\n');
		}
	return(i);
	}
# endif
short yyexca[] ={
-1, 1,
	0, -1,
	-2, 0,
	};
# define YYNPROD 33
# define YYLAST 291
short yyact[]={

  34,  45,  35,  23,  21,  43,  27,  28,   4,  34,
  16,  32,  41,  21,  46,  27,  28,  10,  34,  16,
  32,   8,  21,   9,  27,  28,  25,  29,  16,   6,
   7,   3,  24,  34,  27,  28,  29,  21,  11,  27,
  28,   2,   5,  16,   1,  29,  21,   0,  27,  28,
   0,   0,  16,   0,   0,  29,  21,   0,  20,   0,
  29,   0,  16,   0,   0,  21,   0,  20,   0,  29,
   0,  16,   0,   0,  31,   0,  20,   0,   0,   0,
  12,   0,   0,  12,   0,   0,   0,   0,  30,   0,
   0,  20,   0,  42,  36,  37,  38,  30,   0,   0,
   0,   0,   0,   0,   0,  39,  30,  40,   0,   0,
  20,   0,   0,   0,   0,   0,   0,   0,   0,  20,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,  44,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,  14,  17,  18,  15,   0,  19,  33,   0,  22,
  14,  17,  18,  15,   0,  19,  33,  26,  22,  14,
  17,  18,  15,   0,   0,  33,   0,  22,   0,   0,
   0,   0,   0,   0,  14,  17,  18,  15,   0,   0,
  33,   0,  22,  14,  17,  18,  15,   0,   0,  33,
   0,  22,  13,  14,  17,  18,  15,   7,  19,   0,
   0,  22,  14,  17,  18,  15,   0,  19,   0,   0,
  22 };
short yypact[]={

-248,-1000,-1000,-231,-1000,  16,-257,-1000,  16,-1000,
-1000,-1000, -27,-262,-1000,-1000,-1000,-1000,-1000,  25,
  25,  25,-1000,-1000,-1000,-1000,-1000,-1000,-1000,-1000,
  25,  -8,  25, -32,-1000,-1000, -18,   6, -36,  -3,
 -18,-124,-1000,-1000,-111,-1000,-1000 };
short yypgo[]={

   0,  44,  41,  31,  38,  21,  23,  17,  74 };
short yyr1[]={

   0,   1,   2,   2,   2,   6,   6,   3,   3,   4,
   5,   5,   7,   7,   8,   8,   8,   8,   8,   8,
   8,   8,   8,   8,   8,   8,   8,   8,   8,   8,
   8,   8,   8 };
short yyr2[]={

   0,   1,   4,   3,   1,   1,   0,   3,   0,   1,
   2,   1,   2,   2,   1,   1,   1,   1,   1,   2,
   2,   2,   3,   2,   3,   5,   3,   4,   2,   2,
   2,   3,   1 };
short yychk[]={

-1000,  -1,  -2,  -3, 256,  -4, 260, 261,  -5,  -6,
  -7,  -4,  -8, 256, 257, 260,  46, 258, 259, 262,
  94,  40, 265, 260,  -6,  -7, 264,  42,  43,  63,
 124,  -8,  47, 263,  36, 264,  -8,  -8,  -8,  -8,
  -8,  44, 125,  41, 263, 125, 125 };
short yydef[]={

   8,  -2,   1,   0,   4,   6,   0,   9,   6,   3,
  11,   5,   0,   0,  14,  15,  16,  17,  18,   0,
   0,   0,  32,   7,   2,  10,  12,  19,  20,  21,
   0,  23,   0,   0,  30,  13,  28,  29,   0,  22,
  24,   0,  26,  31,   0,  27,  25 };
#define YYFLAG   -1000
#define YYERROR  goto yyerrlab
#define YYACCEPT return(0)
#define YYABORT  return(1)

#ifdef YYDEBUGON
int     yydebug = 1;    /* @VG .  */
#define YYDEBUG
#else
# ifdef YYDEBUG
int     yydebug = 0;    /* 1   */
# endif
#endif

#ifdef YYVX      /*  YYV   */
YYSTYPE yyv[YYMAXDEPTH]; /*     */
#endif

int     yychar = -1;     /*    */
int     yynerrs = 0;     /*   */
short   yyerrflag = 0;   /*     */

yyparse()
{
	short             yys[YYMAXDEPTH];
#ifndef YYVX
	YYSTYPE yyv[YYMAXDEPTH];   /*     */
#endif
	short             yyj, yym;
	register YYSTYPE *yypvt;
	register short    yystate, *yyps, yyn;
	register YYSTYPE *yypv;
	register short   *yyxi;

	yystate   = 0;
	yychar    = -1;
	yynerrs   = 0;
	yyerrflag = 0;
	yyps = &yys[-1];
	yypv = &yyv[-1];

    yystack:    /*       */

#ifdef YYDEBUG
	if( yydebug  ) printf("state %d, char %d\n":,
			       yystate, yychar );
#endif
	if( ++yyps > &yys[YYMAXDEPTH] ) {
		yyerror("yacc stack overflow");
		return(1);
	}
	*yyps = yystate;
	++yypv;
	*yypv = yyval;

    yynewstate:
	yyn = yypact[yystate];
	if( yyn <= YYFLAG )
		goto yydefault; /*   */

	if( yychar < 0 )
		if( (yychar = yylex()) < 0 )
			yychar = 0;
	if( (yyn += yychar) < 0 || yyn >= YYLAST )
		goto yydefault;

	if( yychk[yyn = yyact[yyn]] == yychar ) { /*   */
		yychar  = -1;
		yyval   = yylval;
		yystate = yyn;
		if( yyerrflag > 0 )
			--yyerrflag;
		goto yystack;
	}

    yydefault:  /*    */

	if( (yyn = yydef[yystate]) == -2 ) {
		if( yychar < 0 )
			if( (yychar = yylex()) < 0 )
				yychar = 0;

		/*    */

		for( yyxi = yyexca ; (*yyxi != (-1)) || (yyxi[1] != yystate) ;
								   yyxi += 2 )
			/*    */;

		while( *(yyxi += 2) >= 0 ) {
			if( *yyxi == yychar )
				break;
		}
		if( (yyn = yyxi[1]) < 0 )
			return(0);   /*  */
	}

	if( yyn == 0 ) {        /*  */

		/*  ...    */

		switch( yyerrflag ) {
		    case 0:     /*    */

			yyerror("syntax error");
		    yyerrlab:
			++yynerrs;

		    case 1:
		    case 2: /*     ...
					         */

			yyerrflag = 3;

			/*       "error" */

			while ( yyps >= yys ) {
				yyn = yypact[*yyps] + YYERRCODE;
				if( yyn >= 0 &&
				    yyn < YYLAST &&
				    yychk[yyact[yyn]] == YYERRCODE ) {

					/*    "error" */
					yystate = yyact[yyn];
					goto yystack;
				}
				yyn = yypact[*yyps];

		 /*   yyps    "error",    */

#ifdef YYDEBUG
				if( yydebug )
    printf("error recovery pops state %d, uncovers %d\n",
						*yyps, yyps[-1] );
#endif
				--yyps;
				--yypv;
			}

		/*         ...  */

		    yyabort:
			return(1);

		    case 3:  /*   ;   */

#ifdef YYDEBUG
			if( yydebug )
		printf("error recovery discards char %d\n",
					 yychar );
#endif

			if( yychar == 0 )
				goto yyabort; /*   EOF,  */
			yychar = -1;
			goto yynewstate;   /*        */
		}
	}

	/*   yyn */

#ifdef YYDEBUG
	if( yydebug )
		printf("reduce %d\n", yyn );
#endif
	yyps -= yyr2[yyn];
	yypvt = yypv;
	yypv -= yyr2[yyn];
	yyval = yypv[1];
	yym = yyn;

	/*       .  */
	yyn = yyr1[yyn];
	yyj = yypgo[yyn] + *yyps + 1;
	if( yyj >= YYLAST || yychk[yystate = yyact[yyj]] != -yyn )
		yystate = yyact[yypgo[yyn]];
	switch(yym){
		
case 1:
# line 24 "parser.y"
{
#ifdef DEBUG
		if( debug )
			sect2dump();
#endif DEBUG
	} break;
case 3:
# line 33 "parser.y"
{
		if( !funcflag )
			phead2();
		funcflag = TRUE;
	} break;
case 4:
# line 39 "parser.y"
{
#ifdef DEBUG
		if( debug ){
			sect1dump();
			sect2dump();
		}
#endif DEBUG
	} break;
case 7:
# line 50 "parser.y"
{      scopy( yypvt[-1], dp );
		def[dptr] = dp;
		dp += slength( yypvt[-1] ) + 1;
		scopy( yypvt[-0], dp );
		subs[dptr++] = dp;
		if( dptr >= DEFSIZE )
			error( "Too many definitions", "  " );
		dp += slength( yypvt[-0] ) + 1;
		if( dp >= dchar + DEFCHAR )
			error( "Definitions too long", "  " );
		subs[dptr] = def[dptr] = 0; /* for lookup - require ending null */
	} break;
case 9:
# line 65 "parser.y"
{
#ifdef DEBUG
		if( sect == DEFSECTION && debug )
			sect1dump();
#endif DEBUG
		sect++;
	} break;
case 10:
# line 74 "parser.y"
{      yyval = mn2( RNEWE, yypvt[-1], yypvt[-0] );
	} break;
case 11:
# line 77 "parser.y"
{      yyval = yypvt[-0];
	} break;
case 12:
# line 81 "parser.y"
{
		if( divflg == TRUE )
			i = mn1( S1FINAL, casecount );
		else
			i = mn1( FINAL, casecount );
		yyval = mn2( RCAT, yypvt[-1], i );
		divflg = FALSE;
		casecount++;
	} break;
case 13:
# line 91 "parser.y"
{
#ifdef DEBUG
		if( debug )
			sect2dump();
#endif
	} break;
case 14:
# line 98 "parser.y"
{      yyval = mn0( yypvt[-0] );
	} break;
case 15:
# line 101 "parser.y"
{
		p = yypvt[-0];
		i = mn0( C(*p++) );
		while( *p )
			i = mn2( RSTR, i, C(*p++) );
		yyval = i;
	} break;
case 16:
# line 109 "parser.y"
{      symbol[C('\n')] = 0;
		if( psave == FALSE ){
			p = ccptr;
			psave = ccptr;
			for( i = 1; i < '\n'; i++ ){
				symbol[C(i)] = 1;
				*ccptr++ = i;
			}
			for( i = '\n' + 1; i < NCH; i++ ){
				symbol[C(i)] = 1;
				*ccptr++ = i;
			}
			*ccptr++ = 0;
			if( ccptr > ccl + CCLSIZE ){
				error( "Many long char classes", "   " );
			}
		}else{
			p = psave;
		}
		yyval = mn1( RCCL, p );
		cclinter( 1 );
	} break;
case 17:
# line 132 "parser.y"
{      yyval = mn1( RCCL, yypvt[-0] );
	} break;
case 18:
# line 135 "parser.y"
{      yyval = mn1( RNCCL, yypvt[-0] );
	} break;
case 19:
# line 138 "parser.y"
{      yyval = mn1( STAR, yypvt[-1] );
	} break;
case 20:
# line 141 "parser.y"
{      yyval = mn1( PLUS, yypvt[-1] );
	} break;
case 21:
# line 144 "parser.y"
{      yyval = mn1( QUEST, yypvt[-1] );
	} break;
case 22:
# line 147 "parser.y"
{      yyval = mn2( BAR, yypvt[-2], yypvt[-0] );
	} break;
case 23:
# line 150 "parser.y"
{      yyval = mn2( RCAT, yypvt[-1], yypvt[-0] );
	} break;
case 24:
# line 153 "parser.y"
{      if( !divflg ){
			j = mn1( S2FINAL, -casecount );
			i = mn2( RCAT, yypvt[-2], j );
			yyval = mn2( DIV, i, yypvt[-0] );
		}else{
			yyval = mn2( RCAT, yypvt[-2], yypvt[-0] );
			warning( "External '/' removed", " '/' " );
		}
		divflg = TRUE;
	} break;
case 25:
# line 164 "parser.y"
{      if( yypvt[-3] > yypvt[-1] ){
			i = yypvt[-3];
			yypvt[-3] = yypvt[-1];
			yypvt[-1] = i;
		}
		if( yypvt[-1] <= 0 ){
			warning( "Iteration range must be >0", "    >0" );
		}else{
			j = yypvt[-4];
			for( k = 2; k <= yypvt[-3]; k++ )
				j = mn2( RCAT, j, dupl( yypvt[-4] ) );
			for( i = yypvt[-3] + 1; i <= yypvt[-1]; i++ ){
				g = dupl( yypvt[-4] );
				for( k = 2; k <= i; k++ )
					g = mn2( RCAT, g, dupl( yypvt[-4] ) );
				j = mn2( BAR, j, g );
			}
			yyval = j;
		}
	} break;
case 26:
# line 185 "parser.y"
{
		if( yypvt[-1] < 0 ){
			warning( "Must be positive iteration", "  " );
		}else if( yypvt[-1] == 0 ){
			yyval = mn0( RNULLS );
		}else{
			j = yypvt[-2];
			for( k = 2; k <= yypvt[-1]; k++ )
				j = mn2( RCAT, j, dupl( yypvt[-2] ) );
			yyval = j;
		}
	} break;
case 27:
# line 198 "parser.y"
{
				/* from n to infinity */
		if( yypvt[-2] < 0 ){
			warning( "Must be positive iteration", "  " );
		}else if( yypvt[-2] == 0 ){
			yyval = mn1( STAR, yypvt[-3] );
		}else if( yypvt[-2] == 1 ){
			yyval = mn1( PLUS, yypvt[-3] );
		}else{          /* >= 2 iterations minimum */
			j = yypvt[-3];
			for( k = 2; k < yypvt[-2]; k++ )
				j = mn2( RCAT, j, dupl( yypvt[-3] ) );
			k = mn1( PLUS, dupl( yypvt[-3] ) );
			yyval = mn2( RCAT, j, k );
		}
	} break;
case 28:
# line 215 "parser.y"
{      yyval = mn2( RSCON, yypvt[-0], yypvt[-1] );
	} break;
case 29:
# line 218 "parser.y"
{      yyval = mn1( CARAT, yypvt[-0] );
	} break;
case 30:
# line 221 "parser.y"
{      i = mn0( '\n' );
		if( !divflg ){
			j = mn1( S2FINAL, -casecount );
			k = mn2( RCAT, yypvt[-1], j );
			yyval = mn2( DIV, k, i );
		}else
			yyval = mn2( RCAT, yypvt[-1], i );
		divflg = TRUE;
	} break;
case 31:
# line 231 "parser.y"
{      yyval = yypvt[-1];
	} break;
case 32:
# line 234 "parser.y"
{      yyval = mn0( RNULLS );
	} break;
	}
	goto yystack;  /*        */
}
