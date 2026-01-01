/* Shared definitions for GNU DIFF
   Copyright (C) 1988, 1989 Free Software Foundation, Inc.

This file is part of GNU DIFF.

GNU DIFF is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 1, or (at your option)
any later version.

GNU DIFF is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with GNU DIFF; see the file COPYING.  If not, write to
the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.  */

/* MS-DOS port (c) 1990 by Thorsten Ohl, ohl@gnu.ai.mit.edu
This port is also distributed under the terms of the GNU General
Public License as published by the Free Software Foundation.

Please note that this file is not identical to the original GNU release,
you should have received this code as patch to the official release.

$Header: e:/gnu/diff/RCS/diff.h 1.15.0.2 91/03/12 17:06:56 tho Exp $  */


#include <ctype.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>

#ifdef USG
#include <time.h>
#ifdef MSDOS
#include <stdlib.h>
#include <malloc.h>
#include <string.h>
#include <process.h>
#include <io.h>
#endif /* MSDOS */
#ifdef HAVE_NDIR
#ifdef NDIR_IN_SYS
#include <sys/ndir.h>
#else
#include <ndir.h>
#endif /* not NDIR_IN_SYS */
#else
#include <dirent.h>
#endif /* not HAVE_NDIR */
#include <fcntl.h>
#ifndef HAVE_DIRECT
#define direct dirent
#endif
#else /* not USG */
#include <sys/time.h>
#include <sys/dir.h>
#include <sys/file.h>
#endif

#ifdef USG
/* Define needed BSD functions in terms of sysV library.  */

#ifdef MSDOS
#define bcopy(s,d,n)	memmove((d),(s),(n))	/* more save! */
#else
#define bcopy(s,d,n)	memcpy((d),(s),(n))
#endif
#define bcmp(s1,s2,n)	memcmp((s1),(s2),(n))
#define bzero(s,n)	memset((s),0,(n))

#if !defined (XENIX) && !defined (MSDOS)
#define dup2(f,t)	(close(t),fcntl((f),F_DUPFD,(t)))
#endif

#define vfork	fork
#define index	strchr
#define rindex	strrchr
#endif

#ifdef sparc
/* vfork clobbers registers on the Sparc, so don't use it.  */
#define vfork fork
#endif

#include <errno.h>
#ifndef MSDOS			/* have it VOLATILE in <stdlib.h> */
extern int      errno;
extern int      sys_nerr;
extern char    *sys_errlist[];
#endif /* not MSDOS */

#define	EOS		(0)
#define	FALSE		(0)
#define TRUE		1

#ifndef MSDOS				/* have it in <stdlib.h> */
#define min(a,b) ((a) <= (b) ? (a) : (b))
#define max(a,b) ((a) >= (b) ? (a) : (b))
#endif

#ifndef PR_FILE_NAME
#define PR_FILE_NAME "/bin/pr"
#endif

/* Support old-fashioned C compilers.  */
#if defined (__STDC__) || defined (__GNUC__)
#include "limits.h"
#else
#define INT_MAX 2147483647
#define CHAR_BIT 8
#endif

/* Support old-fashioned C compilers.  */
#if !defined (__STDC__) && !defined (__GNUC__) || defined (MSDOS)
#define const
#endif

#ifndef O_RDONLY
#define O_RDONLY 0
#endif

#ifdef MSDOS
#if !defined (_MSC_VER) || (_MSC_VER < 600)
#define _huge huge
#endif /* MSC 5.1 */
#else /* not MSDOS */
#define _huge
#endif /* not MSDOS */

/* Variables for command line options */

#ifndef GDIFF_MAIN
#define EXTERN extern
#else
#define EXTERN
#endif

enum output_style {
  /* Default output style.  */
  OUTPUT_NORMAL,
  /* Output the differences with lines of context before and after (-c).  */
  OUTPUT_CONTEXT,
  /* Output the differences in a unified context diff format (-u). */
  OUTPUT_UNIFIED,
  /* Output the differences as commands suitable for `ed' (-e).  */
  OUTPUT_ED,
  /* Output the diff as a forward ed script (-f).  */
  OUTPUT_FORWARD_ED,
  /* Like -f, but output a count of changed lines in each "command" (-n). */
  OUTPUT_RCS,
  /* Output merged #ifdef'd file (-D).  */
  OUTPUT_IFDEF };

/* True for output styles that are robust,
   i.e. can handle a file that ends in a non-newline.  */
#define ROBUST_OUTPUT_STYLE(S) \
 ((S) == OUTPUT_CONTEXT || (S) == OUTPUT_UNIFIED || (S) == OUTPUT_RCS \
  || (S) == OUTPUT_NORMAL)

EXTERN enum output_style output_style;

/* Number of lines of context to show in each set of diffs.
   This is zero when context is not to be shown.  */
EXTERN int      context;

/* Consider all files as text files (-a).
   Don't interpret codes over 0177 as implying a "binary file".  */
EXTERN int	always_text_flag;

/* Ignore changes in horizontal whitespace (-b).  */
EXTERN int      ignore_space_change_flag;

/* Ignore all horizontal whitespace (-w).  */
EXTERN int      ignore_all_space_flag;

/* Ignore changes that affect only blank lines (-B).  */
EXTERN int      ignore_blank_lines_flag;

/* Ignore changes that affect only lines matching this regexp (-I).  */
EXTERN char	*ignore_regexp;

/* Result of regex-compilation of `ignore_regexp'.  */
EXTERN struct re_pattern_buffer ignore_regexp_compiled;

/* 1 if lines may match even if their lengths are different.
   This depends on various options.  */
EXTERN int      length_varies;

/* Ignore differences in case of letters (-i).  */
EXTERN int      ignore_case_flag;

/* File labels for `-c' output headers (-L).  */
EXTERN char *file_label[2];

/* Regexp to identify function-header lines (-F).  */
EXTERN char	*function_regexp;

/* Result of regex-compilation of `function_regexp'.  */
EXTERN struct re_pattern_buffer function_regexp_compiled;

/* Say only whether files differ, not how (-q).  */
EXTERN int 	no_details_flag;

/* Report files compared that match (-s).
   Normally nothing is output when that happens.  */
EXTERN int      print_file_same_flag;

/* character that ends a line.  Currently this is always `\n'.  */
EXTERN char     line_end_char;

/* Output the differences with exactly 8 columns added to each line
   so that any tabs in the text line up properly (-T).  */
EXTERN int	tab_align_flag;

/* Expand tabs in the output so the text lines up properly
   despite the characters added to the front of each line (-t).  */
EXTERN int	tab_expand_flag;

/* In directory comparison, specify file to start with (-S).
   All file names less than this name are ignored.  */
EXTERN char	*dir_start_file;

/* If a file is new (appears in only one dir)
   include its entire contents (-N).
   Then `patch' would create the file with appropriate contents.  */
EXTERN int	entire_new_file_flag;

/* Pipe each file's output through pr (-l).  */
EXTERN int	paginate_flag;

/* String to use for #ifdef (-D).  */
EXTERN char *	ifdef_string;

/* String containing all the command options diff received,
   with spaces between and at the beginning but none at the end.
   If there were no options given, this string is empty.  */
EXTERN char *	switch_string;

/* Nonzero means use heuristics for better speed.  */
EXTERN int	heuristic;

/* Name of program the user invoked (for error messages).  */
EXTERN char *	program;

/* The result of comparison is an "edit script": a chain of `struct change'.
   Each `struct change' represents one place where some lines are deleted
   and some are inserted.
   
   LINE0 and LINE1 are the first affected lines in the two files (origin 0).
   DELETED is the number of lines deleted here from file 0.
   INSERTED is the number of lines inserted here in file 1.

   If DELETED is 0 then LINE0 is the number of the line before
   which the insertion was done; vice versa for INSERTED and LINE1.  */

struct change
{
  struct change *link;		/* Previous or next edit command  */
  int inserted;			/* # lines of file 1 changed here.  */
  int deleted;			/* # lines of file 0 changed here.  */
  int line0;			/* Line number of 1st deleted line.  */
  int line1;			/* Line number of 1st inserted line.  */
  char ignore;			/* Flag used in context.c */
};

/* Structures that describe the input files.  */

/* Data on one line of text.  */

struct line_def {
    char _huge  *text;
    int         length;
    unsigned	hash;
};

/* Data on one input file being compared.  */

struct file_data {
    int             desc;	/* File descriptor  */
    char           *name;	/* File name  */
    struct stat     stat;	/* File status from fstat()  */
    int             dir_p;	/* 1 if file is a directory  */

    /* Buffer in which text of file is read.  */
    char _huge *    buffer;     /* Allocated size of buffer.  */
#ifdef MSDOS
    /* Allocated size of buffer.  */
    long	    bufsize;
    /* Number of valid characters now in the buffer. */
    long	    buffered_chars;
#else /* not MSDOS */
    /* Allocated size of buffer.  */
    int		    bufsize;
    /* Number of valid characters now in the buffer. */
    int		    buffered_chars;
#endif /* not MSDOS */

    /* Array of data on analyzed lines of this chunk of this file.  */
    struct line_def *linbuf;

    /* Allocated size of linbuf array (# of elements).  */
    int		    linbufsize;

    /* Number of elements of linbuf containing valid data. */
    int		    buffered_lines;

    /* Pointer to end of prefix of this file to ignore when hashing. */
    char _huge *prefix_end;

    /* Count of lines in the prefix. */
    int prefix_lines;

    /* Pointer to start of suffix of this file to ignore when hashing. */
    char _huge *suffix_begin;

    /* Count of lines in the suffix. */
    int suffix_lines;

    /* Vector, indexed by line number, containing an equivalence code for
       each line.  It is this vector that is actually compared with that
       of another file to generate differences. */
    int		   *equivs;

    /* Vector, like the previous one except that
       the elements for discarded lines have been squeezed out.  */
    int		   *undiscarded;

    /* Vector mapping virtual line numbers (not counting discarded lines)
       to real ones (counting those lines).  Both are origin-0.  */
    int		   *realindexes;

    /* Total number of nondiscarded lines. */
    int		    nondiscarded_lines;

    /* Vector, indexed by real origin-0 line number,
       containing 1 for a line that is an insertion or a deletion.
       The results of comparison are stored here.  */
    char	   *changed_flag;

    /* 1 if file ends in a line with no final newline. */
    int		    missing_newline;

    /* 1 more than the maximum equivalence value used for this or its
       sibling file. */
    int equiv_max;

    /* Table translating diff's internal line numbers 
       to actual line numbers in the file.
       This is needed only when some lines have been discarded.
       The allocated size is always linbufsize
       and the number of valid elements is buffered_lines.  */
    int		   *ltran;
};

/* Describe the two files currently being compared.  */

struct file_data files[2];

/* Queue up one-line messages to be printed at the end,
   when -l is specified.  Each message is recorded with a `struct msg'.  */

struct msg
{
  struct msg *next;
  char *format;
  char *arg1;
  char *arg2;
};

/* Head of the chain of queues messages.  */

EXTERN struct msg *msg_chain;

/* Tail of the chain of queues messages.  */

EXTERN struct msg *msg_chain_end;

/* Stdio stream to output diffs to.  */

EXTERN FILE *outfile;

/* Declare various functions.  */

#ifdef __STDC__
#define VOID void

extern int diff_2_files(struct file_data *, int);
extern void print_context_header (struct file_data *inf, int unidiff_flag);
extern void print_context_script (struct change *script, int unidiff_flag);
extern int diff_dirs (char *name1, char *name2,
		      int (*handle_file) (char *, char *, char *, char *, int),
		      int depth, int nonex1, int nonex2);
extern void print_rcs_script (struct change *);
extern void print_ed_script (struct change *);
extern void pr_forward_ed_script (struct change *);
extern void print_ifdef_script (struct change *);
extern int read_files (struct file_data *);
extern void print_normal_script (struct change *);
extern int line_cmp (struct line_def *, struct line_def *);
extern  void pfatal_with_name (char *);
extern void *xcalloc (int, int);
extern void print_1_line (char *, struct line_def *);
extern void message (char *,...);
extern void print_message_queue (void);
extern struct change *find_change (struct change *);
extern void error (char *,...);
extern char *concat (char *, char *, char *);
extern int change_letter (int, int);
extern void setup_output (char *, char *, int);
extern void *xmalloc (unsigned int);
extern struct change *find_reverse_change (struct change *);
extern void fatal (char *);
extern void debug_script (struct change *sp);
extern int translate_line_number (struct file_data *, int);
extern void finish_output (void);
extern void perror_with_name (char *);
extern void *xrealloc (void *, unsigned int);
extern void fatal_with_name (char *, char *);
extern void translate_range (struct file_data *, int, int, int *, int *);
extern void print_number_range (char, struct file_data *, int, int);
extern void print_script (struct change *,
			  struct change *(*)(struct change *),
			  void (*)(struct change *));
extern void analyze_hunk (struct change *, int *, int *, int *, int *, int *, int *);
extern long hread (int fd, void _huge *buffer, long bytes);
extern void _huge *xhalloc (long);
extern void _huge *xhrealloc (void _huge *ptr, long new_size, long old_size);

#else
#define VOID char

char *xmalloc ();
char *xrealloc ();
char *concat ();
void free ();
char *rindex ();
char *index ();

void message ();
void print_message_queue ();

#endif /* __STDC__ */
void print_script ();
void translate_range ();
