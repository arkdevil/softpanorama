/*
 * yylex for lex tables
 *
 * Copyright (C) 1988, 1989, 1990, 1991 by Rob Duff
 * All rights reserved
 */

#include <stdio.h>
#include "yylex.h"

#define NBPW    16      /* bits per word */
#define YYSIZE  100     /* size of work buffer */

int     yyline  = 0;
int     yyleng  = 0;
char    yytext[YYSIZE+1] = "";

static int lleof = 0;
static int llmore = 0;

static unsigned char *llsave[NBPW]; /* Right-context buffer                 */
static unsigned char llbuf[YYSIZE]; /* work buffer                          */
static unsigned char *llp1 = llbuf; /* pointer to next avail. in buffer     */
static unsigned char *llp2 = llbuf; /* pointer to end of lookahead          */
static unsigned char *llend = llbuf;/* pointer to end of buffer             */

extern yytab lextab;
static yytab *lltab = &lextab;

extern void exit(int);
extern int yywrap(void);
extern void yyecho(void);
extern void yyerror(char*, ...);

extern int yyinp(void);
extern void yyout(char);

static int llset(void);
static int llinp(void);
static int lltst(int, char*);
static int llmov(yytab*, int, int);

yylex()
{
    register yytab *lp;
    yyrej   *save;
    register int c;
    int     st, l, llk, final;
    char    *cp;

loop:
    if (llset()) {
        if (yywrap())
            return(0);
    }
    st = 0;
    llk = 0;
    lp = lltab;
    save = lp->llback;
    final = -1;
    llend = llbuf + 1;

    do {
        if (lp->lllook && (l = lp->lllook[st]) != 0) {
            for (c=0; c<NBPW; c++)
                if (l&(1<<c))
                    llsave[c] = llp1;
            llk++;
        }
        if ((c = lp->llfinal[st]) != -1) {
            save->llfin = final;
            save->lllen = llend - llbuf;
            save++;
            final = c;
            if ((l = ((c >> 11) & 037)) != 0)
                llend = llsave[l-1];
            else
                llend = llp1;
        }
        if ((c = llinp()) <= 0)
            break;
        if ((cp = lp->llbrk) != 0 && llk == 0 && lltst(c, cp)) {
            llp1--;
            break;
        }
    } while ((st = llmov(lp, c, st)) != -1);

    if (llp2 < llp1)
        llp2 = llp1;
    if (final == -1) {
        llend = llp1;
        if (st == 0 && c <= 0)
            goto loop;
        if ((cp = lp->llill) != 0 && lltst(c, cp)) {
            if (c >= ' ' && c <= '~')
                yyerror("Illegal character: %c", c);
            else
                yyerror("Illegal character: \\%03o", c);
            goto loop;
        }
    }

back:
    llp1 = llend;
    yyleng = (int)(llend - llbuf);
    yytext[yyleng] = '\0';
    if (final == -1) {
        yyecho();
        goto loop;
    }
    if ((c = (*lp->llactr)(final&03777)) >= 0)
        return(c);
    if (c == -1 && save-- > lp->llback) {
        final = save->llfin;
        llend = llbuf + save->lllen;
        yytext[yyleng] = llbuf[yyleng];
        goto back;
    }
    goto loop;
}

/*
 *  check character class table
 */
static
lltst(c, tab)
register int c;
char tab[];
{
    return(tab[(c >> 3) & 037] & (1 << (c & 07)) );
}

/*
 * Return TRUE if EOF and nothing was moved in the look-ahead buffer
 */
static
llset()
{
    register unsigned char *lp1, *lp2;

    if (llmore == 0)
        llend = llbuf;
    llmore = 0;
    for (lp1 = llend, lp2 = llp1; lp2 < llp2; lp1++, lp2++)
        *lp1 = *lp2;
    llp2 = lp1;
    llp1 = llend;
    return(lleof && llp1 == llp2);
}

static
llmov(lp, c, st)
register yytab *lp;
register int    st;
int    c;
{
    int     base;

    while ((base = lp->llbase[st]+c) > lp->llnxtmax || lp->llcheck[base] != st)
        if (st != lp->llendst)
            st = lp->lldefault[st];
        else
            return(-1);
    return(lp->llnext[base]);
}

/*
 * Get the next character from the save buffer (if possible)
 * If the save buffer's empty, then return EOF or the next
 * input character.  Ignore the character if it's in the
 * ignore class.
 */
static
llinp()
{
    register c;
    register char *cp;

    cp = lltab->llign;
    for (;;) {
        c = (llp1 < llp2) ? *llp1 : (lleof) ? EOF : yyinp();
        if (c != EOF) {
            if (cp && lltst(c, cp))
                continue;
            if (llp1 >= (llbuf+YYSIZE)) {
                yyerror("Token buffer overflow");
                exit(1);
            }
            yytext[(int)(llp1 - llbuf)] = c;
            *llp1++ = c;
        } else
            lleof = 1;
        return(c);
    }
}

/*
 *  add next token to end of this one
 */
void
yymore()
{
    llmore = 1;
}

/*
 *  switch contexts to lp
 */
yytab *
yyswitch(lp)
yytab *lp;
{
    register yytab *olp;

    olp = lltab;
    lltab = (lp == NULL) ? &lextab : lp;
    return(olp);
}

/*
 *
 */
void
yyecho()
{
    register int cp;

    for (cp = 0; cp < yyleng; cp++)
        yyout(yytext[cp]);
}

/*
 *  Look how many characters are backed up
 */
int
yylook()
{
    return (int)(llp2 - llp1);
}

/*
 *  Peek at the next character of input
 */
int
yypeek()
{
    int     c;

    if (llp1 < llp2)
        return(*llp1);
    if (lleof)
        return (EOF);
    if (llp1 >= (llbuf+YYSIZE)) {
        yyerror("Token buffer overflow");
        exit(1);
    }
    c = yyinp();
    if (c == EOF) {
        lleof = 1;
        return (EOF);
    }
    *llp1 = c;
    llp2 = llp1 + 1;
    return (c);
}

/*
 *  steal next character from input
 */
int
yynext()
{
    int     c;

    c = (llp1 < llp2) ? *llp1++ : (lleof) ? EOF : yyinp();
    if (c == EOF)
        lleof = 1;
    return(c);
}

/*
 *  put back c on input
 */
void
yyback(c)
{
    register unsigned char *lp1, *lp2;

    if (llp1 > llend)
        llp1--;
    else if (llp2 >= (llbuf+YYSIZE)) {
        yyerror("Token buffer overflow");
        exit(1);
    }
    else {
        for (lp1 = llp1, lp2 = llp2 - 1; lp2 >= lp1; lp2--)
            lp2[1] = lp2[0];
        llp2++;
    }
    *llp1 = c;
}

/*
 *  add character to token
 */
void
yyplus(c)
{
    register unsigned char *lp1, *lp2;

    if (llp1 == llend) {
        if (llp2 >= (llbuf+YYSIZE)) {
            yyerror("Token buffer overflow");
            exit(1);
        }
        for (lp1 = llp1, lp2 = llp2 - 1; lp2 >= lp1; lp2--)
            lp2[1] = lp2[0];
        llp1++;
        llp2++;
    }
    yytext[(int)(llend - llbuf)] = c;
    *llend = c;
    llend++;
    yyleng = (int)(llend - llbuf);
    yytext[yyleng] = '\0';
}

/*
 *  trim token to length n
 */
void
yyless(n)
{
    register unsigned char *lp1, *lp2;

    for (lp1 = llend, lp2 = llp1; lp2 < llp2; lp1++, lp2++)
        *lp1 = *lp2;
    llp2 = lp1;
    if (n < 0)
        n = 0;
    else if (n > (int)(llend - llbuf))
        n = (int)(llend - llbuf);
    yyleng = n;
    yytext[n] = '\0';
    llend = llp1 = llbuf + n;
}

/*
 * Re-initialize yylex() so that it can be re-used on
 * another file.
 */
void
yyinit()
{
    lleof = llmore = yyline = yyleng = 0;
    llp1 = llp2 = llend = llbuf;
    lltab = &lextab;
    *yytext = '\0';
}

