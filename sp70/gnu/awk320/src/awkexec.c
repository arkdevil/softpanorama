/*
 * Awk pseudo code execution
 *
 * Copyright (C) 1988, 1989, 1990, 1991 by Rob Duff
 * All rights reserved
 */

#define XDEBUG 1

#include <stdio.h>
#include <conio.h>
#include <string.h>
#include <stdlib.h>
#include <mem.h>
#include <math.h>
#include <time.h>
#include <alloc.h>
#include <setjmp.h>

#include "awkfstr.h"
#include "awk.h"

#define getarg(type) (*((type*)pcode)++)

extern jmp_buf nextjmp, exitjmp;

#define pop(x) xpop(x)
#define push(x) xpush(x)
#define get(x, y) xmove(x, y)

extern void xpop(void far *dst);
extern void xpush(void far *src);
extern void xmove(void far *dst, void far *src);

extern int rexp;

extern long randl(void);
extern void srandl(long);

int test(int, ITEM*);
int isin(ITEM*, ITEM*);
int ijump(ITEM*, ITEM*);
int split(FSTR, ITEM*, FSTR);

char *xprintf(FSTR, ITEM*, int);

void load(ITEM*, ITEM*);
void fetch(ITEM*, ITEM*);
void pluck(ITEM*, ITEM*);
void store(ITEM*, ITEM*);
void index(ITEM*, ITEM*, ITEM*);
void select(ITEM*, ITEM*, ITEM*);
void copyitem(ITEM*, ITEM*);

static void call(int, int);
static void enter(IDENT*, int);
static void leave(void);

void make_array(ITEM*);
void clear_array(ITEM*);
ELEMENT *add_element(ELEMENT*, ITEM*);

void free_item(ITEM*);
void free_string(FSTR);
void free_array(ELEMENT*);

FSTR allstr(unsigned long);
void *allawk(unsigned);
ELEMENT *allell(void);
void relell(ELEMENT*);

extern int trace;

static int break_check = 100;

static  ITEM    a[1] = { { ACTUAL, S_SHORT } };
static  ITEM    b[1] = { { ACTUAL, S_SHORT } };
static  ITEM    c[1] = { { ACTUAL, S_SHORT } };
static  ITEM  one[1] = { { ACTUAL, S_SHORT, "\0377", 1 } };

static ELEMENT *ellist = NULL;
static  int     opcode;
static  int     i, j;
static  void    *v;

struct {
    int     cyline;
    void    *cpcode;
    void    *cdebug;
    ITEM    *cframe;
    ITEM    *cstack;
} stack[MAXLEVEL];

static int  level;
static char *pcode;
static char *debug;

/*
 * execute pseudo code and return expression value
 */
int awkexec(char *cp)
{
    level = 0;
    yyline = 0;
    pcode = cp;
    debug = cp;
    for (;;) {
#if XDEBUG
        if (trace)
            print_op(debug, pcode);
#endif
        opcode = *pcode++;
        switch (opcode) {
        case C_END:
            if (stackptr < stacktop) {
                i = test(C_IS, stackptr);
                while (stackptr < stacktop)
                    free_item(stackptr++);
            }
            else
                i = 0;
            return i;
        case C_EQ:
        case C_NE:
        case C_LT:
        case C_GT:
        case C_LE:
        case C_GE:
            compare(opcode, stackptr+1, stackptr, c);
            free_item(stackptr++);
            free_item(stackptr++);
            push(c);
            break;
        case C_MUL:
        case C_DIV:
        case C_MOD:
        case C_ADD:
        case C_SUB:
            arithmetic(opcode, stackptr+1, stackptr, c);
            free_item(stackptr++);
            free_item(stackptr++);
            push(c);
            break;
        case C_PRE:
        case C__PRE:
            i = C__PRE;
            load(stackptr, a);
            arithmetic(getarg(char), a, one, c);
            store(c, stackptr);
            free_item(stackptr++);
            free_item(a);
            if (opcode == i)
                push(c);
            else
                free_item(c);
            break;
        case C_POST:
        case C__POST:
            i = C__POST;
            load(stackptr, c);
            arithmetic(getarg(char), c, one, a);
            store(a, stackptr);
            free_item(stackptr++);
            if (opcode == i)
                push(c);
            else
                free_item(c);
            break;
        case C_IS:
        case C_NOT:
            c->svalue.ival = test(opcode, stackptr);
            c->stype = S_SHORT;
            c->sclass = ACTUAL;
            c->sstr = nullstr;
            free_item(stackptr++);
            push(c);
            break;
        case C_RAND:
            c->svalue.dval = ldexp(randl(), rexp);
            c->stype = S_DOUBLE;
            c->sclass = ACTUAL;
            c->sstr = nullstr;
            push(c);
            break;
        case C_SYS:
            fstrncpy(buffer, tostring(stackptr), MAXCODE-1);
            c->svalue.ival = system(buffer+1);
            c->stype = S_SHORT;
            c->sclass = ACTUAL;
            free_item(stackptr++);
            push(c);
            break;
        case C_LEN:
            c->svalue.lval = fstrlen(tostring(stackptr)+1);
            c->stype = S_LONG;
            c->sclass = ACTUAL;
            c->sstr = nullstr;
            free_item(stackptr++);
            push(c);
            break;
        case C_INT:
            modf(todouble(stackptr), &c->svalue.dval);
            c->stype = S_DOUBLE;
            c->sclass = ACTUAL;
            c->sstr = nullstr;
            free_item(stackptr++);
            push(c);
            break;
        case C_NEG:
        case C_NUM:
        case C_COS:
        case C_EXP:
        case C_LOG:
        case C_SIN:
        case C_SQRT:
            dfunc1(opcode, stackptr, c);
            free_item(stackptr++);
            push(c);
            break;
        case C_ATAN2:
        case C_POW:
            dfunc2(opcode, stackptr+1, stackptr, c);
            free_item(stackptr++);
            free_item(stackptr++);
            push(c);
            break;
        case C_IN:
            c->svalue.ival = isin(stackptr+1, stackptr);
            c->stype = S_SHORT;
            c->sclass = ACTUAL;
            free_item(stackptr++);
            free_item(stackptr++);
            push(c);
            break;
        case C_MAT:
            match(tostring(stackptr+1), toregexp(stackptr));
            c->svalue.ival = rstart?1:0;
            c->stype = S_SHORT;
            c->sclass = ACTUAL;
            free_item(stackptr++);
            free_item(stackptr++);
            push(c);
            break;
        case C_CAT:
            c->sstr = catstr(onestring(stackptr+1), tostring(stackptr));
            c->stype = S_STRING;
            c->sclass = ACTUAL;
            free_item(stackptr++);
            free_item(stackptr++);
            push(c);
            break;
        case C_UPR:
            c->sstr = uprstr(onestring(stackptr));
            c->stype = S_STRING;
            c->sclass = ACTUAL;
            free_item(stackptr++);
            push(c);
            break;
        case C_LWR:
            c->sstr = lwrstr(onestring(stackptr));
            c->stype = S_STRING;
            c->sclass = ACTUAL;
            free_item(stackptr++);
            push(c);
            break;
        case C_SELECT:
            select(stackptr+1, stackptr, c);
            free_item(stackptr++);
            free_item(stackptr++);
            push(c);
            break;
        case C_LOAD:
            load(stackptr, c);
            free_item(stackptr++);
            push(c);
            break;
        case C_FETCH:
            fetch(getarg(void*), c);
            push(c);
            break;
        case C_PLUCK:
            pluck(getarg(void*), c);
            push(c);
            break;
        case C_STORE:
        case C__STORE:
            i = C__STORE;
            j = getarg(char);
            if (j == 0)
                copyitem(stackptr, c);
            else {
                load(stackptr+1, a);
                arithmetic(j, a, stackptr, c);
                free_item(a);
            }
            store(c, stackptr+1);
            free_item(stackptr++);
            free_item(stackptr++);
            if (opcode == i)
                push(c);
            else
                free_item(c);
            break;
        case C_COPY:
        case C__COPY:
            i = C__COPY;
            j = getarg(char);
            if (j == 0)
                load(stackptr, c);
            else {
                load(stackptr+1, a);
                load(stackptr, b);
                arithmetic(j, a, b, c);
                free_item(b);
                free_item(a);
            }
            store(c, stackptr+1);
            free_item(stackptr++);
            free_item(stackptr++);
            if (opcode == i)
                push(c);
            else
                free_item(c);
            break;
        case C_DUP:
            stackptr--;
            copyitem(stackptr+1, stackptr);
            break;
        case C_UNDER:
            stackptr--;
            copyitem(stackptr+2, stackptr);
            break;
        case C_SWAP:
            get(c, stackptr);
            get(stackptr, stackptr+1);
            get(stackptr+1, c);
            break;
        case C_DROP:
            free_item(stackptr++);
            break;
        case C_CALL:
            i = getarg(char);   /* procnum */
            j = getarg(char);   /* params */
            call(i, j);
            break;
        case C_USER:
            v = getarg(void*);  /* function */
            i = getarg(char);   /* params */
            enter(v, i);
            break;
        case C_RETURN:
            pop(c);
            leave();
            push(c);
            break;
        case C_JUMP:
            i = getarg(short);
            pcode += i;
            if (break_check-- < 0) {
                kbhit();
                break_check = 100;
            }
            break;
        case C_FJMP:
        case C_TJMP:
            i = getarg(short);
            if (test((opcode == C_FJMP) ? C_NOT: C_IS, stackptr)) {
                pcode += i;
                if (break_check-- < 0) {
                    kbhit();
                    break_check = 100;
                }
            }
            free_item(stackptr++);
            break;
        case C_OJMP:
        case C_AJMP:
            i = getarg(short);
            if (test((opcode == C_AJMP) ? C_NOT: C_IS, stackptr)) {
                pcode += i;
                free_item(stackptr);
                stackptr->stype = S_SHORT;
                stackptr->svalue.ival = (opcode == C_OJMP);
            }
            else
                free_item(stackptr++);
            break;
        case C_IJMP:
            i = getarg(short);
            v = tovariable(stackptr + 1, C_LOAD);
            if (ijump(stackptr, v) == 0) {
                pcode += i;
                if (break_check-- < 0) {
                    kbhit();
                    break_check = 100;
                }
                free_item(stackptr++);
                free_item(stackptr++);
            }
            break;
        case C_DOLAR:
            i = tointeger(stackptr);
            if (i < 0 || i >= MAXFIELD)
                error("Field out of range");
            c->svalue.sptr = fieldtab + i;
            c->stype = S_FIELD;
            c->sclass = FORMAL;
            free_item(stackptr++);
            push(c);
            break;
        case C_FIELD:
            c->svalue.sptr = getarg(void*);
            c->stype = S_FIELD;
            c->sclass = FORMAL;
            push(c);
            break;
        case C_BUILT:
            c->svalue.sptr = getarg(void*);
            c->stype = S_BUILT;
            c->sclass = FORMAL;
            push(c);
            break;
        case C_ADDR:
            c->svalue.sptr = getarg(void*);
            c->stype = S_SIMPLE;
            c->sclass = FORMAL;
            push(c);
            break;
        case C_AUTO:
            c->svalue.sptr = stacktop + getarg(short);
            c->stype = S_STACK;
            c->sclass = FORMAL;
            push(c);
            break;
        case C_CCON:
            c->svalue.dval = getarg(char);
            c->stype = S_DOUBLE;
            c->sclass = ACTUAL;
            push(c);
            break;
        case C_ICON:
            c->svalue.dval = getarg(short);
            c->stype = S_DOUBLE;
            c->sclass = ACTUAL;
            push(c);
            break;
        case C_LCON:
            c->svalue.lval = getarg(long);
            c->stype = S_DOUBLE;
            c->sclass = ACTUAL;
            push(c);
            break;
        case C_DCON:
            c->svalue.dval = getarg(double);
            c->stype = S_DOUBLE;
            c->sclass = ACTUAL;
            push(c);
            break;
        case C_SCON:
            c->sstr = getarg(char*);
            c->stype = S_STRING;
            c->sclass = ACTUAL;
            push(c);
            break;
        case C_RCON:
            c->svalue.cptr = getarg(void*);
            c->stype = S_REGEXP;
            c->sclass = ACTUAL;
            push(c);
            break;
        case C_FCON:
            c->svalue.fptr = getarg(void*);
            c->stype = S_FILES;
            c->sclass = ACTUAL;
            push(c);
            break;
        case C_LINE:
            yyname = getarg(char*);
            yyline = getarg(short);
            break;
        default:
            error("Invalid opcode %03o", opcode);
        }
    }
}

/*
 * test array b to see if an element with index a exists
 */
int isin(ITEM *a, ITEM *b)
{
    FSTR    si;
    ITEM    *vp;
    ELEMENT *ep;

    vp = tovariable(b, C_LOAD);
    if (vp->stype == S_ARRAY) {
        si = tostring(a);
        ep = vp->svalue.aptr;
        while (ep != NULL) {
            if (fstrcmp(si+1, ep->aindex+1) == 0)
                if (ep->atype == S_NUMBER && ep->astr == nullstr)
                    return 0;
                else
                    return 1;
            ep = ep->anext;
        }
    }
    return 0;
}

/*
 * logical (true/false) test
 */
int test(int op, ITEM *ip)
{
    if (op == C_NOT) {
        if (ip->stype == S_STRING)
            return ip->sstr[0] == '\0';
        else if (ip->stype == S_SHORT)
            return ip->svalue.ival == 0;
        else if (ip->stype == S_LONG)
            return ip->svalue.lval == 0;
        else
            return todouble(ip) == 0;
    }
    else {
        if (ip->stype == S_STRING)
            return ip->sstr[0] != '\0';
        else if (ip->stype == S_SHORT)
            return ip->svalue.ival != 0;
        else if (ip->stype == S_LONG)
            return ip->svalue.lval != 0;
        else
            return todouble(ip) != 0;
    }
}

/*
 * call the standard procedures
 */
static void call(int p, int n)
{
    int     pc, i, j, k;
    long    ltime;
    double  d;
    FSTR    s, t;
    char    *r;
    FYLE    *fp;
    ITEM    *vp;
    ELEMENT *ep;
    ELEMENT *bp;

    pc = 0;
    switch(p) {
    case P_NEXT:
        stacktop = stackbot + MAXSTACK;
        while (stackptr < stacktop) {
            free_item(stackptr);
            stackptr++;
        }
        longjmp(nextjmp, 1);
        break;
    case P_EXIT:
        if (n == 1)
            status = tointeger(stackptr);
        stacktop = stackbot + MAXSTACK;
        while (stackptr < stacktop)
            free_item(stackptr++);
        longjmp(exitjmp, 1);
        break;
    case P_SRAND:
        if (n == 0) {
            time(&ltime);
        }
        else {
            ltime = ldexp(modf(todouble(stacktop), &d), -rexp);
        }
        srandl(ltime);
        break;
    case P_PRINT:
        t = onestring((ITEM*)ofs);
        fp = tofyle(stackptr);
        for (i = n - 1; i >= 1; i--) {
            s = tostring(stackptr+i);
            fprintf(fp->ffyle, "%Fs", s+1);
            if (i > 1)
                fprintf(fp->ffyle, "%Fs", t+1);
        }
        s = onestring((ITEM*)ors);
        fprintf(fp->ffyle, "%Fs", s+1);
        break;
    case P_PRINTF:
        s = onestring(stackptr + n - 1);
        r = xprintf(s, stackptr + n - 2, n - 2);
        fp = tofyle(stackptr);
        fputs(r+1, fp->ffyle);
        break;
    case P_SPRINTF:
        pc = 1;
        s = onestring(stackptr + n - 1);
        r = xprintf(s, stackptr + n - 2, n - 1);
        c->sstr = getstr(r);
        c->stype = S_STRING;
        c->sclass = ACTUAL;
        break;
    case P_GETLINE:
        pc = 1;
        fp = tofyle(stackptr);
        vp = tovariable(stackptr+1, C_STORE);
        c->svalue.ival = getline(fp, (ITEM*)vp);
        c->stype = S_SHORT;
        c->sclass = ACTUAL;
        break;
    case P_GSUB:
    case P_LSUB:
        pc = 1;
        i = p == P_GSUB;
        r = toregexp(stackptr + 3);
        s = onestring(stackptr);
        t = tostring(stackptr + 2);
        c->sstr = subst(i, t, s, r);
        c->stype = S_STRING;
        c->sclass = ACTUAL;
        store(c, stackptr + 1);
        c->svalue.ival = rcount;
        c->stype = S_SHORT;
        c->sclass = ACTUAL;
        break;
    case P_JOIN:
        pc = 1;
        code[0] = ZSTR;
        code[1] = '\0';
        t = onestring((ITEM*)subsep);
        for (i = n - 1; i >= 0; i--) {
            s = tostring(stackptr+i);
            fstrcat(code + 1, s + 1);
            if (i > 0)
                fstrcat(code + 1, t + 1);
        }
        c->sstr = getstr(code);
        c->stype = S_STRING;
        c->sclass = ACTUAL;
        break;
    case P_SPLIT:
        pc = 1;
        vp = tovariable(stackptr + 1, C_STORE);
        s = onestring(stackptr + 2);
        t = tostring(stackptr);
        c->svalue.ival = split(s+1, vp, t+1);
        c->stype = S_SHORT;
        c->sclass = ACTUAL;
        break;
    case P_INDEX:
        pc = 1;
        s = onestring(stackptr+1)+1;
        t = tostring(stackptr)+1;
        if (*t == '\0')
            t = s;
        else
            t = fstrstr(s, t);
        if (t != NULL)
            i = (int)(t - s) + 1;
        else
            i = 0;
        c->svalue.ival = i;
        c->stype = S_SHORT;
        c->sclass = ACTUAL;
        break;
    case P_MATCH:
        pc = 1;
        s = onestring(stackptr+1);
        r = toregexp(stackptr);
        match(s, r);
        free_item(rl);
        rl->stype = S_DOUBLE;
        rl->svalue.dval = rlength;
        free_item(rst);
        rst->stype = S_DOUBLE;
        rst->svalue.dval = rstart;
        c->svalue.dval = rstart;
        c->stype = S_DOUBLE;
        c->sclass = ACTUAL;
        break;
    case P_SUBSTR:
        pc = 1;
        if (n == 3) {
            s = tostring(stackptr+2);
            i = tointeger(stackptr+1);
            j = tointeger(stackptr);
        }
        else {
            i = tointeger(stackptr);
            s = tostring(stackptr+1);
            j = fstrlen(s+1);
        }
        k = fstrlen(s+1);
        if (j < 1 || i < 1 || i > k)
            t = nullstr;
        else {
            if (j > k - i + 1)
                j = k - i + 1;
            if (j > MAXCODE-2)
                j = MAXCODE-2;
            code[0] = ZSTR;
            fstrncpy(code+1, s + i, j);
            code[j+1] = '\0';
            t = getstr(code);
        }
        c->sstr = t;
        c->stype = S_STRING;
        c->sclass = ACTUAL;
        break;
    case P_CREATE:
    case P_APPEND:
    case P_CLOSE:
    case P_OPEN:
        pc = 1;
        c->svalue.fptr = getfile(stackptr, p);
        c->stype = S_FILES;
        c->sclass = FORMAL;
        break;
    case P_DELETE:
        vp = tovariable(stackptr + 1, C_STORE);
        if (vp->stype == S_ARRAY) {
            s = tostring(stackptr);
            ep = vp->svalue.aptr;
            if (s[1] == '\0')
                free_item((ITEM*)ep);
            else {
                bp = ep;
                ep = ep->anext;
                while (ep != NULL && (i = fstrcmp(s+1, ep->aindex+1)) > 0) {
                    bp = ep;
                    ep = ep->anext;
                }
                if (ep != NULL && i == 0) {
                    bp->anext = ep->anext;
                    ep->anext = NULL;
                    c->svalue.aptr = ep;
                    c->stype = S_ARRAY;
                    c->sclass = ACTUAL;
                    free_item(c);
                }
            }
        }
        break;
    }
    while (n > 0 && stackptr < stacktop) {
        free_item(stackptr);
        stackptr++;
        n--;
    }
    if (pc)
        push(c);
}

/*
 * enter the user procedure
 */
static void enter(IDENT *p, int n)
{
    int     k;
    FUNC    *fp;

    if ((fp = p->vfunc) == NULL)
        error("function not defined %s", p->vname);
    if (level >= MAXLEVEL)
        error("function call depth too great");

    stack[level].cyline = yyline;
    stack[level].cpcode = pcode;
    stack[level].cdebug = debug;
    stack[level].cstack = stacktop;
    stack[level].cframe = stackptr + n;
    level++;

    k = fp->psize;
    while (n > k) {
        free_item(stackptr++);
        n--;
    }
    while (n < k) {
        push(nul);
        n++;
    }
    stacktop = stackptr;
    if (stacktop - stackbot < 20)
        error("Stack overflow");
    debug = pcode = fp->pcode;
}

/*
 * leave the user procedure;
 */
static void leave()
{
    ITEM    *frame;

    if (level < 1)
        error("return without gosub");
    level--;
    yyline = stack[level].cyline;
    pcode = stack[level].cpcode;
    debug = stack[level].cdebug;
    stacktop = stack[level].cstack;
    frame = stack[level].cframe;
    while (stackptr < frame) {
        free_item(stackptr++);
    }
}

/*
 * load the contents of a variable field or array
 */
void load(ITEM *sp, ITEM *dp)
{
    ITEM    *vp;

    vp = tovariable(sp, C_LOAD);
    get(dp, vp);
    if (vp->stype == S_STRING || vp->stype == S_NUMBER)
        dp->sstr = getstr(vp->sstr);
    else if (vp->stype == S_ARRAY)
        dp->sclass = FORMAL;
}

/*
 * fetch the contents of a variable or array
 */
void fetch(ITEM *sp, ITEM *dp)
{
    get(dp, sp);
    if (sp->stype == S_STRING || sp->stype == S_NUMBER)
        dp->sstr = getstr(sp->sstr);
    else if (sp->stype == S_ARRAY)
        dp->sclass = FORMAL;
}

/*
 * pluck the contents of a field
 */
void pluck(ITEM *sp, ITEM *dp)
{
    if (sp == fieldtab)
        unparse();
    else
        parse();
    get(dp, sp);
    if (sp->stype == S_STRING || sp->stype == S_NUMBER)
        dp->sstr = getstr(sp->sstr);
    else if (sp->stype == S_ARRAY)
        dp->sclass = FORMAL;
}

/*
 * Set the regular expression associated with the field separator
 */
void setfs()
{
    FSTR    fsp;

    fsp = tostring(fs);
    if (fsp[1] == ' ' && fsp[2] == '\0') {
        if (awkfs != blankfs) {
            free_string(awkfs);
            if (awkfre[1] != '\0')
                free(awkfre);
        }
        awkfs = blankfs;
        awkfre = blankre;
    }
    else if (fstrcmp(fsp+1, awkfs+1) != 0) {
        if (awkfs != blankfs) {
            free_string(awkfs);
            if (awkfs[1] == '\0' || awkfs[2] != '\0')
                free(awkfre);
        }
        awkfs = newstr(fsp);
        if (awkfs[1] != '\0' && awkfs[2] == '\0') {
            awkfre = "  ";
            if (awkfs[1] < ' ') {
                awkfre[0] = R_CHAR;
                awkfre[1] = awkfs[1];
                awkfre[2] = R_END;
            }
            else {
                awkfre[0] = awkfs[1];
                awkfre[1] = R_END;
            }
        }
        else {
            lineptr = awkfs+1;
            yyinit();
            awkfre = regexp(2);
        }
    }
}

/*
 * store an item (sp) in a variable, field or array
 */
void store(ITEM *sp, ITEM *dp)
{
    ITEM    *vp;
    ELEMENT *ep;

    if (sp->stype == S_ARRAY) {
        ep = sp->svalue.aptr;
        if (ep->atype == S_NUMBER && ep->astr == nullstr) {
            vp = tovariable(dp, C_STORE);
            if (vp == nul) return;
            ep = allell();
            ep->aclass = ACTUAL;
            ep->atype = S_NUMBER;
            ep->astr = nullstr;
            ep->avalue.dval = 0;
            ep->aindex = nullstr;
            ep->anext = NULL;
            free_item(vp);
            vp->sclass = ACTUAL;
            vp->stype = S_ARRAY;
            vp->sstr = nullstr;
            vp->svalue.aptr = ep;
            return;
        }
        else
            error("array assignment");
    }
    vp = tovariable(dp, C_STORE);
    if (vp == nul)
        return;
    free_item(vp);
    get(vp, sp);
    vp->sclass = ACTUAL;
    if (sp->stype == S_STRING || sp->stype == S_NUMBER)
        vp->sstr = newstr(sp->sstr);
    if (vp <= ofmt) {
        if (vp == ofmt)
            fstrncpy(ofmtstr, tostring(ofmt), 65);
        if (vp == fs)
            setfs();
    }
}

/*
 * free the dynamic storage occupied by an item
 */
void free_item(ITEM *ip)
{
    if (ip->stype == S_STRING || ip->stype == S_NUMBER)
        free_string(ip->sstr);
    else if (ip->sclass == ACTUAL && ip->stype == S_ARRAY)
        free_array(ip->svalue.aptr);
    get(ip, nul);
}

/*
 * free the values, indexes and elements of an array
 */
void free_array(ELEMENT *ep)
{
    ELEMENT *next;

    while (ep != NULL) {
        next = ep->anext;
        if (ep->atype == S_STRING || ep->atype == S_NUMBER)
            free_string(ep->astr);
        free_string(ep->aindex);
        relell(ep);
        ep = next;
    }
}

/*
 * free the dynamic storage occupied by a string
 * strings have a reference count to avoid multiple
 * allocation and freeing
 */
void free_string(FSTR sp)
{
    if (sp == nullstr)
        return;
    if (*sp == ZSTR || *sp == LSTR || *sp == TSTR)
        return;
    if (*sp == ZSTR + 1)
        farfree(sp);
    else
        *sp -= 1;
}

/*
 * allocate dynamic storage for a string
 * strings have a reference count to avoid multiple
 * allocation and freeing
 */
FSTR getstr(FSTR sp)
{
    long    len;
    FSTR    dp;

    if (sp[1] == '\0')
        return (nullstr);
    if (*sp == LSTR) {
        return sp;
    }
    if (*sp == TSTR) {
        return sp;
    }
    if (*sp >= 0) {
        fprintf (stderr, "Use count error %Fp '%Fs'\n", sp, sp);
    }
    if (*sp != ZSTR && *sp != ESTR) {
        *sp += 1;
        return sp;
    }
    len = fstrlen(sp+1) + 2;
    dp = allstr(len);
    fstrcpy(dp+1, sp+1);
    *dp = ZSTR + 1;
    return (dp);
}

/*
 * allocate dynamic storage for a string
 * strings have a reference count to avoid multiple
 * allocation and freeing
 * this is different from getstr in that temporary
 * strings are allocated and copied when a temp string
 * is stored in a variable or array index.
 */
FSTR newstr(FSTR sp)
{
    long    len;
    FSTR    dp;

    if (sp[1] == '\0')
        return (nullstr);
    if (*sp == LSTR) {
        return sp;
    }
    if (*sp >= 0) {
        fprintf (stderr, "Use count error %Fp '%Fs'\n", sp, sp);
    }
    if (*sp != ZSTR && *sp != TSTR && *sp != ESTR) {
        *sp += 1;
        return sp;
    }
    len = fstrlen(sp+1) + 2;
    dp = allstr(len);
    fstrcpy(dp+1, sp+1);
    *dp = ZSTR + 1;
    return (dp);
}

FSTR catstr(FSTR a, FSTR b)
{
    long    len;
    FSTR    dp;

    len = fstrlen(a+1)  + fstrlen(b+1) + 2;
    if (len > 60000L)
        error("string length exceeded");
    dp = allstr(len);
    *dp = ZSTR + 1;
    fstrcpy(dp+1, a+1);
    fstrcat(dp+1, b+1);
    return (dp);
}

FSTR uprstr(FSTR sp)
{
    long    len;
    FSTR    dp;

    len = fstrlen(sp+1) + 2;
    dp = allstr(len);
    *dp = ZSTR + 1;
    fstrupr(dp+1, sp+1);
    return (dp);
}

FSTR lwrstr(FSTR sp)
{
    long    len;
    FSTR    dp;

    len = fstrlen(sp+1) + 2;
    dp = allstr(len);
    *dp = ZSTR + 1;
    fstrlwr(dp+1, sp+1);
    return (dp);
}

/*
 * copy an item.  Strings are copied.
 */
void copyitem(ITEM *sp, ITEM *dp)
{
    get(dp, sp);
    if (sp->stype == S_STRING || sp->stype == S_NUMBER)
        dp->sstr = getstr(sp->sstr);
}

/*
 * index an array element from a with b store in c
 */
void index(ITEM *a, ITEM *b, ITEM *c)
{
    FSTR    sp;
    ITEM    *vp;
    ELEMENT *ep;

    sp = tostring(b);
    vp = tovariable(a, C_LOAD);
    if (vp->stype == S_ARRAY) {
        ep = vp->svalue.aptr;
        while (ep != NULL) {
            if (fstrcmp(sp+1, ep->aindex+1) == 0) {
                if (ep->atype == S_NUMBER && ep->astr == nullstr)
                    ep = NULL;
                break;
            }
            ep = ep->anext;
        }
    }
    else
        ep = NULL;
    if (ep == NULL)
        get(c, nul);
    else
        get(c, ep);
}

/*
 * select an array element from a with index b
 * store in c, create a new element if not found
 */
void select(ITEM *a, ITEM *b, ITEM *c)
{
    int     cmp;
    FSTR    sp;
    ITEM    *vp;
    ELEMENT *ep, *fp;

    sp = tostring(b);
    vp = tovariable(a, C_LOAD);
    make_array(vp);
    ep = vp->svalue.aptr;
    if (sp[1] != '\0') {
        fp = ep;
        ep = ep->anext;
        while (ep != NULL && (cmp = fstrcmp(sp+1, ep->aindex+1)) > 0) {
            fp = ep;
            ep = ep->anext;
        }
        if (ep == NULL || cmp != 0) {
            ep = allell();
            get(ep, nul);
            ep->aindex = newstr(sp);
            ep->anext = fp->anext;
            fp->anext = ep;
        }
    }
    c->stype = S_ARRAY;
    c->sclass = FORMAL;
    c->svalue.aptr = ep;
}

/*
 * add element ep into the array pointed to by the
 * variable pointer vp in lexical order.
 */
ELEMENT *add_element(ELEMENT *np, ITEM *vp)
{
    ELEMENT *ep, *fp;

    ep = vp->svalue.aptr;
    fp = ep;
    ep = ep->anext;
    while (ep != NULL && fstrcmp(np->aindex+1, ep->aindex+1) > 0) {
        fp = ep;
        ep = ep->anext;
    }
    ep = np;
    ep->anext = fp->anext;
    fp->anext = ep;
    return ep;
}

/*
 * make sure that a variable is of type array
 * if not then initialize it to an empty array
 */
void make_array(ITEM *vp)
{
    ELEMENT *ep;

    if (vp->stype != S_ARRAY) {
        ep = allell();
        get(ep, nul);
        ep->aindex = nullstr;
        ep->anext = NULL;
        free_item((ITEM*)vp);
        vp->sclass = ACTUAL;
        vp->stype = S_ARRAY;
        vp->svalue.aptr = ep;
    }
}

/*
 * erase an array or create a new one
 */
void clear_array(ITEM *vp)
{
    ELEMENT *ep;

    if (vp->stype == S_ARRAY) {
        ep = vp->svalue.aptr;
        free_array(ep->anext);
        free_item((ITEM*)ep);
        ep->anext = NULL;
    }
    else
        make_array(vp);
}

/*
 * split a string into fields according to
 * the regular expression lfs
 */
int split(FSTR src, ITEM *vp, FSTR lfs)
{
    char    *dst;
    char    *reg;
    FSTR    beg;
    FSTR    mat;
    FSTR    tp;
    ELEMENT *ep;

    c->stype = S_SHORT;
    c->sclass = ACTUAL;
    c->svalue.ival = 0;
    clear_array(vp);
    if (lfs[0] == ' ' && lfs[1] == '\0') {
        reg = blankre;
        while (*src == ' ' || *src == '\t' || *src == '\n')
            src++;
    }
    else if (lfs[0] != '\0' && lfs[1] == '\0') {
        reg = buffer;
        if (lfs[0] < ' ')
            *reg++ = R_CHAR;
        *reg++ = lfs[0];
        *reg++ = R_END;
        reg = buffer;
    }
    else {
        lineptr = lfs;
        yyinit();
        reg = regexp(0);
    }
    beg = src;
    while (*src != '\0') {
        dst = code;
        *dst++ = ZSTR;
        while (*src != '\0' &&
              (mat = matchp(beg, src, reg)) == NULL && *src != '\n')
            *dst++ = *src++;
        if (mat != NULL && *src != '\0') {
            if(mat > src)
                src = mat;
            else if (dst == code + 1)
                *dst++ = *src++;
        }
        else if (*src == '\n')
            src++;
        *dst++ = '\0';
        c->svalue.ival++;
        tp = getstr(tostring(c));
        ep = allell();
        ep->aclass = ACTUAL;
        ep->atype = S_STRING;
        ep->astr = getstr(code);
        ep->aindex = tp;
        ep->anext = NULL;
        ep = add_element(ep, vp);
        if (isnumber(code+1)) {
            ep->avalue.dval = todouble((ITEM*)ep);
            ep->atype = S_NUMBER;
        }
    }
    return c->svalue.ival;
}

/*
 * do the array index stepping in a 
 * for (x in y) loop
 */
int ijump(ITEM *ip, ITEM *vp)
{
    ELEMENT *ep;

    if (ip->stype != S_ARRAY)
        return 0;
    ep = ip->svalue.aptr;
    while (ep != NULL && ep->atype == S_NUMBER && ep->astr == nullstr)
        ep = ep->anext;
    if (ep == NULL)
        return 0;
    free_item((ITEM*)vp);
    vp->stype = S_STRING;
    vp->sstr = getstr(ep->aindex);
    ip->svalue.aptr = ep->anext;
    return 1;
}

/*
 * perform memory allocation with error checking
 */
FSTR allstr(unsigned long int size)
{
    FSTR    fmp;

    fmp = farmalloc(size);
    if (fmp == NULL)
        error("Out of memory");
    return(fmp);
}

/*
 * perform memory allocation with error checking
 */
void *allawk(unsigned int size)
{
    void    *mp;

    mp = malloc(size);
    if (mp == NULL)
        error("Out of memory");
    memset(mp, 0, size);
    return(mp);
}

ELEMENT *allell(void)
{
    int     i;
    ELEMENT *e;

    if (ellist == NULL) {
        e = allawk(sizeof(ELEMENT)*32);
        for (i = 0; i < 31; i++) {
            e->anext = ellist;
            ellist = e++;
        }
    }
    else {
        e = ellist;
        ellist = ellist->anext;
    }
    return e;
}

void relell(ELEMENT *e)
{
    e->anext = ellist;
    ellist = e;
}

/*
 * convert the list of n items  in ip to a string
 * according to the format string sp
 */
char *xprintf(FSTR sp, ITEM *ip, int n)
{
    char    *dp;
    char    *fp;
    int     xf, fc;
    TRIX    trix;

    sp++;
    dp = code;
    *dp++ = ZSTR;
    while (*sp != 0) {
        while (*sp != 0 && *sp != '%' && dp < code+MAXCODE-1)
            *dp++ = *sp++;
        if (n > 0 && sp[0] == '%' && sp[1] != '%') {
            xf = 0;
            fp = fmtstr;
            *fp++ = ZSTR;
            *fp++ = *sp++;
            if (*sp == '-')
                *fp++ = *sp++;
            while (*sp >= '0' && *sp <= '9')
                *fp++ = *sp++;
            if (*sp == '.') {
                *fp++ = *sp++;
                while (*sp >= '0' && *sp <= '9')
                    *fp++ = *sp++;
            }
            if (*sp == 'l')
                *fp++ = *sp++;
            *fp++ = fc = *sp++;
            *fp++ = '\0';
            switch (fc) {
            case 's':
                fp[-2] = 'F';
                fp[-1] = 's';
                *fp++ = '\0';
                trix.fstr = tostring(ip)+1;
                break;
            case 'c':
                if (ip->stype == S_STRING)
                    trix.lval = ip->sstr[1];
                else
                    trix.lval = tolong(ip);
                break;
            case 'X':
            case 'x':
            case 'o':
            case 'u':
            case 'd':
                fp[-2] = 'l';
                fp[-1] = fc;
                *fp++ = '\0';
                trix.lval = tolong(ip);
                break;
            case 'E':
            case 'F':
            case 'G':
            case 'e':
            case 'f':
            case 'g':
                trix.dval = todouble(ip);
                break;
            default:
                xf++;
                trix.lval = 0;
            }
            if (xf == 0) {
                n--;
                ip--;
            }
            sprintf(dp, fmtstr+1, trix.dval);
            dp = strchr(dp, '\0');
        }
        else if (*sp == '%') {
            *dp++ = '%';
            sp += 2;
        }
    }
    *dp = '\0';
    return code;
}

