/*
 * Awk code generator
 *
 * Copyright (C) 1988, 1989, 1990, 1991 by Rob Duff
 * All rights reserved
 */

#include <stdio.h>
#include <mem.h>
#include "awk.h"
#include "awklex.h"

short linenum = 0;                  /* line number for next opcode */
short lastptr = 0;                  /* index to previous opcode */
short codeptr = 0;                  /* index into code buffer */
short lastlabel = 0;                /* index into jump target list */
short nextlabel = 1;
LABLE labels[MAXLABEL];             /* table to hold jump targets */

TRIX trix;

void putline(void);
void genline(void);

int
getlabel()
{
    int     label;

    if (lastlabel >= MAXLABEL)
        yyerror("label overflow");
    label = lastlabel++;
    labels[label].where = 0;
    labels[label].label = nextlabel++;
#ifdef LDEBUG
    print_label("get", label);
#endif
    return(label);
}

void putlabel(int label)
{
#ifdef LDEBUG
    print_label("put", label);
#endif
    lastlabel--;
    if (labels[label].where < 0)
        yyerror("undefined label");
    if (label != lastlabel)
        yyerror("lost label");
}

void uselabel(int label, int value)
{
    int     i;

#ifdef LDEBUG
    print_label("use", label);
    print_label("for", value);
#endif
    i = labels[label].where;
    labels[label].where = labels[value].where;
    labels[value].where = i;
}

void genlabel(int label)
{
    int     i, loc, tmp;

    loc = -labels[label].where;
    labels[label].where = codeptr + 1;
    while (loc > 0) {
        for (i = 0; i < sizeof(short); i++)
            trix.sval[i] = code[loc+i];
        tmp = trix.ival;
        trix.ival = codeptr - (loc + sizeof(short));
        for (i = 0; i < sizeof(short); i++)
            code[loc+i] = trix.sval[i];
        loc = tmp;
    }
#ifdef LDEBUG
    printf("set %d(%d)\n", labels[label].label, labels[label].where);
#endif
    genline();
}

LINK*
genact(char *cp)
{
    LINK *lp;

    lp = yyalloc(sizeof(LINK));
    lp->cnext = NULL;
    lp->ccode = cp;
    return lp;
}

RULE*
genrule(char *start, char *stop)
{
    RULE *rp;

    rp = yyalloc(sizeof(RULE));
    rp->start = start;
    rp->stop = stop;
    rp->seen = 0;
    rp->flag = 0;
    rp->action = NULL;
    rp->next = NULL;
    return rp;
}

char*
gencode()
{
    char    *cp;

#ifdef CDEBUG
    print_code(code);
#endif
    cp = yyalloc(codeptr);
    memcpy(cp, code, codeptr);
    code[0] = C_END;
    codeptr = 0;
    lastptr = 0;
    lastlabel = 0;
    stackptr = stacktop;
    return cp;
}

void putline()
{
    int     i;

    if (awkline > 0 && linenum > 0) {
        code[codeptr++] = C_LINE;
        trix.sptr = yyname;
        for (i = 0; i < sizeof(char*); i++)
            code[codeptr++] = trix.sval[i];
        trix.ival = linenum;
        for (i = 0; i < sizeof(short); i++)
            code[codeptr++] = trix.sval[i];
        linenum = 0;
    }
}

void genline()
{
    linenum = yyline;
}

void gendrop(void)
{
    int     op;

    op = code[lastptr];
    if (op == C__PRE || op == C__POST || op == C__STORE || op == C__COPY)
        code[lastptr] = op + 1; 
    else {
        putline();
        lastptr = codeptr;
        code[codeptr++] = C_DROP;
    }
}

void genstore(int arg)
{
    int     op;

    putline();
    if (code[lastptr] == C_LOAD) {
        codeptr = lastptr;
        op = C__COPY;
    }
    else if (code[lastptr] == C_FETCH) {
        code[lastptr] = C_ADDR;
        op = C__COPY;
    }
    else if (code[lastptr] == C_PLUCK) {
        code[lastptr] = C_FIELD;
        op = C__COPY;
    }
    else
        op = C__STORE;
    lastptr = codeptr;
    code[codeptr++] = op;
    code[codeptr++] = arg;
}

void genbyte(int op)
{
    putline();
    lastptr = codeptr;
    code[codeptr++] = op;
}

void gentwo(int op, int arg)
{
    putline();
    lastptr = codeptr;
    code[codeptr++] = op;
    code[codeptr++] = arg;
}

void gendcon(double dcon)
{
    int     i;

    putline();
    lastptr = codeptr;
    code[codeptr++] = C_DCON;
    trix.dval = dcon;
    for (i = 0; i < sizeof(double); i++)
        code[codeptr++] = trix.sval[i];
}

void genicon(int icon)
{
    int     i;

    putline();
    lastptr = codeptr;
    if (icon <= 255)  {
        code[codeptr++] = C_CCON;
        trix.cval = (char)icon;
        for (i = 0; i < sizeof(char); i++)
            code[codeptr++] = trix.sval[i];
    }
    else {
        code[codeptr++] = C_ICON;
        trix.ival = (int)icon;
        for (i = 0; i < sizeof(short); i++)
            code[codeptr++] = trix.sval[i];
    }
}

void genlcon(long lcon)
{
    int     i;

    putline();
    lastptr = codeptr;
    code[codeptr++] = C_LCON;
    trix.lval = (long)lcon;
    for (i = 0; i < sizeof(long); i++)
        code[codeptr++] = trix.sval[i];
}

void genscon(char *scon)
{
    int     i;

    putline();
    lastptr = codeptr;
    code[codeptr++] = C_SCON;
    trix.sptr = scon;
    for (i = 0; i < sizeof(char*); i++)
        code[codeptr++] = trix.sval[i];
}

void genrcon(char *rcon)
{
    int     i;

    putline();
    lastptr = codeptr;
    code[codeptr++] = C_RCON;
    trix.vptr = rcon;
    for (i = 0; i < sizeof(void*); i++)
        code[codeptr++] = trix.sval[i];
}

void genfield(double field)
{
    int     i;

    if ( field < 0 || field >= MAXFIELD )
        yyerror("Field number out of range");
    putline();
    lastptr = codeptr;
    code[codeptr++] = C_FIELD;
    trix.vptr = fieldtab + (int)field;
    for (i = 0; i < sizeof(void*); i++)
        code[codeptr++] = trix.sval[i];
}

void genfcon(int fcon)
{
    int     i;

    putline();
    lastptr = codeptr;
    code[codeptr++] = C_FCON;
    trix.vptr = files + fcon;
    for (i = 0; i < sizeof(void*); i++)
        code[codeptr++] = trix.sval[i];
}

void genaddr(IDENT *var)
{
    int     i;
    LIST    *lp;

    putline();
    lastptr = codeptr;
    i = 0;
    for (lp = yydisplay; lp != NULL; lp = lp->lnext) {
        if (lp->litem == var) {
            code[codeptr++] = C_AUTO;
            trix.ival = i;
            for (i = 0; i < sizeof(int); i++)
                code[codeptr++] = trix.sval[i];
            return;
        }
        i++;
    }
    if (var->vitem == NULL) {
        var->vitem = nextvar++;
        code[codeptr++] = C_ADDR;
    }
    else if ((ITEM*)(var->vitem) - vartab < builtin)
        code[codeptr++] = C_BUILT;
    else
        code[codeptr++] = C_ADDR;
    trix.vptr = var->vitem;
    for (i = 0; i < sizeof(void*); i++)
        code[codeptr++] = trix.sval[i];
}

void gencall(int func, int args)
{
    putline();
    lastptr = codeptr;
    code[codeptr++] = C_CALL;
    code[codeptr++] = func;
    code[codeptr++] = args;
}

void genuser(IDENT *func, int args)
{
    int     i;

    putline();
    lastptr = codeptr;
    code[codeptr++] = C_USER;
    trix.vptr = func;
    for (i = 0; i < sizeof(void*); i++)
        code[codeptr++] = trix.sval[i];
    code[codeptr++] = args;
}

void genjump(int kind, int label)
{
    int     i, loc;

    putline();
    lastptr = codeptr;
    code[codeptr++] = kind;
    loc = labels[label].where;
    if (loc <= 0) {
        trix.ival = -loc;
        labels[label].where = -codeptr;
    }
    else
        trix.ival = loc - (codeptr + sizeof(short) + 1);
    for (i = 0; i < sizeof(short); i++)
        code[codeptr++] = trix.sval[i];
}

int
lastcode()
{
    return code[lastptr];
}

double
lastdcon()
{
    codeptr = lastptr;
    return *(double*)(&code[lastptr+1]);
}

void
lastvoid()
{
    codeptr = lastptr;
}

void
lastop(int op)
{
    code[lastptr] = op;
}
