/* Copyright (C) 1988, 1989 Free Software Foundation, Inc.
This file is part of GNU Make.

GNU Make is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 1, or (at your option)
any later version.

GNU Make is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with GNU Make; see the file COPYING.  If not, write to
the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.  */

/*
 * MS-DOS port (c) 1990 by Thorsten Ohl <ohl@gnu.ai.mit.edu>
 *
 * To this port, the same copying conditions apply as to the
 * original release.
 *
 * IMPORTANT:
 * This file is not identical to the original GNU release!
 * You should have received this code as patch to the official
 * GNU release.
 *
 * MORE IMPORTANT:
 * This port comes with ABSOLUTELY NO WARRANTY.
 *
 * $Header: e:/gnu/make/RCS/make.h'v 3.58.0.3 90/08/27 01:25:24 tho Exp $
 */

#include <signal.h>
#include <stdio.h>

#ifndef	sun
#include <sys/types.h>
#endif


#ifndef MSDOS
#include <sys/param.h>
#endif /* not MSDOS */
#ifndef MAXPATHLEN
#define MAXPATHLEN 1024
#endif	/* No MAXPATHLEN.  */

#include <sys/stat.h>

#ifdef	USG
#include <string.h>
#define	index(s, c)	strchr((s), (c))
#define	rindex(s, c)	strrchr((s), (c))

#include <memory.h>
#define bcmp(s1, s2, n)	memcmp ((s1), (s2), (n))
#define bzero(s, n)	memset ((s), 0, (n))
#define bcopy(s, d, n)	memcpy ((d), (s), (n))

#else	/* Not USG.  */
#include <strings.h>

extern int bcmp ();
extern void bzero (), bcopy ();

#endif	/* USG.  */

#ifdef	__GNUC__
#define	alloca(n)	__builtin_alloca (n)
#else	/* Not GCC.  */
#ifdef	sparc
#include <alloca.h>
#else	/* Not sparc.  */
#ifdef MSDOS
#include <malloc.h>
#else /* not MSDOS */
extern char *alloca ();
#endif /* not MSDOS  */
#endif	/* sparc.  */
#endif	/* GCC.  */

#ifndef	iAPX286
#define streq(a, b) \
  ((a) == (b) || \
   (*(a) == *(b) && (*(a) == '\0' || !strcmp ((a) + 1, (b) + 1))))
#else
/* Buggy compiler can't handle this.  */
#define streq(a, b) (strcmp ((a), (b)) == 0)
#endif

/* Add to VAR the hashing value of C, one character in a name.  */
#define	HASH(var, c) \
  ((var += (c)), (var = ((var) << 7) + ((var) >> 20)))

#if defined(__GNUC__) || defined(ENUM_BITFIELDS)
#define	ENUM_BITFIELD(bits)	:bits
#else
#define	ENUM_BITFIELD(bits)
#endif

#ifdef MSDOS
extern  void die (int status);
#else /* not MSDOS */
extern void die ();
#endif /* not MSDOS */

/*     misc.c */
#ifdef MSDOS
extern  char *concat (char *s1, char *s2, char *s3);
extern  char *end_of_token (char *s);
extern  char *find_next_token (char **ptr, unsigned int *lengthptr);
extern  char *lindex (char *s, char *limit, int c);
extern  char *next_token (char *s);
extern  char *savestring (char *str, unsigned int length);
extern  char *sindex (char *big, unsigned int blen, char *small,
		      unsigned int slen);
extern  char *xmalloc (unsigned int size);
extern  char *xrealloc (char *ptr, unsigned int size);
extern  int alpha_compare (char **s1, char **s2);
extern  struct dep *copy_dep_chain (struct dep *d);
extern  void collapse_continuations (char *line);
extern  void collapse_line (char *line);
extern  void error (char *s1, ...);
extern  void fatal (char *s1, ...);
extern  void perror_with_name (char *str, char *name);
extern  void pfatal_with_name (char *name);
extern  void print_spaces (unsigned int n);
#else /* not MSDOS */
extern void fatal (), error ();
extern void pfatal_with_name (), perror_with_name ();
extern char *savestring (), *concat ();
extern char *xmalloc (), *xrealloc ();
extern char *find_next_token (), *next_token (), *end_of_token ();
extern void collapse_continuations (), collapse_line ();
extern char *sindex (), *lindex ();
extern int alpha_compare ();
extern void print_spaces ();
extern struct dep *copy_dep_chain ();
extern char *find_percent ();
#endif /* not MSDOS */

/* ar.c */
#ifndef	NO_ARCHIVES
#ifdef MSDOS
extern  int ar_name (char *name);
extern  int ar_touch (char *name);
extern  long ar_member_date (char *name);
#else /* not MSDOS */
extern int ar_name ();
extern int ar_touch ();
extern time_t ar_member_date ();
#endif /* not MSDOS */
#endif

/* dir.c */
#ifdef MSDOS
extern  char *dir_name (char *dir);
extern  int dir_file_exists_p (char *dirname, char *filename);
extern  int file_exists_p (char *name);
extern  int file_impossible_p (char *filename);
extern  void file_impossible (char *filename);
extern  void print_dir_data_base (void);
#else /* not MSDOS */
extern void dir_load ();
extern int dir_file_exists_p (), file_exists_p (), file_impossible_p ();
extern void file_impossible ();
extern char *dir_name ();
#endif /* not MSDOS */

/* default.c */
#ifdef MSDOS
extern  void install_default_implicit_rules (void);
extern  void set_default_suffixes (void);
#else /* not MSDOS */
extern void set_default_suffixes (), install_default_implicit_rules ();
#endif /* not MSDOS */

/* rule.c */
#ifdef MSDOS
extern  void convert_to_pattern (void);
extern  void count_implicit_rule_limits (void);
extern  void create_pattern_rule (char **targets, char **target_percents,
				  int terminal, struct dep *deps,
				  struct commands *commands, int override);
extern  void print_rule_data_base (void);
#else /* not MSDOS */
extern void convert_to_pattern (), count_implicit_rule_limits ();
extern void create_pattern_rule ();
#endif /* not MSDOS */

/*    vpath.c */
#ifdef MSDOS
extern  int vpath_search (char **file);
extern  void build_vpath_lists (void);
extern  void construct_vpath_list (char *pattern, char *dirpath);
extern  void print_vpath_data_base (void);
#else /* not MSDOS */
extern void build_vpath_lists (), construct_vpath_list ();
extern int vpath_search ();
#endif /* not MSDOS */
  
/*     read.c */
#ifdef MSDOS
extern  char *find_percent (char *pattern);
extern  struct dep *read_all_makefiles (char **makefiles);
extern  void uniquize_deps (struct dep *chain);
extern  void construct_include_path (char **arg_dirs);
#else /* not MSDOS */
extern void construct_include_path ();
#endif /* not MSDOS */

/*   remake.c */
#ifdef MSDOS
extern  int update_goal_chain (struct dep *goals, int makefiles);
extern  void notice_finished_file (struct file *file);
extern  time_t f_mtime (struct file *file, int search);
extern  int remote_kill (int id, int sig);
extern  int remote_status (int *exit_code_ptr, int *signal_ptr,
			   int *coredump_ptr, int block);
extern  int start_remote_job (char **argv, int stdin_fd, int *is_remote,
			      int *id_ptr, int *used_stdin);
extern  int start_remote_job_p (void);
extern  void block_remote_children (void);
extern  void unblock_remote_children (void);
#else /* not MSDOS */
extern int update_goal_chain ();
extern void notice_finished_file ();
#endif /* not MSDOS */

/* glob.c */
#ifdef MSDOS
extern  char **glob_filename (char *pathname);
extern  char **glob_vector (char *pat, char *dir);
extern  int glob_match (char *pattern, char *text, int dot_special);
extern  int glob_pattern_p (char *pattern);
#else /* not MSDOS */
extern int glob_pattern_p ();
extern char **glob_filename ();
#endif /* not MSDOS */

#ifdef MSDOS
#include <stdlib.h>
#else /* not MSDOS */
#ifndef	USG
extern int sigsetmask ();
#endif
extern int kill (), sigblock ();
extern void free ();
extern void abort (), exit ();
extern int unlink (), stat ();
extern void qsort ();
extern int atoi ();
extern int pipe (), close (), open (), lseek (), read ();
extern char *ctime ();
#endif /* not MSDOS */

#ifdef MSDOS
extern  char **construct_command_argv (char *line, struct file *file);
extern  void wait_for_children (unsigned int n, int err);
extern  void wait_to_start_job (void);
extern  void init_siglist (void);
extern  void print_file_variables (struct file *file);
extern  int try_implicit_rule (struct file *file, unsigned int depth);
#endif /* MSDOS */

#ifndef MSDOS			/* <stdlib.h> */
extern char **environ;
#endif /* not MSDOS */

#ifdef	USG
extern char *getcwd ();
#ifdef MSDOS
extern char *msdos_format_filename (char *name);
#define	getwd(buf)	msdos_format_filename (getcwd (buf, MAXPATHLEN - 2))
#else /* not MSDOS */
#define	getwd(buf)	getcwd (buf, MAXPATHLEN - 2)
#endif /* not MSDOS */
#else	/* Not USG.  */
extern char *getwd ();
#endif	/* USG.  */


extern char *reading_filename;
extern unsigned int *reading_lineno_ptr;

extern int just_print_flag, silent_flag, ignore_errors_flag, keep_going_flag;
extern int debug_flag, print_data_base_flag, question_flag, touch_flag;
extern int env_overrides, no_builtin_rules_flag, print_version_flag;
extern int print_directory_flag;

extern unsigned int job_slots;
extern double max_load_average;

extern char *program;

extern unsigned int makelevel;


#define DEBUGPR(msg)							\
  if (debug_flag) { print_spaces (depth); printf (msg, file->name);	\
		    fflush (stdout);  } else
