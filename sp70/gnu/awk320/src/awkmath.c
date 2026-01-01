/*
 * Awk math operations
 *
 * Copyright (C) 1988, 1989, 1990, 1991 by Rob Duff
 * All rights reserved
 */

#include <math.h>
#include "awkfstr.h"
#include "awk.h"

/*
 * Perform arithmetic calculations
 */
void arithmetic(int op, ITEM *a, ITEM *b, ITEM *c)
{
    double  ad, bd;

    c->sclass = ACTUAL;
    c->stype = S_DOUBLE;
    bd = todouble(b);
    ad = todouble(a);
    switch(op) {
    case C_MUL: c->svalue.dval = (ad * bd); break;
    case C_DIV: c->svalue.dval = (ad / bd); break;
    case C_MOD: c->svalue.dval = fmod(ad, bd); break;
    case C_SUB: c->svalue.dval = (ad - bd); break;
    case C_ADD: c->svalue.dval = (ad + bd); break;
    case C_POW: c->svalue.dval = pow(ad, bd); break;
    default:  c->svalue.dval = 0;
    }
    c->sstr = nullstr;
}

/*
 * compare numbers and strings
 */
void compare(int op, ITEM *a, ITEM *b, ITEM *c)
{
    int     sc;
    double  ad, bd;
    FSTR    as, bs;

    c->sclass = ACTUAL;
    c->stype = S_SHORT;
    if (a->stype <= S_NUMBER && b->stype <= S_NUMBER) {
        bd = todouble(b);
        ad = todouble(a);
        switch(op) {
        case C_EQ: c->svalue.ival = (ad == bd); break;
        case C_NE: c->svalue.ival = (ad != bd); break;
        case C_LT: c->svalue.ival = (ad <  bd); break;
        case C_GT: c->svalue.ival = (ad >  bd); break;
        case C_LE: c->svalue.ival = (ad <= bd); break;
        case C_GE: c->svalue.ival = (ad >= bd); break;
        default: c->svalue.ival = 0;
        }
    }
    else {
        as = onestring(a);
        bs = tostring(b);
        sc = fstrcmp(as+1, bs+1);
        switch (op) {
        case C_EQ: c->svalue.ival = (sc == 0); break;
        case C_NE: c->svalue.ival = (sc != 0); break;
        case C_LT: c->svalue.ival = (sc <  0); break;
        case C_GT: c->svalue.ival = (sc >  0); break;
        case C_LE: c->svalue.ival = (sc <= 0); break;
        case C_GE: c->svalue.ival = (sc >= 0); break;
        default: c->svalue.ival = 0;
        }
    }
    c->sstr = nullstr;
}

/*
 * double single argument function
 */
void dfunc1(int op, ITEM *a, ITEM *c)
{
    double  ad;

    c->sclass = ACTUAL;
    c->stype = S_DOUBLE;
    ad = todouble(a);
    switch (op) {
    case C_NUM:   c->svalue.dval = ad; break;
    case C_NEG:   c->svalue.dval = -ad; break;
    case C_COS:   c->svalue.dval = cos(ad); break;
    case C_EXP:   c->svalue.dval = exp(ad); break;
    case C_LOG:   c->svalue.dval = log(ad); break;
    case C_SIN:   c->svalue.dval = sin(ad); break;
    case C_SQRT:  c->svalue.dval = sqrt(ad); break;
    default:    c->svalue.dval = 0;
    }
    c->sstr = nullstr;
}

/*
 * double double argument function
 */
void dfunc2(int op, ITEM *a, ITEM *b, ITEM *c)
{
    double  ad, bd;

    c->sclass = ACTUAL;
    c->stype = S_DOUBLE;
    ad = todouble(a);
    bd = todouble(b);
    switch (op) {
    case C_ATAN2: c->svalue.dval = atan2(ad, bd); break;
    case C_POW:   c->svalue.dval = pow(ad, bd); break;
    default:    c->svalue.dval = 0;
    }
    c->sstr = nullstr;
}

