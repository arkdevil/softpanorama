/*
 * global definitions for AWK
 *
 * Copyright (C) 1988, 1989, 1990, 1991 by Rob Duff
 * All rights reserved
 *
 * Distribution of this program is permitted provided that
 * it is not done for direct commercial gain.
 */

#include <stdio.h>

#define FLOATER

typedef char far *FSTR;

/*
 * Array sizes
 */
#define MAXFILE 12
#define MAXNAME 100
#define MAXCODE 2002
#define MAXLINE 2002
#define MAXLEVEL 100
#define MAXFIELD 101
#define MAXLABEL 256
#define MAXSTACK 500

/*
 * Regular Expression opcodes
 */
#define R_END     0
#define R_BOL     1
#define R_EOL     2
#define R_ANY     3
#define R_BAR     4
#define R_CHAR    5
#define R_STAR    6
#define R_PLUS    7
#define R_QUEST   8
#define R_CLASS   9
#define R_NCLAS  10
#define R_RANGE  11

/*
 * Pseudo machine opcodes
 */
#define C_END     0
#define C_EQ      1
#define C_NE      2
#define C_LT      3
#define C_GT      4
#define C_LE      5
#define C_GE      6
#define C_MUL     7
#define C_DIV     8
#define C_MOD     9
#define C_ADD    10
#define C_SUB    11
#define C_NEG    12
#define C_NOT    13
#define C_NUM    14
#define C__PRE   15
#define C_PRE    16
#define C__POST  17       
#define C_POST   18       
#define C_IS     19
#define C_IN     20
#define C_MAT    21
#define C_CAT    22
#define C_RAND   23
#define C_SYS    24
#define C_LEN    25
#define C_COS    26
#define C_EXP    27
#define C_INT    28
#define C_LOG    29
#define C_SIN    30
#define C_SQRT   31
#define C_ATAN2  32
#define C_POW    33
#define C_DOLAR  34
#define C_FIELD  35
#define C_PLUCK  36
#define C_ADDR   37
#define C_FETCH  38
#define C_AUTO   39
#define C_BUILT  40
#define C_SELECT 41
#define C_LOAD   42
#define C__STORE 43
#define C_STORE  44
#define C__COPY  45
#define C_COPY   46
#define C_DUP    47
#define C_SWAP   48
#define C_UNDER  49
#define C_DROP   50
#define C_CALL   51
#define C_USER   52
#define C_RETURN 53
#define C_JUMP   54
#define C_FJMP   55
#define C_TJMP   56
#define C_AJMP   57
#define C_OJMP   58
#define C_IJMP   59
#define C_CCON   60
#define C_ICON   61
#define C_LCON   62
#define C_DCON   63
#define C_SCON   64
#define C_RCON   65
#define C_FCON   66
#define C_LINE   67
#define C_UPR    68
#define C_LWR    69
/*                 
 * Standard procedures
 */
#define P_NEXT    1
#define P_EXIT    2
#define P_PRINT   3
#define P_PRINTF  4
#define P_GETLINE 5
#define P_SRAND   6
#define P_GSUB    7
#define P_LSUB    8
#define P_JOIN    9
#define P_SPLIT   10
#define P_DELETE  11
#define P_INDEX   12
#define P_MATCH   13
#define P_SUBSTR  14
#define P_SPRINTF 15
#define P_OPEN    16
#define P_CREATE  17
#define P_APPEND  18
#define P_CLOSE   19

/*
 * Storage classes
 */
#define ACTUAL  0
#define FORMAL  1

/*
 * Storage types
 */
#define S_SHORT    0
#define S_LONG     1
#define S_DOUBLE   2
#define S_NUMBER   3
#define S_STRING   4
#define S_REGEXP   5
#define S_ARRAY    6
#define S_STACK    7
#define S_FILES    8
#define S_FIELD    9
#define S_SIMPLE  10
#define S_BUILT   11

/*
 * string types
 */
 #define ZSTR '\200'    /* not allocated */
 #define ESTR '\375'    /* final use count */
 #define TSTR '\376'    /* temporary */
 #define LSTR '\377'    /* literal */

/*
 * special label tags
 */
#define L_NORMAL   0
#define L_CONTINUE 1
#define L_BREAK    2
#define L_DONE     3
#define L_MARK     4
#define L_FOR      5
#define L_ELSE     6
#define L_WHILE    7

/*
 * Value
 */
typedef union DATUM {
    short       ival;
    long        lval;
    double      dval;
    char        *cptr;
    struct FYLE *fptr;
    struct ITEM *sptr;
    struct ELEMENT *aptr;
} DATUM;

/*
 * Value Stack
 */
typedef struct ITEM {
    int         sclass;
    int         stype;
    FSTR        sstr;
    DATUM       svalue;
} ITEM;

/*
 * Array Value
 */
typedef struct ELEMENT {
    int         aclass;
    int         atype;
    FSTR        astr;
    DATUM       avalue;
    FSTR        aindex;
    struct ELEMENT *anext;
} ELEMENT;

/*
 * Symbol Table
 */
typedef struct IDENT {
    void        *vitem;
    char        *vname;
    struct FUNC *vfunc;
    struct IDENT *vnext;
} IDENT;

/*
 * parameter list
 */
typedef struct LIST {
    IDENT       *litem;
    struct LIST *lnext;
} LIST;

/*
 * Label storage
 */
typedef struct {
    short       label;
    short       where;
} LABLE;

/*
 *
 */
typedef struct FUNC {
    int         psize;
    char        *pcode;
    LIST        *plist;
} FUNC;

/*
 * code list link
 */
typedef struct LINK {
    char        *ccode;
    struct LINK *cnext;
} LINK;
/*
 * File structure
 */
typedef struct FYLE {
    FSTR        fname;
    char        *fmode;
    FILE        *ffyle;
} FYLE;

/*
 * Rules structure
 */
typedef struct RULE {
    char         *start;
    char         *stop;
    char         seen;
    char         flag;
    char         *action;
    struct RULE  *next;
} RULE;

/*
 * AWK input file name list
 */
typedef struct NAME {
    char    *name;
    struct NAME *next;
} NAME;

/*
 * code fetch trick
 */
typedef union {
    short       ival;
    long        lval;
    double      dval;
    FSTR        fstr;
    unsigned int uval;
    unsigned char cval;
    void        *vptr;
    char        *sptr;
    void        *fptr;
    char        sval[8];
} TRIX;

/*
 * Global variables
 */

extern short awkline;
extern NAME *awklist;
extern char *awkstdin;

extern ITEM *nextvar;
extern ITEM vartab[MAXNAME];
extern ITEM fieldtab[MAXFIELD];
extern ITEM stackbot[MAXSTACK];
extern ITEM *stackptr, *stacktop;
extern FYLE *nextfile;
extern FYLE files[MAXFILE];
extern RULE *rules, *rulep;

extern LINK *beginact;
extern LINK *beginend;
extern LINK *endact;
extern LINK *endend;

extern char fmtstr[66];
extern char ofmtstr[66];
extern char code[MAXCODE];
extern char buffer[MAXCODE];
extern char linebuf[MAXLINE];

extern FSTR awkfs;
extern FSTR nullstr;
extern FSTR lineptr;
extern FSTR blankfs;
extern FSTR fieldbuf;

extern short aline;
extern short builtin;
extern short modfield;
extern short modrecord;
extern short status, awkeof, rlength, rstart, rcount;

extern int yyline;
extern char *yyname;
extern char *awkfre, *blankre;


extern IDENT *ident;
extern LABLE labels[MAXLABEL];

extern ITEM *fn, *nf, *nr, *fs, *rs;
extern ITEM *nul, *ofs, *ors, *ofmt;
extern ITEM *ac, *av, *fnr, *rl, *rst, *subsep;

extern FILE *awkfile;
/*
 * Global procedures
 */

extern void parse(void);
extern void unparse(void);
extern void deparse(void);
extern void free_item(ITEM*);
extern void error(char*, ...);
extern void clear_array(ITEM*);
extern void match(FSTR, char*);
extern void index(ITEM*, ITEM*, ITEM*);

extern ELEMENT *add_element(ELEMENT*, ITEM*);

extern FSTR getstr(FSTR);
extern FSTR newstr(FSTR);
extern FSTR uprstr(FSTR);
extern FSTR lwrstr(FSTR);
extern FSTR catstr(FSTR, FSTR);
extern void *allawk(unsigned);

extern FSTR matchp(FSTR, FSTR, char*);
extern char *subst(int, FSTR, FSTR, char*);

extern char *print_re(char*);
extern char *print_op(char*, char*);

extern void print_item(ITEM*);
extern void print_value(ITEM*);
extern void print_one(char*, ITEM*);
extern void print_code(char *);
extern void print_two(char*, ITEM*, ITEM*);
extern void print_element(char*, ELEMENT*);
extern void print_label(char *str, int label);

extern FYLE *tofyle(ITEM*);
extern FYLE *getfile(ITEM*, int);

extern long tolong(ITEM*);
extern int tointeger(ITEM*);
extern char *toregexp(ITEM*);
extern FSTR tostring(ITEM*);
extern FSTR onestring(ITEM*);
extern double todouble(ITEM*);
extern ITEM *tovariable(ITEM*, int);

extern IDENT *lookup(char*);
extern IDENT *lookfor(ITEM*);

extern int isnumber(FSTR);
extern FSTR isname(FSTR);

extern void setfs(void);
extern void setfile(FSTR);
extern void setargv(int, char*, char**);

extern int awkexec(char *);
extern void awkclose(void);
extern char *awkfind(char*, char*, int);

extern void getargs(NAME*);
extern char *getargv(void);
extern int getrecord(void);
extern int getline(FYLE*, ITEM*);

extern void dfunc1(int, ITEM*, ITEM*);
extern void dfunc2(int, ITEM*, ITEM*, ITEM*);
extern void compare(int, ITEM*, ITEM*, ITEM*);
extern void arithmetic(int, ITEM*, ITEM*, ITEM*);

extern char *regexp(int);

extern int yyparse(void);
extern void yyinit(void);

