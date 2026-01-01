/*
 * Awk regular expression compiler/interpreter
 *
 * Copyright (C) 1988, 1989, 1990, 1991 by Rob Duff
 * All rights reserved
 */

#include <stdio.h>
#include <stdlib.h>
#include <mem.h>

extern void kbhit(void);

#include "awkfstr.h"
#include "awk.h"

static char *patptr;

extern int yynext(void);
extern void yyerror(char*);
extern void *yyalloc(unsigned);

int re_next(void);
int re_term(int);
int re_sequence(int);
int re_factor(char*, int);
int re_expression(char*, int);
int re_class(void);
int re_mapc(void);
int re_next(void);

void re_back(int);

void moveup(char*, int);
int classed(char*, int);

char *fstrnsub(char*, FSTR, FSTR, int);

#define reljmp(r) ((r) + (*((unsigned short*)(r))) + sizeof(short))

static FSTR pmatch(FSTR, char*);
static FSTR star(FSTR, char*, char*);

FSTR    bol;
char    eor;
short   rechar;

short   rstart;
short   rcount;
short   rlength;

static unsigned char cclass[32];

/*
 * Compile a regular expression
 */
char *regexp(int copy)
{
    int     c;
    char    *lp;

    if (copy==1)
        eor = '/';
    else
        eor = '\0';
    rechar = EOF;
    patptr = buffer;
    c = re_expression(patptr, re_next());
    *patptr++ = R_END;
    if (copy > 0) {
        if (copy == 1 && c != '/')
            yyerror("syntax error");
        c = (int)(patptr - buffer);
        lp = yyalloc(c);
        memcpy(lp, buffer, c);
        return lp;
    }
    else {
        return buffer;
    }
}

static int re_expression(char *lp, int c)
{
    c = re_sequence(c);
    if (c == '|') {
        *patptr++ = R_END;
        moveup(lp, R_END);
        c = re_expression(patptr, re_next());
        *patptr++ = R_END;
        moveup(lp, R_BAR);
    }
    return(c);
}

static int re_sequence(int c)
{
    if (c == '^') {
        *patptr++ = R_BOL;
        c = re_next();
    }
    while (c != '|' && c != ')' && c != '$' && c != eor  && c != EOF)
        c = re_factor(patptr, c);
    if (c == '$') {
        *patptr++ = R_EOL;
        c = re_next();
    }
    return c;
}

static int re_factor(char *lp, int c)
{
    c = re_term(c);
    switch(c) {
    case '*': c = R_STAR; break;
    case '+': c = R_PLUS; break;
    case '?': c = R_QUEST; break;
    default: return(c);
    }
    *patptr++ = R_END;
    moveup(lp, c);
    c = re_next();
    return(c);
}

static int re_term(int c)
{
    if (c == eor)
        return c;
    switch(c) {
    case EOF:
    case '*':
    case '+':
    case '?':
    case '|':
    case '^':   return (EOF);
    case ')':
    case '$':   return (c);
    case '.':   *patptr++ = R_ANY; break;
    case '[':   return re_class();
    case '(':
        c = re_expression(patptr, re_next());
        if (c != ')')
            return (EOF);
        break;
    case '\n':
        if (eor == '/')
            return (EOF);
        *patptr++ = R_CHAR;
        *patptr++ = '\n';
        break;
    case '/':
        if (eor == '/')
            return ('/');
        *patptr++ = '/';
        break;
    case '\\':
        c = re_mapc();
    default:
        if (c < ' ' /* ASCII */)
            *patptr++ = R_CHAR;
        *patptr++ = c;
    }
    return re_next();
}

/*
 * Compile a character class
 */
static int re_class()
{
    int     c, i, o;

    if ( (c = re_next()) == EOF )
        return (EOF);
    for (i = 0; i < 32; i++)
        cclass[i] = 0;
    if ( c == '^') {
        o = R_NCLAS;
        c = re_next();
    }
    else
        o = R_CLASS;

    if (c == ']') {
        cclass[c >> 3] |= 1 << (c & 7);
        c = re_next();
    }
    while (c != ']') {
        if (c == EOF || c == '\n')
            return EOF;
        if (c == '\\')
            c = re_mapc();
        i = re_next();
        if (i == '-') {
            i = re_next();
            if (i == '\n' || i == EOF)
                return EOF;
            if (i == ']') {
                cclass[c >> 3] |= 1 << (c & 7);
                cclass['-' >> 3] |= 1 << ('-' & 7);
            }
            else {
                if (i == '\\')
                    i = re_mapc();
                if (i <= c)
                    return (EOF);
                while (c <= i) {
                    cclass[c >> 3] |= 1 << (c & 7);
                    c++;
                }
                i = re_next();
            }
        }
        else
            cclass[c >> 3] |= 1 << (c & 7);
        c = i;
    }
    if (o == R_NCLAS)
        cclass[0] |= 0x1;
    else
        cclass[0] &= 0xFE;
    *patptr++ = o;
    for (i = 0; i < 32; i++)
        *patptr++ = cclass[i];
    return re_next();
}

void moveup(char *lp, int op)
{
    register char *sp;
    int     i;
    TRIX    trix;

    sp = patptr;
    while (sp >= lp) {
        sp[3] = sp[0];
        sp--;
    }
    trix.ival = patptr - lp;
    *lp++ = op;
    patptr += 3;
    for (i = 0; i < sizeof(short); i++)
        *lp++ = trix.sval[i];
}

static int re_mapc()
{
    int     c, n, octv;

    c = re_next();
    switch (c) {
    case '\n':
        return(R_EOL);
    case 'b':
        return('\b');
    case 'f':
        return('\f');
    case 'n':
        return('\n');
    case 'r':
        return('\r');
    case 't':
        return('\t');
    case '0':
    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
    case '6':
    case '7':
        octv = c - '0';
        for (n = 1; (c = re_next()) >= '0' && c<='7' && n <= 3; n++)
            octv = octv * 010 + c - '0';
        re_back(c);
        return(octv);
    case '\"':
    case '\'':
    default:
        return(c);
    }
}

static int re_next()
{
    int     c;

renext:
    if (rechar == EOF)
        c = yynext();
    else {
        c = rechar;
        rechar = EOF;
    }

    if (c == '\\' && eor == '/') {
        c = yynext();
        if (c == '\n')
            goto renext;
        rechar = c;
        c = '\\';
    }
    return c;
} 

static void re_back(int c)
{
    rechar = c;
}

void match(FSTR lp, char *pp)
{
    FSTR    mp;

    lp++;
    bol = lp;
    rstart = 0;
    rlength = 0;
    for(;;) {
        if ((mp = pmatch(lp, pp)) != NULL) {
            rstart = lp - bol + 1;
            rlength = mp - lp;
            return;
        }
        if (*lp == '\0')
            break;
        lp++;
    }
}

FSTR matchp(FSTR bp, FSTR lp, char *pp)
{
    bol = bp;
    lp = pmatch(lp, pp);
    return lp;
}

char *fstrnsub(char *dp, FSTR rp, FSTR sp, int n)
{
    int     m;
    char    *tp;

    tp = dp;
    dp = (void*)fstrchr(dp, '\0');
    while (*rp != '\0') {
        if (rp[0] == '\\' && rp[1] == '&') {
            rp++;
            *dp++ = *rp++;
        }
        else if (*rp == '&') {
            for (m = 0; m < n; m++)
                *dp++ = sp[m];
            rp++;
        }
        else
            *dp++ = *rp++;
    }
    *dp = '\0';
    return tp;
}

char *subst(int global, FSTR rp, FSTR lp, char *pp)
{
    char    *dp;
    FSTR    mp;
    FSTR    sp;

    lp++;
    rp++;
    sp = lp;
    bol = lp;
    rcount = 0;
    dp = code;
    *dp++ = ZSTR;
    *dp = '\0';
    while (*lp != '\0') {
        if ((mp = pmatch(lp, pp)) != NULL) {
            rcount++;
            if (sp != lp)
                fstrncat(dp, sp, (int)(lp - sp));
            fstrnsub(dp, rp, lp, (int)(mp - lp));
            sp = lp = mp;
            if (global == 0)
                break;
            else {
                if (global > 100) {
                    global = 1;
                    kbhit();
                }
                else
                    global++;
                continue;
            }
        }
        lp++;
    }
    fstrcat(dp, sp);
    return code;
}

static FSTR pmatch(FSTR lp, char *pp)
{
    int     op;
    FSTR    sp;
    FSTR    ep;
 
    while ((op = *pp) != R_END) {
        pp++;
        switch(op) {
        case R_BOL:
            if (lp != bol)
                return NULL;
            break;
        case R_EOL:
            if (*lp != '\0')
                return NULL;
            break;
        case R_ANY:
            if (*lp++ == '\0')
                return NULL;
            break;
        case R_CHAR:
            if (*lp++ != *pp++)
                return NULL;
            break;
        case R_CLASS:
            if (classed(pp, *lp++) == 0)
                return NULL;
            pp += 32;
            break;
        case R_NCLAS:
            if (classed(pp, *lp++) != 0)
                return NULL;
            pp += 32;
            break;
        case R_BAR:
            ep = pmatch(lp, pp + 5);
            sp = pmatch(lp, reljmp(pp + 3));
            if (ep != NULL) {
                if (sp != NULL && sp > ep)
                    lp = sp;
                else
                    lp = ep;
                pp = reljmp(pp);
                break;
            }
            else if (sp != NULL) {
                lp = sp;
                pp = reljmp(pp);
                break;
            }
            return NULL;
        case R_QUEST:
            ep = pmatch(lp, pp + 2);
            pp = reljmp(pp);
            if (ep)
                lp = ep;
            break;
        case R_PLUS:
            if ((lp = pmatch(lp, pp + 2)) == 0)
                return NULL;
        case R_STAR:
            if ((ep = star(lp, pp + 2, reljmp(pp))) != 0)
                return ep;
            pp = reljmp(pp);
            break;
        default:
            if ( *lp++ != op)
                return NULL;
        }
    }
    return lp;
}

static FSTR star(FSTR lp, char *pp, char *qq)
{
    FSTR    ep;
    FSTR    fp;

    if ((ep = pmatch(lp, pp)) != NULL)
        if ((fp = star(ep, pp, qq)) != NULL)
            return fp;
        else
            return pmatch(ep, qq);
    else
        return pmatch(lp, qq);
}

static int classed(char *cc, int ch)
{
    return (cc[(ch>>3)&037]&(1<<(ch&07)));
}

