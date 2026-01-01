/*
 * GNU m4 -- A simple macro processor
 * Copyright (C) 1989, 1990 Free Software Foundation, Inc. 
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 1, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

/*
 * MS-DOS port (c) 1990 by Thorsten Ohl, ohl@gnu.ai.mit.edu
 * This port is also distributed under the terms of the
 * GNU General Public License as published by the
 * Free Software Foundation.
 *
 * Please note that this file is not identical to the
 * original GNU release, you should have received this
 * code as patch to the official release.
 *
 * $Header: e:/gnu/m4/RCS/m4.h 0.5.1.0 90/09/28 18:35:05 tho Exp $
 */

#include <stdio.h>
#include <ctype.h>
#ifdef MSDOS
#include <stdarg.h>
#else
#include <varargs.h>
#endif

#include "obstack.h"

#ifdef MSDOS
#include <stdlib.h>
#else /* not MSDOS */
extern char *malloc();
extern char *realloc();
extern void free();
extern char *mktemp();
extern int mkstemp();
#endif /* not MSDOS */

#ifdef USG
#include <string.h>
#define	index(s, c)	strchr((s), (c))
#define	rindex(s, c)	strrchr((s), (c))

#include <memory.h>
#define bcmp(s1, s2, n)	memcmp ((s1), (s2), (n))
#define bzero(s, n)	memset ((s), 0, (n))
#define bcopy(s, d, n)	memcpy ((d), (s), (n))

#else /* not USG */
#include <strings.h>

extern int bcmp ();
extern void bzero (), bcopy ();
#endif /* USG */


#define obstack_chunk_alloc	xmalloc
#define obstack_chunk_free	xfree

#define nil 0

typedef enum boolean { false = 0, true = 1 } boolean;

#ifndef MSDOS
extern int errno;
extern int sys_nerr;
extern char *sys_errlist[];
#endif /* not MSDOS */

#define syserr() ((errno > 0 && errno < sys_nerr) ? sys_errlist[errno] : "Unknown error")


/* miscellaneous, that must be first */
typedef void builtin_func();


/* File: m4.c  --- global definitions*/

/* Option flags */
extern int interactive;			/* -e */
extern int sync_output;			/* -s */
extern int debug_level;			/* -d */
extern int hash_table_size;		/* -H */
extern int no_gnu_extensions;		/* -g */

/* Error handling */
#ifdef MSDOS
extern void warning (char *fmt, ...);
extern void error (char *fmt, ...);
extern void fatal (char *fmt, ...);
extern void internal_error (char *fmt, ...);
#else /* not MSDOS */
extern void warning();
extern void error();
extern void fatal();
extern void internal_error();
#endif /* not MSDOS */

/* Memory allocation */
#ifdef MSDOS
extern char *xmalloc (unsigned int size);
extern void xfree (char *p);
extern char *xstrdup (char *s);
#else /* not MSDOS */
extern char *xmalloc();
extern char *xrealloc();
extern void xfree();
extern char *xstrdup();
#endif /* not MSDOS */


/* File: input.c  --- lexical definitions */

/* Various different token types */
enum token_type {
    TOKEN_EOF,				/* end of file */
    TOKEN_STRING,			/* a quoted string */
    TOKEN_WORD,				/* an identifier */
    TOKEN_SIMPLE,			/* a single character */
    TOKEN_MACDEF,			/* a macros definition (see "defn") */
};

/* The amount of data for a token, a macro argument, and a macro definition */
enum token_data_type {
    TOKEN_VOID,
    TOKEN_TEXT,
    TOKEN_FUNC,
};

struct token_data {
    enum token_data_type type;
    union {
	char *text;
	builtin_func *func;
    } u;
};

#define TOKEN_DATA_TYPE(td)	((td)->type)
#define TOKEN_DATA_TEXT(td)	((td)->u.text)
#define TOKEN_DATA_FUNC(td)	((td)->u.func)

typedef enum token_type token_type;
typedef enum token_data_type token_data_type;
typedef struct token_data token_data;

#ifdef MSDOS
extern void input_init (void);
extern int peek_input (void);
extern enum token_type next_token (struct token_data *td);
extern void skip_line (void);
#else /* not MSDOS */
extern void input_init();
extern int peek_input();
extern token_type next_token();
extern void skip_line();
#endif /* not MSDOS */

/* push back input */
#ifdef MSDOS
extern void push_file (FILE *fp, char *title);
extern void push_macro (void (*func) ());
extern struct obstack *push_string_init (void);
extern char *push_string_finish (void);
extern void push_wrapup (char *s);
extern enum boolean pop_wrapup (void);
#else /* not MSDOS */
extern void push_file();
extern void push_macro();
extern void push_string();
extern struct obstack *push_string_init();
extern char *push_string_finish();
extern void push_wrapup();
extern boolean pop_wrapup();
#endif /* not MSDOS */

/* current input file, and line */
extern char *current_file;
extern int current_line;

/* left and right quote, begin and end comment */
extern char lquote, rquote, bcomm, ecomm;

#define DEF_LQUOTE '`'
#define DEF_RQUOTE '\''
#define DEF_BCOMM '#'
#define DEF_ECOMM '\n'


/* File: output.c --- output functions */
extern int output_lines;
extern int output_current_line;

#ifdef MSDOS
extern void output_init (void);
extern void sync_line (int line, char *file);
extern void shipout_text (struct obstack *obs, char *text);
extern void make_divertion (int divnum);
extern void insert_divertion (int divnum);
#else /* not MSDOS */
extern void output_init();
extern void sync_line();
extern void shipout_text();
extern void make_divertion();
extern void insert_divertion();
#endif /* not MSDOS */


/* File symtab.c  --- symbol table definitions */

/* Operation modes for lookup_symbol() */
enum symbol_lookup {
    SYMBOL_LOOKUP,
    SYMBOL_INSERT,
    SYMBOL_DELETE,
    SYMBOL_PUSHDEF,
    SYMBOL_POPDEF,
};

/* Symbol table entry */
struct symbol {
    struct symbol *next;
    boolean traced;
    boolean shadowed;
    boolean macro_args;

    char *name;
    token_data data;
};

#define SYMBOL_NEXT(s)		((s)->next)
#define SYMBOL_TRACED(s)	((s)->traced)
#define SYMBOL_SHADOWED(s)	((s)->shadowed)
#define SYMBOL_MACRO_ARGS(s)	((s)->macro_args)
#define SYMBOL_NAME(s)		((s)->name)
#define SYMBOL_TYPE(s)		(TOKEN_DATA_TYPE(&(s)->data))
#define SYMBOL_TEXT(s)		(TOKEN_DATA_TEXT(&(s)->data))
#define SYMBOL_FUNC(s)		(TOKEN_DATA_FUNC(&(s)->data))

typedef enum symbol_lookup symbol_lookup;
typedef struct symbol symbol;
#ifdef MSDOS
typedef void hack_symbol(symbol *sym, char *data);
#else /* not MSDOS */
typedef void hack_symbol();
#endif /* not MSDOS */

#define HASHMAX 509			/* Default, overridden by -Hsize */

extern symbol **symtab;

#ifdef MSDOS
extern void symtab_init (void);
extern struct symbol *lookup_symbol (char *name, enum symbol_lookup mode);
extern void hack_all_symbols (hack_symbol *func, char *data);
#else /* not MSDOS */
extern void symtab_init();
extern symbol *lookup_symbol();
extern hack_symbol hack_all_symbols();
#endif /* not MSDOS */


/* File: macro.c  --- macro expansion */

#ifdef MSDOS
extern void expand_input (void);
#else /* not MSDOS */
extern void expand_input();
#endif /* not MSDOS */


/* File: builtin.c  --- builtins */

struct builtin {
    char *name;
    boolean gnu_extension;
    boolean groks_macro_args;
    builtin_func *func;
};

struct predefined {
    char *name;
    boolean gnu_extension;
    char *func;
};

typedef struct builtin builtin;
typedef struct predefined predefined;

#ifdef MSDOS
extern void builtin_init (void);
extern void define_user_macro (char *name, char *text,\
			       enum symbol_lookup mode);
extern void undivert_all (void);
extern void expand_user_macro (struct obstack *obs, struct symbol *sym,\
			       int argc, struct token_data **argv);
#else /* not MSDOS */
extern void builtin_init();
extern void define_user_macro();
extern void undivert_all();
extern void expand_user_macro();
#endif /* not MSDOS */


/* File: eval.c  --- expression evaluation */

#ifdef MSDOS
typedef long eval_t;		/* use 32-bit arithmetic */
extern enum boolean evaluate (char *expr, eval_t *val);        /* eval.c */
#else /* not MSDOS */
typedef int eval_t;
extern boolean evaluate();
#endif /* not MSDOS */


/* Debug stuff */

#ifdef DEBUG
#define DEBUG_INPUT
#define DEBUG_MACRO
#define DEBUG_SYM

#endif


/* Obstack stuff.  */

#ifdef MSDOS
extern void _obstack_free (struct obstack *h, void *obj);
extern void _obstack_begin (struct obstack *h, int size, int alignment,\
			    void * (*chunkfun) (unsigned int size),\
			    void (*freefun) (char *p));
extern void _obstack_newchunk (struct obstack *h, int length);
extern int _obstack_allocated_p (struct obstack *h, void *obj);
#endif /* MSDOS */

