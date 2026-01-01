%token CHAR CCL NCCL STR DELIM SCON ITER NEWE NULLS
%left SCON '/' NEWE
%left '|'
%left '$' '^'
%left CHAR CCL NCCL '(' '.' STR NULLS
%left ITER
%left CAT
%left '*' '+' '?'

%{
#include "ldefs.h"
#define	error(x,y) Error(x)
#define warning(x,y) Warning(x)
%}
%%
%{
int      i;
int      j;
int      k;
int      g;
char    *p;
%}
acc     :       lexinput
	={
#ifdef DEBUG
		if( debug )
			sect2dump();
#endif DEBUG
	}
	;
lexinput:       defns delim prods end
	|       defns delim end
	={
		if( !funcflag )
			phead2();
		funcflag = TRUE;
	}
	| error
	={
#ifdef DEBUG
		if( debug ){
			sect1dump();
			sect2dump();
		}
#endif DEBUG
	}
	;
end:    delim | ;
defns:  defns STR STR
	={      scopy( $2, dp );
		def[dptr] = dp;
		dp += slength( $2 ) + 1;
		scopy( $3, dp );
		subs[dptr++] = dp;
		if( dptr >= DEFSIZE )
			error( "Too many definitions", "Слишком много определений" );
		dp += slength( $3 ) + 1;
		if( dp >= dchar + DEFCHAR )
			error( "Definitions too long", "Определения слишком длинные" );
		subs[dptr] = def[dptr] = 0; /* for lookup - require ending null */
	}
	|
	;
delim:  DELIM
	={
#ifdef DEBUG
		if( sect == DEFSECTION && debug )
			sect1dump();
#endif DEBUG
		sect++;
	}
	;
prods:  prods pr
	={      $$ = mn2( RNEWE, $1, $2 );
	}
	|       pr
	={      $$ = $1;
	}
	;
pr:     r NEWE
	={
		if( divflg == TRUE )
			i = mn1( S1FINAL, casecount );
		else
			i = mn1( FINAL, casecount );
		$$ = mn2( RCAT, $1, i );
		divflg = FALSE;
		casecount++;
	}
	| error NEWE
	={
#ifdef DEBUG
		if( debug )
			sect2dump();
#endif
	}
r:      CHAR
	={      $$ = mn0( $1 );
	}
	| STR
	={
		p = $1;
		i = mn0( C(*p++) );
		while( *p )
			i = mn2( RSTR, i, C(*p++) );
		$$ = i;
	}
	| '.'
	={      symbol[C('\n')] = 0;
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
				error( "Many long char classes", "Много длинных классов символов" );
			}
		}else{
			p = psave;
		}
		$$ = mn1( RCCL, p );
		cclinter( 1 );
	}
	| CCL
	={      $$ = mn1( RCCL, $1 );
	}
	| NCCL
	={      $$ = mn1( RNCCL, $1 );
	}
	| r '*'
	={      $$ = mn1( STAR, $1 );
	}
	| r '+'
	={      $$ = mn1( PLUS, $1 );
	}
	| r '?'
	={      $$ = mn1( QUEST, $1 );
	}
	| r '|' r
	={      $$ = mn2( BAR, $1, $3 );
	}
	| r r %prec CAT
	={      $$ = mn2( RCAT, $1, $2 );
	}
	| r '/' r
	={      if( !divflg ){
			j = mn1( S2FINAL, -casecount );
			i = mn2( RCAT, $1, j );
			$$ = mn2( DIV, i, $3 );
		}else{
			$$ = mn2( RCAT, $1, $3 );
			warning( "External '/' removed", "Внешний '/' удален" );
		}
		divflg = TRUE;
	}
	| r ITER ',' ITER '}'
	={      if( $2 > $4 ){
			i = $2;
			$2 = $4;
			$4 = i;
		}
		if( $4 <= 0 ){
			warning( "Iteration range must be >0", "Диапазон итерации должен быть >0" );
		}else{
			j = $1;
			for( k = 2; k <= $2; k++ )
				j = mn2( RCAT, j, dupl( $1 ) );
			for( i = $2 + 1; i <= $4; i++ ){
				g = dupl( $1 );
				for( k = 2; k <= i; k++ )
					g = mn2( RCAT, g, dupl( $1 ) );
				j = mn2( BAR, j, g );
			}
			$$ = j;
		}
	}
	| r ITER '}'
	={
		if( $2 < 0 ){
			warning( "Must be positive iteration", "Недопустимы негативные итерации" );
		}else if( $2 == 0 ){
			$$ = mn0( RNULLS );
		}else{
			j = $1;
			for( k = 2; k <= $2; k++ )
				j = mn2( RCAT, j, dupl( $1 ) );
			$$ = j;
		}
	}
	| r ITER ',' '}'
	={
				/* from n to infinity */
		if( $2 < 0 ){
			warning( "Must be positive iteration", "Недопустимы негативные итерации" );
		}else if( $2 == 0 ){
			$$ = mn1( STAR, $1 );
		}else if( $2 == 1 ){
			$$ = mn1( PLUS, $1 );
		}else{          /* >= 2 iterations minimum */
			j = $1;
			for( k = 2; k < $2; k++ )
				j = mn2( RCAT, j, dupl( $1 ) );
			k = mn1( PLUS, dupl( $1 ) );
			$$ = mn2( RCAT, j, k );
		}
	}
	| SCON r
	={      $$ = mn2( RSCON, $2, $1 );
	}
	| '^' r
	={      $$ = mn1( CARAT, $2 );
	}
	| r '$'
	={      i = mn0( '\n' );
		if( !divflg ){
			j = mn1( S2FINAL, -casecount );
			k = mn2( RCAT, $1, j );
			$$ = mn2( DIV, k, i );
		}else
			$$ = mn2( RCAT, $1, i );
		divflg = TRUE;
	}
	| '(' r ')'
	={      $$ = $2;
	}
	|       NULLS
	={      $$ = mn0( RNULLS );
	}
	;
%%
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
									error( "Not enough memory for parsing", "Мало памяти для дерева разбора" );
								p = c;
								cfree( p, i, 1 );
								name = myalloc( treesize, sizeof( *name ) );
								left = myalloc( treesize, sizeof( *left ) );
								right = myalloc( treesize, sizeof( *right ) );
								nullstr = myalloc( treesize, sizeof( *nullstr ) );
								parent = myalloc( treesize, sizeof( *parent ) );
								if( name == 0 || left == 0 || right == 0 || parent == 0 || nullstr == 0 )
									error( "Not enough memory for parsing", "Мало памяти для дерева разбора" );
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
										       "необходимо переопределение табл. символов");
								chset = TRUE;
								for(i = 0; i<ZCH; i++)
									ctable[i] = 0;
								while(getl(p) && scomp(p,"%T") != 0 && scomp(p,"%t") != 0 ){
									if((n = siconv(p)) <= 0 || n > ZCH){
										warning("Bad value of char %d", "Плохое значение символа %d",n);
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
													 "Символ '%c' использован дважды", c );
											else
												warning( "Char %3o used twice",
													 "Символ %3o использован дважды", c );
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
								error("Unexpected EOF", "Неожиданный EOF");
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
										      "Слишком много стартовых условиий");
									sp += slength(sp) + 1;
									if(sp >= schar+STARTCHAR)
										error("Start conditions too long",
										      "Стартовые условия слишком длинные");
								}
								continue;
						  default:
								warning("Illegal request %s",
									"Неправильный запрос %s",p);
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
								"Строки подстановки не могут начинаться с цифр");
						return(freturn(STR));
				}
			}else{       /* still sect 1, but prev != '\n' */
				p = bptr;
				while(*p && space(*p)) p++;
				if(*p == 0)
					warning("Translation not defined - empty string",
						"Не задана трансляция - пустая строка");
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
							 "Выполнимые операторы должны быть справа после %%" );
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
							warning( "Definition %s not found", "Определение %s не найдено", token );
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
							warning( "Undefined start condition %s", "Неопределенное стартовое условие %s", token );
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
						error( "Too many start conditions used", "Использовано слишком много стартовых условий" );
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
							warning( "String too long", "Слишком длинная строка" );
							i = TOKENSIZE-1;
							break;
						}
					}
					if( c == '\n' ){
						yyline--;
						warning( "Nonterminated string", "Незакрытая строка" );
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
								warning( "Inverted range", "Инвертированый диапазон" );
								n = j;
								j = k;
								k = n;
								symbol[C(j)] = 1;
							}
							if( !( ( 'A' <= j && k <= 'Z' ) ||
							       ( 'a' <= j && k <= 'z' ) ||
							       ( '0' <= j && k <= '9' )
#ifdef Ucode

							    || ( C('А')<=j && k<=C('Я') )
							    || ( C('а')<=j && k<=C('я') )
#endif
#ifdef KOI8
							    || ( 0300<=KtoU(j) && KtoU(k)<=0337 )
							    || ( 0340<=KtoU(j) && KtoU(k)<=0377 )
#endif
											   ) )

								warning( "Nonportable char class '%c'-'%c'", "Неперемещаемый класс символов '%c'-'%c'", j, k );
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
							       "Слишком большие классы символов" );
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
