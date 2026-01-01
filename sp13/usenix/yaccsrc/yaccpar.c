#define YYFLAG   -1000
#define YYERROR  goto yyerrlab
#define YYACCEPT return(0)
#define YYABORT  return(1)

#ifdef YYDEBUGON
int     yydebug = 1;    /* @VG спец. случай */
#define YYDEBUG
#else
# ifdef YYDEBUG
int     yydebug = 0;    /* 1 для отладки */
# endif
#endif

#ifdef YYVX      /* Размещать YYV в стеке */
YYSTYPE yyv[YYMAXDEPTH]; /* стек для хранения значений */
#endif

int     yychar = -1;     /* номер текущей лексемы */
int     yynerrs = 0;     /* число ошибок */
short   yyerrflag = 0;   /* флаг восстановления после ошибок */

yyparse()
{
	short             yys[YYMAXDEPTH];
#ifndef YYVX
	YYSTYPE yyv[YYMAXDEPTH];   /* стек для хранения значений */
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

    yystack:    /* занести состояние и значение в стек */

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
		goto yydefault; /* простое состояние */

	if( yychar < 0 )
		if( (yychar = yylex()) < 0 )
			yychar = 0;
	if( (yyn += yychar) < 0 || yyn >= YYLAST )
		goto yydefault;

	if( yychk[yyn = yyact[yyn]] == yychar ) { /* возможен сдвиг */
		yychar  = -1;
		yyval   = yylval;
		yystate = yyn;
		if( yyerrflag > 0 )
			--yyerrflag;
		goto yystack;
	}

    yydefault:  /* действие по умолчанию */

	if( (yyn = yydef[yystate]) == -2 ) {
		if( yychar < 0 )
			if( (yychar = yylex()) < 0 )
				yychar = 0;

		/* просмотреть таблицу исключений */

		for( yyxi = yyexca ; (*yyxi != (-1)) || (yyxi[1] != yystate) ;
								   yyxi += 2 )
			/* ПУСТО */;

		while( *(yyxi += 2) >= 0 ) {
			if( *yyxi == yychar )
				break;
		}
		if( (yyn = yyxi[1]) < 0 )
			return(0);   /* принято */
	}

	if( yyn == 0 ) {        /* ошибка */

		/* ошибка ... попытка продолжить разбор */

		switch( yyerrflag ) {
		    case 0:     /* отметить новую ошибку */

			yyerror("syntax error");
		    yyerrlab:
			++yynerrs;

		    case 1:
		    case 2: /* неполностью восстановлено после ошибки ...
					      попробовать еще раз */

			yyerrflag = 3;

			/* поискать состояние где возможен сдвиг при "error" */

			while ( yyps >= yys ) {
				yyn = yypact[*yyps] + YYERRCODE;
				if( yyn >= 0 &&
				    yyn < YYLAST &&
				    yychk[yyact[yyn]] == YYERRCODE ) {

					/* имитировать сдвиг при "error" */
					yystate = yyact[yyn];
					goto yystack;
				}
				yyn = yypact[*yyps];

		 /* в текущем yyps нет сдвига для "error", поднять из стека */

#ifdef YYDEBUG
				if( yydebug )
    printf("error recovery pops state %d, uncovers %d\n",
						*yyps, yyps[-1] );
#endif
				--yyps;
				--yypv;
			}

		/* в стеке нет состояний со сдвигом для ошибки ... облом */

		    yyabort:
			return(1);

		    case 3:  /* нет возможности сдвига; прочитать лексему */

#ifdef YYDEBUG
			if( yydebug )
		printf("error recovery discards char %d\n",
					 yychar );
#endif

			if( yychar == 0 )
				goto yyabort; /* не пропускать EOF, конец */
			yychar = -1;
			goto yynewstate;   /* попробовать еще раз в том же состоянии */
		}
	}

	/* свертка правила yyn */

#ifdef YYDEBUG
	if( yydebug )
		printf("reduce %d\n", yyn );
#endif
	yyps -= yyr2[yyn];
	yypvt = yypv;
	yypv -= yyr2[yyn];
	yyval = yypv[1];
	yym = yyn;

	/* обратиться к таблице переходов чтобы узнать след. состояние */
	yyn = yyr1[yyn];
	yyj = yypgo[yyn] + *yyps + 1;
	if( yyj >= YYLAST || yychk[yystate = yyact[yyj]] != -yyn )
		yystate = yyact[yypgo[yyn]];
	switch(yym){
		$A
	}
	goto yystack;  /* положить в стек новое состояние и значение */
}
