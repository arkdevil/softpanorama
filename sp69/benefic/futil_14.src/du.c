/* du -- summarize disk usage
   Copyright (C) 1988, 1989, 1990 Free Software Foundation, Inc.

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

/* Differences from the Unix du:
   * Doesn't simply ignore the names of regular files given as arguments
     when -a is given.
   * Additional options:
   -l		Count the size of all files, even if they have appeared
		already in another hard link.
   -x		Do not cross file-system boundaries during the recursion.
   -c		Write a grand total of all of the arguments after all
		arguments have been processed.  This can be used to find
		out the disk usage of a directory, with some files excluded.
   -k		Print sizes in kilobytes instead of 512 byte blocks
		(the default required by POSIX).
   -b		Print sizes in bytes (added by POSIX).

   By tege@sics.se, Torbjorn Granlund,
   and djm@ai.mit.edu, David MacKenzie.  */

#include <stdio.h>
#include <errno.h>
#include <getopt.h>
#include <sys/types.h>
#include "system.h"

#ifdef STDC_HEADERS
#include <stdlib.h>
#else
char *malloc ();
char *realloc ();

extern int errno;
#endif

/* Initial number of entries in each hash table entry's table of inodes.  */
#define INITIAL_HASH_MODULE 100

/* Initial number of entries in the inode hash table.  */
#define INITIAL_ENTRY_TAB_SIZE 70

/* Initial size to allocate for `path'.  */
#define INITIAL_PATH_SIZE 100

/* Hash structure for inode and device numbers.  The separate entry
   structure makes it easier to rehash "in place".  */

struct entry
{
  ino_t ino;
  dev_t dev;
  struct entry *coll_link;
};

/* Structure for a hash table for inode numbers. */

struct htab
{
  unsigned modulus;		/* Size of the `hash' pointer vector.  */
  struct entry *entry_tab;	/* Pointer to dynamically growing vector.  */
  unsigned entry_tab_size;	/* Size of current `entry_tab' allocation.  */
  unsigned first_free_entry;	/* Index in `entry_tab'.  */
  struct entry *hash[1];	/* Vector of pointers in `entry_tab'.  */
};


/* Structure for dynamically resizable strings. */

typedef struct
{
  unsigned alloc;		/* Size of allocation for the text.  */
  unsigned length;		/* Length of the text currently.  */
  char *text;			/* Pointer to the text.  */
} *string, stringstruct;

char *savedir ();
char *xmalloc ();
char *xrealloc ();
int hash_insert ();
int hash_insert2 ();
long count_entry ();
void error ();
void hash_init ();
void hash_reset ();
void str_concatc ();
void str_copyc ();
void str_init ();
void str_trunc ();

/* Name under which this program was invoked.  */
char *program_name;

/* If nonzero, display only a total for each argument. */
int opt_summarize_only = 0;

/* If nonzero, display counts for all files, not just directories. */
int opt_all = 0;

/* If nonzero, count each hard link of files with multiple links. */
int opt_count_all = 0;

/* If nonzero, do not cross file-system boundaries. */
int opt_one_file_system = 0;

/* If nonzero, print a grand total at the end. */
int opt_combined_arguments = 0;

enum output_size
{
  size_blocks,			/* Default. */
  size_kilobytes,		/* -k. */
  size_bytes			/* -b. */
};

/* The units to count in. */
enum output_size output_size = size_blocks;

/* Accumulated path for file or directory being processed.  */
string path;

/* Pointer to hash structure, used by the hash routines.  */
struct htab *htab;

/* Globally used stat buffer.  */
struct stat stat_buf;

struct option long_options[] =
{
  {"all", 0, &opt_all, 1},
  {"bytes", 0, NULL, 'b'},
  {"count-links", 0, &opt_count_all, 1},
  {"kilobytes", 0, NULL, 'k'},
  {"one-file-system", 0, &opt_one_file_system, 1},
  {"summarize", 0, &opt_summarize_only, 1},
  {"total", 0, &opt_combined_arguments, 1},
  {NULL, 0, NULL, 0}
};

void
usage (reason)
     char *reason;
{
  if (reason != NULL)
    fprintf (stderr, "%s: %s\n", program_name, reason);

  fprintf (stderr, "\
Usage: %s [-abcklsx] [+all] [+total] [+count-links] [+summarize]\n\
       [+bytes] [+kilobytes] [+one-file-system] [path...]\n",
	   program_name);

  exit (2);
}

void
main (argc, argv)
     int argc;
     char *argv[];
{
  int c;
  int ind;

  program_name = argv[0];

  while ((c = getopt_long (argc, argv, "abcklsx", long_options, &ind)) != EOF)
    {
      switch (c)
	{
	case 0:			/* Long option. */
	  break;

	case 'a':
	  opt_all = 1;
	  break;

	case 'b':
	  output_size = size_bytes;
	  break;

	case 'c':
	  opt_combined_arguments = 1;
	  break;

	case 'x':
	  opt_one_file_system = 1;
	  break;

	case 'k':
	  output_size = size_kilobytes;
	  break;

	case 'l':
	  opt_count_all = 1;
	  break;

	case 's':
	  opt_summarize_only = 1;
	  break;

	default:
	  usage ((char *) 0);
	}
    }

  if (opt_all && opt_summarize_only)
    usage ("cannot both summarize and show all entries");

  /* Initialize the hash structure for inode numbers.  */

  hash_init (INITIAL_HASH_MODULE, INITIAL_ENTRY_TAB_SIZE);

  str_init (&path, INITIAL_PATH_SIZE);

  if (optind == argc)
    {
      str_copyc (path, ".");

      /* Initialize the hash structure for inode numbers.  */

      hash_reset ();

      /* Get the size of the current directory only.  */

      count_entry (".", 1, 0);
    }
  else
    {
      char wd[PATH_MAX + 2];
      char *arg;
      ino_t initial_ino;	/* Initial directory's inode. */
      dev_t initial_dev;	/* Initial directory's device. */
      long tot_size = 0;	/* Grand total size of all args. */

      if (getwd (wd) == NULL)
	error (1, errno, "cannot get current directory");

      /* Remember the inode and device number of the current directory.  */

      if (stat (".", &stat_buf))
	error (1, errno, "current directory");
      initial_ino = stat_buf.st_ino;
      initial_dev = stat_buf.st_dev;

      do
	{
	  int s;
	  arg = argv[optind];

	  /* Delete final slash in the argument, unless the slash is alone.  */

	  s = strlen (arg) - 1;
	  if (s != 0)
	    {
	      if (arg[s] == '/')
		arg[s] = 0;

	      str_copyc (path, arg);
	    }
	  else if (arg[0] == '/')
	    str_trunc (path, 0);/* Null path for root directory.  */
	  else
	    str_copyc (path, arg);

	  if (!opt_combined_arguments)
	    hash_reset ();

	  tot_size += count_entry (arg, 1, 0);

	  /* chdir if `count_entry' has changed the working directory.  */

	  if (stat (".", &stat_buf))
	    error (1, errno, ".");
	  if ((stat_buf.st_ino != initial_ino
	       || stat_buf.st_dev != initial_dev)
	      && chdir (wd) < 0)
	    error (1, errno, "cannot change to directory %s", wd);

	  optind++;
	}
      while (optind < argc);

      if (opt_combined_arguments)
	{
	  printf ("%ld\ttotal\n", output_size == size_bytes ? tot_size
		  : convert_blocks (tot_size, output_size == size_kilobytes));
	  fflush (stdout);
	}
    }
  exit (0);
}

/* Print (if appropriate) and return the size
   (in units determined by `output_size') of file or directory ENT.
   TOP is one for external calls, zero for recursive calls.
   LAST_DEV is the device that the parent directory of ENT is on.  */

long
count_entry (ent, top, last_dev)
     char *ent;
     int top;
     dev_t last_dev;
{
  long size;

  if (lstat (ent, &stat_buf) < 0)
    {
      error (0, errno, "%s", path->text);
      return 0;
    }

  if (!opt_count_all
      && stat_buf.st_nlink > 1
      && hash_insert (stat_buf.st_ino, stat_buf.st_dev))
    return 0;			/* Have counted this already.  */

  if (output_size == size_bytes)
    size = stat_buf.st_size;
  else
    {
      size = ST_NBLOCKS (stat_buf);
#ifdef HPUX_NFS_BUG
      if (size >= 2 * (stat_buf.st_size + DEV_BSIZE - 1) / DEV_BSIZE)
	size = (size + 1) / 2;
#endif
    }

  if ((stat_buf.st_mode & S_IFMT) == S_IFDIR)
    {
      unsigned pathlen;
      dev_t dir_dev;
      char *name_space;
      char *namep;

      dir_dev = stat_buf.st_dev;

      if (opt_one_file_system && !top && last_dev != dir_dev)
	return 0;		/* Don't enter a new file system.  */

      if (chdir (ent) < 0)
	{
	  error (0, errno, "cannot change to directory %s", path->text);
	  return 0;
	}

      errno = 0;
      name_space = savedir (".", stat_buf.st_size);
      if (name_space == NULL)
	{
	  if (errno)
	    {
	      error (0, errno, "%s", path->text);
	      chdir ("..");	/* Try to return to previous directory.  */
	      return 0;
	    }
	  else
	    error (1, 0, "virtual memory exhausted");
	}

      /* Remember the current path.  */

      str_concatc (path, "/");
      pathlen = path->length;

      namep = name_space;
      while (*namep != 0)
	{
	  str_concatc (path, namep);

	  size += count_entry (namep, 0, dir_dev);

	  str_trunc (path, pathlen);
	  namep += strlen (namep) + 1;
	}
      free (name_space);
      chdir ("..");

      if (!opt_summarize_only || top)
	{
	  printf ("%ld\t%s\n", output_size == size_bytes ? size
		  : convert_blocks (size, output_size == size_kilobytes),
		  path->text);
	  fflush (stdout);
	}
    }
  else if (opt_all || top)
    {
      printf ("%ld\t%s\n", output_size == size_bytes ? size
	      : convert_blocks (size, output_size == size_kilobytes),
	      path->text);
      fflush (stdout);
    }

  return size;
}

/* Allocate space for the hash structures, and set the global
   variable `htab' to point to it.  The initial hash module is specified in
   MODULUS, and the number of entries are specified in ENTRY_TAB_SIZE.  (The
   hash structure will be rebuilt when ENTRY_TAB_SIZE entries have been
   inserted, and MODULUS and ENTRY_TAB_SIZE in the global `htab' will be
   doubled.)  */

void
hash_init (modulus, entry_tab_size)
     unsigned modulus;
     unsigned entry_tab_size;
{
  struct htab *htab_r;

  htab_r = (struct htab *)
    xmalloc (sizeof (struct htab) + sizeof (struct entry *) * modulus);

  htab_r->entry_tab = (struct entry *)
    xmalloc (sizeof (struct entry) * entry_tab_size);

  htab_r->modulus = modulus;
  htab_r->entry_tab_size = entry_tab_size;
  htab = htab_r;

  hash_reset ();
}

/* Reset the hash structure in the global variable `htab' to
   contain no entries.  */

void
hash_reset ()
{
  int i;
  struct entry **p;

  htab->first_free_entry = 0;

  p = htab->hash;
  for (i = htab->modulus; i > 0; i--)
    *p++ = NULL;
}

/* Insert an item (inode INO and device DEV) in the hash
   structure in the global variable `htab', if an entry with the same data
   was not found already.  Return zero if the item was inserted and non-zero
   if it wasn't.  */

int
hash_insert (ino, dev)
     ino_t ino;
     dev_t dev;
{
  struct htab *htab_r = htab;	/* Initially a copy of the global `htab'.  */

  if (htab_r->first_free_entry >= htab_r->entry_tab_size)
    {
      int i;
      struct entry *ep;
      unsigned modulus;
      unsigned entry_tab_size;

      /* Increase the number of hash entries, and re-hash the data.
	 The method of shrimping and increasing is made to compactify
	 the heap.  If twice as much data would be allocated
	 straightforwardly, we would never re-use a byte of memory.  */

      /* Let `htab' shrimp.  Keep only the header, not the pointer vector.  */

      htab_r = (struct htab *)
	xrealloc ((char *) htab_r, sizeof (struct htab));

      modulus = 2 * htab_r->modulus;
      entry_tab_size = 2 * htab_r->entry_tab_size;

      /* Increase the number of possible entries.  */

      htab_r->entry_tab = (struct entry *)
	xrealloc ((char *) htab_r->entry_tab,
		 sizeof (struct entry) * entry_tab_size);

      /* Increase the size of htab again.  */

      htab_r = (struct htab *)
	xrealloc ((char *) htab_r,
		 sizeof (struct htab) + sizeof (struct entry *) * modulus);

      htab_r->modulus = modulus;
      htab_r->entry_tab_size = entry_tab_size;
      htab = htab_r;

      i = htab_r->first_free_entry;

      /* Make the increased hash table empty.  The entries are still
	 available in htab->entry_tab.  */

      hash_reset ();

      /* Go through the entries and install them in the pointer vector
	 htab->hash.  The items are actually inserted in htab->entry_tab at
	 the position where they already are.  The htab->coll_link need
	 however be updated.  Could be made a little more efficient.  */

      for (ep = htab_r->entry_tab; i > 0; i--)
	{
	  hash_insert2 (htab_r, ep->ino, ep->dev);
	  ep++;
	}
    }

  return hash_insert2 (htab_r, ino, dev);
}

/* Insert INO and DEV in the hash structure HTAB, if not
   already present.  Return zero if inserted and non-zero if it
   already existed.  */

int
hash_insert2 (htab, ino, dev)
     struct htab *htab;
     ino_t ino;
     dev_t dev;
{
  struct entry **hp, *ep2, *ep;
  hp = &htab->hash[ino % htab->modulus];
  ep2 = *hp;

  /* Collision?  */

  if (ep2 != NULL)
    {
      ep = ep2;

      /* Search for an entry with the same data.  */

      do
	{
	  if (ep->ino == ino && ep->dev == dev)
	    return 1;		/* Found an entry with the same data.  */
	  ep = ep->coll_link;
	}
      while (ep != NULL);

      /* Did not find it.  */

    }

  ep = *hp = &htab->entry_tab[htab->first_free_entry++];
  ep->ino = ino;
  ep->dev = dev;
  ep->coll_link = ep2;		/* `ep2' is NULL if no collision.  */

  return 0;
}

/* Initialize the struct string S1 for holding SIZE characters.  */

void
str_init (s1, size)
     string *s1;
     unsigned size;
{
  string s;

  s = (string) xmalloc (sizeof (stringstruct));
  s->text = xmalloc (size + 1);

  s->alloc = size;
  *s1 = s;
}

static void
ensure_space (s, size)
     string s;
     unsigned size;
{
  if (s->alloc < size)
    {
      s->text = xrealloc (s->text, size + 1);
      s->alloc = size;
    }
}

/* Assign the null-terminated C-string CSTR to S1.  */

void
str_copyc (s1, cstr)
     string s1;
     char *cstr;
{
  unsigned l = strlen (cstr);
  ensure_space (s1, l);
  strcpy (s1->text, cstr);
  s1->length = l;
}

void
str_concatc (s1, cstr)
     string s1;
     char *cstr;
{
  unsigned l1 = s1->length;
  unsigned l2 = strlen (cstr);
  unsigned l = l1 + l2;

  ensure_space (s1, l);
  strcpy (s1->text + l1, cstr);
  s1->length = l;
}

/* Truncate the string S1 to have length LENGTH.  */

void
str_trunc (s1, length)
     string s1;
     unsigned length;
{
  if (s1->length > length)
    {
      s1->text[length] = 0;
      s1->length = length;
    }
}

/* Allocate N bytes of memory dynamically, with error checking.  */

char *
xmalloc (n)
     unsigned n;
{
  char *p;

  p = malloc (n);
  if (p == 0)
    error (1, 0, "virtual memory exhausted");
  return p;
}

/* Change the size of an allocated block of memory P to N bytes,
   with error checking.
   If P is NULL, run xmalloc.
   If N is 0, run free and return NULL.  */

char *
xrealloc (p, n)
     char *p;
     unsigned n;
{
  if (p == 0)
    return xmalloc (n);
  if (n == 0)
    {
      free (p);
      return 0;
    }
  p = realloc (p, n);
  if (p == 0)
    error (1, 0, "virtual memory exhausted");
  return p;
}
