/*
 * Awk debug printing routines
 *
 * Copyright (C) 1988, 1989, 1990, 1991 by Rob Duff
 * All rights reserved
 */

#include <stdio.h>

#include "awk.h"

#define DEBUG 1

#if DEBUG

char *optab[] ={
    "END", 
    "EQ", "NE", "LT", "GT", "LE", "GE",
    "MUL", "DIV", "MOD", "ADD", "SUB",
    "NEG", "NOT", "NUM", "_PRE ","PRE ", "_POST", "POST",
    "IS", "IN", "MAT", "CAT",
    "RAND", "SYS", "LEN", 
    "COS", "EXP", "INT", "LOG", "SIN", "SQRT", 
    "ATAN2", "POW",
    "DOLAR", "FIELD", "PLUCK", 
    "VAR", "FETCH", "AUTO", "BUILT", 
    "SELECT", "LOAD",
    "_STORE", "STORE", "_COPY", "COPY",
    "DUP", "SWAP", "UNDER", "DROP",
    "CALL", "USER", "RETURN",
    "JUMP", "FJMP", "TJMP", "AJMP", "OJMP", "IJMP",
    "CCON", "ICON", "LCON", "DCON",
    "SCON", "RCON", "FCON", "LINE"
};

char *calltab[] ={
    "none", "next", "exit", "print", "printf", "getline", 
    "srand", "gsub", "lsub", "join", "split", "delete", 
    "index", "match", "substr", "sprintf", "open", 
    "create", "append", "close", "system"
};

char *class[] ={"ACTUAL" , "FORMAL" };
char *types[] ={"SHORT", "LONG", "DOUBLE", "NUMBER", "STRING",
                "REGEXP", "ARRAY" , "STACK" , "FILES" , "FIELD ",
                "SIMPLE", "BUILTIN" };

char *jumps[] = { 
    "NORMAL","CONTINUE","BREAK","DONE","MARK","FOR","ELSE","WHILE" };

char *print_ccl(char *ccl)
{
    int     i;

    for (i = 1; i < 256; i++) {
        if (ccl[(i>>3)&037] & (1<<(i&7))) {
            if (i < ' ') {
                switch (i) {
                case '\b':
                    printf("\\b");
                    break;
                case '\f':
                    printf("\\f");
                    break;
                case '\n':
                    printf("\\n");
                    break;
                case '\r':
                    printf("\\r");
                    break;
                case '\t':
                    printf("\\t");
                    break;
                default:
                    printf("\\%03o", i);
                }
            }
            else
                printf("%c", i);
        }
    }
    return ccl+32;
}

char *print_re(char *pp)
{
    register int c;

    while ((c = *pp++) != R_END) {
        switch (c) {
        case R_BOL:       fprintf(stderr, "^"); break;
        case R_EOL:       fprintf(stderr, "$"); break;
        case R_ANY:       fprintf(stderr, "."); break;
        case R_CLASS:
            fprintf(stderr, "[");
            pp = print_ccl(pp);
            fprintf(stderr, "]");
            break;
        case R_NCLAS:
            fprintf(stderr, "[^");
            pp = print_ccl(pp);
            fprintf(stderr, "]");
            break;
        case R_BAR:
            pp = print_re(pp + 5);
            fprintf(stderr, "|");
            pp = print_re(pp);
            break;
        case R_STAR:
            fprintf(stderr, "(");
            pp = print_re(pp + 2);
            fprintf(stderr, ")*");
            break;
        case R_PLUS:
            fprintf(stderr, "(");
            pp = print_re(pp + 2);
            fprintf(stderr, ")+");
            break;
        case R_QUEST:
            fprintf(stderr, "(");
            pp = print_re(pp + 2);
            fprintf(stderr, ")?");
            break;
        case R_RANGE:
            c = *pp++;
            fprintf(stderr, "%c-%c", c, *pp++);
            break;
        case R_CHAR:
            c = *pp++;
            fprintf(stderr, "\\%03o", c);
            break;
        case '$':
        case '^':
        case '.':
        case '/':
        case '\\':
        case '*':
        case '+':
        case '?':
        case '(':
        case ')':
        case '[':
        case ']':
            fprintf(stderr, "\\");
        default:
            fprintf(stderr, "%c", c);
            break;
        }
    }
    return pp;
}

void print_code(char *st)
{
    char    *cp;

    cp = st;
    while (*cp != C_END)
        cp = print_op(st, cp);
    print_op(st, cp);
    fprintf(stderr, "\n");
}

char *print_op(char *st, char *cp)
{
    int     op, i;
    long    l;
    char    *c;
    double  d;
    FYLE    *f;
    IDENT   *v;

    i = (int)(cp - st);
    op = *cp++;
    fprintf(stderr, "%04X:%04d %04d %-8s", (int)st, i, 
        (int)(stacktop - stackptr), optab[op]);
    switch(op) {
    case C_CALL:
        i = *cp++;
        fprintf(stderr, "%s,%3d", calltab[i], *((char*)cp)++);
        break;
    case C_USER:
        v = *((IDENT**)cp)++;
        i = *cp++;
        fprintf(stderr, "%s,%3d", v->vname, i);
        break;
    case C_JUMP:
    case C_FJMP:
    case C_TJMP:
    case C_IJMP:
    case C_AJMP:
    case C_OJMP:
        i = *((short*)cp)++;
        fprintf(stderr, "%04d", i + (int)(cp - st));
        break;
    case C_LINE:
        c = *((char**)cp)++;
        i = *((short*)cp)++;
        fprintf(stderr, "%d  %s", i, c);
        break;
    case C_CCON:
        i = *((char*)cp)++;
        fprintf(stderr, "%d", i);
        break;
    case C_AUTO:
    case C_ICON:
        i = *((short*)cp)++;
        fprintf(stderr, "%d", i);
        break;
    case C_LCON:
        l = *((long*)cp)++;
        fprintf(stderr, "%ld", l);
        break;
    case C_DCON:
        d = *((double*)cp)++;
        fprintf(stderr, "%.10g", d);
        break;
    case C_FCON:
        f = *((FYLE**)cp)++;
        fprintf(stderr, "%s", f->fname+1);
        break;
    case C_RCON:
        c = *((char**)cp)++;
        fprintf(stderr, "/");
        print_re(c);
        fprintf(stderr, "/");
        break;
    case C_SCON:
        c = (*((char**)cp)++)+1;
        fprintf(stderr, "\"%s\"", c);
        break;
    case C_FIELD:
    case C_PLUCK:
        i = (int)((*((ITEM**)cp)++) - fieldtab);
        fprintf(stderr, "$%d", i);
        break;
    case C_ADDR:
    case C_BUILT:
    case C_FETCH:
        v = lookfor((*((ITEM**)cp)++));
        fprintf(stderr, "%s", v->vname);
        break;
    case C_PRE:
    case C_POST:
    case C_STORE:
    case C_COPY:
    case C__PRE:
    case C__POST:
    case C__STORE:
    case C__COPY:
        i = *((char*)cp)++;
        if (i != 0) {
            fprintf(stderr, "%s", optab[i]);
            break;
        }
    }
    fprintf(stderr, "\n");
    return cp;
}

void print_one(char *sp, ITEM *ip)
{
    fprintf(stderr, "%s: ", sp);
    print_item(ip);
    fprintf(stderr, "\n");
}

void print_two(char *sp, ITEM *ip1, ITEM *ip2)
{
    fprintf(stderr, "%s: ", sp);
    print_item(ip1);
    print_item(ip2);
    fprintf(stderr, "\n");
}

void print_element(char *sp, ELEMENT *ep)
{
    fprintf(stderr, "%s ", sp);
    if (ep == NULL)
        fprintf(stderr, "<NULL>");
    else {
        printf("[%Fs] ", ep->aindex+1);
        print_item((ITEM*)ep);
    }
    fprintf(stderr, "\n");
}

void print_item(ITEM *ip)
{
    fprintf(stderr, "%s %s ", class[ip->sclass], types[ip->stype]);
    print_value(ip);
}

void print_value(ITEM *ip)
{
    int     i;
    FYLE    *fp;
    ELEMENT *ep;

    switch (ip->stype) {
    case S_SHORT:
        fprintf(stderr, "%d ", ip->svalue.ival);
        break;
    case S_LONG:
        fprintf(stderr, "%ld ", ip->svalue.lval);
        break;
    case S_DOUBLE:
        fprintf(stderr, "%.6g", ip->svalue.dval);
        fprintf(stderr, " ");
        break;
    case S_NUMBER:
        if (ip->sstr == nullstr) {
            fprintf(stderr, "<DEFAULT>");
            break;
        }
    case S_STRING:
        fprintf(stderr, "\"%Fs\" ", ip->sstr+1);
        break;
    case S_FILES:
        fp = ip->svalue.fptr;
        fprintf(stderr, "%Fs(%d)x %4X", fp->fname+1, (int)(fp-files), fp->ffyle);
        break;
    case S_FIELD:
        i = (int)(ip->svalue.sptr - fieldtab);
        fprintf(stderr, "$%d ", i);
        print_item(ip->svalue.sptr);
        break;
    case S_SIMPLE:
    case S_BUILT:
        i = (int)(ip->svalue.sptr - vartab);
        fprintf(stderr, "%d", i);
        print_item(ip->svalue.sptr);
        break;
    case S_STACK:
        i = (int)(ip->svalue.sptr - stacktop);
        fprintf(stderr, "%d ", i);
        print_item(ip->svalue.sptr);
        break;
    case S_ARRAY:
        ep = ip->svalue.aptr;
        fprintf(stderr, "\n");
        while (ep != NULL) {
            print_element("       ", ep);
            ep = ep->anext;
        }
        break;
    default:
        fprintf(stderr, "%04X ", ip->svalue.ival);
        break;
    }
}

void print_label(char *str, int label)
{
    printf("%s %d(%d)\n", str, labels[label].label, labels[label].where);
}

#endif


