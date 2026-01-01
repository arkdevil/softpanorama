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
 * $Header: e:/gnu/m4/RCS/m4.c 0.5.1.0 90/09/28 18:35:03 tho Exp $
 */

#include "m4.h"
#include "version.h"

#include <signal.h>

/* Operate interactively (-e) */
int interactive = 0;

/* Enable sync output for /lib/cpp (-s) */
int sync_output = 0;

/* Debug (-d[level]) */
int debug_level = 0;

/* Hash table size (should be a prime) (-Hsize) */
int hash_table_size = HASHMAX;

/* Disable GNU extensions (-G) */
int no_gnu_extensions = 0;

#ifdef TRACE_MEMORY_USAGE
/* Look where m4 eats up the memory (-t) */
int trace_memory_usage = 0;
#endif /* TRACE_MEMORY_USAGE */


#ifdef MSDOS
extern int main (int argc, char **argv);
static void vmesg(char *level, char *fmt, va_list args);
static void no_memory (void);
static void usage (void);
#endif /* MSDOS */


/* 
 * usage --- Print usage message on stderr.
 */
void 
usage()
{
    fprintf(stderr, "Usage: m4 [options] file ....\n");
    exit(1);
}


#define NEXTARG --argc, ++argv

int 
main(argc, argv)
    int argc;
    char **argv;
{
    boolean no_more_options = false;
    char *macro_value;
    FILE *fp;

    /* 
     * First, we decode the basic arguments, to size up tables and stuff.
     */
    for (NEXTARG; argc && argv[0][0] == '-'; NEXTARG) {
	switch (argv[0][1]) {
	case 'e':
	    interactive = 1;
	    break;

	case 'V':
	    fprintf(stderr,
#ifdef MSDOS
		    "\
GNU m4 %s, Copyright (C) 1989, 1990 Free Software Foundation, Inc.\n\
There is ABSOLUTELY NO WARRANTY for GNU m4.  See the file\n\
COPYING in the source distribution for more details.\n\
$Header: e:/gnu/m4/RCS/m4.c 0.5.1.0 90/09/28 18:35:03 tho Exp $\n\
(compiled " __DATE__ " " __TIME__ " MS-DOS)\n",
#else /* not MSDOS */
		    "\
GNU m4 %s, Copyright (C) 1989, 1990 Free Software Foundation, Inc.\n\
There is ABSOLUTELY NO WARRANTY for GNU m4.  See the file\n\
COPYING in the source distribution for more details.\n",
#endif /* not MSDOS */
		    version);
	    break;

	case 's':
	    sync_output = 1;
	    break;

	case 'd':
	    debug_level = atoi(&argv[0][2]);
	    if (debug_level < 0)
		debug_level = 0;
	    break;

	case 'H':
	    hash_table_size = atoi(&argv[0][2]);
	    if (hash_table_size <= 0)
		hash_table_size = HASHMAX;
	    break;

	case 'G':
	    no_gnu_extensions = 1;
	    break;

	case 'B':			/* compatibility junk */
	case 'S':
	case 'T':
	    break;

#ifdef TRACE_MEMORY_USAGE
	case 't':
	    trace_memory_usage++;
	    break;
#endif /* TRACE_MEMORY_USAGE */

	default:
	    usage();

	    /* These are handled later */
	case '\0':			/* `-' meaning standard input */
	case 'D':			/* define macro */
	case 'U':			/* undefine macro */
	    no_more_options = true;
	    break;
	}
	if (no_more_options)
	    break;
    }

    input_init();
    output_init();
    symtab_init();
    builtin_init();
    
    /* 
     * Define command line macro definitions.  Must come after
     * initialisation of the symbol table.
     */
    no_more_options = false;
    for (; argc && argv[0][0] == '-'; NEXTARG) {
	switch (argv[0][1]) {
	case '\0':
	    no_more_options = true;
	    break;

	case 'D':
	    macro_value = index(&argv[0][2], '=');
	    if (macro_value == nil)
		macro_value = "";
	    else
		*macro_value++ = '\0';
	    define_user_macro(&argv[0][2], macro_value, SYMBOL_INSERT);
	    break;

	case 'U':
	    lookup_symbol(&argv[0][2], SYMBOL_DELETE);
	    break;

	default:
	    usage();
	    break;
	}
	if (no_more_options)
	    break;
    }

    /* 
     * Interactive mode means unbuffered output, and interrupts ignored.
     */
    if (interactive) {
	signal(SIGINT, SIG_IGN);
	setbuf(stdout, (char *)NULL);
    }

    /* 
     * Handle the various input files.  Each file is pushed on the
     * input, and the input read.  Wrapup text is handled separately
     * later.
     */
    if (argc == 0) {
	push_file(stdin, "Standard Input");
	expand_input();    
    } else {
	for ( ; argc > 0; NEXTARG) {
	    if (strcmp(argv[0], "-") == 0) {
		push_file(stdin, "Standard Input");
	    } else {
		fp = fopen(argv[0], "r");
		if (fp == nil) {
		    error("can't open %s: %s", argv[0], syserr());
		    continue;
		} else
		    push_file(fp, argv[0]);
	    }
	    expand_input();
	}
    }
#undef NEXTARG
    
    /* Now handle wrapup text. */
    while (pop_wrapup())
	expand_input();

    undivert_all();

    return 0;
}



/* 
 * The rest of this file contains error handling functions, and memory
 * allocation.
 */

#ifdef MSDOS			/* <stdarg.h> */

/* Basic varargs function for all error output */

void 
vmesg(char *level, char *fmt, va_list args)
{
  fflush(stdout);
  fprintf(stderr, "%s: %d: ", current_file, current_line);
  if (level != nil)
    fprintf(stderr, "%s: ", level);

  vfprintf(stderr, fmt, args);

  putc('\n', stderr);
}

/* Internal errors -- print and dump core */

void 
internal_error (char *fmt, ...)
{
  va_list args;

  va_start (args, fmt);
  vmesg ("internal error", fmt, args);
  va_end (args);

  abort();
}

/* Fatal error -- print and exit */

void 
fatal (char *fmt, ...)
{
  va_list args;

  va_start (args, fmt);
  vmesg ("fatal error", fmt, args);
  va_end (args);

  exit (1);
}

/* "Normal" error -- just complain */

void 
error (char *fmt, ...)
{
  va_list args;

  va_start (args, fmt);
  vmesg ((char *)nil, fmt, args);
  va_end (args);
}

/* Warning --- for potential trouble */

void 
warning (char *fmt, ...)
{
  va_list args;

  va_start (args, fmt);
  vmesg ("warning", fmt, args);
  va_end (args);
}

#else /* not MSDOS */

/* Basic varargs function for all error output */

void 
vmesg(level, args)
    char *level;
    va_list args;
{
    char *fmt;

    fflush(stdout);
    fmt = va_arg(args, char*);
    fprintf(stderr, "%s: %d: ", current_file, current_line);
    if (level != nil)
	fprintf(stderr, "%s: ", level);
    vfprintf(stderr, fmt, args);
    putc('\n', stderr);
}

/* Internal errors -- print and dump core */
/* VARARGS */
void 
internal_error(va_alist)
    va_dcl
{
    va_list args;
    va_start(args);
    vmesg("internal error", args);
    va_end(args);

    abort();
}

/* Fatal error -- print and exit */
/* VARARGS */
void 
fatal(va_alist)
    va_dcl
{
    va_list args;
    va_start(args);
    vmesg("fatal error", args);
    va_end(args);

    exit(1);
}

/* "Normal" error -- just complain */
/* VARARGS */
void 
error(va_alist)
    va_dcl
{
    va_list args;
    va_start(args);
    vmesg((char *)nil, args);
    va_end(args);
}

/* Warning --- for potential trouble */
/* VARARGS */
void 
warning(va_alist)
    va_dcl
{
    va_list args;
    va_start(args);
    vmesg("warning", args);
    va_end(args);
}

#endif /* not MSDOS */


/* 
 * Memory allocation functions
 */

/* Out ofmemory error -- die */
void 
no_memory()
{
    fatal("Out of memory");
}

/* Free previously allocated memory */
void 
xfree(p)
    char *p;
{
#ifdef TRACE_MEMORY_USAGE
    if (trace_memory_usage)
      fprintf (stderr, "freeing @%Fp.\n", (void _far *) p);
#endif /* TRACE_MEMORY_USAGE */
    free(p);
}

/* Semi-safe malloc -- never returns nil */
char *
xmalloc(size)
    unsigned int size;
{
    register char *cp = malloc(size);
#ifdef TRACE_MEMORY_USAGE
    if (trace_memory_usage)
      {
	fprintf (stderr, "allocating %5u (%04x) bytes ", size, size);
	if (cp == nil)
	  fprintf (stderr, "failed.\n");
	else
	  fprintf (stderr, "@%Fp.\n", (void _far *) cp);
      }
#endif /* TRACE_MEMORY_USAGE */
    if (cp == nil)
	no_memory();
    return cp;
}

#if 0
/* Ditto realloc */
char *
xrealloc(p, size)
    char *p;
    unsigned int size;
{
    register char *cp = realloc(p, size);
    if (cp == nil)
	no_memory();
    return cp;
}
#endif

/* and strdup */
char *
xstrdup(s)
    char *s;
{
    return strcpy(xmalloc((unsigned int)strlen(s)+1), s);
}
