/*
 * awk main programme
 *
 * Copyright (C) 1988, 1989, 1990, 1991 by Rob Duff
 * All rights reserved
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <mem.h>
#include <alloc.h>
#include <string.h>
#include <setjmp.h>
#include <signal.h>

#include "awk.h"

IDENT *ident;                       /* list of all identifiers */

ITEM *nextvar;                      /* pointer to next unused variable */
ITEM vartab[MAXNAME];               /* table to hold variables */

ITEM *stackptr, *stacktop;          /* stack pointer and top limit */
ITEM stackbot[MAXSTACK];            /* the stack */
ITEM fieldtab[MAXFIELD];            /* table to hold fields 0..MAXFIELD-1 */
RULE *rules, *rulep;                /* awk code pointers */
FYLE files[MAXFILE];                /* table to hold files */
FYLE *nextfile;                     /* pointer to unused file */

LINK *beginact;                     /* list of BEGIN actions */
LINK *beginend;                     /* pointer to last BEGIN action */
LINK *endact;                       /* list of END actions */
LINK *endend;                       /* pointer to last END action */

FILE *awkfile;                      /* AWK program input file */

char *yyname;                       /* program file name */
char *awkfre;                       /* RE for field separator */
char *awkname;                      /* data file name */
char *blankre;                      /* RE for " " field separator */

char fmtstr[66];                    /* format string */
char ofmtstr[66] = "\377%.6g";      /* output format string */
char namebuf[66];                   /* internal form for file name */
char code[MAXCODE];                 /* code generation buffer */
char buffer[MAXCODE];               /* string buffer */
char linebuf[MAXLINE] = "";         /* program input buffer */

NAME *varlist;                      /* list of var=text options */
NAME *varlast;                      /* last var in list */
NAME *awklist;                      /* list of program file names */
NAME *awklast;                      /* last name in list */
char *awkstdin = "<stdin>";

FSTR awkfs;                         /* current field separator */
FSTR lineptr;                       /* program line pointer */
FSTR nullstr = "\377";              /* standard null string */
FSTR blankfs = "\377[ \\t\\n]+";    /* " " field separator */
FSTR fieldbuf;                      /* field string storage */

short trace;                        /* trace execution */
short awkline;                      /* include line information */
short builtin;                      /* number of builtin variables */
short status, awkeof;               /* exit status and EOF status */

ITEM  *ac, *av, *rl, *rst;          /* BUILTIN variables */
ITEM  *nr, *fnr, *fs, *rs;          /* BUILTIN */
ITEM  *ofs, *ors, *ofmt;            /* BUILTIN */
ITEM  *nf, *fn, *nul, *subsep;      /* BUILTIN */

jmp_buf nextjmp, exitjmp;           /* next and exit long jump buffers */

void awkfpe();
extern ELEMENT *allell(void);

static void usage(void);            /* error message */
static void awkinit(void);          /* initialize AWK */
static void execute(void);          /* execute an ACTION */
static void addname(char *);        /* add -f program file */
static void addvar(char *);         /* add -v var=text */
static ITEM *buildin(char*, int, int, FSTR);

int main(int argc, char *argv[])
{
    int     found;                  /* found wildcard file */
    char    *arg0;                  /* program name */
    char    *argn;                  /* data file names */
    LINK    *acts;                  /* pointer to next action */

    awkinit();                      /* initialize program */
    arg0 = argv[0];                 /* get program name */
    argc--; argv++;                 /* get next argument */
    while (argc > 0 && argv[0][0] == '-') { /* parse options */
        if (argv[0][1] == 'f') {    /* input file option */
            if (argv[0][2] != '\0') /* is it a separate arg? */
                addname(argv[0]+2); /* no */
            else if (argc > 0) {
                argc--; argv++;     /* yes */
                addname(argv[0]);   /* get next argument */
            }
            else {                  /* oops no more arguments */
                error("no file specified for -f", NULL);
            }
        }
        else if (argv[0][1] == 'v') {    /* var=text option */
            if (argv[0][2] != '\0') /* is it a separate arg? */
                addvar(argv[0]+2); /* no */
            else if (argc > 0) {
                argc--; argv++;     /* yes */
                addvar(argv[0]);   /* get next argument */
            }
            else {                  /* oops no more arguments */
                error("no var=text specified for -v", NULL);
            }
        }
        else if (argv[0][1] == 'F') {
            argv[0][1] = LSTR;      /* field separator */
            fs->sstr = argv[0] + 1; /* convert to internal form */
            awkeof = 1;
            setfs();                /* calculate RE for FS */
            yyinit();
        }
        else if (argv[0][1] == 't') {
            trace++;                /* trace execution */
        }
        else if (argv[0][1] == 't') {
            awkline++;              /* include lines */
        }
        else if (argv[0][1] == '-') {
            argc--; argv++;         /* "--" means end of options */
            break;
        }
        else if (argv[0][1] == '\0') {
            addname(awkstdin);      /* "-" means stdin */
            argc--; argv++;
            break;
        }
        else
            usage();                /* messy option */
        argc--; argv++;
    }
    if (awklist == NULL) {          /* don't have -f option */
        if (argc > 0) {
            if (strpbrk(*argv, " \",/[]|<>+=;") == NULL) {
                strcpy(buffer, *argv);      /* move to larger space */
                awkfile = fopen(buffer ,"r");
                if (awkfile != NULL) {
                    awkeof = 0;
                    yyname = *argv;
                    lineptr = linebuf;
                    *lineptr = '\0';
                }
                else {
                    strcat(buffer, ".awk"); /* try .AWK */
                    awkfile = fopen(buffer, "r");
                    if (awkfile != NULL) {
                        awkeof = 0;
                        yyname = malloc(strlen(buffer)+1);
                        strcpy(yyname, buffer);
                        lineptr = linebuf;
                        *lineptr = '\0';
                    }
                    else {
                        awkeof = 1;         /* no input files */
                        strcpy(linebuf, *argv);
                        strcat(linebuf, "\n");
                        lineptr = linebuf;
                    }
                }
            }
            else {                  /* must be a program */
                awkeof = 1;         /* no input files */
                strcpy(linebuf, *argv);
                strcat(linebuf, "\n");
                lineptr = linebuf;
            }
            argc--; argv++;
        }
        else {
            awkeof = 0;
            addname(awkstdin);      /* no file name for stdin */
        }
    }
    else
        awkeof = 0;

    yyparse();                      /* compile AWK program */
    awkeof = 1;                     /* end of awk program */
    if (awkfile != stdin)           /* close if not stdin */
        fclose(awkfile);
    deparse();                      /* clean up input record */
    setargv(argc, arg0, argv);      /* set ARGV and ARGC */
    if (varlist != NULL)
        getargs(varlist);
    if (setjmp(exitjmp) == 0) {     /* EXIT() point */
        if (beginact != NULL)       /* if we have BEGIN actions */
            if (setjmp(nextjmp) == 0) { /* set NEXT() point */
                acts = beginact;
                while (acts != NULL) {  /* execute BEGIN actions */
                    awkexec(acts->ccode);
                    acts = acts->cnext; /* point to next action */
                }
            }
        found = 0;
        argn = getargv();
        if (rulep != NULL || endact != NULL) do {
            if (argn != NULL) {
                if (*argn == '\0') {
                    argn = getargv();   /* get the next input file */
                    if (argn == NULL)
                        break;          /* stop when no more */
                }
                if (argn[0] == '-' && argn[1] == '\0') {
                    awkfile = stdin;    /* check for standard input */
                    awkname = "";
                    argn = "";
                }
                else {
                    if (awkfind(buffer, argn, 0) == NULL) {
                        if (found > 0) {    /* wildcard file */
                            found = 0;      /* no more match */
                            argn = "";
                            continue;
                        }
                        error("can't find file %s", argn);
                    }
                    awkfile = fopen(buffer ,"r");
                    if (awkfile == NULL)    /* can't open file */
                        error("can't open data file", buffer);
                    awkname = buffer;       /* set FILENAME */
                    found++;
                }
            }
            else {
                awkname = "";               /* no FILENAME for stdin */
                awkfile = stdin;            /* file not specified */
            }
            namebuf[0] = TSTR;              /* mark FILENAME as temporary */
            strcpy(namebuf+1, awkname);
            setfile(namebuf);               /* set FILENAME and FNR */
            files[1].ffyle = awkfile;
            execute();                      /* execute program */
            if (awkfile != stdin)
                fclose(awkfile);            /* close opened file */
        } while (argn != NULL);             /* repeat for next file */
    }
    deparse();                              /* free FIELD temporaries */
    setfile(nullstr);                       /* clear FILENAME and FNR */
    if (setjmp(exitjmp) == 0) {             /* EXIT () point in END */
        if (setjmp(nextjmp) == 0) {         /* some fool may try this */
            for (acts = endact; acts != NULL; acts = acts->cnext)
                awkexec(acts->ccode);       /* execute end actions */
        }
    }
    awkclose();                             /* close all the FILES */
    return status;                          /* return exit code */
}

static void execute()
{
    int     flag;

    while (getrecord() > 0) {               /* read a record (line) */
        rulep = rules;                      /* start at the first pat/act */
        if (setjmp(nextjmp) == 0) {         /* NEXT() point */
            while (rulep != NULL) {
                if (rulep->start == NULL)
                    rulep->seen = 1;        /* no rule means always */
                else if (rulep->seen == 0 && awkexec(rulep->start) != 0)
                    rulep->seen = 1;        /* success means start */
                flag = rulep->seen;
                if (rulep->stop == NULL)
                    rulep->seen = 0;        /* no rule means once */
                else if (rulep->seen != 0 && awkexec(rulep->stop) != 0)
                    rulep->seen = 0;        /* success means stop */
                if (flag != 0)
                    awkexec(rulep->action); /* execute action on start */
                rulep = rulep->next;        /* do next rule */
            }
        }
        deparse();                          /* free FIELD assignments */
    }
}

/*
 * create builtin variable
 */
static ITEM *buildin(char *name, int class, int type, FSTR ptr)
{
    IDENT *vp;

    nextvar->sclass = class;
    nextvar->stype = type;
    nextvar->sstr = ptr;
    nextvar->svalue.dval = 0;

    vp = malloc(sizeof(IDENT));
    vp->vitem = nextvar;
    vp->vname = name;
    vp->vfunc = NULL;
    vp->vnext = ident;
    ident = vp;
    
    builtin++;
    return nextvar++;
}

/*
 * initialize all the structures used by AWK
 */
static void awkinit()
{
    int     i;
    ELEMENT *ep;

    trace = 0;
    status = 0;
    ident = NULL;
    rules = NULL;
    rulep = NULL;
    endact = NULL;
    endend = NULL;
    beginact = NULL;
    beginend = NULL;
    stackptr = stacktop = stackbot + MAXSTACK;

    fieldbuf = farmalloc(MAXLINE+MAXFIELD+MAXFIELD);
    builtin = 0;
    nextvar = vartab;
    nul = buildin("\"\"", ACTUAL, S_NUMBER, nullstr);
    fs = buildin("FS", ACTUAL, S_STRING, "\377 ");
    ofs = buildin("OFS", ACTUAL, S_STRING, "\377 ");
    nf = buildin("NF", ACTUAL, S_SHORT, 0);
    ofmt = buildin("OFMT", ACTUAL, S_STRING, ofmtstr);

    rs = buildin("RS", ACTUAL, S_STRING, "\377\n");
    ors = buildin("ORS", ACTUAL, S_STRING, "\377\n");
    nr = buildin("NR", ACTUAL, S_SHORT, 0);
    fnr = buildin("FNR", ACTUAL, S_SHORT, 0);
    fn = buildin("FILENAME", ACTUAL, S_STRING, namebuf);

    av = buildin("ARGV", ACTUAL, S_STRING, nullstr);
    ac = buildin("ARGC", ACTUAL, S_STRING, nullstr);

    rl = buildin("RLENGTH", ACTUAL, S_STRING, nullstr);
    rst = buildin("RSTART", ACTUAL, S_STRING, nullstr);
    subsep = buildin("SUBSEP", ACTUAL, S_STRING, "\377\034");

    for (i = builtin; i < MAXNAME; i++) {
        ep = allell();                      /* this stuff allows undefined */
        ep->aclass = ACTUAL;                /* variables to be passed to */
        ep->atype = S_NUMBER;               /* functions as arrays */
        ep->astr = nullstr;
        ep->avalue.dval = 0;
        ep->aindex = nullstr;
        ep->anext = NULL;
        vartab[i].sclass = ACTUAL;
        vartab[i].stype = S_ARRAY;
        vartab[i].sstr = nullstr;
        vartab[i].svalue.aptr = ep;
    }
    for (i = 0; i < MAXFIELD; i++) {
        fieldtab[i].sclass = ACTUAL;
        fieldtab[i].stype = S_STRING;
        fieldtab[i].sstr = nullstr;
    }
    nextfile = files + 2;
    files[0].fname = "\377<stdout>";
    files[0].fmode = "w";
    files[0].ffyle = stdout;
    files[1].fname = "\377<stdin>";
    files[1].fmode = "r";
    files[1].ffyle = stdin;
    for (i = 2; i < MAXFILE; i++) {
        files[i].fname = nullstr;
        files[i].fmode = "";
        files[i].ffyle = NULL;
    }
    awkeof = 1;
    yyinit();
    lineptr = blankfs+1;
    blankre = regexp(2);
    *lineptr = '\0';
    yyinit();
    awkfs = blankfs;
    awkfre = blankre;
    awkfile = stdin;
    awkname = NULL;
    awklist = NULL;
    awklast = NULL;
    varlist = NULL;
    varlast = NULL;
    lineptr = NULL;
    yyname = NULL;
    yyline = 0;

    signal(SIGFPE, awkfpe);
}

/*
 * display an error message and leave
 */
void
error(char *fmt, ...)
{
    va_list ap;

    va_start(ap, fmt);
    fprintf(stderr, "awk ERROR");
    if (yyname)
        fprintf(stderr, " %s", yyname);
    if (yyline)
        fprintf(stderr, " line %d", yyline);
    fprintf(stderr, ": ");
    vfprintf(stderr, fmt, ap);
    fprintf(stderr, "\n");
    va_end(ap)
    exit(1);
}

static void addname(char *name)
{
    NAME    *list;

    list = malloc(sizeof(NAME));
    list->name = name;
    list->next = NULL;
    if (awklast == NULL)
        awklist = list;
    else
        awklast->next = list;
    awklast = list;
}

static void addvar(char *name)
{
    NAME    *list;

    list = malloc(sizeof(NAME));
    list->name = name;
    list->next = NULL;
    if (varlast == NULL)
        varlist = list;
    else
        varlast->next = list;
    varlast = list;
}

void awkfpe()
{
    error("floating point exception", NULL);
}

/*
 * print a help message about how to use AWK and exit
 */
static void usage()
{
    fprintf(stderr, "   AWK version 3.20 (22-May-91)\n\n");
    fprintf(stderr, "          Copyright (C) 1990, 91 by Rob Duff\n");
    fprintf(stderr, "          Vancouver BC Canada V5N 1Y9\n\n");
    fprintf(stderr, "usage: awk [-l] [-t] [-f name] [-v var=text] [-Ffs] [--] [prog] [data ... ]\n");
    fprintf(stderr, "       -l      include line number tracing for debugging\n");
    fprintf(stderr, "       -t      will trace execution of the program\n");
    fprintf(stderr, "       -f      specify program file\n");
    fprintf(stderr, "       name    is the name of a file containing an AWK program. You may\n");
    fprintf(stderr, "               specify multiple program files with multiple -f options\n");
    fprintf(stderr, "               A -f name and prog program definition may not be mixed\n");
    fprintf(stderr, "       -v      assign var before any BEGIN blocks\n");
    fprintf(stderr, "       -F      specify a pattern to match for field separation\n");
    fprintf(stderr, "       fs      is the pattern to match for field separation\n");
    fprintf(stderr, "       --      ends the option list.\n\n");
    fprintf(stderr, "       prog    is a quoted program or a file name with optional [.AWK]\n");
    fprintf(stderr, "               you may specify stdin with a dash (-). Not used with -f.\n");
    fprintf(stderr, "       data    is any file name including wildcards.  If file is of the\n");
    fprintf(stderr, "               form var=text then text is assigned to var in the program\n");
    fprintf(stderr, "               instead of reading a file.\n");
    fprintf(stderr, "       If no options are specified then the program and data are both\n");
    fprintf(stderr, "       read from stdin.  You end the program with a line containing\n");
    fprintf(stderr, "       only a single period (.) in the first column.\n\n");
    exit(1);
}

