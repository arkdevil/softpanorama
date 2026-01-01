/*
 * lex library header file
 *
 * Copyright (C) 1988, 1989, 1990, 1991 by Rob Duff
 * All rights reserved
 */

/*
 * reject backup table entry
 */

typedef struct {
    short llfin;
    short lllen;
} yyrej;

/*
 * Description of scanning tables. The entries at the front of
 * the struct must remain in place for the assembler routines to find.
 */
typedef struct {
    int     llendst;        /* Last state number */
    int     llnxtmax;       /* Last in next table */
    short   *llbase;        /* Base table */
    short   *llnext;        /* Next state table */
    short   *llcheck;       /* Check value table */
    short   *lldefault;     /* Default state table */
    short   *llfinal;       /* Final state descriptions */
    short   *lllook;        /* Look ahead vector if != NULL */
    yyrej   *llback;        /* reject backup vector */
    int     (*llactr)(int); /* Action routine */
    char    *llign;         /* Ignore char vec if != NULL */
    char    *llbrk;         /* Break char vec if != NULL */
    char    *llill;         /* Illegal char vec if != NULL */
} yytab;

