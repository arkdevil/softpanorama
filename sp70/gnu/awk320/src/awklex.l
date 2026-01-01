%{
/*
 * Awk lexical analyser
 *
 * Copyright (C) 1988, 1989, 1990, 1991 by Rob Duff
 * All rights reserved
 */
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include <alloc.h>

#include "awk.h"
#include "awklex.h"
#include "awkyacc.h"
#undef input
#pragma warn-rch

int input(void);

struct  func {
    char    *name;
    char    type, code;
} *funcp, func[] = {
    0,0,0
};

static int comment(void);
static void string(int);
static void newline(void);
static void eatspace(void);

%}
%%
"\\\n"      ;
[ \t]       eatspace();
'\n'    {
            newline();
            return T_EOL;
        }
'#'     {
            comment();
            newline();
            return T_EOL;
        }
"BEGIN"     return T_BEGIN;
"END"       return T_END;
"if"        return T_IF;
"in"        return T_IN;
"do"        return T_DO;
"for"       return T_FOR;
"else"      return T_ELSE;
"while"     return yydone?T_DONE:T_WHILE;
"break"     return T_BREAK;
"continue"  return T_CONTINUE;
"function"  return T_FUNCTION;
"return"    return T_RETURN;
"next"      return T_NEXT;
"exit"      return T_EXIT;
"close"     return T_CLOSE;
"print"     return T_PRINT;
"printf"    return T_PRINTF;
"getline"   return T_GETLINE;
"delete"    return T_DELETE;
"index"     return T_INDEX;
"match"     return T_MATCH;
"split"     return T_SPLIT;
"substr"    return T_SUBSTR;
"sprintf"   return T_SPRINTF;
"srand"     return T_SRAND;
"sub"       { yylval.ival = P_LSUB; return T_SUB; }
"gsub"      { yylval.ival = P_GSUB; return T_SUB; }
"rand"      { yylval.ival = C_RAND; return T_FUNC0; }
"system"    { yylval.ival = C_SYS; return T_FUNC1; }
"length"    { yylval.ival = C_LEN; return T_FUNC1; }
"toupper"   { yylval.ival = C_UPR; return T_FUNC1; }
"tolower"   { yylval.ival = C_LWR; return T_FUNC1; }
"cos"       { yylval.ival = C_COS; return T_FUNC1; }
"exp"       { yylval.ival = C_EXP; return T_FUNC1; }
"int"       { yylval.ival = C_INT; return T_FUNC1; }
"log"       { yylval.ival = C_LOG; return T_FUNC1; }
"sin"       { yylval.ival = C_SIN; return T_FUNC1; }
"sqrt"      { yylval.ival = C_SQRT; return T_FUNC1; }
"atan2"     { yylval.ival = C_ATAN2; return T_FUNC2; }
[a-zA-Z_][0-9a-zA-Z_]* {
            funcp = func;
            while (funcp->name != 0) {
                if (strcmp(yytext, funcp->name) == 0) {
                    yylval.ival = funcp->code;
                    return funcp->type;
                }
                funcp++;
            }
            yylval.vptr = lookup(yytext);
            if (yypeek() == '(')
                return T_USER;
            return T_NAME;
        }
[0-9]+ |
[0-9]+\.[0-9]+ |
[0-9]+[Ee][-+]?[0-9]+ |
[0-9]+\.[0-9]+[Ee][-+]?[0-9]+ {
            yylval.dval = atof(yytext);
            return T_DCON;
        }
">>"        return T_APPEND;
"!~"        return T_NOMATCH;
"&&"        return T_LAND;
"||"        return T_LIOR;
"!="        { yylval.ival = C_NE; return T_RELOP; }
"=="        { yylval.ival = C_EQ; return T_RELOP; }
"<="        { yylval.ival = C_LE; return T_RELOP; }
">="        { yylval.ival = C_GE; return T_RELOP; }
"++"        { yylval.ival = C_ADD; return T_INCOP; }
"--"        { yylval.ival = C_SUB; return T_INCOP; }
"^="        { yylval.ival = C_POW; return T_STORE; }
"*="        { yylval.ival = C_MUL; return T_STORE; }
"/="        { yylval.ival = C_DIV; return T_STORE; }
"%="        { yylval.ival = C_MOD; return T_STORE; }
"+="        { yylval.ival = C_ADD; return T_STORE; }
"-="        { yylval.ival = C_SUB; return T_STORE; }
"="         { yylval.ival = 0; return T_STORE; }
"}"     {
            yyback('\n');
            return '}';
        }
"-"         return '-';
"]"         return ']';
[{[$!?:;,^~/*%+<>()] {
            return *yytext;
        }
'"'     {
            string('"');
            return T_SCON;
        }
.           return ERROR;
%%

static void string(int ec)
{
    register int len;
    register c;

    buffer[0] = '\377';
    for (len = 1; len < 79 && (c = yymapc(ec, '\\')) != EOF; len++)
        buffer[len] = c;
    buffer[len] = '\0';
    if (len == 1)
        yylval.sptr = (char near *)nullstr;
    else {
        yylval.sptr = yyalloc(len+1);
        strcpy(yylval.sptr, buffer);
    }
}

static int comment()
{
    register int ch;

    while ((ch = yynext()) != EOF && ch != '\n')
        ;
    return ch;
}

static void newline()
{
    register int ch;

    while ((ch = yynext()) != EOF) {
        if (ch == '#')
            ch = comment();
        if (ch != ' ' && ch != '\t' && ch != '\n') {
            yyback(ch);
            break;
        }
    }
}

static void eatspace()
{
    register int ch;

    while ((ch = yynext()) == ' ' || ch == '\t')
        ;
    yyback(ch);
}

int
input()
{
    if (lineptr == NULL) {
        if (awklist != NULL) {
            yyline = 0;
            yyname = awklist->name;
            if (yyname == awkstdin)
                awkfile = stdin;
            else {
                awkfile = fopen(yyname ,"r");
                if (awkfile == NULL)
                    error("Can't open program file %s", yyname);
            }
            awklist = awklist->next;
            lineptr = linebuf;
            *lineptr = '\0';
        }
        else {
            awkeof = 1;
            return(EOF);
        }
    }
    if (*lineptr == '\0') {
        if (awkeof)
            return(EOF);
        lineptr = fgets(linebuf, 128, awkfile);
        if (lineptr != linebuf) {
            lineptr = NULL;
            return('\n');
        }
        yyline++;
        genline();
        if (linebuf[0] == '.' && linebuf[1] == '\n') {
            awkeof = 1;
            lineptr = NULL;
            return(EOF);
        }
    }
    return(*lineptr++);
}

IDENT *lookup(char *name)
{
    char    *sp;
    IDENT   *vp;

    for (vp = ident; vp != NULL; vp = vp->vnext)
        if (strcmp(name, vp->vname) == 0)
            return vp;
    if (nextvar >= vartab+MAXNAME)
        yyerror("Too many variables");
    
    sp = yyalloc(strlen(name) + 1);
    strcpy(sp, name);
    vp = yyalloc(sizeof(IDENT));
    vp->vitem = NULL;
    vp->vname = sp;
    vp->vfunc = NULL;
    vp->vnext = ident;
    ident = vp;
    return vp;
}

void *
yyalloc(size)
unsigned int size;
{
    void    *mp;

    mp = malloc(size);
    if (mp == NULL)
        yyerror("out of memory");
    memset(mp, 0, size);
    return(mp);
}

void
yyerror(str)
char *str;
{
    char  *lp, *ep;

    fprintf(stderr, "%s", linebuf);
    if ((char near *)lineptr != NULL) {
        ep = (char near *)lineptr - 1 - yylook();
        for (lp = linebuf; lp < ep; lp++)
            fputc(*lp=='\t'?'\t':' ', stderr);
        fprintf(stderr, "^\n");
    }
    error(str, NULL);
}

