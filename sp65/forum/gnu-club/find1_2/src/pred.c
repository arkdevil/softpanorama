/* The Predicates and associated routines for Find.
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

   $Header: e:/gnu/find/RCS/pred.c 1.2.0.3 90/09/23 16:09:50 tho Exp $
 */

#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <pwd.h>
#ifndef MSDOS
struct passwd *getpwuid ();
#include <grp.h>
struct group *getgrgid ();
#endif /* not MSDOS */
#ifndef USG
#include <strings.h>
#else
#include <string.h>
#define index strchr
#define rindex strrchr
#endif
#include "defs.h"

#ifdef MSDOS

#include <time.h>
#include <process.h>

extern void error (int status, int errnum, char *message, ...);
extern char *basename (char *fname);
extern char *filesystem_type (struct stat *statp);
extern void list_file (char *name, struct stat *statp);
extern int glob_match (char *pattern, char *text, int dot_special);

static char launch (struct pred_struct *pred_ptr);

#else /* not MSDOS */

int fork ();
int wait ();

boolean pred_and ();
boolean pred_atime ();
boolean pred_close ();
boolean pred_ctime ();
/* no pred_depth */
boolean pred_exec ();
boolean pred_fstype ();
/* no pred_fulldays */
boolean pred_group ();
boolean pred_inum ();
boolean pred_links ();
boolean pred_ls ();
boolean pred_mtime ();
boolean pred_name ();
boolean pred_negate ();
boolean pred_newer ();
boolean pred_nogroup ();
boolean pred_nouser ();
boolean pred_ok ();
boolean pred_open ();
boolean pred_or ();
boolean pred_perm ();
boolean pred_permmask ();
boolean pred_print ();
boolean pred_prune ();
boolean pred_regex ();
boolean pred_size ();
boolean pred_type ();
boolean pred_user ();
/* no pred_version */
/* no pred_xdev */

boolean launch ();
char *basename ();
char *filesystem_type ();
void list_file ();

#endif /* not MSDOS */

#ifdef	DEBUG
struct pred_assoc
{
#ifdef MSDOS
  PRED_FCT pred_func;
#else
  PFB pred_func;
#endif
  char *pred_name;
};

struct pred_assoc pred_table[] =
{
  {pred_and, "and     "},
  {pred_atime, "atime   "},
  {pred_close, ")       "},
  {pred_ctime, "ctime   "},
  {pred_exec, "exec    "},
  {pred_fstype, "fstype  "},
  {pred_group, "group   "},
  {pred_inum, "inum    "},
  {pred_links, "links   "},
  {pred_ls, "ls      "},
  {pred_mtime, "mtime   "},
  {pred_name, "name    "},
  {pred_negate, "!       "},
  {pred_newer, "newer   "},
  {pred_nogroup, "nogroup "},
  {pred_nouser, "nouser  "},
  {pred_ok, "ok      "},
  {pred_open, "(       "},
  {pred_or, "or      "},
  {pred_perm, "perm    "},
  {pred_permmask, "permmask"},
  {pred_print, "print   "},
  {pred_prune, "prune   "},
  {pred_regex, "regex   "},
  {pred_size, "size    "},
  {pred_type, "type    "},
  {pred_user, "user    "},
  {0, "none    "}
};

struct op_assoc
{
  short type;
  char *type_name;
};

struct op_assoc type_table[] =
{
  {NO_TYPE, "no_type	"},
  {VICTIM_TYPE, "victim_type	"},
  {UNI_OP, "uni_op	"},
  {BI_OP, "bi_op	"},
  {OPEN_PAREN, "open_paren	"},
  {CLOSE_PAREN, "close_paren	"},
  {-1, "unknown	"}
};

struct prec_assoc
{
  short prec;
  char *prec_name;
};

struct prec_assoc prec_table[] =
{
  {NO_PREC, "no_prec     "},
  {OR_PREC, "or_prec     "},
  {AND_PREC, "and_prec	"},
  {NEGATE_PREC, "negate_prec "},
  {MAX_PREC, "max_prec    "},
  {-1, "unknown	"}
};
#endif	/* DEBUG */

/* Predicate processing routines.
 
   PATHNAME is the full pathname of the file being checked.
   *STAT_BUF contains information about PATHNAME.
   *PRED_PTR contains information for applying the predicate.
 
   Return true if the file passes this predicate, false if not. */

boolean
pred_and (pathname, stat_buf, pred_ptr)
     char *pathname;
     struct stat *stat_buf;
     struct pred_struct *pred_ptr;
{
  if ((*pred_ptr->pred_left->pred_func) (pathname, stat_buf,
					 pred_ptr->pred_left))
    return ((*pred_ptr->pred_right->pred_func) (pathname, stat_buf,
						pred_ptr->pred_right));
  else
    return (false);
}

boolean
pred_atime (pathname, stat_buf, pred_ptr)
     char *pathname;
     struct stat *stat_buf;
     struct pred_struct *pred_ptr;
{
#ifdef	DEBUG
  printf ("pred_atime: checking %s %ld %s", pathname, stat_buf->st_atime,
	  ctime (&stat_buf->st_atime));
#endif	/* DEBUG */
  switch (pred_ptr->args.info.kind)
    {
    case COMP_GT:
      if (stat_buf->st_atime > pred_ptr->args.info.l_val)
	return (true);
      break;
    case COMP_LT:
      if (stat_buf->st_atime < pred_ptr->args.info.l_val)
	return (true);
      break;
    case COMP_EQ:
      if ((stat_buf->st_atime >= pred_ptr->args.info.l_val)
	  && (stat_buf->st_atime < pred_ptr->args.info.l_val
	      + DAYSECS))
	return (true);
      break;
    }
  return (false);
}

boolean
pred_close (pathname, stat_buf, pred_ptr)
     char *pathname;
     struct stat *stat_buf;
     struct pred_struct *pred_ptr;
{
  error (0, 0, "oops -- got into pred_close!");
  return (true);
}

boolean
pred_ctime (pathname, stat_buf, pred_ptr)
     char *pathname;
     struct stat *stat_buf;
     struct pred_struct *pred_ptr;
{
  switch (pred_ptr->args.info.kind)
    {
    case COMP_GT:
      if (stat_buf->st_ctime > pred_ptr->args.info.l_val)
	return (true);
      break;
    case COMP_LT:
      if (stat_buf->st_ctime < pred_ptr->args.info.l_val)
	return (true);
      break;
    case COMP_EQ:
      if ((stat_buf->st_ctime >= pred_ptr->args.info.l_val)
	  && (stat_buf->st_ctime < pred_ptr->args.info.l_val
	      + DAYSECS))
	return (true);
      break;
    }
  return (false);
}

boolean
pred_exec (pathname, stat_buf, pred_ptr)
     char *pathname;
     struct stat *stat_buf;
     struct pred_struct *pred_ptr;
{
  int i, path_pos;

  for (path_pos = 0, i = pred_ptr->args.exec_vec.path_loc[0];
       i != -1;
       path_pos++, i = pred_ptr->args.exec_vec.path_loc[path_pos])
    pred_ptr->args.exec_vec.vec[i] = pathname;
  return (launch (pred_ptr));
}

boolean
pred_fstype (pathname, stat_buf, pred_ptr)
     char *pathname;
     struct stat *stat_buf;
     struct pred_struct *pred_ptr;
{
  char *fstype;

  fstype = filesystem_type (stat_buf);
  if (fstype && strcmp (fstype, pred_ptr->args.str) == 0)
    return (true);
  return (false);
}

boolean
pred_group (pathname, stat_buf, pred_ptr)
     char *pathname;
     struct stat *stat_buf;
     struct pred_struct *pred_ptr;
{
  if (pred_ptr->args.gid == stat_buf->st_gid)
    return (true);
  else
    return (false);
}

boolean
pred_inum (pathname, stat_buf, pred_ptr)
     char *pathname;
     struct stat *stat_buf;
     struct pred_struct *pred_ptr;
{
  switch (pred_ptr->args.info.kind)
    {
    case COMP_GT:
      if (stat_buf->st_ino > pred_ptr->args.info.l_val)
	return (true);
      break;
    case COMP_LT:
      if (stat_buf->st_ino < pred_ptr->args.info.l_val)
	return (true);
      break;
    case COMP_EQ:
      if (stat_buf->st_ino == pred_ptr->args.info.l_val)
	return (true);
      break;
    }
  return (false);
}

boolean
pred_links (pathname, stat_buf, pred_ptr)
     char *pathname;
     struct stat *stat_buf;
     struct pred_struct *pred_ptr;
{
  switch (pred_ptr->args.info.kind)
    {
    case COMP_GT:
      if (stat_buf->st_nlink > pred_ptr->args.info.l_val)
	return (true);
      break;
    case COMP_LT:
      if (stat_buf->st_nlink < pred_ptr->args.info.l_val)
	return (true);
      break;
    case COMP_EQ:
      if (stat_buf->st_nlink == pred_ptr->args.info.l_val)
	return (true);
      break;
    }
  return (false);
}

boolean
pred_ls (pathname, stat_buf, pred_ptr)
     char *pathname;
     struct stat *stat_buf;
     struct pred_struct *pred_ptr;
{
  list_file (pathname, stat_buf);
  return (true);
}

boolean
pred_mtime (pathname, stat_buf, pred_ptr)
     char *pathname;
     struct stat *stat_buf;
     struct pred_struct *pred_ptr;
{
  switch (pred_ptr->args.info.kind)
    {
    case COMP_GT:
      if (stat_buf->st_mtime > pred_ptr->args.info.l_val)
	return (true);
      break;
    case COMP_LT:
      if (stat_buf->st_mtime < pred_ptr->args.info.l_val)
	return (true);
      break;
    case COMP_EQ:
      if ((stat_buf->st_mtime >= pred_ptr->args.info.l_val)
	  && (stat_buf->st_mtime < pred_ptr->args.info.l_val
	      + DAYSECS))
	return (true);
      break;
    }
  return (false);
}

boolean
pred_name (pathname, stat_buf, pred_ptr)
     char *pathname;
     struct stat *stat_buf;
     struct pred_struct *pred_ptr;
{
  char *just_fname;

  just_fname = basename (pathname);
  if (glob_match (pred_ptr->args.str, just_fname, 1))
    return (true);
  return (false);
}

boolean
pred_negate (pathname, stat_buf, pred_ptr)
     char *pathname;
     struct stat *stat_buf;
     struct pred_struct *pred_ptr;
{
  return (!(*pred_ptr->pred_left->pred_func) (pathname, stat_buf,
					      pred_ptr->pred_left));
}

boolean
pred_newer (pathname, stat_buf, pred_ptr)
     char *pathname;
     struct stat *stat_buf;
     struct pred_struct *pred_ptr;
{
  if (stat_buf->st_mtime > pred_ptr->args.time)
    return (true);
  return (false);
}

boolean
pred_nogroup (pathname, stat_buf, pred_ptr)
     char *pathname;
     struct stat *stat_buf;
     struct pred_struct *pred_ptr;
{
  return getgrgid (stat_buf->st_gid) == NULL;
}

boolean
pred_nouser (pathname, stat_buf, pred_ptr)
     char *pathname;
     struct stat *stat_buf;
     struct pred_struct *pred_ptr;
{
  return getpwuid (stat_buf->st_uid) == NULL;
}

boolean
pred_ok (pathname, stat_buf, pred_ptr)
     char *pathname;
     struct stat *stat_buf;
     struct pred_struct *pred_ptr;
{
  int i, yes, path_pos;

  for (path_pos = 0, i = pred_ptr->args.exec_vec.path_loc[0];
       i != -1;
       path_pos++, i = pred_ptr->args.exec_vec.path_loc[path_pos])
    pred_ptr->args.exec_vec.vec[i] = pathname;
  fprintf (stderr, "< %s ... %s > ? ",
	   pred_ptr->args.exec_vec.vec[0], pathname);
  fflush (stderr);
  i = getchar ();
  yes = (i == 'y' || i == 'Y');
  while (i != EOF && i != '\n')
    i = getchar ();
  if (yes)
    return (launch (pred_ptr));
  else
    return (false);
}

boolean
pred_open (pathname, stat_buf, pred_ptr)
     char *pathname;
     struct stat *stat_buf;
     struct pred_struct *pred_ptr;
{
  error (0, 0, "oops -- got into pred_open!");
  return (true);
}

boolean
pred_or (pathname, stat_buf, pred_ptr)
     char *pathname;
     struct stat *stat_buf;
     struct pred_struct *pred_ptr;
{
  if (!(*pred_ptr->pred_left->pred_func) (pathname, stat_buf,
					  pred_ptr->pred_left))
    return ((*pred_ptr->pred_right->pred_func) (pathname, stat_buf,
						pred_ptr->pred_right));
  else
    return (true);
}

boolean
pred_perm (pathname, stat_buf, pred_ptr)
     char *pathname;
     struct stat *stat_buf;
     struct pred_struct *pred_ptr;
{
  if (pred_ptr->args.perm & 010000)
    {
      /* Magic flag set in parse_perm: compare suid, sgid, sticky bits as well;
	 also, true if at least the given bits are set. */
      if ((stat_buf->st_mode & 07777 & perm_mask & pred_ptr->args.perm)
	  == (pred_ptr->args.perm & 07777))
	return (true);
    }
  else
    {
      if ((stat_buf->st_mode & 0777 & perm_mask) == pred_ptr->args.perm)
	return (true);
    }
  return (false);
}

boolean
pred_permmask (pathname, stat_buf, pred_ptr)
     char *pathname;
     struct stat *stat_buf;
     struct pred_struct *pred_ptr;
{
  perm_mask = pred_ptr->args.perm;
  return (true);
}

boolean
pred_print (pathname, stat_buf, pred_ptr)
     char *pathname;
     struct stat *stat_buf;
     struct pred_struct *pred_ptr;
{
  puts (pathname);
  return (true);
}

boolean
pred_prune (pathname, stat_buf, pred_ptr)
     char *pathname;
     struct stat *stat_buf;
     struct pred_struct *pred_ptr;
{
  stop_at_current_level = true;
  return (do_dir_first);	/* This is what SunOS find seems to do. */
}

boolean
pred_regex (pathname, stat_buf, pred_ptr)
     char *pathname;
     struct stat *stat_buf;
     struct pred_struct *pred_ptr;
{
  if (re_match (pred_ptr->args.regex, pathname, strlen (pathname), 0,
		(struct re_registers *) NULL) != -1)
    return (true);
  return (false);
}

boolean
pred_size (pathname, stat_buf, pred_ptr)
     char *pathname;
     struct stat *stat_buf;
     struct pred_struct *pred_ptr;
{
  unsigned long f_val;

  if (pred_ptr->args.size.block)
    f_val = (stat_buf->st_size + BLKSIZE - 1) / BLKSIZE;
  else
    f_val = stat_buf->st_size;
  switch (pred_ptr->args.size.kind)
    {
    case COMP_GT:
      if (f_val > pred_ptr->args.size.size)
	return (true);
      break;
    case COMP_LT:
      if (f_val < pred_ptr->args.size.size)
	return (true);
      break;
    case COMP_EQ:
      if (f_val == pred_ptr->args.size.size)
	return (true);
      break;
    }
  return (false);
}

boolean
pred_type (pathname, stat_buf, pred_ptr)
     char *pathname;
     struct stat *stat_buf;
     struct pred_struct *pred_ptr;
{
  if ((stat_buf->st_mode & S_IFMT) == pred_ptr->args.type)
    return (true);
  else
    return (false);
}

boolean
pred_user (pathname, stat_buf, pred_ptr)
     char *pathname;
     struct stat *stat_buf;
     struct pred_struct *pred_ptr;
{
  if (pred_ptr->args.uid == stat_buf->st_uid)
    return (true);
  else
    return (false);
}

boolean
launch (pred_ptr)
     struct pred_struct *pred_ptr;
{
  int status, wait_ret, child_pid;

  /*  1) fork to get a child; parent remembers the child pid
      2) child execs the command requested
      3) parent waits, with stat_loc non_zero
      check for proper pid of child
      Possible returns:
   
      ret	errno	status(h)   status(l)
      pid	x	signal#	    0177	stopped
      pid	x	exit arg    0		term by exit or _exit
      pid	x	0	    signal #	term by signal
      -1	EINTR				parent got signal
      -1	other				some other kind of error
      
      Return true only if the pid matches, status(l) is
      zero, and the exit arg (status high) is 0.
      Otherwise return false, possibly printing an error message. */

#ifdef MSDOS

  status = spawnvp (P_WAIT, pred_ptr->args.exec_vec.vec[0],\
		    pred_ptr->args.exec_vec.vec);

#else /* not MSDOS */

  child_pid = fork ();
  if (child_pid == -1)
    error (1, errno, "cannot fork");
  if (child_pid == 0)
    {
      /* We be the child. */
      execvp (pred_ptr->args.exec_vec.vec[0], pred_ptr->args.exec_vec.vec);
      error (1, errno, "%s", pred_ptr->args.exec_vec.vec[0]);
    }
  wait_ret = wait (&status);
  if (wait_ret == -1)
    {
      error (0, errno, "error waiting for child process");
      exit_status = 1;
      return (false);
    }
  if (wait_ret != child_pid)
    {
      error (0, 0, "wait saw another child, pid %d", wait_ret);
      error (0, 0, "expected child pid %d; status: %d %d",
	     child_pid, status >> 8, status & 0xff);
      exit_status = 1;
      return (false);
    }
  if (status & 0xff == 0177)
    {
      error (0, 0, "child stopped; status %d %d\n",
	     status >> 8, status & 0xff);
      exit_status = 1;
      return (false);
    }

#endif /* not MSDOS */

  if (status & 0xff != 0)
    {
      error (0, 0, "child terminated abnormally; status %d %d",
	     status >> 8, status & 0xff);
      exit_status = 1;
      return (false);
    }
  return (!(status >> 8));
}

#ifdef	DEBUG
/* Return a pointer to the string representation of 
   the predicate function PRED_FUNC. */

char *
find_pred_name (pred_func)
#ifdef MSDOS
     PRED_FCT pred_func;
#else
     PFB pred_func;
#endif
{
  int i;

  for (i = 0; pred_table[i].pred_func != 0; i++)
    if (pred_table[i].pred_func == pred_func)
      break;
  return (pred_table[i].pred_name);
}

char *
type_name (type)
     short type;
{
  int i;

  for (i = 0; type_table[i].type != (short) -1; i++)
    if (type_table[i].type == type)
      break;
  return (type_table[i].type_name);
}

char *
prec_name (prec)
     short prec;
{
  int i;

  for (i = 0; prec_table[i].prec != (short) -1; i++)
    if (prec_table[i].prec == prec)
      break;
  return (prec_table[i].prec_name);
}

/* Walk the expression tree NODE to stdout.
   INDENT is the number of levels to indent the left margin. */

void
print_tree (node, indent)
     struct pred_struct *node;
     int indent;
{
  int i;

  if (node == NULL)
    return;
  for (i = 0; i < indent; i++)
    printf ("    ");
  printf ("%s %s %s %x\n", find_pred_name (node->pred_func),
	  type_name (node->p_type), prec_name (node->p_prec), node);
  for (i = 0; i < indent; i++)
    printf ("    ");
  printf ("left:\n");
  print_tree (node->pred_left, indent + 1);
  for (i = 0; i < indent; i++)
    printf ("    ");
  printf ("right:\n");
  print_tree (node->pred_right, indent + 1);
}

/* Copy STR into BUF and trim blanks from the end of BUF.
   Return BUF. */

char *
blank_rtrim (str, buf)
     char *str;
     char *buf;
{
  int i;

  if (str == NULL)
    return (NULL);
  strcpy (buf, str);
  i = strlen (buf) - 1;
  while ((i >= 0) && ((buf[i] == ' ') || buf[i] == '\t'))
    i--;
  buf[++i] = '\0';
  return (buf);
}

/* Print out the predicate list starting at NODE. */

void
print_list (node)
     struct pred_struct *node;
{
  struct pred_struct *cur;
  char name[256];

  cur = node;
  while (cur != NULL)
    {
      printf ("%s ", blank_rtrim (find_pred_name (cur->pred_func), name));
      cur = cur->pred_next;
    }
  printf ("\n");
}
#endif	/* DEBUG */
