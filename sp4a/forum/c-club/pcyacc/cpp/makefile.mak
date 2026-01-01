
YFLAG=-c -d
CFLAG=-c -AC
LFLAG=/Fecppc

OBJS=main.obj yytab.obj lex.obj new.obj link.obj aggr.obj type.obj fct.obj gen.obj err.obj fmt.obj

cppc.exe : $(OBJS)
	   cl $(LFLAG) $(OBJS)

main.obj :  main.c const.h global.h yylex.h yyerr.h
	    cl $(CFLAG) main.c

yytab.c  : gram.y
	   pcyacc $(YFLAG) gram.y

yytab.obj: yytab.c const.h global.h yylex.h cppcmain.h
	   cl $(CFLAG) yytab.c

lex.obj  : lex.c const.h global.h yytab.h yyerr.h cppcmain.h
	   cl $(CFLAG) lex.c

new.obj  : new.c const.h global.h
	   cl $(CFLAG) new.c

link.obj : link.c const.h global.h cppcmain.h
           cl $(CFLAG) link.c

aggr.obj : aggr.c const.h global.h
           cl $(CFLAG) aggr.c

type.obj : type.c const.h global.h
           cl $(CFLAG) type.c

fct.obj  : fct.c const.h global.h
           cl $(CFLAG) fct.c

gen.obj  : gen.c const.h global.h cppcmain.h
           cl $(CFLAG) gen.c

err.obj  : err.c const.h yylex.h	    
	   cl $(CFLAG) err.c

fmt.obj  : fmt.c
           cl $(CFLAG) fmt.c

