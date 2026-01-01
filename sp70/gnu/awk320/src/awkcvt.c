/*
 * Awk ITEM conversion routines
 *
 * Copyright (C) 1988, 1989, 1990, 1991 by Rob Duff
 * All rights reserved
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "awk.h"
#include "awkfstr.h"

extern long fatol(FSTR);

static  char    onestr[66];
static  char    twostr[66];
static  char    numstr[66];

static void updatenf(ITEM*);

/*
 * convert any item to a double
 */
double todouble(ITEM *ip)
{
    switch(ip->stype) {
    case S_SHORT:
        return (ip->svalue.ival);
    case S_LONG:
        return (ip->svalue.lval);
    case S_DOUBLE:
    case S_NUMBER:
        return (ip->svalue.dval);
    case S_STRING:
        fstrncpy(numstr, ip->sstr, 64);
        return(atof(numstr+1));
    default:
        return 0;
    }
}

/*
 * convert any item to a long
 */
long tolong(ITEM *ip)
{
    switch(ip->stype) {
    case S_SHORT:
        return (long)(ip->svalue.ival);
    case S_LONG:
        return (long)(ip->svalue.lval);
    case S_DOUBLE:
    case S_NUMBER:
        return (long)(ip->svalue.dval);
    case S_STRING:
        return(fatol(ip->sstr+1));
    default:
        return 0L;
    }
}

/*
 * convert any item to an integer
 */
int tointeger(ITEM *ip)
{
    switch(ip->stype) {
    case S_SHORT:
    case S_LONG:
        return (ip->svalue.ival);
    case S_DOUBLE:
    case S_NUMBER:
        return (ip->svalue.dval);
    case S_STRING:
        return((int)fatol(ip->sstr+1));
    default:
        return 0;
    }
}

/*
 * a value has been assigned to a field so update NF
 */
static void updatenf(ITEM *ip)
{
    int     i;

    parse();
    i = (int)(ip - fieldtab);
    if (i > tointeger(nf)) {
        free_item(nf);
        nf->stype = S_SHORT;
        nf->svalue.ival = i;
    }
}

/*
 * return a pointer to a variable
 * if there is an error return a pointer to null
 */
ITEM *tovariable(ITEM *ip, int mode)
{
    ITEM    *vp;

    switch(ip->stype) {
    case S_FIELD:
        vp = ip->svalue.sptr;
        if (mode == C_LOAD) {
            if (vp == fieldtab)
                unparse();
            else
                parse();
        }
        else {
            if (vp == fieldtab) {
                modrecord = 1;
                modfield = 0;
            }
            else {
                updatenf(vp);
                modrecord = 0;
                modfield = 1;
            }
        }
        return ip->svalue.sptr;
    case S_BUILT:
        vp = ip->svalue.sptr;
        if (vp <= ofmt) {
            parse();
            unparse();
            if (vp == nf && mode == C_STORE)
                modfield = 1;
        }
    case S_SIMPLE:
    case S_STACK:
    case S_ARRAY:
        return ip->svalue.sptr;
    default:
        return vartab;
    }
}

/*
 * convert an item to a FYLE pointer
 * the parser makes sure that the item
 * is of type FILES
 */
FYLE *tofyle(ITEM *ip)
{
    FYLE    *fp;

    fp = ip->svalue.fptr;
    fstrncpy(numstr, fp->fname, 64);
    if (fp->ffyle == NULL)
        fp->ffyle = fopen(numstr+1, fp->fmode);
    if (fp->ffyle == NULL && fp->fmode[0] != 'r')
        error("can't open file \"%s\" for %s", numstr+1, fp->fmode);
    return fp;
}

/*
 * convert any item to a string
 * if it is not already a string
 * sprintf it into a buffer
 */
FSTR onestring(ITEM *ip)
{
    *onestr = ZSTR;
    switch(ip->stype) {
    case S_SHORT:
        sprintf(onestr+1, "%d", ip->svalue.ival);
        return onestr;
    case S_LONG:
        sprintf(onestr+1, "%ld", ip->svalue.lval);
        return onestr;
    case S_DOUBLE:
        sprintf(onestr+1, ofmtstr+1, ip->svalue.dval);
        return onestr;
    case S_NUMBER:
    case S_STRING:
        return(ip->sstr);
    default:
        return nullstr;
    }
}

/*
 * convert any item to a string
 * if it is not already a string
 * sprintf it into a buffer
 */
FSTR tostring(ITEM *ip)
{
    *twostr = ZSTR;
    switch(ip->stype) {
    case S_SHORT:
        sprintf(twostr+1, "%d", ip->svalue.ival);
        return twostr;
    case S_LONG:
        sprintf(twostr+1, "%ld", ip->svalue.lval);
        return twostr;
    case S_DOUBLE:
        sprintf(twostr+1, ofmtstr+1, ip->svalue.dval);
        return twostr;
    case S_NUMBER:
    case S_STRING:
        return(ip->sstr);
    default:
        return nullstr;
    }
}

/*
 * coerce to regular expression
 * (regexp uses buffer)
 */
char *toregexp(ITEM *ip)
{
    if (ip->stype == S_REGEXP)
        return ip->svalue.cptr;
    lineptr = tostring(ip) + 1;
    yyinit();
    return regexp(0);
}

