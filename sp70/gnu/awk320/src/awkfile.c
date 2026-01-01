/*
 * Awk file and command line processing
 *
 * Copyright (C) 1988, 1989, 1990, 1991 by Rob Duff
 * All rights reserved
 */

#include <stdio.h>
#include <conio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>

#include "awkfstr.h"
#include "awk.h"

extern long fatol(FSTR);
ELEMENT *allell(void);

short modfield = 0;
short modrecord = 0;

static ITEM argn[1] = { { ACTUAL, S_SHORT } };
static ITEM argp[1] = { { FORMAL, S_SIMPLE } };

static  char    argvbuf[66];        /* string form of getargv */

static void set_element(int, char*, ITEM*);

/*
 * set an element of the ARGV array
 */
static void set_element(int argc, char *arg, ITEM *vp)
{
    FSTR    sp;
    ELEMENT *ep;
    ITEM    ip[1];

    ip->stype = S_SHORT;
    ip->sclass = ACTUAL;
    ip->svalue.ival = argc;
    sp = getstr(tostring(ip));
    buffer[0] = ZSTR;
    fstrncpy(buffer+1, arg, MAXCODE-2);
    ep = allell();
    ep->aclass = ACTUAL;
    ep->atype = S_STRING;
    ep->astr = getstr(buffer);
    ep->aindex = sp;
    ep->anext = NULL;
    add_element(ep, vp);
    if (isnumber(arg)) {
        ep->avalue.dval = todouble((ITEM*)ep);
        ep->atype = S_NUMBER;
    }
}

/*
 * copy argv into ARGV
 */
void setargv(int n, char *arg0, char *argv[])
{
    int     argc;

    clear_array(av);
    set_element(0, arg0, av);
    argc = 1;
    while (n) {
        set_element(argc, *argv, av);
        n--; argc++; argv++;
    }
    free_item((ITEM*)ac);
    ac->stype = S_SHORT;
    ac->svalue.ival = argc;
    argn->svalue.ival = 0;
    argp->svalue.sptr = av;
}

/*
 * check to see whether an argument is a
 * command line assignment.
 * returns pointer to string after "="
 */
FSTR isname(FSTR sp)
{
    if (*sp > ' ' && (isalpha(*sp) || *sp == '_'))
        sp++;
    while (*sp > ' ' && (isalnum(*sp) || *sp == '_'))
        sp++;
    if (*sp != '=')
        sp = NULL;
    return sp;
}

/*
 * check to see if a field can be fully
 * represented as a number.
 */
int isnumber(FSTR sp)
{
    int     lag, lead, len, power, digit;
    FSTR    exp;

    if (*sp == '\0')
        return 0;
    exp = "0"; len = 1;
    lead = lag = digit = 0;
    if (*sp == '+' || *sp == '-')
        *sp++;
    if (*sp > ' ' && isdigit(*sp))
        digit++;
    while (*sp == '0')
        sp++;
    while (*sp > ' ' && isdigit(*sp)) {
        lead++;
        sp++;
    }
    if (*sp == '.') {
        sp++;
        if (*sp > ' ' && isdigit(*sp))
            digit++;
        while (*sp == '0') {
            lag++;
            sp++;
        }
        while (*sp > ' ' && isdigit(*sp))
            sp++;
    }
    if (*sp == 'e' || *sp == 'E') {
        sp++;
        exp = sp;
        len = 0;
        if (*sp == '+' || *sp == '-')
            *sp++;
        if (*sp < ' ' || !isdigit(*sp))
            return 0;
        while (*sp == '0')
            sp++;
        while (*sp > ' ' && isdigit(*sp)) {
            len++;
            sp++;
        }
    }
    if (digit == 0)
        return 0;
    if (*sp != '\0')
        return 0;
    if (len > 3)
        return 0;
    power = (int)fatol(exp);
    if (lead > 0)
        power += lead;
    else
        power -= lag;
    if (power > 307 || power < -305)
        return 0;
    return 1;
}

/*
 * get next non null element of ARGV less than ARGC
 * the user program may delete some of the arguments
 * or set them to null to erase them.
 */
char *getargv()
{
    int     argc, n;
    FSTR    argv, argq;
    IDENT   *vp;
    ITEM    *sp;
    ITEM    item[1];

    argc = tointeger(ac);
    while (++(argn->svalue.ival) < argc) {
        index(argp, argn, item);
        argv = tostring(item);
        argq = isname(argv + 1);
        if (argq != NULL) {
            n = (int)(argq - argv) - 1;
            if (n > MAXCODE-1)
                n = MAXCODE-1;
            fstrncpy(buffer, argv + 1, n);
            buffer[n] = '\0';
             for (vp = ident; vp != NULL; vp = vp->vnext) {
                if (fstrcmp(buffer, vp->vname) == 0) {
                    sp = vp->vitem;
                    if (sp != nul) {
                        buffer[0] = ZSTR;
                        fstrncpy(buffer + 1, argq + 1, MAXCODE-2);
                        free_item(sp);
                        sp->stype = S_STRING;
                        sp->sstr = getstr(buffer);
                        if (isnumber(buffer+1)) {
                            sp->svalue.dval = todouble(sp);
                            sp->stype = S_NUMBER;
                        }
                    }
                    break;
                }
            }
        }
        else if (argv[1] != '\0') {
            fstrncpy(argvbuf, argv+1, 64);
            return argvbuf;
        }
    }
    return NULL;
}

/*
 * get a list of var=text elements and process them
 */
void getargs(NAME *list)
{
    int     n;
    FSTR    var, text;
    IDENT   *vp;
    ITEM    *sp;

    while (list != NULL) {
        var = list->name;
        text = isname(var);
        if (text != NULL) {
            n = (int)(text - var);
            if (n > MAXCODE-1)
                n = MAXCODE-1;
            fstrncpy(buffer, var, n);
            buffer[n] = '\0';
             for (vp = ident; vp != NULL; vp = vp->vnext) {
                if (strcmp(buffer, vp->vname) == 0) {
                    sp = vp->vitem;
                    if (sp != nul) {
                        buffer[0] = ZSTR;
                        fstrncpy(buffer + 1, text + 1, MAXCODE-2);
                        free_item(sp);
                        sp->stype = S_STRING;
                        sp->sstr = getstr(buffer);
                        if (isnumber(buffer+1)) {
                            sp->svalue.dval = todouble(sp);
                            sp->stype = S_NUMBER;
                        }
                    }
                    break;
                }
            }
        }
        else
            error("invalid -v var=text syntax %s", list->name);
        list = list->next;
    }
}

/*
 * set the filename variable to name
 * and clear FNR to 0
 */
void setfile(FSTR name)
{
    free_item(fn);
    fn->stype = S_STRING;
    fn->sstr = name;
    free_item(fnr);
    fnr->stype = S_SHORT;
    fnr->svalue.ival = 0;
}

/*
 * read the next input record to $0
 */
int getrecord()
{
    kbhit();
    return getline(files + 1, (ITEM*)fieldtab);
}

/*
 * read the input until an end of record character
 * is read or until the end of input.
 */
int getline(FYLE *fp, ITEM *ip)
{
    int     ch, och, lrs;
    char    *lp, *ep;
    FSTR    dp;
    double  lnr;

    if (fp->ffyle == NULL) {
        return -1;
    }
    if (ip == (ITEM*)fieldtab) {
        lp = linebuf;
        ep = linebuf + sizeof(linebuf) - 1;
        *lp++ = TSTR;
    }
    else {
        lp = buffer;
        ep = buffer + sizeof(buffer) - 1;
        *lp++ = ZSTR;
    }
    *lp = '\0';
    if (feof(fp->ffyle))
        return 0;
    dp = tostring(rs);
    lrs = dp[1];
    ch = fgetc(fp->ffyle);
    if (ch == EOF)
        return 0;
    if (lrs == 0) {
        och = '\0';
        while (ch != EOF && lp < ep) {
            if (ch == '\n' && och == '\n')
                break;
            *lp++ = och = ch;
            ch = fgetc(fp->ffyle);
        }
    }
    else {
        while (ch != EOF && ch != lrs && lp < ep) {
            *lp++ = ch;
            ch = fgetc(fp->ffyle);
        }
    }
    if (ch != EOF && lp == ep)
        ungetc(ch, fp->ffyle);
    *lp = '\0';
    if (ip == (ITEM*)fieldtab) {
        modrecord = 1;
        modfield = 0;
        free_item(ip);
        ip->stype = S_STRING;
        ip->sstr = linebuf;
        if (ch == EOF && lp == linebuf+1)
            return 0;
    }
    else {
        if (ip != (ITEM*)nul) {
            free_item(ip);
            ip->stype = S_STRING;
            ip->sstr = getstr(buffer);
        }
        if (ch == EOF && lp == buffer+1)
            return 0;
    }
    if (fp == (files + 1)) {
        lnr = todouble((ITEM*)fnr);
        if (fnr->stype != S_DOUBLE) {
            free_item((ITEM*)fnr);
            fnr->stype = S_DOUBLE;
        }
        fnr->svalue.dval = lnr + 1;
        lnr = todouble((ITEM*)nr);
        if (nr->stype != S_DOUBLE) {
            free_item((ITEM*)nr);
            nr->stype = S_DOUBLE;
        }
        nr->svalue.dval = lnr + 1;
    }
    return 1;
}

/*
 * free all the fields to prepare for the
 * next input record.
 */
void deparse()
{
    int     i;

    for (i = 0; i < MAXFIELD; i++)
        free_item(fieldtab + i);
    fieldtab->stype = S_STRING;
    fieldtab->sstr = linebuf;
    linebuf[0] = TSTR;
    linebuf[1] = 0;
    free_item((ITEM*)nf);
    nf->stype = S_SHORT;
    nf->svalue.ival = 0;
    modfield = 0;
    modrecord = 0;
}

/*
 * parse the input record into fields
 */
void parse()
{
    FSTR    dst, mat, beg, src;
    int     lnf, i;
    ITEM    *ip;

    if (modrecord) {
        for (i = 1; i < MAXFIELD; i++)
            free_item(fieldtab + i);
        lnf = 0;
        dst = fieldbuf;
        src = onestring(fieldtab)+1;
        beg = src;
        mat = NULL;
        ip = fieldtab+1;
        if (awkfre == blankre) {
            i = *src++;
            while (i != '\0' && lnf < MAXFIELD-1) {
                while (i > '\0' && isspace(i))
                    i = *src++;
                if (i != '\0') {
                    ip->stype = S_STRING;
                    ip->sstr = dst;
                    *dst++ = TSTR;
                    while (i != '\0' && (i < 0 || !isspace(i))) {
                        *dst++ = i;
                        i = *src++;
                    }
                    *dst++ = '\0';
                    if (isnumber(ip->sstr+1)) {
                        ip->svalue.dval = todouble(ip);
                        ip->stype = S_NUMBER;
                    }
                    lnf++;
                    ip++;
                }
            }
        }
        else {
            while (*src != '\0' && lnf < MAXFIELD-1) {
                ip->stype = S_STRING;
                ip->sstr = dst;
                *dst++ = TSTR;
                while (*src != '\0' && 
                      (mat = matchp(beg, src, awkfre)) == NULL && *src != '\n')
                    *dst++ = *src++;
                if (src == mat)
                    *dst++ = *mat++;
                if (mat != NULL) {
                     if (*src != '\0') {
                        if(mat > src)
                            src = mat;
                        else {
                            mat = NULL;
                            if (dst == fieldbuf + 1)
                                *dst++ = *src++;
                        }
                    }
                }
                else if (*src == '\n') {
                    src++;
                    mat = NULL;
                }
                *dst++ = '\0';
                if (isnumber(ip->sstr+1)) {
                    ip->svalue.dval = todouble(ip);
                    ip->stype = S_NUMBER;
                }
                lnf++;
                ip++;
            }
            if (mat != NULL) {
                ip->stype = S_STRING;
                ip->sstr = nullstr;
                lnf++;
            }
        }
        free_item((ITEM*)nf);
        nf->stype = S_SHORT;
        nf->svalue.ival = lnf;
            modfield = 0;
        modrecord = 0;
    }
}

/*
 * convert the fields back into the input record
 * this is done whenever $0 is referenced after
 * any field is modified.
 */
void unparse()
{
    int     i, lnf;
    char    *dp;
    FSTR    sp, fp;

    if (modfield) {
        free_item(fieldtab);
        fieldtab->stype = S_STRING;
        fieldtab->sstr = linebuf;
        dp = linebuf;
        *dp++ = TSTR;
        fp = tostring((ITEM*)ofs);
        lnf = tointeger((ITEM*)nf);
        for (i = 1; i <= lnf; i++) {
            if (i > 1) {
                sp = fp+1;
                while (*sp != '\0')
                    *dp++ = *sp++;
            }
            sp = tostring(fieldtab + i)+1;
            while (*sp != '\0')
                *dp++ = *sp++;
        }
        *dp = '\0';
        for (i = lnf + 1; i < MAXFIELD; i++)
            free_item(fieldtab + i);
        modfield = 0;
        modrecord = 0;
    }
}

/*
 * convert an item into a file number
 * the item is converted to a string
 * and this string is used as the filename
 * mp is a pointer to a string that is the
 * open mode of the file "w" or "a"
 */
FYLE *getfile(ITEM *a, int p)
{
    FSTR    sp;
    FYLE    *fp;

    sp = tostring(a);
    for (fp = files + 2; fp < nextfile; fp++) {
        if (fstrcmp(fp->fname+1, sp+1) == 0)
            break;
    }
    if (p == P_CLOSE) {
        if (fp < nextfile && fp->ffyle != NULL) {
            fclose(fp->ffyle);
            fp->ffyle = NULL;
        }
        fp = NULL;
    }
    else {
        if (fp >= nextfile) {
            if (nextfile >= files + MAXFILE) {
                for (fp = files; fp < nextfile; fp++) {
                    if (fp->ffyle == NULL)
                        break;
                }
            }
            else
                fp = nextfile++;
            if (fp >= files + MAXFILE)
                error("too many files open \"%s\"", sp+1);
        }
        if (fp->ffyle == NULL) {
            switch (p) {
            case P_OPEN:
                fp->fmode = "r";
                break;
            case P_CREATE:
                fp->fmode = "w";
                break;
            case P_APPEND:
                fp->fmode = "a";
                break;
            }
            fp->fname = newstr(sp);
            fp->ffyle = NULL;
        }
    }
    return fp;
}

/*
 * close all of the files used by the AWK program
 */
void awkclose()
{
    FYLE *fp;

    for (fp = files + 2; fp < nextfile; fp++)
        if (fp->ffyle != NULL)
            fclose(fp->ffyle);
}

