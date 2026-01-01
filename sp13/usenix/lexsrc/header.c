#include "ldefs.h"

phead1()
{
	if( fout == NULL )
		error( "No %%%% in head\n", " %%%%  \n" );
	fprintf( fout, "#include <stdio.h>\n" );
/*
	if( ZCH > NCH ){
		fprintf( fout, "#define U(x) ((x)&0377)\n" );
	}else{
		fprintf( fout, "#define U(x) x\n" );
	}
 */
	fprintf( fout, "#define ediag(x,y) (x)\n" );
	fprintf( fout, "#define U(x) ((unsigned)(x))\n" );
	fprintf( fout, "#define NLSTATE yyprevious=YYNEWLINE\n" );
	fprintf( fout, "#define BEGIN yybgin = yysvec + 1 +\n" );
	fprintf( fout, "#define INITIAL 0\n" );
	fprintf( fout, "#define YYLERR 0\n" );
	fprintf( fout, "#define YYSTATE (yyestate-yysvec-1)\n" );
	if( optim ){
		fprintf( fout, "#define YYOPTIM 1\n" );
	}
# ifdef DEBUG
	fprintf( fout, "#define LEXDEBUG 1\n" );
# endif
	fprintf( fout, "#define YYLMAX 200\n" );
	fprintf( fout, "#define output(c) putc(c,yyout)\n" );
	fprintf( fout, "%s%d%s\n",
  "#define input() (((yytchar=yysptr>yysbuf?U(*--yysptr):getc(yyin))==",
	ctable['\n'],
 "?(yylineno++,yytchar):yytchar)==EOF?0:yytchar)" );
	fprintf( fout,
"#define unput(c) {yytchar= (c);if(yytchar=='\\n')yylineno--;*yysptr++=yytchar;}\n" );
	fprintf( fout, "#define yymore() (yymorfg=1)\n" );
	fprintf( fout, "#define ECHO fprintf(yyout, \"%%s\",yytext)\n" );
	fprintf( fout, "#define REJECT { nstr = yyreject(); goto yyfussy;}\n" );
	fprintf( fout, "int yyleng; extern char yytext[];\n" );
	fprintf( fout, "int yymorfg;\n" );
	fprintf( fout, "extern char *yysptr, yysbuf[];\n" );
	fprintf( fout, "int yytchar;\n" );
	fprintf( fout, "FILE *yyin ={stdin}, *yyout ={stdout};\n" );
	fprintf( fout, "extern int yylineno;\n" );
	fprintf( fout, "struct yysvf { \n" );
	fprintf( fout, "\tstruct yywork *yystoff;\n" );
	fprintf( fout, "\tstruct yysvf *yyother;\n" );
	fprintf( fout, "\tint *yystops;};\n" );
	fprintf( fout, "struct yysvf *yyestate;\n" );
	fprintf( fout, "extern struct yysvf yysvec[], *yybgin;\n" );
}

phead2()
{
	if( fout == NULL )
		error( "No %%%% in head\n", " %%%%  \n" );
	fprintf( fout, "while((nstr = yylook()) >= 0)\n" );
	fprintf( fout, "yyfussy: switch(nstr){\n" );
	fprintf( fout, "case 0:\n" );
	fprintf( fout, "if(yywrap()) return(0); break;\n" );
}

ptail()
{
	if( !pflag ){
		if( fout == NULL )
			error( "No %%%% in head\n", " %%%%  \n" );
		fprintf( fout, "case -1:\nbreak;\n" );             /* for reject */
		fprintf( fout, "default:\n" );
		fprintf( fout, "fprintf(yyout,ediag(\"bad switch yylook %%d\",\"  yylook %%d\"),nstr);\n" );
		fprintf( fout, "} return(0); }\n" );
		fprintf( fout, "/*  yylex */\n" );
	}
	pflag = 1;
}

statistics()
{
	fprintf( errorf, ediag(
"%d/%d nodes(%%e)\n%d/%d positions(%%p)\n%d/%d states(%%n)\n%ld jumps\n",
"%d/%d (%%e)\n%d/%d (%%p)\n%d/%d (%%n)\n%ld \n"),
		tptr, treesize, nxtpos-positions, maxpos, stnum+1, nstates, rcount );
	fprintf( errorf, ediag(
"%d/%d packed char classes(%%k)\n",
"%d/%d   (%%k)\n"), pcptr-pchar, pchlen );
	if( optim ){
		fprintf( errorf, ediag(
"%d/%d packed jumps(%%a)\n",
"%d/%d  (%%a)\n"), nptr, ntrans );
	}
	fprintf( errorf, ediag(
"%d/%d output slots(%%o)\n",
"%d/%d  (%%o)\n"), yytop, outsize );
}
