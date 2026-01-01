/* find -- search for files in a directory heirarchy
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

/* GNU find was written by Eric Decker (cire@cisco.com),
   with enhancements by David MacKenzie (djm@ai.mit.edu). */

/* MS-DOS port (c) 1990 by Thorsten Ohl, ohl@gnu.ai.mit.edu
   This port is also distributed under the terms of the
   GNU General Public License as published by the
   Free Software Foundation.

   Please note that this file is not identical to the
   original GNU release, you should have received this
   code as patch to the official release.

   $Header: e:/gnu/find/RCS/find.c 1.2.0.3 90/09/23 16:09:38 tho Exp $
 */

/* Usage: find path... [expression]

   Predicates:

   Numbers can be specified as
   +n for greater than n, or
   -n for less than n,
   n for exactly n.

   If none of -print, -ls, -ok, -exec are given, -print is assumed.

   -atime n			file last accessed n*24 hours ago
   -ctime n			file status last modified n*24 hours ago
   -depth			true; process dir contents before dir itself
   -exec cmd			exec cmd, true if 0 status returned
   -fulldays			true; from day boundaries rather than from now
   -fstype type			file is on a filesystem of type type
   -group gname			file belongs to group gname (gid allowed)
   -inum n			file has inode number n
   -links n			file has n links
   -ls				true; list current file in 'ls -li' format
   -mtime n			file data last modified n*24 hours ago
   -name pattern		base of path name matches glob pattern
				('*' and '?' do not match '.' at start)
   -newer file			modtime is more recent than file's
   -nouser			no user corresponds to file's uid
   -nogroup			no group corresponds to file's gid
   -ok cmd			like exec but ask user first; false if not 'y'
   -perm mode			perm bits are exactly mode (octal or symbol)
   -perm -mode			perm bits mode are set (s,s,t checked)
   -permmask mode		true; set significant bits mask for next -perm
				(allows testing for unset bits)
   -print			true; print current full pathname
   -prune			(no -depth) true; do not descend current dir
				(-depth) false; no effect
   -regex pattern		path name matches regex pattern
   -size n[c]			file has n blocks (or chars)
   -type c			file type: b, c, d, p, f, l, s
   -user uname			file is owned by uname (uid allowed)
   -version			true; print find version number on stderr
   -xdev			true; don't descend dirs with different st_dev

   Grouping operators (in order of decreasing precendence):

   ( expr )			force precedence
   ! expr			true if expr is false
   expr1 expr2			and (implied); expr2 not eval if expr1 false
   expr1 -o expr2		or; expr2 not eval if expr1 true
   expr1 -or expr2		same as -o

   find processes files by applying each predicate in turn until the
   overall expression evaluates false.  The expression evaluation
   continues until the outcome is known (left hand side false for and,
   true for or).  Once this happens no more expressions are
   evaluated and find moves on to the next pathname.

   Exits with status 0 if all files are processed successfully,
   >0 if error occurrs. */

#include <sys/types.h>
#include <stdio.h>
#ifndef USG
#include <strings.h>
#else
#include <string.h>
#define index strchr
#define rindex strrchr
#endif
#include <sys/stat.h>
#ifndef S_IFLNK
#define lstat stat
#endif

#include "defs.h"

#define apply_predicate(pathname, stat_buf_ptr, node)	\
  (*(node)->pred_func)((pathname), (stat_buf_ptr), (node))

char *savedir ();
void error ();

/* Name this program was run with. */
char *program_name;

/* All predicates for each path to process. */
struct pred_struct *predicates;

/* The last predicate allocated. */
struct pred_struct *last_pred;

/* The root of the evaluation tree. */
struct pred_struct *eval_tree;

/* If true, process directory before contents.  True unless -depth given. */
boolean do_dir_first;

/* Global permission mask for -perm. */
unsigned long perm_mask;

/* Seconds between 00:00 1/1/70 and either one day before now
   (the default), or the start of today (if -fulldays is given). */
long cur_day_start;

/* If true, cur_day_start has been adjusted to the start of the day. */
boolean full_days;

/* If true, don't cross filesystem boundaries. */
boolean stay_on_filesystem;

/* If true, don't descend past current directory. */
boolean stop_at_current_level;

/* Status value to return to system. */
int exit_status;

void
main (argc, argv)
     int argc;
     char *argv[];
{
  int i;
#ifdef MSDOS
  PARSE_FCT parse_function;
#else
  PFB parse_function;		/* Pointer to who is to do the parsing. */
#endif
  struct pred_struct *cur_pred;
  char *predicate_name;		/* Name of predicate being parsed. */

  program_name = argv[0];

  predicates = NULL;
  last_pred = NULL;
  do_dir_first = true;
  cur_day_start = time ((long *) 0) - DAYSECS;
  full_days = false;
  stay_on_filesystem = false;
  exit_status = 0;

#ifdef	DEBUG
  printf ("%ld %s", cur_day_start, ctime (&cur_day_start));
#endif /* DEBUG */

  /* Find where in ARGV the predicates begin. */
  for (i = 1; i < argc && index ("-!()", argv[i][0]) == 0; i++)
    ;

  if (i == 1)
    usage ("no paths specified");

  /* Enclose the expression in `( ... )' so a default -print will
     apply to the whole expression. */
  parse_open (argv, &argc);
  /* Build the input order list. */
  while (i < argc)
    {
      if (index ("-!()", argv[i][0]) == 0)
	usage ("paths must precede expression");
      predicate_name = argv[i];
      parse_function = find_parser (predicate_name);
      if (parse_function == NULL)
	error (1, 0, "invalid predicate `%s'", predicate_name);
      i++;
      if (!(*parse_function) (argv, &i))
	{
	  if (argv[i] == NULL)
	    error (1, 0, "missing argument to `%s'", predicate_name);
	  else
	    error (1, 0, "invalid argument to `%s'", predicate_name);
	}
    }
  if (predicates->pred_next == NULL)
    {
      /* No predicates that are entered into the tree were given.
	 Remove the `(', because `( ) -print' is not a valid expression. */
      free (predicates);
      predicates = last_pred = NULL;
    }
  else
    parse_close (argv, &argc);

  if (no_side_effects (predicates))
    parse_print (argv, &argc);

#ifdef	DEBUG
  print_list (predicates);
#endif /* DEBUG */

  /* Done parsing the predicates.  Build the evaluation tree. */
  cur_pred = predicates;
  eval_tree = get_expr (&cur_pred, NO_PREC);
#ifdef	DEBUG
  print_tree (eval_tree, 0);
#endif /* DEBUG */

  /* Process all of the input paths. */
  for (i = 1; i < argc && index ("-!()", argv[i][0]) == 0; i++)
    process_path (argv[i], true);

  exit (exit_status);
}

/* Recursively descend path PATHNAME, applying the predicates.
   If ROOT is true, PATHNAME is a command line argument, and
   thus the root of a subtree. */

void
process_path (pathname, root)
     char *pathname;
     boolean root;
{
  static dev_t root_dev;
  struct stat stat_buf;
  char *name_space;

  if (lstat (pathname, &stat_buf) != 0)
    {
      error (0, errno, "%s", pathname);
      exit_status = 1;
      return;
    }

  if ((stat_buf.st_mode & S_IFMT) != S_IFDIR)
    {
      perm_mask = 07777;	/* Start fresh. */
      apply_predicate (pathname, &stat_buf, eval_tree);
      return;
    }

  if (stay_on_filesystem)
    {
      if (root)
	root_dev = stat_buf.st_dev;
      else if (stat_buf.st_dev != root_dev)
	return;
    }

  stop_at_current_level = false;

  if (do_dir_first)
    {
      perm_mask = 07777;	/* Start fresh. */
      apply_predicate (pathname, &stat_buf, eval_tree);
    }

  if (stop_at_current_level == false)
    {
      errno = 0;
      name_space = savedir (pathname, stat_buf.st_size);
      if (name_space == NULL)
	{
	  if (errno)
	    {
	      error (0, errno, "%s", pathname);
	      exit_status = 1;
	    }
	  else
	    error (1, 0, "virtual memory exhausted");
	}
      else
	{
	  char *namep;		/* Current point in `name_space'. */
	  char *cur_path;	/* Full path of each file to process. */
	  unsigned cur_path_size; /* Bytes allocated for `cur_path'. */
	  unsigned file_len;	/* Length of each path to process. */
	  unsigned pathname_len; /* Length of `pathname' + 2. */

	  if (!strcmp (pathname, "/"))
	    pathname_len = 2;	/* Won't add a slash to this. */
#ifdef MSDOS
	  else if (!strcmp (pathname + 1, ":/"))
	    pathname_len = 4;	/* Won't add a slash to this either. */
#endif /* MSDOS */
	  else
	    pathname_len = strlen (pathname) + 2; /* For '/' and '\0'. */
	  cur_path_size = 0;
	  cur_path = NULL;

	  for (namep = name_space; *namep;
	       namep += file_len - pathname_len + 1)
	    {
	      file_len = pathname_len + strlen (namep);
	      if (file_len > cur_path_size)
		{
		  while (file_len > cur_path_size)
		    cur_path_size += 1024;
		  if (cur_path)
		    free (cur_path);
		  cur_path = xmalloc (cur_path_size);
		  strcpy (cur_path, pathname);
		  cur_path[pathname_len - 2] = '/';
		}
	      strcpy (cur_path + pathname_len - 1, namep);
	      process_path (cur_path, false);
	    }
	  if (cur_path)
	    free (cur_path);
	  free (name_space);
	}
    }

  if (do_dir_first == false)
    {
      perm_mask = 07777;	/* Start fresh. */
      apply_predicate (pathname, &stat_buf, eval_tree);
    }
}

/* Return true if there are no side effects in any of the predicates in
   predicate list PRED, false if there are any. */

boolean
no_side_effects (pred)
     struct pred_struct *pred;
{
  while (pred != NULL)
    {
      if (pred->side_effects)
	return (false);
      pred = pred->pred_next;
    }
  return (true);
}
