/*
 * yyparse.c --  parser for yacc output
 */

#define YYFLAG -1000
#define YYABORT return(1)
#define YYACCEPT return(0)
#define YYERROR goto yyerrlab

int     yychar = -1;    /* current input token number */
int     yydebug = 0;    /* 1 for debugging */
int     yynerrs = 0;    /* number of errors */
short   yyerrflag = 0;  /* error recovery flag */
short   yys[YYMAXDEPTH];/* where the stack is stored */
YYSTYPE yyv[YYMAXDEPTH];/* where the values are stored */

#ifndef YYLOG
#define YYLOG stderr
#endif

yyparse()
{
    short   yyj;
    short   yym;
    short   *yyps;
    short   *yyxi;
    YYSTYPE *yypv;
    YYSTYPE *yypvt;
    short   yystate;
    register short  yyn;

    extern int yylex(void);
    extern void yyerror(char*);

    yystate = 0;
    yychar = -1;
    yynerrs = 0;
    yyerrflag = 0;
    yyps= &yys[-1];
    yypv= &yyv[-1];

yystack:    /* put a state and value onto the stack */
#ifdef YYDEBUG
    if (yydebug)
        fprintf(YYLOG, "state %d, char 0%o\n", yystate, yychar );
#endif
    if (++yyps> &yys[YYMAXDEPTH]) {
        yyerror("yacc stack overflow");
        goto yyabort;
    }
    *yyps = yystate;
    ++yypv;
#ifdef UNION
    yyunion(yypv, &yyval);
#else
    *yypv = yyval;
#endif
yynewstate:
    yyn = yypact[yystate];
    if (yyn <= YYFLAG)
        goto yydefault; /* simple state */
    if (yychar < 0)
        if ((yychar=yylex())<0)
            yychar=0;
    if ((yyn += yychar)<0 || yyn >= YYLAST)
        goto yydefault;
    if (yychk[yyn=yyact[yyn]] == yychar) {
        yychar = -1;
#ifdef UNION
        yyunion(&yyval, &yylval);
#else
        yyval = yylval;
#endif
        yystate = yyn;
        if (yyerrflag > 0)
            --yyerrflag;
        goto yystack;
    }
/* 
 *default state action
 */
yydefault:
    if ((yyn=yydef[yystate]) == -2) {
        if (yychar<0) if ((yychar = yylex())<0) yychar = 0;
/*
 * look through exception table
 */
        for (yyxi=yyexca; (*yyxi != (-1)) || (yyxi[1] != yystate) ; yyxi += 2)
            ;
        for (yyxi += 2; *yyxi >= 0; yyxi += 2)
            if (*yyxi == yychar)
                break;
        if ((yyn = yyxi[1]) < 0)
            return(0);   /* accept */
    }
    if (yyn == 0) {
/* error ... attempt to resume parsing */
        switch (yyerrflag) {
        case 0:
            yyerror("syntax error");
yyerrlab:
            ++yynerrs;
        case 1:
        case 2:
            yyerrflag = 3;
            while (yyps >= yys) {
                yyn = yypact[*yyps] + YYERRCODE;
                if (yyn>= 0 && yyn < YYLAST && yychk[yyact[yyn]] == YYERRCODE) {
                    yystate = yyact[yyn];
                    goto yystack;
                }
                yyn = yypact[*yyps];
#ifdef YYDEBUG
                if (yydebug)
                    fprintf(YYLOG, "error recovery pops state %d, uncovers %d\n",
                                *yyps, yyps[-1]);
#endif
                --yyps;
                --yypv;
            }
yyabort:
            return(1);
        case 3:
#ifdef YYDEBUG
            if (yydebug)
                fprintf(YYLOG, "error recovery discards char %d\n", yychar );
#endif
            if (yychar == 0)
                goto yyabort; /* don't discard EOF, quit */
            yychar = -1;
            goto yynewstate;   /* try again in the same state */
        }
    }

    /* reduction by production yyn */
    yyps -= yyr2[yyn];
    yypvt = yypv;
    yypv -= yyr2[yyn];
#ifdef UNION
    yyunion(&yyval, &yypv[1]);
#else
    yyval = yypv[1];
#endif
    yym=yyn;
    yyn = yyr1[yyn];
    yyj = yypgo[yyn] + *yyps + 1;
    if (yyj>=YYLAST || yychk[yystate = yyact[yyj]] != -yyn)
        yystate = yyact[yypgo[yyn]];
    switch(yym) {
        $A
    }
    goto yystack;
}

