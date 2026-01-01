/* Common definitions for the 'find' package
   Copyright (C) 1987, 1990 Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 1, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.  */

/* MS-DOS port (c) 1990 by Thorsten Ohl, ohl@gnu.ai.mit.edu
   This port is also distributed under the terms of the
   GNU General Public License as published by the
   Free Software Foundation.

   Please note that this file is not identical to the
   original GNU release, you should have received this
   code as patch to the official release.

   $Header: e:/gnu/find/RCS/defs.h 1.2.0.3 90/09/23 16:10:04 tho Exp $
 */

#include "regex.h"

typedef char boolean;
#define		true    1
#define		false	0

#ifdef MSDOS

#define PARSE_ARGS \
  char **argv, int *arg_ptr

#define PRED_ARGS \
  char *pathname, struct stat *stat_buf, struct pred_struct *pred_ptr

/* Pointer to function returning boolean. */
typedef boolean (*PRED_FCT) (PRED_ARGS);
typedef boolean (*PARSE_FCT) (PARSE_ARGS);

#include <stdio.h>
#include <stdlib.h>
#include <time.h>

extern struct pred_struct *get_new_pred (void);
extern struct pred_struct *get_new_pred_chk_op (void);
extern struct pred_struct *insert_victim (char (*pred_func)());
extern char *xmalloc (unsigned int n);
extern void usage (char *msg);
extern void error (int status, int errnum, char *message, ...);

extern PARSE_FCT find_parser (char *search_name);
extern char no_side_effects (struct pred_struct *pred);
extern boolean parse_close (PARSE_ARGS);
extern boolean parse_open (PARSE_ARGS);
extern boolean parse_print (PARSE_ARGS);

extern boolean pred_and (PRED_ARGS);
extern boolean pred_atime (PRED_ARGS);
extern boolean pred_close (PRED_ARGS);
extern boolean pred_ctime (PRED_ARGS);
extern boolean pred_exec (PRED_ARGS);
extern boolean pred_fstype (PRED_ARGS);
extern boolean pred_group (PRED_ARGS);
extern boolean pred_inum (PRED_ARGS);
extern boolean pred_links (PRED_ARGS);
extern boolean pred_ls (PRED_ARGS);
extern boolean pred_mtime (PRED_ARGS);
extern boolean pred_name (PRED_ARGS);
extern boolean pred_negate (PRED_ARGS);
extern boolean pred_newer (PRED_ARGS);
extern boolean pred_nogroup (PRED_ARGS);
extern boolean pred_nouser (PRED_ARGS);
extern boolean pred_ok (PRED_ARGS);
extern boolean pred_open (PRED_ARGS);
extern boolean pred_or (PRED_ARGS);
extern boolean pred_perm (PRED_ARGS);
extern boolean pred_permmask (PRED_ARGS);
extern boolean pred_print (PRED_ARGS);
extern boolean pred_prune (PRED_ARGS);
extern boolean pred_regex (PRED_ARGS);
extern boolean pred_size (PRED_ARGS);
extern boolean pred_type (PRED_ARGS);
extern boolean pred_user (PRED_ARGS);

extern boolean insert_exec_ok (boolean (*func) (), PARSE_ARGS);
extern boolean get_num_days (char *str, unsigned long *num_days,
			     enum comparison_type *comp_type);
extern boolean insert_time (PARSE_ARGS, PRED_FCT pred);
extern boolean get_num (char *str, unsigned long *num, short *comp_type);
extern boolean insert_num (PARSE_ARGS, PRED_FCT pred);

extern void read_mtab (void);

struct pred_struct *get_expr (struct pred_struct **input, short prev_prec);
extern void process_path (char *pathname, char root);

extern void main (int argc, char **argv);
extern char *savedir (char *dir, unsigned int name_size);

#else /* not MSDOS */

/* Pointer to function returning boolean. */
typedef boolean (*PFB)();

char *malloc ();
int fprintf ();
int printf ();
long time ();
void exit ();
void free ();

PFB find_parser ();
boolean no_side_effects ();
boolean parse_print ();
char *xmalloc ();
struct pred_struct *get_expr ();
struct pred_struct *get_new_pred ();
struct pred_struct *get_new_pred_chk_op ();
struct pred_struct *insert_victim ();
void error ();
void usage ();
void process_path ();

#endif /* not MSDOS */

#ifdef	DEBUG
void print_tree ();
void print_list ();
#endif	/* DEBUG */

/* Argument structures for predicates. */

enum comparison_type
{
  COMP_GT,
  COMP_LT,
  COMP_EQ
};

enum predicate_type
{
  NO_TYPE,
  VICTIM_TYPE,
  UNI_OP,
  BI_OP,
  OPEN_PAREN,
  CLOSE_PAREN
};

enum predicate_precedence
{
  NO_PREC,
  OR_PREC,
  AND_PREC,
  NEGATE_PREC,
  MAX_PREC
};

struct long_t
{
  enum comparison_type kind;
  unsigned long l_val;
};

struct size_t
{
  short kind;
  boolean block;
  unsigned long size;
};

struct exec_t
{
  short *path_loc;
  char **vec;
};

struct pred_struct
{
  /* Pointer to the function that implements this predicate.  */
#ifdef MSDOS
  PRED_FCT pred_func;
#else
  PFB pred_func;
#endif
#ifdef	DEBUG
  char *p_name;
#endif

  /* The type of this node.  There are two kinds.  The first is real
     predicates ("victims") such as -perm, -print, or -exec.  The
     other kind is operators for combining predicates. */
  enum predicate_type p_type;

  /* The precedence of this node.  Only has meaning for operators. */
  enum predicate_precedence p_prec;

  /* True if this predicate node produces side effects. */
  boolean side_effects;

  /* Information needed by the predicate processor.
     Next to each member are listed the predicates that use it. */
  union
  {
    char *str;			/* name fstype */
    struct re_pattern_buffer *regex; /* regex */
    struct exec_t exec_vec;	/* exec ok */
    struct long_t info;		/* atime ctime mtime inum links */
    struct size_t size;		/* size */
    unsigned short uid;		/* user */
    unsigned short gid;		/* group */
    time_t time;		/* newer */
    unsigned long perm;		/* perm permmask */
    unsigned long type;		/* type */
  } args;

  /* The next predicate in the user input sequence,
     which repesents the order in which the user supplied the
     predicates on the command line. */
  struct pred_struct *pred_next;

  /* The right and left branches from this node in the expression
     tree, which represents the order in which the nodes should be
     processed. */
  struct pred_struct *pred_left;
  struct pred_struct *pred_right;
};

/* The number of seconds in a day. */
#define		DAYSECS	    86400

/* The number of bytes in a block for -size. */
#define		BLKSIZE	    512

#ifndef MSDOS			/* errno is declared `volatile'! */
extern int errno;
#endif

extern char *program_name;
extern struct pred_struct *predicates;
extern struct pred_struct *last_pred;
extern boolean do_dir_first;
extern unsigned long perm_mask;
extern long cur_day_start;
extern boolean full_days;
extern boolean stay_on_filesystem;
extern boolean stop_at_current_level;
extern int exit_status;
