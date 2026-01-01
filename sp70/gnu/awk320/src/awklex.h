/*
 * Awk header for lexical analysis and parsing
 *
 * Copyright (C) 1988, 1989, 1990, 1991 by Rob Duff
 * All rights reserved
 */

extern int yyline;
extern int yydone;
extern LIST *yydisplay;

extern void yyinit(void);
extern void yyback(int);
extern void yyerror(char *error);
extern void *yyalloc(unsigned size);

extern int yynext(void);
extern int yylook(void);
extern int yypeek(void);
extern int yyparse(void);
extern int yymapc(int, int);

extern void lastop(int);
extern int lastcode(void);
extern void lastvoid(void);
extern double lastdcon(void);

extern int getlabel(void);
extern void putlabel(int);
extern void uselabel(int, int);

extern char *gencode(void);
extern RULE *genrule(char*, char*);
extern LINK *genact(char*);

extern void gendrop(void);
extern void genstore(int);

extern void genaddr(IDENT*);
extern void genfield(double);

extern void genline(void);
extern void genlabel(int);
extern void genbyte(int);
extern void genfcon(int);
extern void genicon(int);
extern void genscon(char*);
extern void genrcon(char*);
extern void gendcon(double);
extern void gentwo(int, int);
extern void gencall(int, int);
extern void genjump(int, int);
extern void genuser(IDENT*, int);

