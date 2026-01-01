/* head -- output first part of file(s)
   Copyright (C) 1989, 1990 Free Software Foundation, Inc.

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
  "$Header: e:/gnu/fileutil/RCS/head.c 1.4.0.3 90/09/19 11:17:59 tho Exp $";

static char Program_Id[] = "head";
static char RCS_Revision[] = "$Revision: 1.4.0.3 $";

#define VERSION \
  "GNU %s, Version %.*s (compiled %s %s for MS-DOS)\n", Program_Id, \
  (sizeof RCS_Revision - 14), (RCS_Revision + 11), __DATE__, __TIME__

#define COPYING \
  "This is free software, distributed under the terms of the\n" \
  "GNU General Public License.  For details, see the file COPYING.\n"
#endif /* MSDOS */

/* Usage: head [-b #] [-c #] [-n #] [-qv] [+blocks #] [+bytes #] [+lines #]
          [+quiet] [+silent] [+verbose] [file...]

          head [-#bclqv] [file...]

   Options:
   -b, +blocks #	Print first # 512-byte blocks.
   -c, +bytes #		Print first # bytes.
   -l, -n, +lines #	Print first # lines.
   -q, +quiet, +silent	Never print filename headers.
   -v, +verbose		Always print filename headers.

   Reads from standard input if no files are given or when a filename of
   ``-'' is encountered.
   By default, filename headers are printed only if more than one file
   is given.
   By default, prints the first 10 lines (head -n 10).

   David MacKenzie <djm@ai.mit.edu> */

#include <stdio.h>
#include <getopt.h>
#include <ctype.h>
#include <sys/types.h>
#include "system.h"

#ifdef STDC_HEADERS
#include <errno.h>
#include <stdlib.h>
#define ISDIGIT(c) (isdigit ((unsigned char) (c)))
#else
#define ISDIGIT(c) (isascii (c) && isdigit (c))

extern int errno;
#endif

/* Number of lines/chars/blocks to head. */
#define DEFAULT_NUMBER 10

#define BLOCKSIZE 512

/* Size of atomic reads. */
#define BUFSIZE (BLOCKSIZE*8)

/* Masks for the operation mode.  If neither BYTES nor BLOCKS is set,
   head operates by lines. */
#define BYTES 1			/* Head in bytes. */
#define BLOCKS 2		/* Head in blocks. */
#define HEADERS 4		/* Write filename headers. */
#ifdef MSDOS
#define BINARY 32		/* Suppress crlf translation. */
#endif

/* When to print the filename banners. */
enum header_mode
{
  multiple_files, always, never
};

#ifdef MSDOS

#include <string.h>
#include <stdarg.h>
#include <io.h>

#include <gnulib.h>

extern  void main (int, char **);
extern  int head_file (char *, int, long);
extern  void write_header (char *);
extern  int head (char *, int, int, long);
extern  int head_bytes (char *, int, long);
extern  int head_lines (char *, int, long);
extern  void xwrite (int, char *, int);
extern  long atou (char *);
extern  char *basename (char *);
extern  void usage (void);

#else /* not MSDOS */

int head ();
int head_bytes ();
int head_file ();
int head_lines ();
long atou ();
void error ();
void usage ();
void write_header ();
void xwrite ();

#endif /* MSDOS */

/* The name this program was run with. */
char *program_name;

struct option long_options[] =
{
#ifdef MSDOS
  {"binary", 1, NULL, 'B'},
  {"copying", 0, NULL, 30},
  {"version", 0, NULL, 31},
#endif
  {"blocks", 1, NULL, 'b'},
  {"bytes", 1, NULL, 'c'},
  {"lines", 1, NULL, 'n'},
  {"quiet", 0, NULL, 'q'},
  {"silent", 0, NULL, 'q'},
  {"verbose", 0, NULL, 'v'},
  {NULL, 0, NULL, 0}
};

void
main (argc, argv)
     int argc;
     char **argv;
{
  enum header_mode header_mode = multiple_files;
  int errors = 0;		/* Exit status. */
  int mode = 0;			/* Flags. */
  long number = -1;		/* Number of items to print (-1 if undef.). */
  int c;			/* Option character. */
  int longind;			/* Index in `long_options' of option found. */

  program_name = argv[0];

  if (argc > 1 && argv[1][0] == '-' && ISDIGIT (argv[1][1]))
    {
      /* Old option syntax; a dash, one or more digits, and one or
	 more option letters.  Move past the number. */
      for (number = 0, ++argv[1]; ISDIGIT (*argv[1]); ++argv[1])
	number = number * 10 + *argv[1] - '0';
      /* Parse any appended option letters. */
      while (*argv[1])
	{
	  switch (*argv[1])
	    {
	    case 'b':
	      mode |= BLOCKS;
	      mode &= ~BYTES;
	      break;

	    case 'c':
	      mode |= BYTES;
	      mode &= ~BLOCKS;
	      break;

	    case 'l':
	      mode &= ~(BYTES | BLOCKS);
	      break;

	    case 'q':
	      header_mode = never;
	      break;

	    case 'v':
	      header_mode = always;
	      break;

	    default:
	      error (0, 0, "unrecognized option `-%c'", *argv[1]);
	      usage ();
	    }
	  ++argv[1];
	}
      /* Make the options we just parsed invisible to getopt. */
      argv[1] = argv[0];
      argv++;
      argc--;
    }

#ifdef MSDOS
  while ((c = getopt_long (argc, argv, "Bb:c:n:qv", long_options, &longind))
#else
  while ((c = getopt_long (argc, argv, "b:c:n:qv", long_options, &longind))
#endif
	 != EOF)
    {
      switch (c)
	{
#ifdef MSDOS
	case 30:
	  fprintf (stderr, COPYING);
	  exit (0);
	  break;

	case 31:
	  fprintf (stderr, VERSION);
	  exit (0);
	  break;

	case 'B':
	  mode |= BINARY;
	  break;
#endif

	case 'b':
	  mode |= BLOCKS;
	  mode &= ~BYTES;
	  number = atou (optarg);
	  if (number == -1)
	    error (1, 0, "invalid number `%s'", optarg);
	  break;

	case 'c':
	  mode |= BYTES;
	  mode &= ~BLOCKS;
	  number = atou (optarg);
	  if (number == -1)
	    error (1, 0, "invalid number `%s'", optarg);
	  break;

	case 'n':
	  mode &= ~(BYTES | BLOCKS);
	  number = atou (optarg);
	  if (number == -1)
	    error (1, 0, "invalid number `%s'", optarg);
	  break;

	case 'q':
	  header_mode = never;
	  break;

	case 'v':
	  header_mode = always;
	  break;

	default:
	  usage ();
	}
    }

  if (number == -1)
    number = DEFAULT_NUMBER;

  if (mode & BLOCKS)
    number *= BLOCKSIZE;

  if (header_mode == always
      || header_mode == multiple_files && optind < argc - 1)
    mode |= HEADERS;

  if (optind == argc)
    errors |= head_file ("-", mode, number);

  for (; optind < argc; ++optind)
    errors |= head_file (argv[optind], mode, number);

  exit (errors);
}

int
head_file (filename, mode, number)
     char *filename;
     int mode;
     long number;
{
  int fd;

  if (!strcmp (filename, "-"))
    {
      filename = "standard input";
      if (mode & HEADERS)
	write_header (filename);
      return head (filename, 0, mode, number);
    }
  else
    {
      fd = open (filename, O_RDONLY);
      if (fd == -1)
	{
	  error (0, errno, "%s", filename);
	  return 1;
	}
      else
	{
	  int errors;

	  if (mode & HEADERS)
	    write_header (filename);
	  errors = head (filename, fd, mode, number);
	  close (fd);
	  return errors;
	}
    }
}

void
write_header (filename)
     char *filename;
{
  static int first_file = 1;

  if (first_file)
    {
      xwrite (1, "==> ", 4);
      first_file = 0;
    }
  else
    xwrite (1, "\n==> ", 5);
  xwrite (1, filename, strlen (filename));
  xwrite (1, " <==\n", 5);
}

int
head (filename, fd, mode, number)
     char *filename;
     int fd;
     int mode;
     long number;
{
#ifdef MSDOS
  int errors;

  if (mode & BINARY)
    {
      setmode (fileno (stdout), O_BINARY);
      setmode (fd, O_BINARY);
    }

  if (mode & (BYTES | BLOCKS))
    errors = head_bytes (filename, fd, number);
  else
    errors = head_lines (filename, fd, number);

  if (mode & BINARY)
    setmode (fileno (stdout), O_TEXT);

  return errors;

#else /* not MSDOS */

  if (mode & (BYTES | BLOCKS))
    return head_bytes (filename, fd, number);
  else
    return head_lines (filename, fd, number);

#endif /* not MSDOS */
}

int
head_bytes (filename, fd, bytes_to_write)
     char *filename;
     int fd;
     long bytes_to_write;
{
  char buffer[BUFSIZE];
  int bytes_read;

  while (bytes_to_write)
    {
      bytes_read = read (fd, buffer, BUFSIZE);
      if (bytes_read == -1)
	{
	  error (0, errno, "%s", filename);
	  return 1;
	}
      if (bytes_read == 0)
	break;
#ifdef MSDOS
      if ((long) bytes_read > bytes_to_write)
	bytes_read = (int) bytes_to_write;
      xwrite (1, buffer, bytes_read);
      bytes_to_write -= (long) bytes_read;
#else /* not MSDOS */
      if (bytes_read > bytes_to_write)
	bytes_read = bytes_to_write;
      xwrite (1, buffer, bytes_read);
      bytes_to_write -= bytes_read;
#endif /* not MSDOS */
    }
  return 0;
}

int
head_lines (filename, fd, lines_to_write)
     char *filename;
     int fd;
     long lines_to_write;
{
  char buffer[BUFSIZE];
  int bytes_read;
  int bytes_to_write;

  while (lines_to_write)
    {
      bytes_read = read (fd, buffer, BUFSIZE);
      if (bytes_read == -1)
	{
	  error (0, errno, "%s", filename);
	  return 1;
	}
      if (bytes_read == 0)
	break;
      bytes_to_write = 0;
      while (bytes_to_write < bytes_read)
	if (buffer[bytes_to_write++] == '\n' && --lines_to_write == 0)
	  break;
      xwrite (1, buffer, bytes_to_write);
    }
  return 0;
}

/* Write plus error check. */

void
xwrite (fd, buffer, count)
     int fd;
     int count;
     char *buffer;
{
  fd = write (fd, buffer, count);
  if (fd != count)
    error (1, errno, "write error");
}

/* Convert `str', a string of ASCII digits, into an unsigned integer.
   Return -1 if `str' does not represent a valid unsigned integer. */

long
atou (str)
     char *str;
{
  long value;

  for (value = 0; ISDIGIT (*str); ++str)
    value = value * 10 + *str - '0';
  return *str ? -1L : value;
}

void
usage ()
{
#ifdef MSDOS
  fprintf (stderr, "\
Usage: %s [-b #] [-c #] [-n #] [-qvB] [+blocks #] [+bytes #]\n\
       [+lines #] [+quiet] [+silent] [+verbose] [+binary] [+version]\n\
       [+copying] [file...]\n\
\n\
       %s [-#bclqv] [file...]\n", program_name, program_name);
  exit (1);
#else
  fprintf (stderr, "\
Usage: %s [-b #] [-c #] [-n #] [-qv] [+blocks #] [+bytes #] [+lines #]\n\
       [+quiet] [+silent] [+verbose] [file...]\n\
\n\
       %s [-#bclqv] [file...]\n", program_name, program_name);
  exit (1);
#endif
}
