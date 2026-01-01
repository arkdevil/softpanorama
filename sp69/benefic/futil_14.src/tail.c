/* tail -- output last part of file(s)
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
  "$Header: e:/gnu/fileutil/RCS/tail.c 1.4.0.4 90/09/19 12:09:20 tho Exp $";

static char Program_Id[] = "tail";
static char RCS_Revision[] = "$Revision: 1.4.0.4 $";

#define VERSION \
  "GNU %s, Version %.*s (compiled %s %s for MS-DOS)\n", Program_Id, \
  (sizeof RCS_Revision - 14), (RCS_Revision + 11), __DATE__, __TIME__

#define COPYING \
  "This is free software, distributed under the terms of the\n" \
  "GNU General Public License.  For details, see the file COPYING.\n"
#endif /* MSDOS */

/* Can display any amount of data, unlike the Unix version, which uses
   a fixed size buffer and therefore can only deliver a limited number
   of lines.

   Usage: tail [-b [+]#] [-c [+]#] [-n [+]#] [-fqv] [+blocks [+]#]
          [+bytes [+]#] [+lines [+]#] [+follow] [+quiet] [+silent]
          [+verbose] [file...]

          tail [+/-#bcflqv] [file...]

   Options:
   -b, +blocks #	Tail by # 512-byte blocks.
   -c, +bytes #		Tail by # bytes.
   -f, +follow		Loop forever trying to read more characters at the
			end of the file, on the assumption that the file
			is growing.  Ignored if reading from a pipe.
			Cannot be used if more than one file is given.
   -l, -n, +lines #	Tail by # lines.
   -q, +quiet, +silent	Never print filename headers.
   -v, +verbose		Always print filename headers.

   If a number (#) starts with a `+', begin printing with the #th item
   from the start of each file, instead of from the end.

   Reads from standard input if no files are given or when a filename of
   ``-'' is encountered.
   By default, filename headers are printed only more than one file
   is given.
   By default, prints the last 10 lines (tail -n 10).

   Started by Paul Rubin <phr@ai.mit.edu>
   Finished by David MacKenzie <djm@ai.mit.edu> */

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
char *malloc ();
void free ();

extern int errno;
#endif

#ifndef _POSIX_SOURCE
long lseek();
#endif

/* Number of items to tail. */
#define DEFAULT_NUMBER 10

/* The number of bytes in a block (-b option). */
#define BLOCKSIZE 512

/* Size of atomic reads. */
#define BUFSIZE (BLOCKSIZE * 8)

/* Masks for the operation mode.  If neither BYTES nor BLOCKS is set,
   tail operates by lines. */
#define BYTES 1			/* Tail by characters. */
#define BLOCKS 2		/* Tail by blocks. */
#define FOREVER 4		/* Read from end of file forever. */
#define START 8			/* Count from start of file instead of end. */
#define HEADERS 16		/* Print filename headers. */
#ifdef MSDOS
#define BINARY 32		/* Suppress crlf translation. */
#endif

/* When to print the filename banners. */
enum header_mode
{
  multiple_files, always, never
};

#ifdef MSDOS

#include <io.h>
#include <string.h>

extern  void main (int, char **);
extern  void write_header (char *);
extern  int tail (char *, int, int, long);
extern  int tail_file (char *, int, long);
extern  int tail_bytes (char *, int, int, long);
extern  int tail_lines (char *, int, int, long);
extern  int file_lines (char *, int, long, long);
extern  int pipe_lines (char *, int, long);
extern  int pipe_bytes (char *, int, long);
extern  int start_bytes (char *, int, long);
extern  int start_lines (char *, int, long);
extern  void dump_remainder (char *, int, int);
extern  void xwrite (int, char *, int);
extern  char *xmalloc (int);
extern  long atou (char *);
extern  char *basename (char *);
extern  void error (int status, int errnum, char *message, ...);
extern  void usage (void);

#else  /* not MSDOS */

char *xmalloc ();
int file_lines ();
int pipe_bytes ();
int pipe_lines ();
int start_bytes ();
int start_lines ();
int tail ();
int tail_bytes ();
int tail_file ();
int tail_lines ();
long atou();
void dump_remainder ();
void error ();
void usage ();
void write_header ();
void xwrite ();

#endif /* not MSDOS */

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
  {"follow", 0, NULL, 'f'},
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
  /* In START mode, the number of items to skip before printing; otherwise,
     the number of items at the end of the file to print.  Initially, -1
     means the value has not been set. */
  long number = -1;
  int c;			/* Option character. */
  int longind;			/* Index in `long_options' of option found. */

  program_name = argv[0];

  if (argc > 1
      && ((argv[1][0] == '-' && ISDIGIT (argv[1][1]))
	  || (argv[1][0] == '+' && (ISDIGIT (argv[1][1]) || argv[1][1] == 0))))
    {
      /* Old option syntax: a dash or plus, one or more digits (zero digits
	 are acceptable with a plus), and one or more option letters. */
      if (argv[1][0] == '+')
	mode |= START;
      if (argv[1][1] != 0)
	{
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

		case 'f':
		  mode |= FOREVER;
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
	}
      /* Make the options we just parsed invisible to getopt. */
      argv[1] = argv[0];
      argv++;
      argc--;
    }

#ifdef MSDOS
  while ((c = getopt_long (argc, argv, "b:c:n:fqvB", long_options, &longind))
#else
  while ((c = getopt_long (argc, argv, "b:c:n:fqv", long_options, &longind))
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
	  if (*optarg == '+')
	    {
	      mode |= START;
	      ++optarg;
	    }
	  else if (*optarg == '-')
	    ++optarg;
	  number = atou (optarg);
	  if (number == -1)
	    error (1, 0, "invalid number `%s'", optarg);
	  break;

	case 'c':
	  mode |= BYTES;
	  mode &= ~BLOCKS;
	  if (*optarg == '+')
	    {
	      mode |= START;
	      ++optarg;
	    }
	  else if (*optarg == '-')
	    ++optarg;
	  number = atou (optarg);
	  if (number == -1)
	    error (1, 0, "invalid number `%s'", optarg);
	  break;

	case 'f':
#ifndef MSDOS
  	  mode |= FOREVER;
#endif /* not MSDOS */
	  break;

	case 'n':
	  mode &= ~(BYTES | BLOCKS);
	  if (*optarg == '+')
	    {
	      mode |= START;
	      ++optarg;
	    }
	  else if (*optarg == '-')
	    ++optarg;
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

  /* To start printing with item `number' from the start of the file, skip
     `number' - 1 items.  `tail +0' is actually meaningless, but for Unix
     compatibility it's treated the same as `tail +1'. */
  if (mode & START)
    {
      if (number)
	--number;
    }

  if (mode & BLOCKS)
    number *= BLOCKSIZE;

  if (optind < argc - 1 && (mode & FOREVER))
    error (1, 0, "cannot follow the ends of multiple files");

  if (header_mode == always
      || header_mode == multiple_files && optind < argc - 1)
    mode |= HEADERS;

  if (optind == argc)
    errors |= tail_file ("-", mode, number);

  for (; optind < argc; ++optind)
    errors |= tail_file (argv[optind], mode, number);

  exit (errors);
}

/* Display the last `number' units of file `filename', controlled by
   the flags in `mode'.  "-" for `filename' means the standard input.
   Return 0 if successful, 1 if an error occurred. */

int
tail_file (filename, mode, number)
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
      return tail (filename, 0, mode, number);
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
	  errors = tail (filename, fd, mode, number);
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

/* Display the last `number' units of file `filename', open for reading
   in `fd', controlled by `mode'.
   Return 0 if successful, 1 if an error occurred. */

int
tail (filename, fd, mode, number)
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
    errors = tail_bytes (filename, fd, mode, number);
  else
    errors = tail_lines (filename, fd, mode, number);

  if (mode & BINARY)
    setmode (fileno (stdout), O_TEXT);

  return errors;

#else /* not MSDOS */

  if (mode & (BYTES | BLOCKS))
    return tail_bytes (filename, fd, mode, number);
  else
    return tail_lines (filename, fd, mode, number);

#endif /* not MSDOS */
}

/* Display the last part of file `filename', open for reading in`fd',
   using `number' characters, controlled by `mode'.
   Return 0 if successful, 1 if an error occurred. */

int
tail_bytes (filename, fd, mode, number)
     char *filename;
     int fd;
     int mode;
     long number;
{
  struct stat stats;

  /* Use fstat instead of checking for errno == ESPIPE because
     lseek doesn't work on some special files but doesn't return an
     error, either. */
  if (fstat (fd, &stats))
    {
      error (0, errno, "%s", filename);
      return 1;
    }

  if (mode & START)
    {
      if ((stats.st_mode & S_IFMT) == S_IFREG)
	lseek (fd, number, L_SET);
      else if (start_bytes (filename, fd, number))
	return 1;
      dump_remainder (filename, fd, mode);
    }
  else
    {
      if ((stats.st_mode & S_IFMT) == S_IFREG)
	{
	  if (lseek (fd, 0L, L_XTND) <= number)
	    /* The file is shorter than we want, or just the right size, so
	       print the whole file. */
	    lseek (fd, 0L, L_SET);
	  else
	    /* The file is longer than we want, so go back. */
	    lseek (fd, -number, L_XTND);
	  dump_remainder (filename, fd, mode);
	}
      else
	return pipe_bytes (filename, fd, number);
    }
  return 0;
}

/* Display the last part of file `filename', open for reading on `fd',
   using `number' lines, controlled by `mode'.
   Return 0 if successful, 1 if an error occurred. */

int
tail_lines (filename, fd, mode, number)
     char *filename;
     int fd;
     int mode;
     long number;
{
  struct stat stats;
  long length;

  if (fstat (fd, &stats))
    {
      error (0, errno, "%s", filename);
      return 1;
    }

  if (mode & START)
    {
      if (start_lines (filename, fd, number))
	return 1;
      dump_remainder (filename, fd, mode);
    }
  else
    {
      if ((stats.st_mode & S_IFMT) == S_IFREG)
	{
	  length = lseek (fd, 0L, L_XTND);
	  if (length != 0 && file_lines (filename, fd, number, length))
	    return 1;
	  dump_remainder (filename, fd, mode);
	}
      else
	return pipe_lines (filename, fd, number);
    }
  return 0;
}

/* Print the last `number' lines from the end of file `fd'.
   Go backward through the file, reading `BUFSIZE' bytes at a time (except
   probably the first), until we hit the start of the file or have
   read `number' newlines.
   `pos' starts out as the length of the file (the offset of the last
   byte of the file + 1).
   Return 0 if successful, 1 if an error occurred. */

int
file_lines (filename, fd, number, pos)
     char *filename;
     int fd;
     long number;
     long pos;
{
  char buffer[BUFSIZE];
  int bytes_read;
  int i;			/* Index into `buffer' for scanning. */

  if (number == 0)
    return 0;

  /* Set `bytes_read' to the size of the last, probably partial, buffer;
     0 < `bytes_read' <= `BUFSIZE'. */
#ifdef MSDOS				/* shut up the compiler */
  bytes_read = (int) (pos % (long) BUFSIZE);
#else
  bytes_read = pos % BUFSIZE;
#endif
  if (bytes_read == 0)
    bytes_read = BUFSIZE;
  /* Make `pos' a multiple of `BUFSIZE' (0 if the file is short), so that all
     reads will be on block boundaries, which might increase efficiency. */
  pos -= bytes_read;
  lseek (fd, pos, L_SET);
  bytes_read = read (fd, buffer, bytes_read);
  if (bytes_read == -1)
    {
      error (0, errno, "%s", filename);
      return 1;
    }

  /* Count the incomplete line on files that don't end with a newline. */
  if (bytes_read && buffer[bytes_read - 1] != '\n')
    --number;

  do
    {
      /* Scan backward, counting the newlines in this bufferfull. */
      for (i = bytes_read - 1; i >= 0; i--)
	{
	  /* Have we counted the requested number of newlines yet? */
	  if (buffer[i] == '\n' && number-- == 0)
	    {
	      /* If this newline wasn't the last character in the buffer,
	         print the text after it. */
	      if (i != bytes_read - 1)
		xwrite (1, &buffer[i + 1], bytes_read - (i + 1));
	      return 0;
	    }
	}
      /* Not enough newlines in that bufferfull. */
      if (pos == 0)
	{
	  /* Not enough lines in the file; print the entire file. */
	  lseek (fd, 0L, L_SET);
	  return 0;
	}
      pos -= BUFSIZE;
      lseek (fd, pos, L_SET);
    }
  while ((bytes_read = read (fd, buffer, BUFSIZE)) > 0);
  if (bytes_read == -1)
    {
      error (0, errno, "%s", filename);
      return 1;
    }
  return 0;
}

/* Print the last `number' lines from the end of the standard input,
   open for reading as pipe `fd'.
   Buffer the text as a linked list of LBUFFERs, adding them as needed.
   Return 0 if successful, 1 if an error occured. */

int
pipe_lines (filename, fd, number)
     char *filename;
     int fd;
     long number;
{
  struct linebuffer
  {
    int nbytes, nlines;
    char buffer[BUFSIZE];
    struct linebuffer *next;
  };
  typedef struct linebuffer LBUFFER;
  LBUFFER *first, *last, *tmp;
  int i;			/* Index into buffers. */
  long total_lines = 0;		/* Total number of newlines in all buffers. */
  int errors = 0;

  first = last = (LBUFFER *) xmalloc (sizeof (LBUFFER));
  first->nbytes = first->nlines = 0;
  tmp = (LBUFFER *) xmalloc (sizeof (LBUFFER));

  /* Input is always read into a fresh buffer. */
  while ((tmp->nbytes = read (fd, tmp->buffer, BUFSIZE)) > 0)
    {
      tmp->nlines = 0;
      tmp->next = NULL;

      /* Count the number of newlines just read. */
      for (i = 0; i < tmp->nbytes; i++)
	if (tmp->buffer[i] == '\n')
	  ++tmp->nlines;
      total_lines += tmp->nlines;

      /* If there is enough room in the last buffer read, just append the new
         one to it.  This is because when reading from a pipe, `nbytes' can
         often be very small. */
      if (tmp->nbytes + last->nbytes < BUFSIZE)
	{
	  bcopy (tmp->buffer, &last->buffer[last->nbytes], tmp->nbytes);
	  last->nbytes += tmp->nbytes;
	  last->nlines += tmp->nlines;
	}
      else
	{
	  /* If there's not enough room, link the new buffer onto the end of
	     the list, then either free up the oldest buffer for the next
	     read if that would leave enough lines, or else malloc a new one.
	     Some compaction mechanism is possible but probably not
	     worthwhile. */
	  last = last->next = tmp;
	  if (total_lines - first->nlines > number)
	    {
	      tmp = first;
	      total_lines -= first->nlines;
	      first = first->next;
	    }
	  else
	    tmp = (LBUFFER *) xmalloc (sizeof (LBUFFER));
	}
    }
  if (tmp->nbytes == -1)
    {
      error (0, errno, "%s", filename);
      errors = 1;
      free ((char *) tmp);
      goto free_lbuffers;
    }

  free ((char *) tmp);

  /* This prevents a core dump when the pipe contains no newlines. */
  if (number == 0)
    goto free_lbuffers;

  /* Count the incomplete line on files that don't end with a newline. */
  if (last->buffer[last->nbytes - 1] != '\n')
    {
      ++last->nlines;
      ++total_lines;
    }

  /* Run through the list, printing lines.  First, skip over unneeded
     buffers. */
  for (tmp = first; total_lines - tmp->nlines > number; tmp = tmp->next)
    total_lines -= tmp->nlines;

  /* Find the correct beginning, then print the rest of the file. */
  if (total_lines > number)
    {
      char *cp;

      /* Skip `total_lines' - `number' newlines.  We made sure that
         `total_lines' - `number' <= `tmp->nlines'. */
      cp = tmp->buffer;
#ifdef MSDOS				/* shut up the compiler */
      for (i = (int) (total_lines - number); i; --i)
#else
      for (i = total_lines - number; i; --i)
#endif
	while (*cp++ != '\n')
	  /* Do nothing. */ ;
      i = cp - tmp->buffer;
    }
  else
    i = 0;
  xwrite (1, &tmp->buffer[i], tmp->nbytes - i);

  for (tmp = tmp->next; tmp; tmp = tmp->next)
    xwrite (1, tmp->buffer, tmp->nbytes);

free_lbuffers:
  while (first)
    {
      tmp = first->next;
      free ((char *) first);
      first = tmp;
    }
  return errors;
}

/* Print the last `number' characters from the end of pipe `fd'.
   This is a stripped down version of pipe_lines.
   Return 0 if successful, 1 if an error occurred. */

int
pipe_bytes (filename, fd, number)
     char *filename;
     int fd;
     long number;
{
  struct charbuffer
  {
    int nbytes;
    char buffer[BUFSIZE];
    struct charbuffer *next;
  };
  typedef struct charbuffer CBUFFER;
  CBUFFER *first, *last, *tmp;
  int i;			/* Index into buffers. */
#ifdef MSDOS
  long total_bytes = 0;		/* Total characters in all buffers. */
#else
  int total_bytes = 0;		/* Total characters in all buffers. */
#endif
  int errors = 0;

  first = last = (CBUFFER *) xmalloc (sizeof (CBUFFER));
  first->nbytes = 0;
  tmp = (CBUFFER *) xmalloc (sizeof (CBUFFER));

  /* Input is always read into a fresh buffer. */
  while ((tmp->nbytes = read (fd, tmp->buffer, BUFSIZE)) > 0)
    {
      tmp->next = NULL;

      total_bytes += tmp->nbytes;
      /* If there is enough room in the last buffer read, just append the new
         one to it.  This is because when reading from a pipe, `nbytes' can
         often be very small. */
      if (tmp->nbytes + last->nbytes < BUFSIZE)
	{
	  bcopy (tmp->buffer, &last->buffer[last->nbytes], tmp->nbytes);
	  last->nbytes += tmp->nbytes;
	}
      else
	{
	  /* If there's not enough room, link the new buffer onto the end of
	     the list, then either free up the oldest buffer for the next
	     read if that would leave enough characters, or else malloc a new
	     one.  Some compaction mechanism is possible but probably not
	     worthwhile. */
	  last = last->next = tmp;
	  if (total_bytes - first->nbytes > number)
	    {
	      tmp = first;
	      total_bytes -= first->nbytes;
	      first = first->next;
	    }
	  else
	    {
	      tmp = (CBUFFER *) xmalloc (sizeof (CBUFFER));
	    }
	}
    }
  if (tmp->nbytes == -1)
    {
      error (0, errno, "%s", filename);
      errors = 1;
      free ((char *) tmp);
      goto free_cbuffers;
    }

  free ((char *) tmp);

  /* Run through the list, printing characters.  First, skip over unneeded
     buffers. */
  for (tmp = first; total_bytes - tmp->nbytes > number; tmp = tmp->next)
    total_bytes -= tmp->nbytes;

  /* Find the correct beginning, then print the rest of the file.
     We made sure that `total_bytes' - `number' <= `tmp->nbytes'. */
  if (total_bytes > number)
#ifdef MSDOS				/* shut up the compiler */
    i = (int) (total_bytes - number);
#else
    i = total_bytes - number;
#endif
  else
    i = 0;
  xwrite (1, &tmp->buffer[i], tmp->nbytes - i);

  for (tmp = tmp->next; tmp; tmp = tmp->next)
    xwrite (1, tmp->buffer, tmp->nbytes);

free_cbuffers:
  while (first)
    {
      tmp = first->next;
      free ((char *) first);
      first = tmp;
    }
  return errors;
}

/* Skip `number' characters from the start of pipe `fd', and print
   any extra characters that were read beyond that.
   Return 1 on error, 0 if ok.  */

int
start_bytes (filename, fd, number)
     char *filename;
     int fd;
     long number;
{
  char buffer[BUFSIZE];
  int bytes_read = 0;

  while (number > 0 && (bytes_read = read (fd, buffer, BUFSIZE)) > 0)
    number -= bytes_read;
  if (bytes_read == -1)
    {
      error (0, errno, "%s", filename);
      return 1;
    }
  else if (number < 0)
#ifdef MSDOS				/* |number| < 64k ??? */
    xwrite (1, &buffer[bytes_read + number], (unsigned int) (-number));
#else
    xwrite (1, &buffer[bytes_read + number], -number);
#endif
  return 0;
}

/* Skip `number' lines at the start of file or pipe `fd', and print
   any extra characters that were read beyond that.
   Return 1 on error, 0 if ok.  */

int
start_lines (filename, fd, number)
     char *filename;
     int fd;
     long number;
{
  char buffer[BUFSIZE];
  int bytes_read = 0;
  int bytes_to_skip = 0;

  while (number && (bytes_read = read (fd, buffer, BUFSIZE)) > 0)
    {
      bytes_to_skip = 0;
      while (bytes_to_skip < bytes_read)
	if (buffer[bytes_to_skip++] == '\n' && --number == 0)
	  break;
    }
  if (bytes_read == -1)
    {
      error (0, errno, "%s", filename);
      return 1;
    }
  else if (bytes_to_skip < bytes_read)
    xwrite (1, &buffer[bytes_to_skip], bytes_read - bytes_to_skip);
  return 0;
}

/* Display file `filename' from the current position in `fd'
   to the end.  If selected in `mode', keep reading from the
   end of the file until killed. */

void
dump_remainder (filename, fd, mode)
     char *filename;
     int fd;
     int mode;
{
  char buffer[BUFSIZE];
  int bytes_read;

output:
  while ((bytes_read = read (fd, buffer, BUFSIZE)) > 0)
    xwrite (1, buffer, bytes_read);
  if (bytes_read == -1)
    error (1, errno, "%s", filename);
#ifndef MSDOS
  if (mode & FOREVER)
    {
      sleep (1);
      goto output;
    }
#endif
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

/* Allocate `size' bytes of memory dynamically, with error check. */

char *
xmalloc (size)
     int size;
{
  char *p;

  p = malloc ((unsigned) size);
  if (p == NULL)
    error (1, 0, "virtual memory exhausted");
  return p;
}

/* Convert `str', a string of ASCII digits, into an unsigned integer.
   Return -1 if `str' does not represent a valid unsigned integer. */

long
atou (str)
     char *str;
{
  unsigned long value;

  for (value = 0; ISDIGIT (*str); ++str)
    value = value * 10 + *str - '0';
  return *str ? -1L : value;
}

void
usage ()
{
#ifdef MSDOS
  fprintf (stderr, "\
Usage: %s [-b [+]#] [-c [+]#] [-n [+]#] [-fqvB] [+blocks [+]#]\n\
       [+bytes [+]#] [+lines [+]#] [+follow] [+quiet] [+silent]\n\
       [+verbose] [+binary] [+copying] [+version] [file...]\n\
\n\
       %s [+/-#bcflqv] [file...]\n", program_name, program_name);
  exit (1);
#else
  fprintf (stderr, "\
Usage: %s [-b [+]#] [-c [+]#] [-n [+]#] [-fqv] [+blocks [+]#]\n\
       [+bytes [+]#] [+lines [+]#] [+follow] [+quiet] [+silent]\n\
       [+verbose] [file...]\n\
\n\
       %s [+/-#bcflqv] [file...]\n", program_name, program_name);
  exit (1);
#endif
}
