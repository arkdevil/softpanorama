/* `dir', `vdir' and `ls' directory listing programs for GNU.
   Copyright (C) 1985, 1988, 1989, 1990 Free Software Foundation, Inc.

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
   code as patch to the official release.  */

#ifdef MSDOS
static char RCS_Id[] =
  "$Header: e:/gnu/fileutil/RCS/ls.c 1.4.0.2 90/09/19 11:18:27 tho Exp $";

static char RCS_Revision[] = "$Revision: 1.4.0.2 $";

#define VERSION \
  "GNU %s, Version %.*s (compiled %s %s for MS-DOS)\n", PROGNAME, \
  (sizeof RCS_Revision - 14), (RCS_Revision + 11), __DATE__, __TIME__

#define COPYING \
  "This is free software, distributed under the terms of the\n" \
  "GNU General Public License.  For details, see the file COPYING.\n"
#endif /* MSDOS */

/* If the macro MULTI_COL is defined,
   the multi-column format is the default regardless
   of the type of output device.
   This is for the `dir' program.

   If the macro LONG_FORMAT is defined,
   the long format is the default regardless of the
   type of output device.
   This is for the `vdir' program.

   If neither is defined,
   the output format depends on whether the output
   device is a terminal.
   This is for the `ls' program. */

/* Written by Richard Stallman and David MacKenzie. */

#include <sys/types.h>
#ifdef _POSIX_SOURCE
#define S_IEXEC S_IXUSR
#else
#ifndef MSDOS
#include <sys/ioctl.h>
#endif /* not MSDOS */
#endif
#include <stdio.h>
#ifndef MSDOS
#include <grp.h>
#endif
#include <pwd.h>
#include <getopt.h>
#include "system.h"

/* Return an int indicating the result of comparing two longs. */
#ifdef INT_16_BITS
#define longdiff(a, b) ((a) < (b) ? -1 : (a) > (b) ? 1 : 0)
#else
#define longdiff(a, b) ((a) - (b))
#endif

#ifdef STDC_HEADERS
#include <errno.h>
#include <stdlib.h>
#include <time.h>
#else
char *ctime ();
char *getenv ();
char *malloc ();
char *realloc ();
long time ();

extern int errno;
#endif

#ifdef MSDOS
#include <string.h>
#include <io.h>

#include <gnulib.h>

extern  int glob_match (char *, char *, int);
extern  void mode_string (unsigned short mode, char *str);
extern  void main (int, char **);
extern  int argmatch (char *, char **);
extern  int decode_switches (int, char **);
extern  void invalid_arg (char *, char *, int);
extern  void queue_directory (char *, char *);
extern  void print_dir (char *, char *);
extern  void add_ignore_pattern (char *);
extern  int file_interesting (struct direct *);
extern  void clear_files (void);
extern  int gobble_file (char *, int, char *);
extern  void extract_dirs_from_files (char *, int);
extern  int is_not_dot_or_dotdot (char *);
extern  void sort_files (void);
extern  int compare_ctime (struct file *, struct file *);
extern  int rev_cmp_ctime (struct file *, struct file *);
extern  int compare_mtime (struct file *, struct file *);
extern  int rev_cmp_mtime (struct file *, struct file *);
extern  int compare_atime (struct file *, struct file *);
extern  int rev_cmp_atime (struct file *, struct file *);
extern  int compare_size (struct file *, struct file *);
extern  int rev_cmp_size (struct file *, struct file *);
extern  int compare_name (struct file *, struct file *);
extern  int rev_cmp_name (struct file *, struct file *);
extern  int compare_extension (struct file *file1, struct file *file2);
extern  int rev_cmp_extension (struct file *file1, struct file *file2);
extern  void print_current_files (void);
extern  void print_long_format (struct file *);
extern  void print_name_with_quoting (char *);
extern  void print_file_name_and_frills (struct file *);
extern  void print_type_indicator (unsigned int);
extern  int length_of_file_name_and_frills (struct file *);
extern  void print_many_per_line (void);
extern  void print_horizontal (void);
extern  void print_with_commas (void);
extern  char *getuser (unsigned short);
extern  char *getgroup (unsigned short);
extern  void indent (int, int);
extern  char *copystring (char *);
extern  void attach (char *, char *, char *);
extern  char *basename (char *);
extern  void usage (void);

#else /* not MSDOS */

struct group *getgrgid ();
struct passwd *getpwuid ();
int glob_match ();
void mode_string ();

char *copystring ();
char *getgroup ();
char *getuser ();
char *make_link_path ();
char *xmalloc ();
char *xrealloc ();
int argmatch ();
int compare_atime ();
int rev_cmp_atime ();
int compare_ctime ();
int rev_cmp_ctime ();
int compare_mtime ();
int rev_cmp_mtime ();
int compare_size ();
int rev_cmp_size ();
int compare_name ();
int rev_cmp_name ();
int compare_extension ();
int rev_cmp_extension ();
int decode_switches ();
int file_interesting ();
int gobble_file ();
int is_not_dot_or_dotdot ();
int length_of_file_name_and_frills ();
void add_ignore_pattern ();
void attach ();
void clear_files ();
void error ();
void extract_dirs_from_files ();
void get_link_name ();
void indent ();
void invalid_arg ();
void print_current_files ();
void print_dir ();
void print_file_name_and_frills ();
void print_horizontal ();
void print_long_format ();
void print_many_per_line ();
void print_name_with_quoting ();
void print_type_indicator ();
void print_with_commas ();
void queue_directory ();
void sort_files ();
void usage ();

#endif /* not MSDOS */

enum filetype
{
  symbolic_link,
  directory,
  arg_directory,		/* Directory given as command line arg. */
  normal			/* All others. */
};

struct file
{
  /* The file name. */
  char *name;

  struct stat stat;

  /* For symbolic link, name of the file linked to, otherwise zero. */
  char *linkname;

  /* For symbolic link and long listing, st_mode of file linked to, otherwise
     zero. */
  unsigned int linkmode;

  enum filetype filetype;
};

/* The table of files in the current directory:

   `files' points to a vector of `struct file', one per file.
   `nfiles' is the number of elements space has been allocated for.
   `files_index' is the number actually in use.  */

/* Address of block containing the files that are described.  */

struct file *files;

/* Length of block that `files' points to, measured in files.  */

int nfiles;

/* Index of first unused in `files'.  */

int files_index;

/* Record of one pending directory waiting to be listed.  */

struct pending
{
  char *name;
  /* If the directory is actually the file pointed to by a symbolic link we
     were told to list, `realname' will contain the name of the symbolic
     link, otherwise zero. */
  char *realname;
  struct pending *next;
};

struct pending *pending_dirs;

/* Current time (seconds since 1970).  When we are printing a file's time,
   include the year if it is more than 6 months before this time.  */

long current_time;

/* The number of digits to use for block sizes.
   4, or more if needed for bigger numbers.  */

int block_size_size;

/* The name the program was run with, stripped of any leading path. */
char *program_name;

/* Option flags */

/* long_format for lots of info, one per line.
   one_per_line for just names, one per line.
   many_per_line for just names, many per line, sorted vertically.
   horizontal for just names, many per line, sorted horizontally.
   with_commas for just names, many per line, separated by commas.

   -l, -1, -C, -x and -m control this parameter.  */

enum format
{
  long_format,			/* -l */
  one_per_line,			/* -1 */
  many_per_line,		/* -C */
  horizontal,			/* -x */
  with_commas			/* -m */
};

enum format format;

/* Type of time to print or sort by.  Controlled by -c and -u.  */

enum time_type
{
  time_mtime,			/* default */
  time_ctime,			/* -c */
  time_atime			/* -u */
};

enum time_type time_type;

/* The file characteristic to sort by.  Controlled by -t, -S, -U, -X. */

enum sort_type
{
  sort_none,			/* -U */
  sort_name,			/* default */
  sort_extension,		/* -X */
  sort_time,			/* -t */
  sort_size			/* -S */
};

enum sort_type sort_type;

/* Direction of sort.
   0 means highest first if numeric,
   lowest first if alphabetic;
   these are the defaults.
   1 means the opposite order in each case.  -r  */

int sort_reverse;

/* Nonzero means print the user and group id's as numbers rather
   than as names.  -n  */

int numeric_users;

/* Nonzero means mention the size in 512 byte blocks of each file.  -s  */

int print_block_size;

/* Nonzero means show file sizes in kilobytes instead of blocks
   (the size of which is system-dependant).  -k */

int kilobyte_blocks;

/* none means don't mention the type of files.
   all means mention the types of all files.
   not_programs means do so except for executables.

   Controlled by -F and -p.  */

enum indicator_style
{
  none,				/* default */
  all,				/* -F */
  not_programs			/* -p */
};

enum indicator_style indicator_style;

/* Nonzero means mention the inode number of each file.  -i  */

int print_inode;

/* Nonzero means when a symbolic link is found, display info on
   the file linked to.  -L  */

int trace_links;

/* Nonzero means when a directory is found, display info on its
   contents.  -R  */

int trace_dirs;

/* Nonzero means when an argument is a directory name, display info
   on it itself.  -d  */

int immediate_dirs;

/* Nonzero means don't omit files whose names start with `.'.  -A */

int all_files;

/* Nonzero means don't omit files `.' and `..'
   This flag implies `all_files'.  -a  */

int really_all_files;

/* A linked list of shell-style globbing patterns.  If a non-argument
   file name matches any of these patterns, it is omitted.
   Controlled by -I.  Multiple -I options accumulate.
   The -B option adds `*~' and `.*~' to this list.  */

struct ignore_pattern
{
  char *pattern;
  struct ignore_pattern *next;
};

struct ignore_pattern *ignore_patterns;

/* Nonzero means quote nongraphic chars in file names.  -b  */

int quote_funny_chars;

/* Nonzero means output nongraphic chars in file names as `?'.  -q  */

int qmark_funny_chars;

/* Nonzero means output each file name using C syntax for a string.
   Always accompanied by `quote_funny_chars'.
   This mode, together with -x or -C or -m,
   and without such frills as -F or -s,
   is guaranteed to make it possible for a program receiving
   the output to tell exactly what file names are present.  -Q  */

int quote_as_string;

/* The number of chars per hardware tab stop.  -T */
int tabsize;

/* Nonzero means we are listing the working directory because no
   non-option arguments were given. */

int dir_defaulted;

/* Nonzero means print each directory name before listing it. */

int print_dir_name;

/* The line length to use for breaking lines in many-per-line format.
   Can be set with -w.  */

int line_length;

/* If nonzero, the file listing format requires that stat be called on
   each file. */

int format_needs_stat;

void
main (argc, argv)
     int argc;
     char **argv;
{
  register int i;
  register struct pending *thispend;

  dir_defaulted = 1;
  print_dir_name = 1;
  pending_dirs = 0;
  current_time = time ((long *) 0);

  program_name = argv[0];
  i = decode_switches (argc, argv);

  format_needs_stat = sort_type == sort_time || sort_type == sort_size
    || format == long_format
    || trace_links || trace_dirs || indicator_style != none
    || print_block_size || print_inode;

  nfiles = 100;
  files = (struct file *) xmalloc (sizeof (struct file) * nfiles);
  files_index = 0;

  clear_files ();

  if (i < argc)
    dir_defaulted = 0;

#ifdef MSDOS
  for (; i < argc; i++)
    {
      if (strlen (argv[i]) == 2 && argv[i][1] == ':')
	{
	  /* The user wants the cwd on another drive.  Help
	     DOS by appending a `.'!  (This allows to stat()
	     the directory.)  */
	  char *temp = (char *) xmalloc (4);
	  strcpy (temp, argv[i]);
	  strcat (temp, ".");
	  argv[i] = temp;
	}

      gobble_file (argv[i], 1, "");
    }
#else /* not MSDOS */
  for (; i < argc; i++)
    gobble_file (argv[i], 1, "");
#endif /* not MSDOS */

  if (dir_defaulted)
    {
      if (immediate_dirs)
	gobble_file (".", 1, "");
      else
	queue_directory (".", 0);
    }

  if (files_index)
    {
      sort_files ();
      if (!immediate_dirs)
	extract_dirs_from_files ("", 0);
      /* `files_index' might be zero now.  */
    }
  if (files_index)
    {
      print_current_files ();
      if (pending_dirs)
	putchar ('\n');
    }
  else if (pending_dirs && pending_dirs->next == 0)
    print_dir_name = 0;

  while (pending_dirs)
    {
      thispend = pending_dirs;
      pending_dirs = pending_dirs->next;
      print_dir (thispend->name, thispend->realname);
      free (thispend->name);
      if (thispend->realname)
	free (thispend->realname);
      free (thispend);
      print_dir_name = 1;
    }

  exit (0);
}

struct option long_options[] =
{
#ifdef MSDOS
  {"copying", 0, NULL, 30},
  {"version", 0, NULL, 31},
#endif
  {"all", 0, 0, 'a'},
  {"escape", 0, 0, 'b'},
  {"directory", 0, 0, 'd'},
  {"inode", 0, 0, 'i'},
  {"kilobytes", 0, 0, 'k'},
  {"numeric-uid-gid", 0, 0, 'n'},
  {"hide-control-chars", 0, 0, 'q'},
  {"reverse", 0, 0, 'r'},
  {"size", 0, 0, 's'},
  {"width", 1, 0, 'w'},
  {"almost-all", 0, 0, 'A'},
  {"ignore-backups", 0, 0, 'B'},
  {"classify", 0, 0, 'F'},
  {"file-type", 0, 0, 'F'},
  {"ignore", 1, 0, 'I'},
  {"dereference", 0, 0, 'L'},
  {"literal", 0, 0, 'N'},
  {"quote-name", 0, 0, 'Q'},
  {"recursive", 0, 0, 'R'},
  {"format", 1, 0, 12},
  {"sort", 1, 0, 10},
  {"tabsize", 1, 0, 'T'},
  {"time", 1, 0, 11},
  {0, 0, 0, 0}
};

char *format_args[] =
{
  "verbose", "long", "commas", "horizontal", "across",
  "vertical", "single-column", 0
};

enum format formats[] =
{
  long_format, long_format, with_commas, horizontal, horizontal,
  many_per_line, one_per_line
};

char *sort_args[] =
{
  "none", "time", "size", "extension", 0
};

enum sort_type sort_types[] =
{
  sort_none, sort_time, sort_size, sort_extension
};

char *time_args[] =
{
  "atime", "access", "use", "ctime", "status", 0
};

enum time_type time_types[] =
{
  time_atime, time_atime, time_atime, time_ctime, time_ctime
};

/* Set all the option flags according to the switches specified.
   Return the index of the first non-option argument.  */

int
decode_switches (argc, argv)
     int argc;
     char **argv;
{
  register char *p;
  int c;
  int longind;

  qmark_funny_chars = 0;
  quote_funny_chars = 0;

  /* initialize all switches to default settings */

#ifdef MULTI_COL
#define PROGNAME "dir"
  /* This is for the `dir' program.  */
  format = many_per_line;
  quote_funny_chars = 1;
#else
#ifdef LONG_FORMAT
#define PROGNAME "vdir"
  /* This is for the `vdir' program.  */
  format = long_format;
  quote_funny_chars = 1;
#else
#define PROGNAME "ls"
  /* This is for the `ls' program.  */
  if (isatty (1))
    {
      format = many_per_line;
      qmark_funny_chars = 1;
    }
  else
    {
      format = one_per_line;
      qmark_funny_chars = 0;
    }
#endif
#endif

  time_type = time_mtime;
  sort_type = sort_name;
  sort_reverse = 0;
  numeric_users = 0;
  print_block_size = 0;
  kilobyte_blocks = 0;
  indicator_style = none;
  print_inode = 0;
  trace_links = 0;
  trace_dirs = 0;
  immediate_dirs = 0;
  all_files = 0;
  really_all_files = 0;
  ignore_patterns = 0;
  quote_as_string = 0;

  p = getenv ("COLUMNS");
  line_length = p ? atoi (p) : 80;

#ifdef TIOCGWINSZ
  {
    struct winsize ws;

    if (ioctl (1, TIOCGWINSZ, &ws) != -1 && ws.ws_col != 0)
      line_length = ws.ws_col;
  }
#endif

  p = getenv ("TABSIZE");
  tabsize = p ? atoi (p) : 8;

  while ((c = getopt_long (argc, argv, "abcdgiklmnpqrstuw:xABCFI:LNQRST:UX1",
			   long_options, &longind)) != EOF)
    {
      switch (c)
	{
	case 'a':
	  all_files = 1;
	  really_all_files = 1;
	  break;
	  
	case 'b':
	  quote_funny_chars = 1;
	  qmark_funny_chars = 0;
	  break;
	  
	case 'c':
	  time_type = time_ctime;
	  break;
	  
	case 'd':
	  immediate_dirs = 1;
	  break;
	  
	case 'g':
	  /* No effect.  For BSD compatibility. */
	  break;

	case 'i':
	  print_inode = 1;
	  break;
	  
	case 'k':
	  kilobyte_blocks = 1;
	  break;
	  
	case 'l':
	  format = long_format;
	  break;
	  
	case 'm':
	  format = with_commas;
	  break;
	  
	case 'n':
	  numeric_users = 1;
	  break;
	  
	case 'p':
	  indicator_style = not_programs;
	  break;
	  
	case 'q':
	  qmark_funny_chars = 1;
	  quote_funny_chars = 0;
	  break;
	  
	case 'r':
	  sort_reverse = 1;
	  break;
	  
	case 's':
	  print_block_size = 1;
	  break;
	  
	case 't':
	  sort_type = sort_time;
	  break;
	  
	case 'u':
	  time_type = time_atime;
	  break;
	  
	case 'w':
	  line_length = atoi (optarg);
	  if (line_length < 1)
	    error (1, 0, "invalid line width: %s", optarg);
	  break;
	  
	case 'x':
	  format = horizontal;
	  break;
	  
	case 'A':
	  all_files = 1;
	  break;
	  
	case 'B':
	  add_ignore_pattern ("*~");
	  add_ignore_pattern (".*~");
	  break;
	  
	case 'C':
	  format = many_per_line;
	  break;
	  
	case 'F':
	  indicator_style = all;
	  break;
	  
	case 'I':
	  add_ignore_pattern (optarg);
	  break;
	  
	case 'L':
	  trace_links = 1;
	  break;
	  
	case 'N':
	  quote_funny_chars = 0;
	  qmark_funny_chars = 0;
	  break;
	  
	case 'Q':
	  quote_as_string = 1;
	  quote_funny_chars = 1;
	  qmark_funny_chars = 0;
	  break;
	  
	case 'R':
	  trace_dirs = 1;
	  break;
	  
	case 'S':
	  sort_type = sort_size;
	  break;
	  
	case 'T':
	  tabsize = atoi (optarg);
	  if (tabsize < 1)
	    error (1, 0, "invalid tab size: %s", optarg);
	  break;

	case 'U':
	  sort_type = sort_none;
	  break;

	case 'X':
	  sort_type = sort_extension;
	  break;

	case '1':
	  format = one_per_line;
	  break;
	  
	case 10:		/* +sort */
	  longind = argmatch (optarg, sort_args);
	  if (longind < 0)
	    {
	      invalid_arg ("sort type", optarg, longind);
	      usage ();
	    }
	  sort_type = sort_types[longind];
	  break;

	case 11:		/* +time */
	  longind = argmatch (optarg, time_args);
	  if (longind < 0)
	    {
	      invalid_arg ("time type", optarg, longind);
	      usage ();
	    }
	  time_type = time_types[longind];
	  break;

	case 12:		/* +format */
	  longind = argmatch (optarg, format_args);
	  if (longind < 0)
	    {
	      invalid_arg ("format type", optarg, longind);
	      usage ();
	    }
	  format = formats[longind];
	  break;

#ifdef MSDOS
	case 30:
	  fprintf (stderr, COPYING);
	  exit (0);
	  break;

	case 31:
	  fprintf (stderr, VERSION);
	  exit (0);
	  break;
#endif

	default:
	  usage ();
	}
    }

  return optind;
}

/* Request that the directory named `name' have its contents listed later.
   If `realname' is nonzero, it will be used instead of `name' when the
   directory name is printed.  This allows symbolic links to directories
   to be treated as regular directories but still be listed under their
   real names. */

void
queue_directory (name, realname)
     char *name;
     char *realname;
{
  struct pending *new;

  new = (struct pending *) xmalloc (sizeof (struct pending));
  new->next = pending_dirs;
  pending_dirs = new;
  new->name = copystring (name);
  if (realname)
    new->realname = copystring (realname);
  else
    new->realname = 0;
}

/* Read directory `name', and list the files in it.
   If `realname' is nonzero, print its name instead of `name';
   this is used for symbolic links to directories. */

void
print_dir (name, realname)
     char *name;
     char *realname;
{
  register DIR *reading;
  register struct direct *next;
  register int total_blocks = 0;

  errno = 0;
  reading = opendir (name);
  if (!reading)
    {
      error (0, errno, "%s", name);
      return;
    }

  /* Read the directory entries, and insert the subfiles into the `files'
     table.  */

  clear_files ();

  while (next = readdir (reading))
    if (file_interesting (next))
      total_blocks += gobble_file (next->d_name, 0, name);

  closedir (reading);

  /* Sort the directory contents.  */
  sort_files ();

  /* If any member files are subdirectories, perhaps they should have their
     contents listed rather than being mentioned here as files.  */

  if (trace_dirs)
    extract_dirs_from_files (name, 1);

  if (print_dir_name)
    {
      if (realname)
	printf ("%s:\n", realname);
      else
	printf ("%s:\n", name);
    }

  if (format == long_format || print_block_size)
    printf ("total %u\n", total_blocks);

  if (files_index)
    print_current_files ();

  if (pending_dirs)
    putchar ('\n');
}

/* Add `pattern' to the list of patterns for which files that match are
   not listed.  */

void
add_ignore_pattern (pattern)
     char *pattern;
{
  register struct ignore_pattern *ignore;

  ignore = (struct ignore_pattern *) xmalloc (sizeof (struct ignore_pattern));
  ignore->pattern = pattern;
  /* Add it to the head of the linked list. */
  ignore->next = ignore_patterns;
  ignore_patterns = ignore;
}

/* Return nonzero if the file in `next' should be listed. */

int
file_interesting (next)
     register struct direct *next;
{
  register struct ignore_pattern *ignore;

  for (ignore = ignore_patterns; ignore; ignore = ignore->next)
    if (glob_match (ignore->pattern, next->d_name, 1))
      return 0;

  if (really_all_files
      || next->d_name[0] != '.'
      || (all_files
	  && next->d_name[1] != '\0'
	  && (next->d_name[1] != '.' || next->d_name[2] != '\0')))
    return 1;

  return 0;
}

/* Enter and remove entries in the table `files'.  */

/* Empty the table of files. */

void
clear_files ()
{
  register int i;

  for (i = 0; i < files_index; i++)
    {
      free (files[i].name);
      if (files[i].linkname)
	free (files[i].linkname);
    }

  files_index = 0;
  block_size_size = 4;
}

/* Add a file to the current table of files.
   Verify that the file exists, and print an error message if it does not.
   Return the number of blocks that the file occupies.  */

int
gobble_file (name, explicit_arg, dirname)
     char *name;
     int explicit_arg;
     char *dirname;
{
  register int blocks;
  register int val;
  register char *path;

  if (files_index == nfiles)
    {
      nfiles *= 2;
      files = (struct file *) xrealloc (files, sizeof (struct file) * nfiles);
    }

  files[files_index].linkname = 0;
  files[files_index].linkmode = 0;

  if (explicit_arg || format_needs_stat)
    {
      /* `path' is the absolute pathname of this file. */

      if (name[0] == '/' || dirname[0] == 0)
	path = name;
      else
	{
	  path = (char *) alloca (strlen (name) + strlen (dirname) + 2);
	  attach (path, dirname, name);
	}

      if (trace_links)
	{
	  val = stat (path, &files[files_index].stat);
	  if (val < 0)
	    /* Perhaps a symbolically-linked to file doesn't exist; stat
	       the link instead. */
	    val = lstat (path, &files[files_index].stat);
	}
      else
	val = lstat (path, &files[files_index].stat);
      if (val < 0)
	{
	  error (0, errno, "%s", path);
	  return 0;
	}

#ifdef S_IFLNK
      if ((files[files_index].stat.st_mode & S_IFMT) == S_IFLNK)
	{
	  char *linkpath;
	  struct stat linkstats;

	  get_link_name (path, &files[files_index]);
	  linkpath = make_link_path (path, files[files_index].linkname);

	  /* Stat the file linked to; automatically trace it in non-long
	     listings, get its mode for the filetype indicator in long
	     listings. */
	  if (linkpath && lstat (linkpath, &linkstats) == 0)
	    {
	      if ((linkstats.st_mode & S_IFMT) == S_IFDIR
		  && explicit_arg && format != long_format)
		{
		  char *tempname;

		  /* Symbolic links to directories that are mentioned on the
		     command line are automatically traced if not being
		     listed as files. */
		  if (!immediate_dirs)
		    {
		      tempname = name;
		      name = linkpath;
		      linkpath = files[files_index].linkname;
		      files[files_index].linkname = tempname;
		    }
		  files[files_index].stat = linkstats;
		}
	      else
		files[files_index].linkmode = linkstats.st_mode;
	    }
	  if (linkpath)
	    free (linkpath);
	}
#endif

      switch (files[files_index].stat.st_mode & S_IFMT)
	{
#ifdef S_IFLNK
	case S_IFLNK:
	  files[files_index].filetype = symbolic_link;
	  break;
#endif

	case S_IFDIR:
	  if (explicit_arg && !immediate_dirs)
	    files[files_index].filetype = arg_directory;
	  else
	    files[files_index].filetype = directory;
	  break;

	default:
	  files[files_index].filetype = normal;
	  break;
	}

      blocks = convert_blocks (ST_NBLOCKS (files[files_index].stat),
			       kilobyte_blocks);
      if (blocks >= 10000 && block_size_size < 5)
	block_size_size = 5;
#ifndef MSDOS
      if (blocks >= 100000 && block_size_size < 6)
	block_size_size = 6;
      if (blocks >= 1000000 && block_size_size < 7)
	block_size_size = 7;
#endif /* not MSDOS */
    }
  else
    blocks = 0;

  files[files_index].name = copystring (name);
  files_index++;

  return blocks;
}

#ifdef S_IFLNK

/* Put the name of the file that `filename' is a symbolic link to
   into the `linkname' field of `f'. */

void
get_link_name (filename, f)
     char *filename;
     struct file *f;
{
  register char *linkbuf;
  register int bufsiz = f->stat.st_size;

  linkbuf = (char *) xmalloc (bufsiz + 1);
  linkbuf[bufsiz] = 0;
  if (readlink (filename, linkbuf, bufsiz) < 0)
    {
      error (0, errno, "%s", filename);
      free (linkbuf);
    }
  else
    f->linkname = linkbuf;
}

/* If `linkname' is a relative path and `path' contains one or more
   leading directories, return `linkname' with those directories
   prepended; otherwise, return a copy of `linkname'.
   If `linkname' is zero, return zero. */

char *
make_link_path (path, linkname)
     char *path;
     char *linkname;
{
  char *linkbuf;
  int bufsiz;

  if (linkname == 0)
    return 0;

  if (*linkname == '/')
    return copystring (linkname);

  /* The link is to a relative path.  Prepend any leading path
     in `path' to the link name. */
  linkbuf = rindex (path, '/');
  if (linkbuf == 0)
    return copystring (linkname);

  bufsiz = linkbuf - path + 1;
  linkbuf = xmalloc (bufsiz + strlen (linkname) + 1);
  strncpy (linkbuf, path, bufsiz);
  strcpy (linkbuf + bufsiz, linkname);
  return linkbuf;
}
#endif

/* Remove any entries from `files' that are for directories,
   and queue them to be listed as directories instead.
   `dirname' is the prefix to prepend to each dirname
   to make it correct relative to ls's working dir.
   `recursive' is nonzero if we should not treat `.' and `..' as dirs.
   This is desirable when processing directories recursively.  */

void
extract_dirs_from_files (dirname, recursive)
     char *dirname;
     int recursive;
{
  register int i, j;
  register char *path;
  int dirlen;

  dirlen = strlen (dirname) + 2;
  /* Queue the directories last one first, because queueing reverses the
     order.  */
  for (i = files_index - 1; i >= 0; i--)
    if ((files[i].filetype == directory || files[i].filetype == arg_directory)
	&& (!recursive || is_not_dot_or_dotdot (files[i].name)))
      {
	if (files[i].name[0] == '/' || dirname[0] == 0)
	  {
	    queue_directory (files[i].name, files[i].linkname);
	  }
	else
	  {
	    path = (char *) xmalloc (strlen (files[i].name) + dirlen);
	    attach (path, dirname, files[i].name);
	    queue_directory (path, files[i].linkname);
	    free (path);
	  }
	if (files[i].filetype == arg_directory)
	  free (files[i].name);
      }

  /* Now delete the directories from the table, compacting all the remaining
     entries.  */

  for (i = 0, j = 0; i < files_index; i++)
    if (files[i].filetype != arg_directory)
      files[j++] = files[i];
  files_index = j;
}

/* Return non-zero if `name' doesn't end in `.' or `..'
   This is so we don't try to recurse on `././././. ...' */

int
is_not_dot_or_dotdot (name)
     char *name;
{
  char *t;

  t = rindex (name, '/');
  if (t)
    name = t + 1;

  if (name[0] == '.'
      && (name[1] == '\0'
	  || (name[1] == '.' && name[2] == '\0')))
    return 0;

  return 1;
}

/* Sort the files now in the table.  */

void
sort_files ()
{
  int (*func) ();

  switch (sort_type)
    {
    case sort_none:
      return;
    case sort_time:
      switch (time_type)
	{
	case time_ctime:
	  func = sort_reverse ? rev_cmp_ctime : compare_ctime;
	  break;
	case time_mtime:
	  func = sort_reverse ? rev_cmp_mtime : compare_mtime;
	  break;
	case time_atime:
	  func = sort_reverse ? rev_cmp_atime : compare_atime;
	  break;
	}
      break;
    case sort_name:
      func = sort_reverse ? rev_cmp_name : compare_name;
      break;
    case sort_extension:
      func = sort_reverse ? rev_cmp_extension : compare_extension;
      break;
    case sort_size:
      func = sort_reverse ? rev_cmp_size : compare_size;
      break;
    }

  qsort (files, files_index, sizeof (struct file), func);
}

/* Comparison routines for sorting the files. */

int
compare_ctime (file1, file2)
     struct file *file1, *file2;
{
  return longdiff (file2->stat.st_ctime, file1->stat.st_ctime);
}

int
rev_cmp_ctime (file2, file1)
     struct file *file1, *file2;
{
  return longdiff (file2->stat.st_ctime, file1->stat.st_ctime);
}

int
compare_mtime (file1, file2)
     struct file *file1, *file2;
{
  return longdiff (file2->stat.st_mtime, file1->stat.st_mtime);
}

int
rev_cmp_mtime (file2, file1)
     struct file *file1, *file2;
{
  return longdiff (file2->stat.st_mtime, file1->stat.st_mtime);
}

int
compare_atime (file1, file2)
     struct file *file1, *file2;
{
  return longdiff (file2->stat.st_atime, file1->stat.st_atime);
}

int
rev_cmp_atime (file2, file1)
     struct file *file1, *file2;
{
  return longdiff (file2->stat.st_atime, file1->stat.st_atime);
}

int
compare_size (file1, file2)
     struct file *file1, *file2;
{
  return longdiff (file2->stat.st_size, file1->stat.st_size);
}

int
rev_cmp_size (file2, file1)
     struct file *file1, *file2;
{
  return longdiff (file2->stat.st_size, file1->stat.st_size);
}

int
compare_name (file1, file2)
     struct file *file1, *file2;
{
  return strcmp (file1->name, file2->name);
}

int
rev_cmp_name (file2, file1)
     struct file *file1, *file2;
{
  return strcmp (file1->name, file2->name);
}

/* Compare file extensions.  Files with no extension are `smallest'.
   If extensions are the same, compare by filenames instead. */

int
compare_extension (file1, file2)
     struct file *file1, *file2;
{
  register char *base1, *base2;
  register int cmp;

  base1 = rindex (file1->name, '.');
  base2 = rindex (file2->name, '.');
  if (base1 == 0 && base2 == 0)
    return strcmp (file1->name, file2->name);
  if (base1 == 0)
    return -1;
  if (base2 == 0)
    return 1;
  cmp = strcmp (base1, base2);
  if (cmp == 0)
    return strcmp (file1->name, file2->name);
  return cmp;
}

int
rev_cmp_extension (file2, file1)
     struct file *file1, *file2;
{
  register char *base1, *base2;
  register int cmp;

  base1 = rindex (file1->name, '.');
  base2 = rindex (file2->name, '.');
  if (base1 == 0 && base2 == 0)
    return strcmp (file1->name, file2->name);
  if (base1 == 0)
    return -1;
  if (base2 == 0)
    return 1;
  cmp = strcmp (base1, base2);
  if (cmp == 0)
    return strcmp (file1->name, file2->name);
  return cmp;
}

/* List all the files now in the table.  */

void
print_current_files ()
{
  register int i;

  switch (format)
    {
    case one_per_line:
      for (i = 0; i < files_index; i++)
	{
	  print_file_name_and_frills (files + i);
	  putchar ('\n');
	}
      break;

    case many_per_line:
      print_many_per_line ();
      break;

    case horizontal:
      print_horizontal ();
      break;

    case with_commas:
      print_with_commas ();
      break;

    case long_format:
      for (i = 0; i < files_index; i++)
	{
	  print_long_format (files + i);
	  putchar ('\n');
	}
      break;
    }
}

void
print_long_format (f)
     struct file *f;
{
  char modebuf[20];
  char timebuf[40];
  long when;

  mode_string (f->stat.st_mode, modebuf);
  modebuf[10] = 0;

  switch (time_type)
    {
    case time_ctime:
      when = f->stat.st_ctime;
      break;
    case time_mtime:
      when = f->stat.st_mtime;
      break;
    case time_atime:
      when = f->stat.st_atime;
      break;
    }

  strcpy (timebuf, ctime (&when));
  if (current_time - when > 6L * 30L * 24L * 60L * 60L
      || current_time - when < 0L)
    {
      /* The file is fairly old or in the future.
	 POSIX says the cutoff is 6 months old;
	 approximate this by 6*30 days.
	 Show the year instead of the time of day.  */
      strcpy (timebuf + 11, timebuf + 19);
    }
  timebuf[16] = 0;

  if (print_inode)
    printf ("%6u ", f->stat.st_ino);

  if (print_block_size)
    printf ("%*u ", block_size_size, convert_blocks (ST_NBLOCKS (f->stat),
						     kilobyte_blocks));

  /* The space between the mode and the number of links is the POSIX
     "optional alternate access method flag". */
  printf ("%s %3u ", modebuf, f->stat.st_nlink);

  if (numeric_users)
    printf ("%-8u ", (unsigned int) f->stat.st_uid);
  else
    printf ("%-8.8s ", getuser (f->stat.st_uid));

  if (numeric_users)
    printf ("%-8u ", (unsigned int) f->stat.st_gid);
  else
    printf ("%-8.8s ", getgroup (f->stat.st_gid));

#ifdef S_IFBLK
  if ((f->stat.st_mode & S_IFMT) == S_IFCHR
      || (f->stat.st_mode & S_IFMT) == S_IFBLK)
#else /* not S_IFBLK */
  if ((f->stat.st_mode & S_IFMT) == S_IFCHR)
#endif /* not S_IFBLK */
    printf ("%3u, %3u ", major (f->stat.st_rdev), minor (f->stat.st_rdev));
  else
    printf ("%8lu ", f->stat.st_size);

  printf ("%s ", timebuf + 4);

  print_name_with_quoting (f->name);

  if (f->filetype == symbolic_link)
    {
      if (f->linkname)
	{
	  fputs (" -> ", stdout);
	  print_name_with_quoting (f->linkname);
	  if (indicator_style != none)
	    print_type_indicator (f->linkmode);
	}
    }
  else if (indicator_style != none)
    print_type_indicator (f->stat.st_mode);
}

void
print_name_with_quoting (p)
     register char *p;
{
  register unsigned char c;

  if (quote_as_string)
    putchar ('"');

  while (c = *p++)
    {
      if (quote_funny_chars)
	{
	  switch (c)
	    {
	    case '\\':
	      printf ("\\\\");
	      break;

	    case '\n':
	      printf ("\\n");
	      break;

	    case '\b':
	      printf ("\\b");
	      break;

	    case '\r':
	      printf ("\\r");
	      break;

	    case '\t':
	      printf ("\\t");
	      break;

	    case '\f':
	      printf ("\\f");
	      break;

	    case ' ':
	      printf ("\\ ");
	      break;

	    case '"':
	      printf ("\\\"");
	      break;

	    default:
	      if (c > 040 && c < 0177)
		putchar (c);
	      else
		printf ("\\%03o", (unsigned int) c);
	    }
	}
      else
	{
	  if (c >= 040 && c < 0177)
	    putchar (c);
	  else if (!qmark_funny_chars)
	    putchar (c);
	  else
	    putchar ('?');
	}
    }

  if (quote_as_string)
    putchar ('"');
}

/* Print the file name of `f' with appropriate quoting.
   Also print file size, inode number, and filetype indicator character,
   as requested by switches.  */

void
print_file_name_and_frills (f)
     struct file *f;
{
  if (print_inode)
    printf ("%6u ", f->stat.st_ino);

  if (print_block_size)
    printf ("%*u ", block_size_size, convert_blocks (ST_NBLOCKS (f->stat),
						     kilobyte_blocks));

  print_name_with_quoting (f->name);

  if (indicator_style != none)
    print_type_indicator (f->stat.st_mode);
}

void
print_type_indicator (mode)
     unsigned int mode;
{
  switch (mode & S_IFMT)
    {
    case S_IFDIR:
      putchar ('/');
      break;

#ifdef S_IFLNK
    case S_IFLNK:
      putchar ('@');
      break;
#endif

#ifdef S_IFIFO
    case S_IFIFO:
      putchar ('|');
      break;
#endif

#ifdef S_IFSOCK
    case S_IFSOCK:
      putchar ('=');
      break;
#endif

    case S_IFREG:
      if (indicator_style == all
	  && (mode & (S_IEXEC | S_IEXEC >> 3 | S_IEXEC >> 6)))
	putchar ('*');
      break;
    }
}

int
length_of_file_name_and_frills (f)
     struct file *f;
{
  register char *p = f->name;
  register char c;
  register int len = 0;

  if (print_inode)
    len += 7;

  if (print_block_size)
    len += 1 + block_size_size;

  if (quote_as_string)
    len += 2;

  while (c = *p++)
    {
      if (quote_funny_chars)
	{
	  switch (c)
	    {
	    case '\\':
	    case '\n':
	    case '\b':
	    case '\r':
	    case '\t':
	    case '\f':
	    case ' ':
	      len += 2;
	      break;

	    case '"':
	      if (quote_as_string)
		len += 2;
	      else
		len += 1;
	      break;

	    default:
	      if (c >= 040 && c < 0177)
		len += 1;
	      else
		len += 4;
	    }
	}
      else
	len += 1;
    }

  if (indicator_style != none)
    {
      unsigned filetype = f->stat.st_mode & S_IFMT;

      if (filetype == S_IFREG)
	{
	  if (indicator_style == all
	      && (f->stat.st_mode & (S_IEXEC | S_IEXEC >> 3 | S_IEXEC >> 6)))
	    len += 1;
	}
      else if (filetype == S_IFDIR
#ifdef S_IFLNK
	       || filetype == S_IFLNK
#endif
#ifdef S_IFIFO
	       || filetype == S_IFIFO
#endif
#ifdef S_IFSOCK
	       || filetype == S_IFSOCK
#endif
	       )
	len += 1;
    }

  return len;
}

void
print_many_per_line ()
{
  int filesno;			/* Index into files. */
  int row;			/* Current row. */
  int max_name_length;		/* Length of longest file name + frills. */
  int name_length;		/* Length of each file name + frills. */
  int pos;			/* Current character column. */
  int cols;			/* Number of files across. */
  int rows;			/* Maximum number of files down. */

  /* Compute the maximum file name length.  */
  max_name_length = 0;
  for (filesno = 0; filesno < files_index; filesno++)
    {
      name_length = length_of_file_name_and_frills (files + filesno);
      if (name_length > max_name_length)
	max_name_length = name_length;
    }

  /* Allow at least two spaces between names.  */
  max_name_length += 2;

  /* Calculate the maximum number of columns that will fit. */
  cols = line_length / max_name_length;
  if (cols == 0)
    cols = 1;
  /* Calculate the number of rows that will be in each column except possibly
     for a short column on the right. */
  rows = files_index / cols + (files_index % cols != 0);
  /* Recalculate columns based on rows. */
  cols = files_index / rows + (files_index % rows != 0);

  for (row = 0; row < rows; row++)
    {
      filesno = row;
      pos = 0;
      /* Print the next row.  */
      while (1)
	{
	  print_file_name_and_frills (files + filesno);
	  name_length = length_of_file_name_and_frills (files + filesno);

	  filesno += rows;
	  if (filesno >= files_index)
	    break;

	  indent (pos + name_length, pos + max_name_length);
	  pos += max_name_length;
	}
      putchar ('\n');
    }
}

void
print_horizontal ()
{
  int filesno;
  int max_name_length;
  int name_length;
  int cols;
  int pos;

  /* Compute the maximum file name length.  */
  max_name_length = 0;
  for (filesno = 0; filesno < files_index; filesno++)
    {
      name_length = length_of_file_name_and_frills (files + filesno);
      if (name_length > max_name_length)
	max_name_length = name_length;
    }

  /* Allow two spaces between names.  */
  max_name_length += 2;

  cols = line_length / max_name_length;
  if (cols == 0)
    cols = 1;

  pos = 0;
  name_length = 0;

  for (filesno = 0; filesno < files_index; filesno++)
    {
      if (filesno != 0)
	{
	  if (filesno % cols == 0)
	    {
	      putchar ('\n');
	      pos = 0;
	    }
	  else
	    {
	      indent (pos + name_length, pos + max_name_length);
	      pos += max_name_length;
	    }
	}

      print_file_name_and_frills (files + filesno);

      name_length = length_of_file_name_and_frills (files + filesno);
    }
  putchar ('\n');
}

void
print_with_commas ()
{
  int filesno;
  int pos, old_pos;

  pos = 0;

  for (filesno = 0; filesno < files_index; filesno++)
    {
      old_pos = pos;

      pos += length_of_file_name_and_frills (files + filesno);
      if (filesno + 1 < files_index)
	pos += 2;		/* For the comma and space */

      if (old_pos != 0 && pos >= line_length)
	{
	  putchar ('\n');
	  pos -= old_pos;
	}

      print_file_name_and_frills (files + filesno);
      if (filesno + 1 < files_index)
	{
	  putchar (',');
	  putchar (' ');
	}
    }
  putchar ('\n');
}

struct userid
{
  unsigned short uid;
  char *name;
  struct userid *next;
};

struct userid *user_alist;

/* Translate `uid' to a login name, with cache.  */

char *
getuser (uid)
     unsigned short uid;
{
  register struct userid *tail;
  struct passwd *pwent;
  char usernum_string[20];

  for (tail = user_alist; tail; tail = tail->next)
    if (tail->uid == uid)
      return tail->name;

  pwent = getpwuid (uid);

  tail = (struct userid *) xmalloc (sizeof (struct userid));
  tail->uid = uid;
  tail->next = user_alist;
  if (pwent == 0)
    {
      sprintf (usernum_string, "%u", (unsigned short) uid);
      tail->name = copystring (usernum_string);
    }
  else
    tail->name = copystring (pwent->pw_name);
  user_alist = tail;
  return tail->name;
}

/* We use the same struct as for userids.  */
struct userid *group_alist;

/* Translate `gid' to a group name, with cache.  */

char *
getgroup (gid)
     unsigned short gid;
{
  register struct userid *tail;
  struct group *grent;
  char groupnum_string[20];

  for (tail = group_alist; tail; tail = tail->next)
    if (tail->uid == gid)
      return tail->name;

  grent = getgrgid (gid);
  tail = (struct userid *) xmalloc (sizeof (struct userid));
  tail->uid = gid;
  tail->next = group_alist;
  if (grent == 0)
    {
      sprintf (groupnum_string, "%u", (unsigned int) gid);
      tail->name = copystring (groupnum_string);
    }
  else
    tail->name = copystring (grent->gr_name);
  group_alist = tail;
  return tail->name;
}

/* Assuming cursor is at position `from', indent up to position `to'.  */

void
indent (from, to)
     int from, to;
{
  while (from < to)
    {
      if (to / tabsize > from / tabsize)
	{
	  putchar ('\t');
	  from += tabsize - from % tabsize;
	}
      else
	{
	  putchar (' ');
	  from++;
	}
    }
}

/* Low level subroutines of general use,
   not specifically related to the task of listing a directory.  */

#ifndef MSDOS

char *
xrealloc (obj, size)
     char *obj;
     int size;
{
  char *val = realloc (obj, size);

  if (!val)
    error (1, 0, "virtual memory exhausted");

  return val;
}

char *
xmalloc (size)
     int size;
{
  char *val = malloc (size);

  if (!val)
    error (1, 0, "virtual memory exhausted");

  return val;
}

#endif /* MSDOS */

/* Return a newly allocated copy of `string'. */

char *
copystring (string)
     char *string;
{
  return strcpy ((char *) xmalloc (strlen (string) + 1), string);
}

/* Put `dirname/name' into `dest', handling `.' and `/' properly. */

void
attach (dest, dirname, name)
     char *dest, *dirname, *name;
{
  char *dirnamep = dirname;

  /* Copy dirname if it is not ".". */
  if (dirname[0] != '.' || dirname[1] != 0)
    {
      while (*dirnamep)
	*dest++ = *dirnamep++;
      /* Add '/' if `dirname' doesn't already end with it. */
      if (dirnamep > dirname && dirnamep[-1] != '/')
	*dest++ = '/';
    }
  while (*name)
    *dest++ = *name++;
  *dest = 0;
}

void
usage ()
{
  fprintf (stderr, "\
Usage: %s [-abcdgiklmnpqrstuxABCFLNQRSUX1] [-w cols] [-T cols] [-I pattern]\n\
       [+all] [+escape] [+directory] [+inode] [+kilobytes]\n\
       [+numeric-uid-gid] [+hide-control-chars] [+reverse] [+size]\n\
       [+width cols] [+tabsize cols] [+almost-all] [+ignore-backups]\n",
	   program_name);
#ifdef MSDOS
  fprintf (stderr, "\
       [+classify] [+file-type] [+ignore pattern] [+dereference] [+literal]\n\
       [+quote-name] [+recursive] [+sort {none,time,size,extension}]\n\
       [+format {long,verbose,commas,across,vertical,single-column}]\n\
       [+time {atime,access,use,ctime,status}] [+copying] [+version]\n\
       [path...]\n");
#else /* not MSDOS */
  fprintf (stderr, "\
       [+classify] [+file-type] [+ignore pattern] [+dereference] [+literal]\n\
       [+quote-name] [+recursive] [+sort {none,time,size,extension}]\n\
       [+format {long,verbose,commas,across,vertical,single-column}]\n\
       [+time {atime,access,use,ctime,status}] [path...]\n");
#endif /* not MSDOS */
  exit (1);
}
