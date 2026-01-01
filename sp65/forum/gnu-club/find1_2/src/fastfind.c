/* fastfind.c -- list files in database matching a pattern

   'fastfind' scans a file list for the full pathname of a file
   given only a piece of the name.  The list has been processed with
   "front-compression" and bigram coding.  Front compression reduces
   space by a factor of 4-5, bigram coding by a further 20-25%.

   The codes are:

   0-28		likeliest differential counts + offset to make nonnegative
   30		escape code for out-of-range count to follow in next word
   128-255 	bigram codes (128 most common, as determined by 'updatedb')
   32-127  	single character (printable) ASCII residue

   A novel two-tiered string search technique is employed:

   First, a metacharacter-free subpattern and partial pathname is
   matched BACKWARDS to avoid full expansion of the pathname list.
   The time savings is 40-50% over forward matching, which cannot efficiently
   handle overlapped search patterns and compressed path residue.

   Then, the actual shell glob-style regular expression (if in this form)
   is matched against the candidate pathnames using the slower routines
   provided in the standard 'find'.

   Author: James A. Woods (jaw@riacs.edu)
   Modified by David MacKenzie (djm@ai.mit.edu)
   MS-DOS mods: Thorsten Ohl (ohl@gnu.ai.mit.edu)
   Public domain. */

#include <stdio.h>
#ifndef USG
#include <strings.h>
#else
#include <string.h>
#define index strchr
#define rindex strrchr
#endif
#include <sys/types.h>
#ifndef MSDOS
#include <sys/param.h>
#endif /* MSDOS */

#ifndef MAXPATHLEN
#define MAXPATHLEN 1024
#endif

#define	YES	1
#define	NO	0

#define	OFFSET	14

#define	ESCCODE	30

#ifdef MSDOS

#include <stdlib.h>

#include <gnulib.h>
char *patprep (char *name);
void fastfind (char *pathpart);

#else /* not MSDOS */

extern int errno;

char *index ();
char *patprep ();
void error ();

#endif /* not MSDOS */

void
fastfind (pathpart)
     char *pathpart;
{
  register char *p, *s;
  register int c;
  char *q;
  int i, count = 0, globflag;
  FILE *fp;
  char *patend, *cutoff;
  char path[MAXPATHLEN];
  char bigram1[128], bigram2[128];
  int found = NO;

  fp = fopen (FCODES, "r");
  if (fp == NULL)
    error (1, errno, "%s", FCODES);

  for (i = 0; i < 128; i++)
    {
      bigram1[i] = getc (fp);
      bigram2[i] = getc (fp);
    }

  globflag = glob_pattern_p (pathpart);
  patend = patprep (pathpart);

  c = getc (fp);
  for (;;)
    {
      count += ((c == ESCCODE) ? getw (fp) : c) - OFFSET;

      for (p = path + count; (c = getc (fp)) > ESCCODE;)
	/* Overlay old path. */
	if (c < 0200)
	  *p++ = c;
	else
	  {
	    /* Bigrams are parity-marked. */
	    *p++ = bigram1[c & 0177];
	    *p++ = bigram2[c & 0177];
	  }
      if (c == EOF)
	break;
      *p-- = '\0';
      cutoff = path;
      if (!found)
	cutoff += count;

      for (found = NO, s = p; s >= cutoff; s--)
	if (*s == *patend)
	  {
	    /* Fast first char check. */
	    for (p = patend - 1, q = s - 1; *p != '\0'; p--, q--)
	      if (*q != *p)
		break;
	    if (*p == '\0')
	      {
		/* Success on fast match. */
		found = YES;
		if (globflag == NO || glob_match (pathpart, path, 1))
		  puts (path);
		break;
	      }
	  }
    }
}

static char globfree[100];

/* Extract the last glob-free subpattern in NAME for fast pre-match;
   prepend '\0' for backwards match; return the end of the new pattern. */

char *
patprep (name)
     char *name;
{
  register char *p, *endmark;
  register char *subp = globfree;

  *subp++ = '\0';
  p = name + strlen (name) - 1;
  /* Skip trailing metacharacters (and [] ranges). */
  for (; p >= name; p--)
    if (index ("*?", *p) == 0)
      break;
  if (p < name)
    p = name;
  if (*p == ']')
    for (p--; p >= name; p--)
      if (*p == '[')
	{
	  p--;
	  break;
	}
  if (p < name)
    p = name;
  /* If pattern has only metacharacters,
     check every path (force '/' search). */
  if (p == name && index ("?*[]", *p) != 0)
    *subp++ = '/';
  else
    {
      for (endmark = p; p >= name; p--)
	if (index ("]*?", *p) != 0)
	  break;
      for (++p; p <= endmark && subp < (globfree + sizeof (globfree));)
	*subp++ = *p++;
    }
  *subp-- = '\0';
  return subp;
}

/* The name this program was run with. */
char *program_name;

/* Usage: find pattern
   Searches a pre-computed file list constructed nightly by cron.
   Its effect is similar to, but much faster than,
   find / -mtime +0 -name "*pattern*" -print */

void
main (argc, argv)
     int argc;
     char **argv;
{
  int optind;

  program_name = argv[0];
#ifdef MSDOS			/* cosmetics  */
  strlwr (program_name);
#endif

  if (argc == 1)
    {
      fprintf (stderr, "Usage: %s pattern...\n", argv[0]);
      exit (1);
    }
  for (optind = 1; optind < argc; ++optind)
    fastfind (argv[optind]);
  exit (0);
}
