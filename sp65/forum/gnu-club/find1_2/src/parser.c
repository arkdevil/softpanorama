/* The Parsers and associated routines for Find.
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

   $Header: e:/gnu/find/RCS/parser.c 1.2.0.3 90/09/23 16:09:45 tho Exp $
 */

#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <pwd.h>
#ifndef MSDOS
#include <grp.h>
#endif /* not MSDOS */
#include <time.h>
#ifndef USG
#include <strings.h>
#else
#include <string.h>
#define index strchr
#define rindex strrchr
#endif
#include "modechange.h"
#include "defs.h"

#ifndef S_IFLNK
#define lstat stat
#endif

#ifdef MSDOS

static boolean parse_atime (PARSE_ARGS);
static boolean parse_ctime (PARSE_ARGS);
static boolean parse_depth (PARSE_ARGS);
static boolean parse_exec (PARSE_ARGS);
static boolean parse_fulldays (PARSE_ARGS);
static boolean parse_fstype (PARSE_ARGS);
static boolean parse_group (PARSE_ARGS);
static boolean parse_inum (PARSE_ARGS);
static boolean parse_links (PARSE_ARGS);
static boolean parse_ls (PARSE_ARGS);
static boolean parse_mtime (PARSE_ARGS);
static boolean parse_name (PARSE_ARGS);
static boolean parse_negate (PARSE_ARGS);
static boolean parse_newer (PARSE_ARGS);
static boolean parse_nogroup (PARSE_ARGS);
static boolean parse_nouser (PARSE_ARGS);
static boolean parse_ok (PARSE_ARGS);
static boolean parse_or (PARSE_ARGS);
static boolean parse_perm (PARSE_ARGS);
static boolean parse_permmask (PARSE_ARGS);
static boolean parse_prune (PARSE_ARGS);
static boolean parse_regex (PARSE_ARGS);
static boolean parse_size (PARSE_ARGS);
static boolean parse_type (PARSE_ARGS);
static boolean parse_user (PARSE_ARGS);
static boolean parse_version (PARSE_ARGS);
static boolean parse_xdev (PARSE_ARGS);

#else /* not MSDOS */

/* no parse_and */
boolean parse_atime ();
boolean parse_close ();
boolean parse_ctime ();
boolean parse_depth ();
boolean parse_exec ();
boolean parse_fstype ();
boolean parse_fulldays ();
boolean parse_group ();
boolean parse_inum ();
boolean parse_links ();
boolean parse_ls ();
boolean parse_mtime ();
boolean parse_name ();
boolean parse_negate ();
boolean parse_newer ();
boolean parse_nogroup ();
boolean parse_nouser ();
boolean parse_ok ();
boolean parse_open ();
boolean parse_or ();
boolean parse_perm ();
boolean parse_permmask ();
boolean parse_print ();
boolean parse_prune ();
boolean parse_regex ();
boolean parse_size ();
boolean parse_type ();
boolean parse_user ();
boolean parse_version ();
boolean parse_xdev ();

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

#endif /* not MSDOS */

long atol ();
struct group *getgrnam ();
struct passwd *getpwnam ();
struct tm *localtime ();
void endgrent ();
void endpwent ();

boolean get_num ();
boolean insert_exec_ok ();
boolean insert_num ();
boolean insert_time ();
char *find_pred_name ();
void read_mtab ();

#ifdef	DEBUG
char *find_pred_name ();
#endif	/* DEBUG */

struct parser_table_t
{
  char *parser_name;
#ifdef MSDOS
  PARSE_FCT parser_func;
#else
  PFB parser_func;
#endif
};

struct parser_table_t parse_table[] =
{
  {"!", parse_negate},
  {"(", parse_open},
  {")", parse_close},
#ifdef UNIMPLEMENTED_UNIX
  {"a", parse_and},		/* do-nothing */
#endif
  {"atime", parse_atime},
#ifdef UNIMPLEMENTED_UNIX
  {"cpio", parse_cpio},
#endif
  {"ctime", parse_ctime},
  {"depth", parse_depth},
  {"exec", parse_exec},
  {"fulldays", parse_fulldays},	/* nonstandard */
  {"fstype", parse_fstype},
  {"group", parse_group},
  {"inum", parse_inum},		/* nonstandard, Unix */
  {"links", parse_links},
  {"ls", parse_ls},		/* nonstandard, Unix */
  {"mtime", parse_mtime},
  {"name", parse_name},
#ifdef UNIMPLEMENTED_UNIX
  {"ncpio", parse_ncpio},
#endif
  {"newer", parse_newer},
  {"nogroup", parse_nogroup},
  {"nouser", parse_nouser},
  {"o", parse_or},
  {"or", parse_or},		/* nonstandard */
  {"ok", parse_ok},
  {"perm", parse_perm},
  {"permmask", parse_permmask},	/* nonstandard */
  {"print", parse_print},
  {"prune", parse_prune},
  {"regex", parse_regex},	/* nonstandard */
  {"size", parse_size},
  {"type", parse_type},
  {"user", parse_user},
  {"version", parse_version},
  {"xdev", parse_xdev},
  {0, 0}
};

/* Return a pointer to the parser function to invoke for predicate
   SEARCH_NAME.
   Return NULL if SEARCH_NAME is not a valid predicate name. */


#ifdef MSDOS
PARSE_FCT
#else
PFB
#endif
find_parser (search_name)
     char *search_name;
{
  int i;

  if (*search_name == '-')
    search_name++;
  for (i = 0; parse_table[i].parser_name != 0; i++)
    if (strcmp (parse_table[i].parser_name, search_name) == 0)
      return (parse_table[i].parser_func);
  return (NULL);
}

/* The parsers are responsible to continue scanning ARGV for
   their arguments.  Each parser knows what is and isn't
   allowed for itself.
   
   ARGV is the argument array.
   *ARG_PTR is the index to start at in ARGV,
   updated to point beyond the last element consumed.
 
   The predicate structure is updated with the new information. */

boolean
parse_atime (argv, arg_ptr)
     char *argv[];
     int *arg_ptr;
{
  return (insert_time (argv, arg_ptr, pred_atime));
}

boolean
parse_close (argv, arg_ptr)
     char *argv[];
     int *arg_ptr;
{
  struct pred_struct *our_pred;

  our_pred = get_new_pred ();
  our_pred->pred_func = pred_close;
#ifdef	DEBUG
  our_pred->p_name = find_pred_name (pred_close);
#endif	/* DEBUG */
  our_pred->p_type = CLOSE_PAREN;
  our_pred->p_prec = NO_PREC;
  return (true);
}

boolean
parse_ctime (argv, arg_ptr)
     char *argv[];
     int *arg_ptr;
{
  return (insert_time (argv, arg_ptr, pred_ctime));
}

boolean
parse_depth (argv, arg_ptr)
     char *argv[];
     int *arg_ptr;
{
  do_dir_first = false;
  return (true);
}

boolean
parse_exec (argv, arg_ptr)
     char *argv[];
     int *arg_ptr;
{
  return (insert_exec_ok (pred_exec, argv, arg_ptr));
}

boolean
parse_fulldays (argv, arg_ptr)
     char *argv[];
     int *arg_ptr;
{
  struct tm *local;

  if (full_days == false)
    {
      cur_day_start += DAYSECS;
      local = localtime (&cur_day_start);
      cur_day_start -= local->tm_sec + local->tm_min * 60
	+ local->tm_hour * 3600;
      full_days = true;
    }
  return (true);
}

boolean
parse_fstype (argv, arg_ptr)
     char *argv[];
     int *arg_ptr;
{
  struct pred_struct *our_pred;

  if ((argv == NULL) || (argv[*arg_ptr] == NULL))
    return (false);
  our_pred = insert_victim (pred_fstype);
  our_pred->args.str = argv[*arg_ptr];
  (*arg_ptr)++;
  read_mtab ();
  return (true);
}

boolean
parse_group (argv, arg_ptr)
     char *argv[];
     int *arg_ptr;
{
  struct group *cur_gr;
  struct pred_struct *our_pred;
  int gid, gid_len;

  if ((argv == NULL) || (argv[*arg_ptr] == NULL))
    return (false);
  cur_gr = getgrnam (argv[*arg_ptr]);
  endgrent ();
  if (cur_gr != NULL)
    gid = cur_gr->gr_gid;
  else
    {
      gid_len = strspn (argv[*arg_ptr], "0123456789");
      if ((gid_len == 0) || (argv[*arg_ptr][gid_len] != '\0'))
	return (false);
      gid = atoi (argv[*arg_ptr]);
    }
  our_pred = insert_victim (pred_group);
  our_pred->args.gid = (short) gid;
  (*arg_ptr)++;
  return (true);
}

boolean
parse_inum (argv, arg_ptr)
     char *argv[];
     int *arg_ptr;
{
  return (insert_num (argv, arg_ptr, pred_inum));
}

boolean
parse_links (argv, arg_ptr)
     char *argv[];
     int *arg_ptr;
{
  return (insert_num (argv, arg_ptr, pred_links));
}

boolean
parse_ls (argv, arg_ptr)
     char *argv[];
     int *arg_ptr;
{
  struct pred_struct *our_pred;

  our_pred = insert_victim (pred_ls);
  our_pred->side_effects = true;
  return (true);
}

boolean
parse_mtime (argv, arg_ptr)
     char *argv[];
     int *arg_ptr;
{
  return (insert_time (argv, arg_ptr, pred_mtime));
}

boolean
parse_name (argv, arg_ptr)
     char *argv[];
     int *arg_ptr;
{
  struct pred_struct *our_pred;

  if ((argv == NULL) || (argv[*arg_ptr] == NULL))
    return (false);
  our_pred = insert_victim (pred_name);
  our_pred->args.str = argv[*arg_ptr];
  (*arg_ptr)++;
  return (true);
}

boolean
parse_negate (argv, arg_ptr)
     char *argv[];
     int *arg_ptr;
{
  struct pred_struct *our_pred;

  our_pred = get_new_pred_chk_op ();
  our_pred->pred_func = pred_negate;
#ifdef	DEBUG
  our_pred->p_name = find_pred_name (pred_negate);
#endif	/* DEBUG */
  our_pred->p_type = UNI_OP;
  our_pred->p_prec = NEGATE_PREC;
  return (true);
}

boolean
parse_newer (argv, arg_ptr)
     char *argv[];
     int *arg_ptr;
{
  struct pred_struct *our_pred;
  struct stat stat_newer;

  if ((argv == NULL) || (argv[*arg_ptr] == NULL))
    return (false);
  if (lstat (argv[*arg_ptr], &stat_newer))
    error (1, errno, "%s", argv[*arg_ptr]);
  our_pred = insert_victim (pred_newer);
  our_pred->args.time = stat_newer.st_mtime;
  (*arg_ptr)++;
  return (true);
}

boolean
parse_nogroup (argv, arg_ptr)
     char *argv[];
     int *arg_ptr;
{
  struct pred_struct *our_pred;

  our_pred = insert_victim (pred_nogroup);
  return (true);
}

boolean
parse_nouser (argv, arg_ptr)
     char *argv[];
     int *arg_ptr;
{
  struct pred_struct *our_pred;

  our_pred = insert_victim (pred_nouser);
  return (true);
}

boolean
parse_ok (argv, arg_ptr)
     char *argv[];
     int *arg_ptr;
{
  boolean insert_exec_ok ();

  return (insert_exec_ok (pred_ok, argv, arg_ptr));
}

boolean
parse_open (argv, arg_ptr)
     char *argv[];
     int *arg_ptr;
{
  struct pred_struct *our_pred;

  our_pred = get_new_pred_chk_op ();
  our_pred->pred_func = pred_open;
#ifdef	DEBUG
  our_pred->p_name = find_pred_name (pred_open);
#endif	/* DEBUG */
  our_pred->p_type = OPEN_PAREN;
  our_pred->p_prec = NO_PREC;
  return (true);
}

boolean
parse_or (argv, arg_ptr)
     char *argv[];
     int *arg_ptr;
{
  struct pred_struct *our_pred;

  our_pred = get_new_pred ();
  our_pred->pred_func = pred_or;
#ifdef	DEBUG
  our_pred->p_name = find_pred_name (pred_or);
#endif	/* DEBUG */
  our_pred->p_type = BI_OP;
  our_pred->p_prec = OR_PREC;
  return (true);
}

boolean
parse_perm (argv, arg_ptr)
     char *argv[];
     int *arg_ptr;
{
  unsigned long perm_val;
  int mode_start = 0;
  struct mode_change *change;
  struct pred_struct *our_pred;

  if ((argv == NULL) || (argv[*arg_ptr] == NULL))
    return (false);
  if (argv[*arg_ptr][0] == '-')
    mode_start = 1;
  
  change = mode_compile (argv[*arg_ptr] + mode_start, MODE_MASK_PLUS);
  if (change == MODE_INVALID)
    error (1, 0, "invalid mode `%s'", argv[*arg_ptr]);
  else if (change == MODE_MEMORY_EXHAUSTED)
    error (1, 0, "virtual memory exhausted");
  perm_val = mode_adjust (0, change);
  mode_free (change);

  our_pred = insert_victim (pred_perm);
  if (mode_start)
    /* Set magic flag to compare suid, sgid, sticky bits as well;
       also, true if at least the given bits are set. */
    our_pred->args.perm = (perm_val & 07777) | 010000;
  else
    our_pred->args.perm = perm_val & 0777;
  (*arg_ptr)++;
  return (true);
}

boolean
parse_permmask (argv, arg_ptr)
     char *argv[];
     int *arg_ptr;
{
  unsigned long mask_val;
  struct mode_change *change;
  struct pred_struct *our_pred;

  if ((argv == NULL) || (argv[*arg_ptr] == NULL))
    return (false);

  change = mode_compile (argv[*arg_ptr], MODE_MASK_PLUS);
  if (change == MODE_INVALID)
    error (1, 0, "invalid mode mask `%s'", argv[*arg_ptr]);
  else if (change == MODE_MEMORY_EXHAUSTED)
    error (1, 0, "virtual memory exhausted");
  mask_val = mode_adjust (0, change);
  mode_free (change);

  our_pred = insert_victim (pred_permmask);
  our_pred->args.perm = mask_val;
  (*arg_ptr)++;
  return (true);
}

boolean
parse_print (argv, arg_ptr)
     char *argv[];
     int *arg_ptr;
{
  struct pred_struct *our_pred;

  our_pred = insert_victim (pred_print);
  /* -print has the side effect of printing.  This prevents us
     from doing undesired multiple printing when the user has
     already specified -print. */
  our_pred->side_effects = true;
  return (true);
}

boolean
parse_prune (argv, arg_ptr)
     char *argv[];
     int *arg_ptr;
{
  struct pred_struct *our_pred;

  our_pred = insert_victim (pred_prune);
  return (true);
}

boolean
parse_regex (argv, arg_ptr)
     char *argv[];
     int *arg_ptr;
{
  struct pred_struct *our_pred;
  struct re_pattern_buffer *re;
  char *error_message;

  if ((argv == NULL) || (argv[*arg_ptr] == NULL))
    return (false);
  our_pred = insert_victim (pred_regex);
  re = (struct re_pattern_buffer *)
    xmalloc (sizeof (struct re_pattern_buffer));
  our_pred->args.regex = re;
  re->allocated = 100;
#ifdef MSDOS
  re->buffer = xmalloc ((size_t) re->allocated);
#else /* not MSDOS */
  re->buffer = xmalloc (re->allocated);
#endif /* not MSDOS */
  re->fastmap = NULL;
  re->translate = NULL;
  error_message = re_compile_pattern (argv[*arg_ptr], strlen (argv[*arg_ptr]),
				      re);
  if (error_message)
    error (1, 0, "%s", error_message);
  (*arg_ptr)++;
  return (true);
}

boolean
parse_size (argv, arg_ptr)
     char *argv[];
     int *arg_ptr;
{
  struct pred_struct *our_pred;
  unsigned long num;
  short c_type;
  boolean blk;
  int len;

  if ((argv == NULL) || (argv[*arg_ptr] == NULL))
    return (false);
  len = strlen (argv[*arg_ptr]);
  if (len == 0)
    error (1, 0, "invalid null argument to -size");
  switch (argv[*arg_ptr][len - 1])
    {
    case 'c':
      blk = false;
      argv[*arg_ptr][len - 1] = '\0';
      break;

    case '0':
    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
    case '6':
    case '7':
    case '8':
    case '9':
      blk = true;
      break;

    default:
      error (1, 0, "invalid -size type `%c'", argv[*arg_ptr][len - 1]);
    }
  if (!get_num (argv[*arg_ptr], &num, &c_type))
    return (false);
  our_pred = insert_victim (pred_size);
  our_pred->args.size.kind = c_type;
  our_pred->args.size.block = blk;
  our_pred->args.size.size = num;
  (*arg_ptr)++;
  return (true);
}

boolean
parse_type (argv, arg_ptr)
     char *argv[];
     int *arg_ptr;
{
  unsigned long type_cell;
  struct pred_struct *our_pred;

  if ((argv == NULL) || (argv[*arg_ptr] == NULL)
      || (strlen (argv[*arg_ptr]) != 1))
    return (false);
  switch (argv[*arg_ptr][0])
    {
#ifdef S_IFBLK
    case 'b':			/* block special */
      type_cell = S_IFBLK;
      break;
#endif
    case 'c':			/* character special */
      type_cell = S_IFCHR;
      break;
    case 'd':			/* directory */
      type_cell = S_IFDIR;
      break;
    case 'f':			/* regular file */
      type_cell = S_IFREG;
      break;
#ifdef S_IFLNK
    case 'l':			/* symbolic link */
      type_cell = S_IFLNK;
      break;
#endif
#ifdef S_IFIFO
    case 'p':			/* pipe */
      type_cell = S_IFIFO;
      break;
#endif
#ifdef S_IFSOCK
    case 's':			/* socket */
      type_cell = S_IFSOCK;
      break;
#endif
    default:			/* none of the above ... nuke em */
      return (false);
    }
  our_pred = insert_victim (pred_type);
  our_pred->args.type = type_cell;
  (*arg_ptr)++;			/* move on to next argument */
  return (true);
}

boolean
parse_user (argv, arg_ptr)
     char *argv[];
     int *arg_ptr;
{
  struct passwd *cur_pwd;
  struct pred_struct *our_pred;
  int uid, uid_len;

  if ((argv == NULL) || (argv[*arg_ptr] == NULL))
    return (false);
  cur_pwd = getpwnam (argv[*arg_ptr]);
  endpwent ();
  if (cur_pwd != NULL)
    uid = cur_pwd->pw_uid;
  else
    {
      uid_len = strspn (argv[*arg_ptr], "0123456789");
      if ((uid_len == 0) || (argv[*arg_ptr][uid_len] != '\0'))
	return (false);
      uid = atoi (argv[*arg_ptr]);
    }
  our_pred = insert_victim (pred_user);
  our_pred->args.uid = (short) uid;
  (*arg_ptr)++;
  return (true);
}

boolean
parse_version (argv, arg_ptr)
     char *argv[];
     int *arg_ptr;
{
  extern char *version_string;

  fprintf (stderr, "%s", version_string);
  return true;
}

boolean
parse_xdev (argv, arg_ptr)
     char *argv[];
     int *arg_ptr;
{
  stay_on_filesystem = true;
  return true;
}

boolean
insert_exec_ok (func, argv, arg_ptr)
     boolean (*func) ();
     char *argv[];
     int *arg_ptr;
{
  int start, end;		/* Indexes in ARGV of start & end of cmd. */
  int num_paths;		/* Number of "{}" insertions to do. */
  int path_pos;			/* Index in array of "{}" insertions. */
  int vec_pos;			/* Index in array of arg words. */
  struct pred_struct *our_pred;

  if ((argv == NULL) || (argv[*arg_ptr] == NULL))
    return (false);
  start = *arg_ptr;
  for (end = start, num_paths = 0;
       (argv[end] != NULL)
       && ((argv[end][0] != ';') || (argv[end][1] != '\0'));
       end++)
    if (strcmp (argv[end], "{}") == 0)
      num_paths++;
  /* Fail if no command given or no semicolon found. */
  if ((end == start) || (argv[end] == NULL))
    {
      *arg_ptr = end;
      return (false);
    }
  our_pred = insert_victim (func);
  our_pred->side_effects = true;
  our_pred->args.exec_vec.path_loc =
    (short *) xmalloc (sizeof (short) * (num_paths + 1));
  our_pred->args.exec_vec.vec =
    (char **) xmalloc (sizeof (char *) * (end - start + 1));
  for (end = start, path_pos = vec_pos = 0;
       (argv[end] != NULL)
       && ((argv[end][0] != ';') || (argv[end][1] != '\0'));
       end++)
    {
      if (strcmp (argv[end], "{}") == 0)
	our_pred->args.exec_vec.path_loc[path_pos++] = vec_pos;
      our_pred->args.exec_vec.vec[vec_pos++] = argv[end];
    }
  our_pred->args.exec_vec.path_loc[path_pos] = -1;
  our_pred->args.exec_vec.vec[vec_pos] = NULL;
  if (argv[end] == NULL)
    *arg_ptr = end;
  else
    *arg_ptr = end + 1;
  return (true);
}

/* Get a number of days and comparison type.
   STR is the ASCII representation.
   Set *NUM_DAYS to the number of days, taken as being from
   the current moment (or possibly midnight).  Thus the sense of the
   comparison type appears to be reversed.
   Set *COMP_TYPE to the kind of comparison that is requested.

   Return true if all okay, false if input error.

   Used by -atime, -ctime and -mtime (parsers) to
   get the appropriate information for a time predicate processor. */

boolean
get_num_days (str, num_days, comp_type)
     char *str;
     unsigned long *num_days;
     enum comparison_type *comp_type;
{
  int len_days;			/* length of field */

  if (str == NULL)
    return (false);
  switch (str[0])
    {
    case '+':
      *comp_type = COMP_LT;
      str++;
      break;
    case '-':
      *comp_type = COMP_GT;
      str++;
      break;
    case '0':
    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
    case '6':
    case '7':
    case '8':
    case '9':
      *comp_type = COMP_EQ;
      break;
    default:
      return (false);
    }

  /* We know the first char has been reasonable.  Find the
     number of days to play with. */
  len_days = strspn (str, "0123456789");
  if ((len_days == 0) || (str[len_days] != '\0'))
    return (false);
  *num_days = (unsigned long) atol (str);
  return (true);
}

/* Insert a time predicate PRED.
   ARGV is a pointer to the argument array.
   ARG_PTR is a pointer to an index into the array, incremented if
   all went well.

   Return true if input is valid, false if not.

   A new predicate node is assigned, along with an argument node
   obtained with malloc.

   Used by -atime, -ctime, and -mtime parsers. */

boolean
insert_time (argv, arg_ptr, pred)
     char *argv[];
     int *arg_ptr;
#ifdef MSDOS
     PRED_FCT pred;
#else
     PFB pred;
#endif
{
  struct pred_struct *our_pred;
  unsigned long num_days;
  enum comparison_type c_type;

  if ((argv == NULL) || (argv[*arg_ptr] == NULL))
    return (false);
  if (!get_num_days (argv[*arg_ptr], &num_days, &c_type))
    return (false);
  our_pred = insert_victim (pred);
  our_pred->args.info.kind = c_type;
  our_pred->args.info.l_val = cur_day_start - num_days * DAYSECS
    + ((c_type == COMP_GT) ? DAYSECS - 1 : 0);
  (*arg_ptr)++;
#ifdef	DEBUG
  printf ("inserting %s\n", our_pred->p_name);
  printf ("    type: %s    %s  ",
	  (c_type == COMP_GT) ? "gt" :
	  ((c_type == COMP_LT) ? "lt" : ((c_type == COMP_EQ) ? "eq" : "?")),
	  (c_type == COMP_GT) ? " >" :
	  ((c_type == COMP_LT) ? " <" : ((c_type == COMP_EQ) ? ">=" : " ?")));
  printf ("%ld %s", our_pred->args.info.l_val,
	  ctime (&our_pred->args.info.l_val));
  if (c_type == COMP_EQ)
    {
      our_pred->args.info.l_val += DAYSECS;
      printf ("                 <  %ld %s", our_pred->args.info.l_val,
	      ctime (&our_pred->args.info.l_val));
      our_pred->args.info.l_val -= DAYSECS;
    }
#endif	/* DEBUG */
  return (true);
}

/* Get a number with comparision information.
   The sense of the comparision information is 'normal'; that is,
   '+' looks for inums or links > than the number and '-' less than.
   
   STR is the ASCII representation of the number.
   Set *NUM to the number.
   Set *COMP_TYPE to the kind of comparison that is requested.
 
   Return true if all okay, false if input error.

   Used by the -inum and -links predicate parsers. */

boolean
get_num (str, num, comp_type)
     char *str;
     unsigned long *num;
     short *comp_type;
{
  int len_num;			/* length of field */

  if (str == NULL)
    return (false);
  switch (str[0])
    {
    case '+':
      *comp_type = COMP_GT;
      str++;
      break;
    case '-':
      *comp_type = COMP_LT;
      str++;
      break;
    case '0':
    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
    case '6':
    case '7':
    case '8':
    case '9':
      *comp_type = COMP_EQ;
      break;
    default:
      return (false);
    }

  /* We know the first char has been reasonable.  Find the number of
     days to play with. */
  len_num = strspn (str, "0123456789");
  if ((len_num == 0) || (str[len_num] != '\0'))
    return (false);
  *num = (unsigned long) atol (str);
  return (true);
}

/* Insert a number predicate.
   ARGV is a pointer to the argument array.
   *ARG_PTR is an index into ARGV, incremented if all went well.
   *PRED is the predicate processor to insert.

   Return true if input is valid, false if error.
   
   A new predicate node is assigned, along with an argument node
   obtained with malloc.

   Used by -inum and -links parsers. */

boolean
insert_num (argv, arg_ptr, pred)
     char *argv[];
     int *arg_ptr;
#ifdef MSDOS
     PRED_FCT pred;
#else
     PFB pred;
#endif
{
  struct pred_struct *our_pred;
  unsigned long num;
  short c_type;

  if ((argv == NULL) || (argv[*arg_ptr] == NULL))
    return (false);
  if (!get_num (argv[*arg_ptr], &num, &c_type))
    return (false);
  our_pred = insert_victim (pred);
  our_pred->args.info.kind = c_type;
  our_pred->args.info.l_val = num;
  (*arg_ptr)++;
#ifdef	DEBUG
  printf ("inserting %s\n", our_pred->p_name);
  printf ("    type: %s    %s  ",
	  (c_type == COMP_GT) ? "gt" :
	  ((c_type == COMP_LT) ? "lt" : ((c_type == COMP_EQ) ? "eq" : "?")),
	  (c_type == COMP_GT) ? " >" :
	  ((c_type == COMP_LT) ? " <" : ((c_type == COMP_EQ) ? " =" : " ?")));
  printf ("%ld\n", our_pred->args.info.l_val);
#endif	/* DEBUG */
  return (true);
}

#ifdef STRSPN_MISSING
int
strspn (str, class)
     char *str, *class;
{
  register char *cl = class;
  register char *st = str;

  while (index (class, *st))
    ++st;
  return st - str;
}
#endif
