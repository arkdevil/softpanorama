#include "ldefs.h"

cfoll( v )
int      v;
{
	register int     i;
	register int     j;
	register int     k;
		 char   *p;

	i = name[v];
	if( i < NCH ){
		i = 1;      /* character */
	}
	switch( i ){
	  case 1:
	  case RSTR:
	  case RCCL:
	  case RNCCL:
	  case RNULLS:
			for( j = 0; j < tptr; j++ ){
				tmpstat[j] = FALSE;
			}
			count = 0;
			follow( v );
#ifdef PP
			padd( foll, v );           /* packing version */
#else
			add( foll, v );            /* no packing version */
#endif PP
			if( i == RSTR ){
				cfoll( left[v] );
			}else if( i == RCCL || i == RNCCL ){       /* compress ccl list */
				for( j = 1; j < NCH; j++ )
					symbol[C(j)] = ( i == RNCCL );
				p = left[v];
				while( *p )
					symbol[C(*p++)] = ( i == RCCL );
				p = pcptr;
				for( j = 1; j < NCH; j++ )
					if( symbol[C(j)] ){
						for( k = 0; p + k < pcptr; k++ )
							if( cindex[C(j)] == *( p + k ) )
								break;
						if( p + k >= pcptr )
							*pcptr++ = cindex[C(j)];
					}
				*pcptr++ = 0;
				if( pcptr > pchar + pchlen )
					error( "Too many packed char classes (%%k)",
					       "     (%%k)" );
				left[v] = p;
				name[v] = RCCL; /* RNCCL eliminated */
#ifdef DEBUG
				if( debug && *p ){
					printf( "ccl %d: %d", v, *p++ );
					while( *p )
						printf( ", %d", *p++ );
					putchar( '\n' );
				}
#endif
			}
			break;
	  case CARAT:
			cfoll( left[v] );
			break;
	  case STAR:
	  case PLUS:
	  case QUEST:
	  case RSCON:
			cfoll( left[v] );
			break;
	  case BAR:
	  case RCAT:
	  case DIV:
	  case RNEWE:
			cfoll( left[v] );
			cfoll( right[v] );
			break;
#ifdef DEBUG
	  case FINAL:
	  case S1FINAL:
	  case S2FINAL:
			break;
	  default:
			warning( "bad switch cfoll %d"," switch cfoll %d", v );
#endif
	}
	return;
}

#ifdef DEBUG
pfoll()
{
	register int     i;
	register int     k;
	register int    *p;
		 int     j;

	/* print sets of chars which may follow positions */
	printf( "pos\tchars\n" );
	for( i = 0; i < tptr; i++ )
		if( p = foll[i] ){
			j = *p++;
			if( j >= 1 ){
				printf( "%d:\t%d", i, *p++ );
				for( k = 2; k <= j; k++ )
					printf( ", %d", *p++ );
				putchar( '\n' );
			}
		}
	return;
}
#endif DEBUG

add( array, n )
int    **array;
int      n;
{
	register int     i;
	register int    *temp;
	register char   *ctemp;

	temp = nxtpos;
	ctemp = tmpstat;
	array[n] = nxtpos;              /* note no packing is done in positions */
	*temp++ = count;
	for( i = 0; i < tptr; i++ )
		if( ctemp[i] == TRUE )
			*temp++ = i;
	nxtpos = temp;
	if( nxtpos >= positions + maxpos )
		error( "Too many positions (%%p)", "   (%%p)" );
	return;
}

follow( v )
int      v;
{
	register int     p;

	if( v >= tptr-1 )
		return;
	p = parent[v];
	if( p == 0 )
		return;
	switch( name[p] ){
			/* will not be CHAR RNULLS FINAL S1FINAL S2FINAL RCCL RNCCL */
	  case RSTR:
			if( tmpstat[p] == FALSE ){
				count++;
				tmpstat[p] = TRUE;
			}
			break;
	  case STAR:
	  case PLUS:
			first( v );
			follow( p );
			break;
	  case BAR:
	  case QUEST:
	  case RNEWE:
			follow( p );
			break;
	  case RCAT:
	  case DIV:
			if( v == left[p] ){
				if( nullstr[right[p]] )
					follow( p );
				first( right[p] );
			}else
				follow( p );
			break;
	  case RSCON:
	  case CARAT:
			follow( p );
			break;
#ifdef DEBUG
	  default:
			warning( "bad switch follow %d", " switch follow %d", p );
#endif DEBUG
	}
	return;
}

first( v )        /* calculate set of positions with v as root which can be active initially */
int      v;
{
	register int     i;
	register char   *p;

	i = name[v];
	if( i < NCH )
		i = 1;
	switch( i ){
	  case 1:
	  case RCCL:
	  case RNCCL:
	  case RNULLS:
	  case FINAL:
	  case S1FINAL:
	  case S2FINAL:
			if( tmpstat[v] == FALSE ){
				count++;
				tmpstat[v] = TRUE;
			}
			break;
	  case BAR:
	  case RNEWE:
			first( left[v] );
			first( right[v] );
			break;
	  case CARAT:
			if( stnum % 2 == 1 )
				first( left[v] );
			break;
	  case RSCON:
			i = stnum/2 +1;
			p = right[v];
			while( *p )
				if( *p++ == i ){
					first( left[v] );
					break;
				}
			break;
	  case STAR:
	  case QUEST:
	  case PLUS:
	  case RSTR:
			first( left[v] );
			break;
	  case RCAT:
	  case DIV:
			first( left[v] );
			if( nullstr[left[v]] )
				first( right[v] );
			break;
#ifdef DEBUG
	  default:
			warning( "bad switch first %d", " switch first %d", v );
#endif DEBUG
	}
	return;
}

cgoto()
{
	register int     i;
	register int     j;
	register int     s;
		 int     npos;
		 int     curpos;
		 int     n;
		 int     tryit;
		 char    tch[NCH];
		 int     tst[NCH];
		 char   *q;

	/* generate initial state, for each start condition */
	fprintf( fout, "int yyvstop[] ={\n0,\n" );
	while( stnum < 2 || stnum/2 < sptr ){
		for( i = 0; i < tptr; i++ )
			tmpstat[i] = 0;
		count = 0;
		if( tptr > 0 )
			first( tptr - 1 );
		add( state, stnum );
#ifdef DEBUG
		if( debug ){
			if( stnum > 1 )
				printf( "%s:\n", sname[stnum/2] );
			pstate( stnum );
		}
#endif DEBUG
		stnum++;
	}
	stnum--;
	/* even stnum = might not be at line begin */
	/* odd stnum  = must be at line begin */
	/* even states can occur anywhere, odd states only at line begin */
	for( s = 0; s <= stnum; s++ ){
		tryit = FALSE;
		cpackflg[s] = FALSE;
		sfall[s] = -1;
		acompute( s );
		for( i = 0; i < NCH; i++ )
			symbol[C(i)] = 0;
		npos = *state[s];
		for( i = 1; i <= npos; i++ ){
			curpos = *( state[s] + i );
			if( name[curpos] < NCH ){
				symbol[C(name[curpos])] = TRUE;
			}else{
				switch( name[curpos] ){
				  case RCCL:
						tryit = TRUE;
						q = left[curpos];
						while( *q ){
							for( j = 1; j < NCH; j++ )
								if( cindex[C(j)] == *q )
									symbol[C(j)] = TRUE;
							q++;
						}
						break;
				  case RSTR:
						symbol[C(right[curpos])] = TRUE;
						break;
#ifdef DEBUG
				  case RNULLS:
				  case FINAL:
				  case S1FINAL:
				  case S2FINAL:
						break;
				  default:
						warning( "bad switch cgoto %d state %d", " switch cgoto %d  %d", curpos, s );
						break;
#endif DEBUG
				}
			}
		}
#ifdef DEBUG
		if( debug ){
			printf( ediag("State %d jumps to:\n\t",
				      " %d   :\n\t"), s );
			charc = 0;
			for( i = 1; i < NCH; i++ ){
				if( symbol[C(i)] )
					allprint( i );
				if( charc > LINESIZE ){
					charc = 0;
					printf( "\n\t" );
				}
			}
			putchar( '\n' );
		}
#endif DEBUG
		/* for each char, calculate next state */
		n = 0;
		for( i = 1; i < NCH; i++ ){
			if( symbol[C(i)] ){
				nextstate( s, i );         /* executed for each state, transition pair */
				xstate = notin( stnum );
				if( xstate == -2 )
					warning( "bad state %d %o", "  %d %o", s, i );
				else if( xstate == -1 ){
					if( stnum >= nstates )
						error( "Too many states (%%n)",
						       "   (%%n)" );
					add( state, ++stnum );
#ifdef DEBUG
					if( debug )
						pstate( stnum );
#endif DEBUG
					tch[C(n)] = i;
					tst[C(n++)] = stnum;
				}else{          /* xstate >= 0 ==> state exists */
					tch[C(n)] = i;
					tst[C(n++)] = xstate;
				}
			}
		}
		tch[C(n)] = 0;
		tst[C(n)] = -1;
		/* pack transitions into permanent array */
		if( n > 0 )
			packtrans( s, tch, tst, n, tryit );
		else
			gotof[s] = -1;
	}
	fprintf( fout, "0};\n" );
	return;
}
	/*      Beware -- 70% of total CPU time is spent in this subroutine -
		if you don't believe me - try it yourself ! */
nextstate( s, c )
int      s;
int      c;
{
	register int     j;
	register int    *newpos;
	register char   *temp;
	register char   *tz;
		 int    *pos;
		 int     i;
		 int    *f;
		 int     num;
		 int     curpos;
		 int     number;

	c = C(c);

	/* state to goto from state s on char c */
	num = *state[s];
	temp = tmpstat;
	pos = state[s] + 1;
	for( i = 0; i < num; i++ ){
		curpos = *pos++;
		j = name[curpos];
#ifdef DEBUG
		if( debug )
			printf( "nextstate: i=%d j=%o c=%o curpos=%d\n", i, j, c, curpos );
#endif
		if( j  < NCH  && j == c ||
		    j == RSTR && c == right[curpos] ||
		    j == RCCL && member( c, left[curpos] ) ){
#ifdef DEBUG
			if( debug )
				printf( "OK\n" );
#endif
			f = foll[curpos];
			number = *f;
			newpos = f+1;
			for( j = 0; j < number; j++ )
				temp[*newpos++] = 2;
		}
	}
	j = 0;
	tz = temp + tptr;
	while( temp < tz ){
		if( *temp == 2 ){
			j++;
			*temp++ = 1;
		}else
			*temp++ = 0;
	}
	count = j;
	return;
}

notin( n )    /* see if tmpstat occurs previously */
int      n;
{
	register int    *j;
	register int     k;
	register char   *temp;
		 int     i;

	if( count == 0 )
		return( -2 );
	temp = tmpstat;
	for( i = n; i >= 0; i-- ){      /* for each state */
		j = state[i];
		if( count == *j++ ){
			for( k = 0; k < count; k++ )
				if( !temp[*j++] )
					break;
			if( k >= count )
				return( i );
		}
	}
	return( -1 );
}

packtrans( st, tch, tst, cnt, tryit )
int      st;
char     tch[NCH];
int      tst[NCH];
int      cnt;
int      tryit;
{
	/* pack transitions into nchar, nexts */
	/* nchar is terminated by '\0', nexts uses cnt, followed by elements */
	/* gotof[st] = index into nchr, nexts for state st */

	/* sfall[st] =  t implies t is fall back state for st */
	/*              == -1 implies no fall back */

	int cmin, cval, tcnt, diff, p, *ast;
	register int i,j,k;
	char *ach;
	int go[NCH], temp[NCH], c;
	int swork[NCH];
	char cwork[NCH];
	int upper;

	rcount += cnt;
	cmin = -1;
	cval = NCH;
	ast = tst;
	ach = tch;
	/* try to pack transitions using ccl's */
	if( !optim )
		goto nopack;          /* skip all compaction */
	if( tryit ){      /* ccl's used */
		for( i = 1; i < NCH; i++ ){
			go[C(i)] = temp[C(i)] = -1;
			symbol[C(i)] = 1;
		}
		for( i = 0; i < cnt; i++ ){
			go[C(tch[C(i)])] = tst[C(i)];
			symbol[C(tch[C(i)])] = 0;
		}
		for( i = 0; i < cnt; i++ ){
			c = U(match[C(tch[C(i)])]);
			if( go[C(c)] != tst[C(i)] || c == U(tch[C(i)]) )
				temp[C(tch[C(i)])] = tst[C(i)];
		}
		/* fill in error entries */
		for( i = 1; i < NCH; i++ )
			if( symbol[C(i)] )
				temp[C(i)] = -2;     /* error trans */
		/* count them */
		k = 0;
		for( i = 1; i < NCH; i++ )
			if( temp[C(i)] != -1 )
				k++;
		if( k < cnt ){     /* compress by char */
#ifdef DEBUG
			if( debug )
				printf( ediag( "used compression %d,  %d vs %d\n",
					       ".   %d,  %d vs %d\n"), st, k, cnt );
#endif DEBUG
			k = 0;
			for( i = 1; i < NCH; i++ )
				if( temp[C(i)] != -1 ){
					cwork[C(k)] = i;
					swork[C(k++)] = ( temp[C(i)] == -2 ? -1 : temp[C(i)] );
				}
			cwork[C(k)] = 0;
#ifdef PC
			ach = cwork;
			ast = swork;
			cnt = k;
			cpackflg[st] = TRUE;
#endif PC
		}
	}
	for( i = 0; i < st; i++ ){    /* get most similar state */
				/* reject state with more transitions, state already represented by a third state,
					and state which is compressed by char if ours is not to be */
		/* if( sfall[i] != -1 ) continue;
		   if( cpackflg[st] == 1 ) if( !( cpackflg[i] == 1 ) ) continue; */
		if( sfall[i] != -1 || ( cpackflg[st] == 1 && cpackflg[i] != 1 ) ){
			continue;
		}
		p = gotof[i];
		if( p == -1 ) /* no transitions */
			continue;
		tcnt = nexts[p];
		if( tcnt > cnt )
			continue;
		diff = 0;
		k = 0;
		j = 0;
		upper = p + tcnt;
		while( ach[C(j)] && p < upper ){
			while( U(ach[C(j)]) < U(nchar[p]) && ach[C(j)] ){
				diff++;
				j++;
			}
			if( ach[C(j)] == 0 )
				break;
			if( U(ach[C(j)]) > U(nchar[p]) ){
				diff = NCH;
				break;
			}
			/* ach[j] == nchar[p] */
			if( ast[C(j)] != nexts[++p] || ast[C(j)] == -1 || ( cpackflg[st] && ach[C(j)] != match[C(ach[C(j)])] ) )
				diff++;
			j++;
		}
		while( ach[C(j)] ){
			diff++;
			j++;
		}
		if( p < upper )
			diff = NCH;
		if( diff < cval && diff < tcnt ){
			cval = diff;
			cmin = i;
			if( cval == 0 )
				break;
		}
	}
	/* cmin = state "most like" state st */
#ifdef DEBUG
	if( debug )
		printf( ediag( "case st %d for st %d diff %d\n",
			       " st %d  st %d  %d\n"), cmin, st, cval );
#endif DEBUG
#ifdef PS
	if( cmin != -1 ){ /* if we can use st cmin */
		gotof[st] = nptr;
		k = 0;
		sfall[st] = cmin;
		p = gotof[cmin]+1;
		j = 0;
		while( ach[C(j)] ){
			/* if cmin has a transition on c, then so will st */
			/* st may be "larger" than cmin, however */
			while( U(ach[C(j)]) < U(nchar[p-1]) && ach[C(j)] ){
				k++;
				nchar[nptr] = ach[C(j)];
				nexts[++nptr] = ast[C(j)];
				j++;
			}
			if( nchar[p-1] == 0 )
				break;
			if( U(ach[C(j)]) > U(nchar[p-1]) ){
				warning( "bad jump %d %d", "  %d %d", st, cmin );
				goto nopack;
			}
			/* ach[j] == nchar[p-1] */
			if( ast[C(j)] != nexts[p] || ast[C(j)] == -1 || ( cpackflg[st] && ach[C(j)] != match[C(ach[C(j)])] ) ){
				k++;
				nchar[nptr] = ach[C(j)];
				nexts[++nptr] = ast[C(j)];
			}
			p++;
			j++;
		}
		while( ach[C(j)] ){
			nchar[nptr] = ach[C(j)];
			nexts[++nptr] = ast[C(j++)];
			k++;
		}
		nexts[gotof[st]] = cnt = k;
		nchar[nptr++] = 0;
	}else{
#endif PS
nopack:
	/* stick it in */
		gotof[st] = nptr;
		nexts[nptr] = cnt;
		for( i = 0; i < cnt; i++ ){
			nchar[nptr] = ach[C(i)];
			nexts[++nptr] = ast[C(i)];
		}
		nchar[nptr++] = 0;
#ifdef PS
	}
#endif PS
	if( cnt < 1 ){
		gotof[st] = -1;
		nptr--;
	}else
		if( nptr > ntrans )
			error( "Too many jumps (%%a)",
			       "   (%%a)" );
	return;
}

#ifdef DEBUG
pstate( s )
int      s;
{
	register int    *p;
	register int     i;
	register int     j;

	printf( ediag( "State %d:\n"," %d:\n"), s );
	p = state[s];
	i = *p++;
	if( i == 0 )
		return;
	printf( "%4d", *p++ );
	for( j = 1; j < i; j++ ){
		printf( ", %4d", *p++ );
		if( j%30 == 0 )
			putchar( '\n' );
	}
	putchar( '\n' );
	return;
}
#endif DEBUG

member( d, t )
int      d;
char    *t;
{
	register int     c;
	register char   *s;

	c = d;
	s = t;
	c = U(cindex[C(c)]);
	while( *s )
		if( *s++ == c )
			return( 1 );
	return( 0 );
}

#ifdef DEBUG
stprt( i )
int      i;
{
	register int     p;
	register int     t;

	printf( ediag("State %d:"," %d:"), i );
	/* print actions, if any */
	t = atable[i];
	if( t != -1 )
		printf( ediag(" end"," ") );
	putchar( '\n' );
	if( cpackflg[i] == TRUE )
		printf( ediag("back char\n",
			      "   \n") );
	if( sfall[i] != -1 )
		printf( ediag("can't back state %d\n",
			      "   %d\n"), sfall[i] );
	p = gotof[i];
	if( p == -1 )
		return;
	printf( ediag("(%d jumps)\n", "(%d )\n"), nexts[p] );
	while( nchar[p] ){
		charc = 0;
		if( nexts[p+1] >= 0 )
			printf( "%d\t", nexts[p+1] );
		else
			printf( "err\t" );
		allprint( nchar[p++] );
		while( nexts[p] == nexts[p+1] && nchar[p] ){
			if( charc > LINESIZE ){
				charc = 0;
				printf( "\n\t" );
			}
			allprint( nchar[p++] );
		}
		putchar( '\n' );
	}
	putchar( '\n' );
	return;
}
#endif DEBUG

acompute( s )     /* compute action list = set of poss. actions */
int      s;
{
	register int    *p;
	register int     i;
	register int     j;
		 int     cnt;
		 int     m;
		 int     temp[300];
		 int     k;
		 int     neg[300];
		 int     n;

	k = 0;
	n = 0;
	p = state[s];
	cnt = *p++;
	if( cnt > 300 )
		error( "Too many positions for  one state",
		       "     " );
	for( i = 0; i < cnt; i++ ){
		if( name[*p] == FINAL )
			temp[k++] = left[*p];
		else if( name[*p] == S1FINAL ){
			temp[k++] = left[*p];
			if( left[*p] > NACTIONS )
				error( "Too many right contexts",
				       "   " );
			extra[left[*p]] = 1;
		}else if( name[*p] == S2FINAL )
			neg[n++] = left[*p];
		p++;
	}
	atable[s] = -1;
	if( k < 1 && n < 1 )
		return;
#ifdef DEBUG
	if( debug )
		printf( ediag( "end %d actions", " %d :"), s );
#endif DEBUG
	/* sort action list */
	for( i = 0; i < k; i++ )
		for( j = i + 1; j < k; j++ )
			if( temp[j] < temp[i] ){
				m = temp[j];
				temp[j] = temp[i];
				temp[i] = m;
			}
	/* remove dups */
	for( i = 0; i < k-1; i++ )
		if( temp[i] == temp[i+1] )
			temp[i] = 0;
	/* copy to permanent quarters */
	atable[s] = aptr;
#ifdef DEBUG
	fprintf( fout, ediag("/* actions for state %d */",
			     "/*    %d */"), s );
#endif DEBUG
	putc( '\n', fout );
	for( i = 0; i < k; i++ )
		if( temp[i] != 0 ){
			fprintf( fout, "%d,\n", temp[i] );
#ifdef DEBUG
			if( debug )
				printf( "%d ", temp[i] );
#endif DEBUG
			aptr++;
		}
	for( i = 0; i < n; i++ ){               /* copy fall back actions - all neg */
		fprintf( fout, "%d,\n", neg[i] );
		aptr++;
#ifdef DEBUG
		if( debug )
			printf( "%d ", neg[i] );
#endif DEBUG
	}
#ifdef DEBUG
	if( debug )
		putchar( '\n' );
#endif DEBUG
	fprintf( fout, "0,\n" );
	aptr++;
	return;
}

#ifdef DEBUG
pccl()
{
	/* print character class sets */
	register int     i;
	register int     j;

	printf( ediag( "char classes overlap\n","  \n") );
	for( i = 0; i < ccount; i++ ){
		charc = 0;
		printf( ediag( "class %d:\n\t"," %d:\n\t"), i );
		for( j = 1; j < NCH; j++ )
			if( cindex[C(j)] == i ){
				allprint( j );
				if( charc > LINESIZE ){
					printf( "\n\t" );
					charc = 0;
				}
			}
		putchar( '\n' );
	}
	charc = 0;
	printf( ediag("found:\n", ":\n") );
	for( i = 0; i < NCH; i++ ){
		allprint( match[C(i)] );
		if( charc > LINESIZE ){
			putchar( '\n' );
			charc = 0;
		}
	}
	putchar( '\n' );
	return;
}
#endif DEBUG

mkmatch()
{
	register int     i;
		 char    tab[NCH];

	for( i = 0; i < ccount; i++ )
		tab[C(i)] = 0;
	for( i = 1; i < NCH; i++ )
		if( tab[C(cindex[C(i)])] == 0 )
			tab[C(cindex[C(i)])] = i;
	/* tab[i] = principal char for new ccl i */
	for( i = 1; i < NCH; i++ )
		match[C(i)] = tab[C(cindex[C(i)])];
	return;
}

layout()
{
	/* format and output final program's tables */
	register int     i;
	register int     j;
	register int     k;
		 int     top;
		 int     bot;
		 int     startup;
		 int     omin;

	startup = 0;
	for( i = 0; i < outsize; i++ )
		verify[i] = advance[i] = 0;
	omin = 0;
	yytop = 0;
	for( i = 0; i <= stnum; i++ ){       /* for each state */
		j = gotof[i];
		if( j == -1 ){
			stoff[i] = 0;
			continue;
		}
		bot = j;
		while( nchar[j] )
			j++;
		top = j - 1;
#ifdef DEBUG
		if( debug ){
			printf( ediag( "State %d: (layout)\n"," %d: (layout)\n"), i );
			for( j = bot; j <= top; j++ ){
				printf( "  %o", nchar[j] );
				if( j%10 == 0 )
					putchar( '\n' );
			}
			putchar( '\n' );
		}
#endif DEBUG
		while( verify[omin+ZCH] )
			omin++;
		startup = omin;
#ifdef DEBUG
		if( debug )
			printf( "bot,top %d, %d startup begins %d\n", bot, top, startup );
#endif DEBUG
		if( chset ){
			do{
				startup += 1;
				if( startup > outsize - ZCH )
					error( "output table overflow",
					       "  " );
				for( j = bot; j <= top; j++ ){
					k = startup + ctable[U(nchar[j])];
					if( verify[k] )
						break;
				}
			}while( j <= top );
#ifdef DEBUG
			if( debug )
				printf( " startup will be %d\n", startup );
#endif DEBUG
			/* have found place */
			for( j = bot; j <= top; j++ ){
				k = startup + ctable[U(nchar[j])];
				if( ctable[U(nchar[j])] <= 0 )
					printf( "j %d nchar %d ctable.nch %d\n", j, U(nchar[j]), ctable[U(nchar[k])] );
				verify[k] = i+1;                        /* state number + 1*/
				advance[k] = nexts[j+1]+1;              /* state number + 1*/
				if( yytop < k )
					yytop = k;
			}
		}else{
			do{
				startup += 1;
				if( startup > outsize - ZCH )
					error( "output table overflow",
					       "  " );
				for( j = bot; j <= top; j++ ){
					k = startup + U(nchar[j]);
					if( verify[k] )
						break;
				}
			}while( j <= top );
			/* have found place */
#ifdef DEBUG
	if( debug )
		printf( " startup going to be %d\n", startup );
#endif DEBUG
			for( j = bot; j <= top; j++ ){
				k = startup + U(nchar[j]);
				verify[k] = i+1;          /* state number + 1*/
				advance[k] = nexts[j+1]+1;/* state number + 1*/
				if( yytop < k )
					yytop = k;
			}
		}
		stoff[i] = startup;
	}

	/* stoff[i] = offset into verify, advance for trans for state i */
	/* put out yywork */
	fprintf( fout, "#define YYTYPE %s\n", stnum+1 > NCH ? "int" : "char" );
	fprintf( fout, "struct yywork { YYTYPE verify, advance; } yycrank[] ={\n" );
	for( i = 0;i <= yytop; i += 4 ){
		for( j = 0; j < 4; j++ ){
			k = i + j;
			if( verify[k] )
				fprintf( fout, "%d,%d,\t", verify[k], advance[k] );
			else
				fprintf( fout, "0,0,\t" );
		}
		putc( '\n', fout );
	}
	fprintf( fout, "0,0};\n" );

	/* put out yysvec */

	fprintf( fout, "struct yysvf yysvec[] ={\n" );
	fprintf( fout, "0,\t0,\t0,\n" );
	for( i = 0; i <= stnum; i++ ){  /* for each state */
		if( cpackflg[i] )
			stoff[i] = -stoff[i];
		fprintf( fout, "yycrank+%d,\t", stoff[i] );
		if( sfall[i] != -1 )
			fprintf( fout, "yysvec+%d,\t", sfall[i] + 1 );       /* state + 1 */
		else
			fprintf( fout, "0,\t\t" );
		if( atable[i] != -1 )
			fprintf( fout, "yyvstop+%d,", atable[i] );
		else
			fprintf( fout, "0,\t" );
#ifdef DEBUG
		fprintf( fout, "\t\t/* state %d */", i );
#endif DEBUG
		putc( '\n', fout );
	}
	fprintf( fout, "0,\t0,\t0};\n" );

	/* put out yymatch */

	fprintf( fout, "struct yywork *yytop = yycrank+%d;\n", yytop );
	fprintf( fout, "struct yysvf *yybgin = yysvec+1;\n" );
	if( optim ){
		fprintf( fout, "char yymatch[] ={\n" );
		if( chset == 0 ){ /* no chset, put out in normal order */
			for( i = 0; i < NCH; i += 8 ){
				for( j = 0; j < 8; j++ ){
					int      fbch;

					fbch = U(match[C( i + j )]);
					if( printable( fbch ) && fbch != '\'' && fbch != '\\' )
						fprintf( fout, "'%c' ,", fbch );
					else
						fprintf( fout, "0%-3o,", fbch );
				}
				putc( '\n', fout );
			}
		}else{
			int *fbarr;

			fbarr = myalloc( 2*NCH, sizeof( *fbarr ) );
			if( fbarr == 0 )
				error( "No space for inverting char table",
				       "     ", 0 );
			for( i = 0; i < ZCH; i++ )
				fbarr[i] = 0;
			for( i = 0; i < NCH; i++ )
				fbarr[ctable[i]] = ctable[U(match[C(i)])];
			for( i = 0; i < ZCH; i += 8 ){
				for( j = 0; j < 8; j++ )
					fprintf( fout, "0%-3o,", fbarr[i+j] );
				putc( '\n', fout );
			}
			cfree( fbarr, 2*NCH, 1 );
		}
		fprintf( fout, "0};\n" );
	}
	/* put out yyextra */
	fprintf( fout, "char yyextra[] ={\n" );
	for( i = 0; i < casecount; i += 8 ){
		for( j = 0; j < 8; j++ )
			fprintf( fout, "%d,", i+j<NACTIONS ?
				extra[i+j] : 0 );
		putc( '\n', fout );
	}
	fprintf( fout, "0};\n" );
	return;
}

shiftr( a, n )
int     *a;
int      n;
{
	int      i;

	for( i = n; i >= 0; i-- )
		a[i+1] = a[i];
}

upone( a, n )
int     *a;
int      n;
{
	int      i;

	for( i = 0; i <= n ; i++ )
		a[i]++;
}

#ifdef PP
padd( array, n )
int    **array;
int      n;
{
	register int     i;
	register int    *j;
	register int     k;

	array[n] = nxtpos;
	if( count == 0 ){
		*nxtpos++ = 0;
		return;
	}
	for( i = tptr - 1; i >= 0; i-- ){
		j = array[i];
		if( j && *j++ == count ){
			for( k = 0; k < count; k++ )
				if( !tmpstat[*j++] )
					break;
			if( k >= count ){
				array[n] = array[i];
				return;
			}
		}
	}
	add( array, n );
	return;
}
#endif PP
