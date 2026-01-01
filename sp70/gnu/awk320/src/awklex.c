/*
 * Created by LEX from "awklex.l"
 */

#include <stdio.h>

extern int yyline, yyleng;
extern char yytext[];

struct lexrej {
    short   llfin;
    short   lllen;
};

struct lextab {
    int     llendst;
    int     llnxtmax;
    short   *llbase;
    short   *llnext;
    short   *llcheck;
    short   *lldefault;
    short   *llfinal;
    short   *lllook;
    struct lexrej *llsave;
    int     (*llactr)();
    char    *llign;
    char    *llbrk;
    char    *llill;
};

#define ERROR   256
#define ECHO    yyecho()
#define BEGIN   yystab=
#define REJECT  return(-1)
#define input() fgetc(stdin)
#define output(c) fputc(c, stdout)

#line 1 "awklex.l"

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


yyinp() { return input(); }
yyout(c) char c; { return output(c); }

/* Action routine */
int _Alextab(__na__) {
    switch (__na__) {
    case 0:
#line 36 "awklex.l"
        ;
        break;
    case 1:
#line 37 "awklex.l"
        eatspace();
        break;
    case 2:
#line 38 "awklex.l"
    {
            newline();
            return T_EOL;
        }
        break;
    case 3:
#line 42 "awklex.l"
    {
            comment();
            newline();
            return T_EOL;
        }
        break;
    case 4:
#line 47 "awklex.l"
        return T_BEGIN;
        break;
    case 5:
#line 48 "awklex.l"
        return T_END;
        break;
    case 6:
#line 49 "awklex.l"
        return T_IF;
        break;
    case 7:
#line 50 "awklex.l"
        return T_IN;
        break;
    case 8:
#line 51 "awklex.l"
        return T_DO;
        break;
    case 9:
#line 52 "awklex.l"
        return T_FOR;
        break;
    case 10:
#line 53 "awklex.l"
        return T_ELSE;
        break;
    case 11:
#line 54 "awklex.l"
        return yydone?T_DONE:T_WHILE;
        break;
    case 12:
#line 55 "awklex.l"
        return T_BREAK;
        break;
    case 13:
#line 56 "awklex.l"
        return T_CONTINUE;
        break;
    case 14:
#line 57 "awklex.l"
        return T_FUNCTION;
        break;
    case 15:
#line 58 "awklex.l"
        return T_RETURN;
        break;
    case 16:
#line 59 "awklex.l"
        return T_NEXT;
        break;
    case 17:
#line 60 "awklex.l"
        return T_EXIT;
        break;
    case 18:
#line 61 "awklex.l"
        return T_CLOSE;
        break;
    case 19:
#line 62 "awklex.l"
        return T_PRINT;
        break;
    case 20:
#line 63 "awklex.l"
        return T_PRINTF;
        break;
    case 21:
#line 64 "awklex.l"
        return T_GETLINE;
        break;
    case 22:
#line 65 "awklex.l"
        return T_DELETE;
        break;
    case 23:
#line 66 "awklex.l"
        return T_INDEX;
        break;
    case 24:
#line 67 "awklex.l"
        return T_MATCH;
        break;
    case 25:
#line 68 "awklex.l"
        return T_SPLIT;
        break;
    case 26:
#line 69 "awklex.l"
        return T_SUBSTR;
        break;
    case 27:
#line 70 "awklex.l"
        return T_SPRINTF;
        break;
    case 28:
#line 71 "awklex.l"
        return T_SRAND;
        break;
    case 29:
#line 72 "awklex.l"
    { yylval.ival = P_LSUB; return T_SUB; }
        break;
    case 30:
#line 73 "awklex.l"
    { yylval.ival = P_GSUB; return T_SUB; }
        break;
    case 31:
#line 74 "awklex.l"
    { yylval.ival = C_RAND; return T_FUNC0; }
        break;
    case 32:
#line 75 "awklex.l"
    { yylval.ival = C_SYS; return T_FUNC1; }
        break;
    case 33:
#line 76 "awklex.l"
    { yylval.ival = C_LEN; return T_FUNC1; }
        break;
    case 34:
#line 77 "awklex.l"
    { yylval.ival = C_UPR; return T_FUNC1; }
        break;
    case 35:
#line 78 "awklex.l"
    { yylval.ival = C_LWR; return T_FUNC1; }
        break;
    case 36:
#line 79 "awklex.l"
    { yylval.ival = C_COS; return T_FUNC1; }
        break;
    case 37:
#line 80 "awklex.l"
    { yylval.ival = C_EXP; return T_FUNC1; }
        break;
    case 38:
#line 81 "awklex.l"
    { yylval.ival = C_INT; return T_FUNC1; }
        break;
    case 39:
#line 82 "awklex.l"
    { yylval.ival = C_LOG; return T_FUNC1; }
        break;
    case 40:
#line 83 "awklex.l"
    { yylval.ival = C_SIN; return T_FUNC1; }
        break;
    case 41:
#line 84 "awklex.l"
    { yylval.ival = C_SQRT; return T_FUNC1; }
        break;
    case 42:
#line 85 "awklex.l"
    { yylval.ival = C_ATAN2; return T_FUNC2; }
        break;
    case 43:
#line 86 "awklex.l"
    {
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
        break;
    case 44:
#line 100 "awklex.l"
    case 45:
#line 101 "awklex.l"
    case 46:
#line 102 "awklex.l"
    case 47:
#line 103 "awklex.l"
    {
            yylval.dval = atof(yytext);
            return T_DCON;
        }
        break;
    case 48:
#line 107 "awklex.l"
        return T_APPEND;
        break;
    case 49:
#line 108 "awklex.l"
        return T_NOMATCH;
        break;
    case 50:
#line 109 "awklex.l"
        return T_LAND;
        break;
    case 51:
#line 110 "awklex.l"
        return T_LIOR;
        break;
    case 52:
#line 111 "awklex.l"
    { yylval.ival = C_NE; return T_RELOP; }
        break;
    case 53:
#line 112 "awklex.l"
    { yylval.ival = C_EQ; return T_RELOP; }
        break;
    case 54:
#line 113 "awklex.l"
    { yylval.ival = C_LE; return T_RELOP; }
        break;
    case 55:
#line 114 "awklex.l"
    { yylval.ival = C_GE; return T_RELOP; }
        break;
    case 56:
#line 115 "awklex.l"
    { yylval.ival = C_ADD; return T_INCOP; }
        break;
    case 57:
#line 116 "awklex.l"
    { yylval.ival = C_SUB; return T_INCOP; }
        break;
    case 58:
#line 117 "awklex.l"
    { yylval.ival = C_POW; return T_STORE; }
        break;
    case 59:
#line 118 "awklex.l"
    { yylval.ival = C_MUL; return T_STORE; }
        break;
    case 60:
#line 119 "awklex.l"
    { yylval.ival = C_DIV; return T_STORE; }
        break;
    case 61:
#line 120 "awklex.l"
    { yylval.ival = C_MOD; return T_STORE; }
        break;
    case 62:
#line 121 "awklex.l"
    { yylval.ival = C_ADD; return T_STORE; }
        break;
    case 63:
#line 122 "awklex.l"
    { yylval.ival = C_SUB; return T_STORE; }
        break;
    case 64:
#line 123 "awklex.l"
    { yylval.ival = 0; return T_STORE; }
        break;
    case 65:
#line 124 "awklex.l"
    {
            yyback('\n');
            return '}';
        }
        break;
    case 66:
#line 128 "awklex.l"
        return '-';
        break;
    case 67:
#line 129 "awklex.l"
        return ']';
        break;
    case 68:
#line 130 "awklex.l"
    {
            return *yytext;
        }
        break;
    case 69:
#line 133 "awklex.l"
    {
            string('"');
            return T_SCON;
        }
        break;
    case 70:
#line 137 "awklex.l"
        return ERROR;
        break;
    }
    return (-2);
}

#line 138 "awklex.l"


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


short _Flextab[] = { -1, 70, 69, 68, 67, 65, 68,
    61, 68, 60, 68, 59, 68, 58, 66,
    63, 57, 68, 62, 56, 68, 54, 64,
    53, 70, 51, 70, 50, 68, 52, 49,
    68, 55, 48, 44, -1, 46, -1, -1,
    45, -1, 47, -1, 44, 43, 43, 43,
    43, 43, 43, 42, 43, 43, 43, 43,
    43, 43, 35, 43, 43, 43, 43, 34,
    43, 43, 39, 43, 43, 43, 43, 33,
    43, 43, 43, 41, 43, 40, 43, 43,
    43, 43, 32, 43, 43, 43, 28, 43,
    29, 43, 43, 26, 43, 43, 43, 43,
    43, 27, 43, 43, 25, 43, 43, 43,
    43, 24, 43, 43, 43, 30, 43, 43,
    43, 43, 43, 21, 43, 43, 43, 43,
    19, 20, 43, 43, 43, 16, 43, 43,
    43, 31, 43, 43, 43, 43, 15, 43,
    43, 43, 43, 18, 43, 36, 43, 43,
    43, 43, 43, 13, 43, 43, 43, 43,
    12, 43, 43, 43, 43, 11, 43, 43,
    37, 43, 17, 43, 43, 10, 43, 43,
    43, 43, 43, 43, 43, 14, 43, 9,
    43, 43, 43, 43, 43, 22, 8, 43,
    7, 38, 43, 43, 23, 6, 43, 43,
    5, 43, 43, 43, 43, 4, 3, 2,
    1, 70, 0, -1,
};

struct lexrej _Vlextab[197];

#line 282 "awklex.l"

short _Nlextab[] = { 1, 1, 1, 1, 1, 1, 1,
    1, 1, 199, 198, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1,
    1, 199, 28, 2, 197, 3, 6, 26,
    1, 3, 3, 10, 17, 3, 14, 1,
    8, 34, 34, 34, 34, 34, 34, 34,
    34, 34, 34, 3, 3, 20, 22, 31,
    3, 1, 44, 192, 44, 44, 189, 44,
    44, 44, 44, 44, 44, 44, 44, 44,
    44, 44, 44, 44, 44, 44, 44, 44,
    44, 44, 44, 44, 3, 200, 4, 12,
    44, 1, 46, 147, 134, 175, 157, 165,
    105, 44, 182, 44, 44, 63, 100, 121,
    44, 115, 44, 125, 71, 51, 44, 44,
    152, 44, 44, 44, 3, 24, 5, 3,
    1, 7, 9, 11, 13, 16, 19, 21,
    23, 25, 27, 29, 32, 33, 202, 202,
    202, 202, 202, 47, 202, 15, 48, 38,
    18, 43, 43, 43, 43, 43, 43, 43,
    43, 43, 43, 40, 202, 49, 202, 50,
    52, 54, 37, 55, 37, 56, 35, 36,
    36, 36, 36, 36, 36, 36, 36, 36,
    36, 39, 39, 39, 39, 39, 39, 39,
    39, 39, 39, 40, 57, 59, 53, 60,
    61, 62, 65, 42, 30, 42, 35, 58,
    41, 41, 41, 41, 41, 41, 41, 41,
    41, 41, 45, 45, 45, 45, 45, 45,
    45, 45, 45, 45, 67, 68, 69, 70,
    73, 74, 76, 45, 45, 45, 45, 45,
    45, 45, 45, 45, 45, 45, 45, 45,
    45, 45, 45, 45, 45, 45, 45, 45,
    45, 45, 45, 45, 45, 78, 79, 80,
    81, 45, 83, 45, 45, 45, 45, 45,
    45, 45, 45, 45, 45, 45, 45, 45,
    45, 45, 45, 45, 45, 45, 45, 45,
    45, 45, 45, 45, 45, 66, 84, 85,
    87, 75, 88, 89, 90, 97, 93, 64,
    91, 72, 82, 92, 94, 86, 95, 96,
    98, 77, 99, 101, 102, 103, 104, 109,
    107, 108, 110, 111, 112, 113, 114, 116,
    117, 118, 119, 120, 122, 106, 123, 124,
    126, 127, 128, 130, 129, 131, 132, 133,
    135, 136, 137, 139, 138, 141, 142, 143,
    144, 145, 140, 146, 148, 149, 150, 151,
    153, 154, 155, 156, 162, 160, 161, 163,
    164, 173, 167, 168, 159, 169, 170, 166,
    158, 171, 172, 174, 176, 177, 178, 179,
    180, 188, 185, 186, 187, 190, 181, 191,
    193, 183, 194, 195, 196, 201, 202, 202,
    202, 202, 184,
};

short _Clextab[] = { 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 6, 8, 10, 12, 14, 17, 20,
    22, 24, 26, 28, 31, 31, 36, 37,
    36, 37, 41, 46, 41, 14, 47, 34,
    17, 34, 34, 34, 34, 34, 34, 34,
    34, 34, 34, 39, 42, 48, 42, 49,
    51, 53, 35, 54, 35, 55, 34, 35,
    35, 35, 35, 35, 35, 35, 35, 35,
    35, 38, 38, 38, 38, 38, 38, 38,
    38, 38, 38, 39, 56, 58, 52, 59,
    60, 61, 64, 40, 28, 40, 34, 52,
    40, 40, 40, 40, 40, 40, 40, 40,
    40, 40, 44, 44, 44, 44, 44, 44,
    44, 44, 44, 44, 66, 67, 68, 69,
    72, 73, 75, 44, 44, 44, 44, 44,
    44, 44, 44, 44, 44, 44, 44, 44,
    44, 44, 44, 44, 44, 44, 44, 44,
    44, 44, 44, 44, 44, 77, 78, 79,
    80, 44, 82, 44, 44, 44, 44, 44,
    44, 44, 44, 44, 44, 44, 44, 44,
    44, 44, 44, 44, 44, 44, 44, 44,
    44, 44, 44, 44, 44, 63, 83, 84,
    86, 71, 87, 88, 89, 91, 92, 63,
    71, 71, 71, 91, 93, 71, 94, 95,
    97, 71, 98, 100, 101, 102, 103, 105,
    106, 107, 109, 110, 111, 112, 113, 115,
    116, 117, 118, 119, 121, 105, 122, 123,
    125, 126, 127, 129, 125, 130, 131, 132,
    134, 135, 136, 134, 137, 139, 141, 142,
    143, 144, 139, 145, 147, 148, 149, 150,
    152, 153, 154, 155, 157, 158, 160, 162,
    163, 165, 166, 167, 158, 168, 169, 165,
    157, 170, 171, 173, 175, 176, 177, 178,
    179, 182, 183, 185, 186, 189, 175, 190,
    192, 182, 193, 194, 195, 200, -1, -1,
    -1, -1, 183,
};

short _Dlextab[] = { 0312, 0312, 0312, 0312, 0312, 0312, 0312,
    0312, 0312, 0312, 0312, 0312, 0312, 0312, 0312,
    0312, 0312, 0312, 0312, 0312, 0312, 0312, 0312,
    0312, 0312, 0312, 0312, 0312, 0312, 0312, 0312,
    0312, 0312, 0312, 0312, 0312, 043, 044, 0312,
    046, 0312, 050, 051, 042, 0312, 054, 054,
    054, 054, 054, 054, 054, 054, 054, 054,
    054, 054, 054, 054, 054, 054, 054, 054,
    054, 054, 054, 054, 054, 054, 054, 054,
    054, 054, 054, 054, 054, 054, 054, 054,
    054, 054, 054, 054, 054, 054, 054, 054,
    054, 054, 054, 054, 054, 054, 054, 054,
    054, 054, 054, 054, 054, 054, 054, 054,
    054, 054, 054, 054, 054, 054, 054, 054,
    054, 054, 054, 054, 054, 054, 054, 054,
    054, 054, 054, 054, 054, 054, 054, 054,
    054, 054, 054, 054, 054, 054, 054, 054,
    054, 054, 054, 054, 054, 054, 054, 054,
    054, 054, 054, 054, 054, 054, 054, 054,
    054, 054, 054, 054, 054, 054, 054, 054,
    054, 054, 054, 054, 054, 054, 054, 054,
    054, 054, 054, 054, 054, 054, 054, 054,
    054, 054, 054, 054, 054, 054, 054, 054,
    054, 054, 054, 054, 054, 054, 054, 054,
    054, 054, 054, 054, 054, 054, 0312, 0312,
    0312, 0312, 0312, 00,
};

short _Blextab[] = { 00, 00, 00, 00, 00, 00, 0103,
    00, 0104, 00, 0105, 00, 0106, 00, 0127,
    00, 00, 0132, 00, 00, 0111, 00, 0112,
    00, 014, 00, 0143, 00, 0115, 00, 00,
    0116, 00, 00, 0150, 0176, 0142, 0143, 0210,
    0135, 0237, 0146, 0170, 00, 0251, 00, 036,
    064, 066, 0164, 00, 070, 0131, 071, 063,
    0107, 0121, 00, 0124, 0126, 0142, 0126, 00,
    0277, 0142, 00, 0165, 0175, 0161, 0176, 00,
    0277, 0165, 0164, 00, 0173, 00, 0221, 0221,
    0241, 0232, 00, 0250, 0267, 0302, 00, 0305,
    0266, 0266, 0271, 00, 0300, 0304, 0305, 0301,
    0320, 00, 0316, 0305, 00, 0331, 0307, 0331,
    0325, 00, 0331, 0312, 0336, 00, 0315, 0326,
    0332, 0326, 0340, 00, 0324, 0336, 0332, 0325,
    0344, 00, 0346, 0325, 0332, 00, 0356, 0342,
    0355, 00, 0336, 0337, 0343, 0350, 00, 0353,
    0351, 0346, 0366, 00, 0356, 00, 0351, 0365,
    0361, 0353, 0375, 00, 0361, 0377, 0404, 0373,
    00, 0377, 0377, 0375, 0405, 00, 0377, 0403,
    00, 0371, 00, 0373, 0412, 00, 0401, 0403,
    0417, 0400, 0414, 0411, 0413, 00, 0410, 00,
    0426, 0420, 0430, 0412, 0432, 00, 00, 0432,
    0435, 00, 0435, 0413, 00, 00, 0466, 0502,
    00, 0502, 0502, 0501, 0475, 00, 00, 00,
    00, 0602, 00, 00,
};

short _Slextab[] = { 00,
};

struct lextab lextab = {
    202,     /* Highest state */
    401,     /* Index of last entry in next */
    _Blextab,    /* -> Base table */
    _Nlextab,    /* -> Next state table */
    _Clextab,    /* -> Check value table */
    _Dlextab,    /* -> Default state table */
    _Flextab,    /* -> Final state table */
    NULL,       /* -> Look-ahead vector */
    _Vlextab,    /* -> length and look ahead save */
    _Alextab,    /* -> Action routine */
    NULL,        /* No Ignore class */
    NULL,        /* No Break class */
    NULL,        /* No Illegal class */
};

