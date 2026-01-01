/* cat -- concatenate files and print on the standard output.
   Copyright (C) 1988, 1990 Free Software Foundation, Inc.

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
  "$Header: e:/gnu/fileutil/RCS/cat.c 1.4.0.2 90/09/19 11:17:40 tho Exp $";

static char Program_Id[] = "cat";
static char RCS_Revision[] = "$Revision: 1.4.0.2 $";

#define VERSION \
  "GNU %s, Version %.*s (compiled %s %s for MS-DOS)\n", Program_Id, \
  (sizeof RCS_Revision - 14), (RCS_Revision + 11), __DATE__, __TIME__

#define COPYING \
  "This is free software, distributed under the terms of the\n" \
  "GNU General Public License.  For details, see the file COPYING.\n"
#endif /* MSDOS */

/* Differences from the Unix cat:
   * Always unbuffered, -u is ignored.
   * 100 times faster with -v -u.
   * 20 times faster with -v.

   By tege@sics.se, Torbjorn Granlund, advised by rms, Richard Stallman. */

#include <stdio.h>
#include <getopt.h>
#include <errno.h>
#include <sys/types.h>
#ifndef _POSIX_SOURCE
#ifndef MSDOS
#include <sys/ioctl.h>
#endif
#endif
#include "system.h"

#ifdef STDC_HEADERS
#include <stdlib.h>
#else
char *malloc ();
void free ();

extern int errno;
#endif

#ifdef MSDOS

#include <string.h>
#include <fcntl.h>
#include <malloc.h>
#include <io.h>

extern void main (int, char **);
extern void error (int status, int errnum, char *message, ...);
extern void usage (char *);
extern void simple_cat (unsigned char *, int);
extern void cat (unsigned char *, int, unsigned char *,\
		 int, int, int, int, int, int, int);
extern void next_line_num (void);
extern char *copystring (char *, char *);

#else /* not MSDOS */

#define max(h,i) ((h) > (i) ? (h) : (i))

char *copystring ();
void cat ();
void error ();
void next_line_num ();
void simple_cat ();

#endif /* not MSDOS */

typedef unsigned char uchar;

/* Name under which this program was invoked.  */
char *program_name;

/* Name of input file.  May be "-".  */
char *infile;

/* Descriptor on which input file is open.  */
int input_desc;

/* Descriptor on which output file is open.  Always is 1.  */
int output_desc;

/* Buffer for line numbers.  */
char line_buf[13] =
{' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '0', '\t', '\0'};

/* Position in `line_buf' where printing starts.  This will not change
   unless the number of lines are more than 999999.  */
char *line_num_print = line_buf + 5;

/* Position of the first digit in `line_buf'.  */
char *line_num_start = line_buf + 10;

/* Position of the last digit in `line_buf'.  */
char *line_num_end = line_buf + 10;

/* Preserves the `cat' function's local `newlines' between invocations.  */
int newlines2 = 0;

/* Count of non-fatal error conditions.  */
int exit_stat = 0;

void
usage (reason)
     char *reason;
{
  if (reason != NULL)
    fprintf (stderr, "%s: %s\n", program_name, reason);

#ifdef MSDOS
  fprintf (stderr, "\
Usage: %s [-benstuvABET] [+number] [+number-nonblank] [+squeeze-blank]\n\
       [+show-nonprinting] [+show-ends] [+show-tabs] [+show-all] [+binary]\n\
       [+copying] [+version] [file...]\n", program_name);
#else /* not MSDOS */
  fprintf (stderr, "\
Usage: %s [-benstuvAET] [+number] [+number-nonblank] [+squeeze-blank]\n\
       [+show-nonprinting] [+show-ends] [+show-tabs] [+show-all] [file...]\n",
	   program_name);
#endif /* not MSDOS */

  exit (2);
}


void
main (argc, argv)
     int argc;
     char *argv[];
{
  /* Optimal size of i/o operations of output.  */
  int outsize;

  /* Optimal size of i/o operations of input.  */
  int insize;

  /* Pointer to the input buffer.  */
  uchar *inbuf;

  /* Pointer to the output buffer.  */
  uchar *outbuf;

  int c;

  /* Index in argv to processed argument.  */
  int argind;

  /* Device number of the output (file or whatever).  */
  int out_dev;

  /* I-node number of the output.  */
  int out_ino;

  /* Nonzero if the output file should not be the same as any input file. */
  int check_redirection = 1;

  struct stat stat_buf;

  /* Variables that are set according to the specified options.  */
  int numbers = 0;
  int numbers_at_empty_lines = 1;
  int squeeze_empty_lines = 0;
  int mark_line_ends = 0;
  int quote = 0;
  int output_tabs = 1;
  int options = 0;
  int longind;
#ifdef MSDOS
  int binary = 0;
#endif

  static struct option long_options[] =
  {
#ifdef MSDOS
    {"binary", 0, NULL, 'B'},
    {"copying", 0, NULL, 30},
    {"version", 0, NULL, 31},
#endif
    {"number-nonblank", 0, NULL, 'b'},
    {"number", 0, NULL, 'n'},
    {"squeeze-blank", 0, NULL, 's'},
    {"show-nonprinting", 0, NULL, 'v'},
    {"show-ends", 0, NULL, 'E'},
    {"show-tabs", 0, NULL, 'T'},
    {"show-all", 0, NULL, 'A'},
    {NULL, 0, NULL, 0}
  };

  program_name = argv[0];

  /* Parse command line options.  */

#ifdef MSDOS
  while ((c = getopt_long (argc, argv, "benstuvABET", long_options, &longind))
#else
  while ((c = getopt_long (argc, argv, "benstuvAET", long_options, &longind))
#endif
	 != EOF)
    {
      options++;
      switch (c)
	{
	case 'b':
	  numbers = 1;
	  numbers_at_empty_lines = 0;
	  break;

	case 'e':
	  mark_line_ends = 1;
	  quote = 1;
	  break;

	case 'n':
	  numbers = 1;
	  break;

	case 's':
	  squeeze_empty_lines = 1;
	  break;

	case 't':
	  output_tabs = 0;
	  quote = 1;
	  break;

	case 'u':
	  /* We provide the -u feature unconditionally.  */
	  options--;
	  break;

	case 'v':
	  quote = 1;
	  break;

	case 'A':
	  quote = 1;
	  mark_line_ends = 1;
	  output_tabs = 0;
	  break;

#ifdef MSDOS
	case 'B':
	  binary++;
	  options--;	/* stdout will be binary iff no other option!  */
	  break;

	case 30:
	  fprintf (stderr, COPYING);
	  exit (0);
	  break;

	case 31:
	  fprintf (stderr, VERSION);
	  exit (0);
	  break;
#endif

	case 'E':
	  mark_line_ends = 1;
	  break;

	case 'T':
	  output_tabs = 0;
	  break;

	default:
	  usage ((char *) 0);
	}
    }

  output_desc = fileno (stdout);

  /* Get device, i-node number, and optimal blocksize of output.  */

  if (fstat (output_desc, &stat_buf) < 0)
    error (1, errno, "standard output");

  outsize = ST_BLKSIZE (stat_buf);
  switch (stat_buf.st_mode & S_IFMT)
    {
      /* Input file can be output file for non-regular files.
	 fstat on pipes returns S_IFSOCK on some systems, S_IFIFO
	 on others, so the checking should not be done for those types,
	 and to allow things like cat < /dev/tty > /dev/tty, checking
	 is not done for device files either. */
    case S_IFREG:
      out_dev = stat_buf.st_dev;
      out_ino = stat_buf.st_ino;
      break;
    default:
      check_redirection = 0;
      break;
    }

  /* Check if any of the input files are the same as the output file.  */

  /* Main loop.  */

  infile = "-";
  argind = optind;

  do
    {
      if (argind < argc)
	infile = argv[argind];

      if (infile[0] == '-' && infile[1] == 0)
	input_desc = fileno (stdin);
      else
	{
	  input_desc = open (infile, O_RDONLY);
	  if (input_desc < 0)
	    {
	      error (0, errno, "%s", infile);
	      exit_stat = 1;
	      continue;
	    }
	}

#ifdef MSDOS
      if (binary)
	{
	  setmode (input_desc, O_BINARY);

	  /* We will not set the output to binary mode if we have
	     another (verbose) option active.  */
	  if (options == 0)
	    setmode (output_desc, O_BINARY);
	}
#endif

      if (fstat (input_desc, &stat_buf) < 0)
	{
	  error (0, errno, "%s", infile);
	  close (input_desc);
	  exit_stat = 1;
	  continue;
	}
      insize = ST_BLKSIZE (stat_buf);

      /* Compare the device and i-node numbers of this input file with
	 the corresponding values of the (output file associated with)
	 stdout, and skip this input file if they coincide.  Input
	 files cannot be redirected to themselves.  */

      if (check_redirection
	  && stat_buf.st_dev == out_dev && stat_buf.st_ino == out_ino)
	{
	  error (0, 0, "%s: input file is output file", infile);
	  exit_stat = 1;
	  continue;
	}

      /* Select which version of `cat' to use. If any options (more than -u)
	 were specified, use `cat', otherwise use `simple_cat'.  */

      if (options == 0)
	{
	  insize = max (insize, outsize);
	  inbuf = (uchar *) malloc (insize);
	  if (inbuf == NULL)
	    error (1, 0, "virtual memory exhausted");

	  simple_cat (inbuf, insize);
	}
      else
	{
#ifdef MSDOS			/* the user wants it slow, he can get it! */
	  insize = outsize = 0x1000;
#endif
	  inbuf = (uchar *) malloc (insize + 1);
	  if (inbuf == NULL)
	    error (1, 0, "virtual memory exhausted");

	  /* Why are (OUTSIZE  - 1 + INSIZE * 4 + 13) bytes allocated for
	     the output buffer?

	     A test whether output needs to be written is done when the input
	     buffer empties or when a newline appears in the input.  After
	     output is written, at most (OUTSIZE - 1) bytes will remain in the
	     buffer.  Now INSIZE bytes of input is read.  Each input character
	     may grow by a factor of 4 (by the prepending of M-^).  If all
	     characters do, and no newlines appear in this block of input, we
	     will have at most (OUTSIZE - 1 + INSIZE) bytes in the buffer.  If
	     the last character in the preceeding block of input was a
	     newline, a line number may be written (according to the given
	     options) as the first thing in the output buffer. (Done after the
	     new input is read, but before processing of the input begins.)  A
	     line number requires seldom more than 13 positions.  */

	  outbuf = (uchar *) malloc (outsize - 1 + insize * 4 + 13);
	  if (outbuf == NULL)
	    error (1, 0, "virtual memory exhausted");

	  cat (inbuf, insize, outbuf, outsize, quote,
	       output_tabs, numbers, numbers_at_empty_lines, mark_line_ends,
	       squeeze_empty_lines);

	  free (outbuf);
	}

      free (inbuf);
      if (input_desc)
	close (input_desc);
    }
  while (++argind < argc);

  exit (exit_stat);
}

/* Plain cat.  Copies the file behind `input_desc' to the file behind
   `output_desc'.  */

void
simple_cat (buf, bufsize)
     /* Pointer to the buffer, used by reads and writes.  */
     uchar *buf;

     /* Number of characters preferably read or written by each read and write
        call.  */
     int bufsize;
{
  /* Actual number of characters read, and therefore written.  */
  int n_read;

  /* Loop until the end of the file.  */

  for (;;)
    {
      /* Read a block of input.  */

      n_read = read (input_desc, buf, bufsize);
      if (n_read < 0)
	{
	  error (0, errno, "%s", infile);
	  exit_stat = 1;
	  return;
	}

      /* End of this file?  */

      if (n_read == 0)
	break;

      /* Write this block out.  */

      if (write (output_desc, buf, n_read) != n_read)
	error (1, errno, "write error");
    }
}

/* Cat the file behind INPUT_DESC to the file behind OUTPUT_DESC.
   Called if any option more than -u was specified.

   A newline character is always put at the end of the buffer, to make
   an explicit test for buffer end unnecessary.  */

void
cat (inbuf, insize, outbuf, outsize, quote,
     output_tabs, numbers, numbers_at_empty_lines,
     mark_line_ends, squeeze_empty_lines)

     /* Pointer to the beginning of the input buffer.  */
     uchar *inbuf;

     /* Number of characters read in each read call.  */
     int insize;

     /* Pointer to the beginning of the output buffer.  */
     uchar *outbuf;

     /* Number of characters written by each write call.  */
     int outsize;

     /* Variables that have values according to the specified options.  */
     int quote;
     int output_tabs;
     int numbers;
     int numbers_at_empty_lines;
     int mark_line_ends;
     int squeeze_empty_lines;
{
  /* Last character read from the input buffer.  */
  uchar ch;

  /* Pointer to the next character in the input buffer.  */
  uchar *bpin;

  /* Pointer to the first non-valid byte in the input buffer, i.e. the
     current end of the buffer.  */
  uchar *eob;

  /* Pointer to the position where the next character shall be written.  */
  uchar *bpout;

  /* Number of characters read by the last read call.  */
  int n_read;

  /* Determines how many consequtive newlines there have been in the
     input.  0 newlines makes NEWLINES -1, 1 newline makes NEWLINES 1,
     etc.  Initially 0 to indicate that we are at the beginning of a
     new line.  The "state" of the procedure is determined by
     NEWLINES.  */
  int newlines = newlines2;

#ifdef FIONREAD
  /* If nonzero, use the FIONREAD ioctl, as an optimization.
     (On Ultrix, it is not supported on NFS filesystems.)  */
  int use_fionread = 1;
#endif

  /* The inbuf pointers are initialized so that BPIN > EOB, and thereby input
     is read immediately.  */

  eob = inbuf;
  bpin = eob + 1;

  bpout = outbuf;

  for (;;)
    {
      do
	{
	  /* Write if there are at least OUTSIZE bytes in OUTBUF.  */

	  if (bpout - outbuf >= outsize)
	    {
	      uchar *wp = outbuf;
	      do
		{
		  if (write (output_desc, wp, outsize) != outsize)
		    error (1, errno, "write error");
		  wp += outsize;
		}
	      while (bpout - wp >= outsize);

	      /* Move the remaining bytes to the beginning of the
		 buffer.  */

	      bcopy (wp, outbuf, bpout - wp);
	      bpout = outbuf + (bpout - wp);
	    }

	  /* Is INBUF empty?  */

	  if (bpin > eob)
	    {
#ifdef FIONREAD
	      int n_to_read = 0;

	      /* Is there any input to read immediately?
		 If not, we are about to wait,
		 so write all buffered output before waiting.  */

	      if (use_fionread
		  && ioctl (input_desc, FIONREAD, &n_to_read) < 0)
		{
		  if (errno == EOPNOTSUPP)
		    use_fionread = 0;
		  else
		    {
		      error (0, errno, "cannot do ioctl on `%s'", infile);
		      exit_stat = 1;
		      newlines2 = newlines;
		      return;
		    }
		}
	      if (n_to_read == 0)
#endif
		{
		  int n_write = bpout - outbuf;

		  if (write (output_desc, outbuf, n_write) != n_write)
		    error (1, errno, "write error");
		  bpout = outbuf;
		}

	      /* Read more input into INBUF.  */

	      n_read = read (input_desc, inbuf, insize);
	      if (n_read < 0)
		{
		  error (0, errno, "%s", infile);
		  exit_stat = 1;
		  newlines2 = newlines;
		  return;
		}
	      if (n_read == 0)
		{
		  newlines2 = newlines;
		  return;
		}

	      /* Update the pointers and insert a sentinel at the buffer
		 end.  */

	      bpin = inbuf;
	      eob = bpin + n_read;
	      *eob = '\n';
	    }
	  else
	    {
	      /* It was a real (not a sentinel) newline.  */

	      /* Was the last line empty?
		 (i.e. have two or more consecutive newlines been read?)  */

	      if (++newlines > 0)
		{
		  /* Are multiple adjacent empty lines to be substituted by
		     single ditto (-s), and this was the second empty line?  */

		  if (squeeze_empty_lines && newlines >= 2)
		    {
		      ch = *bpin++;
		      continue;
		    }

		  /* Are line numbers to be written at empty lines (-n)?  */

		  if (numbers && numbers_at_empty_lines)
		    {
		      next_line_num ();
		      bpout = (uchar *) copystring (bpout, line_num_print);
		    }
		}

	      /* Output a currency symbol if requested (-e).  */

	      if (mark_line_ends)
		*bpout++ = '$';

	      /* Output the newline.  */

	      *bpout++ = '\n';
	    }
	  ch = *bpin++;
	}
      while (ch == '\n');

      /* Are we at the beginning of a line, and line numbers are requested?  */

      if (newlines >= 0 && numbers)
	{
	  next_line_num ();
	  bpout = (uchar *) copystring (bpout, line_num_print);
	}

      /* Here CH cannot contain a newline character.  */

      /* The loops below continue until a newline character is found,
	 which means that the buffer is empty or that a proper newline
	 has been found.  */

      /* If quoting, i.e. at least one of -v, -e, or -t specified,
	 scan for chars that need conversion.  */
      if (quote)
	for (;;)
	  {
	    if (ch >= 32)
	      {
		if (ch < 127)
		  *bpout++ = ch;
		else if (ch == 127)
		  *bpout++ = '^',
		    *bpout++ = '?';
		else
		  {
		    *bpout++ = 'M',
		      *bpout++ = '-';
		    if (ch >= 128 + 32)
		      if (ch < 128 + 127)
			*bpout++ = ch - 128;
		      else
			*bpout++ = '^',
			  *bpout++ = '?';
		    else
		      *bpout++ = '^',
			*bpout++ = ch - 128 + 64;
		  }
	      }
	    else if (ch == '\t' && output_tabs)
	      *bpout++ = '\t';
	    else if (ch == '\n')
	      {
		newlines = -1;
		break;
	      }
	    else
	      *bpout++ = '^',
		*bpout++ = ch + 64;

	    ch = *bpin++;
	  }
      else
	/* Not quoting, neither of -v, -e, or -t specified.  */
	for (;;)
	  {
	    if (ch == '\t' && !output_tabs)
	      *bpout++ = '^',
		*bpout++ = ch + 64;
	    else if (ch != '\n')
	      *bpout++ = ch;
	    else
	      {
		newlines = -1;
		break;
	      }

	    ch = *bpin++;
	  }
    }
}

/* Compute the next line number.  */

void
next_line_num ()
{
  char *endp = line_num_end;
  do
    {
      if ((*endp)++ < '9')
	return;
      *endp-- = '0';
    }
  while (endp >= line_num_start);
  *--line_num_start = '1';
  if (line_num_start < line_num_print)
    line_num_print--;
}

/* A less stupid strcpy.  Returns a pointer to the end of the destination
   string, instead of to the beginning.  Doesn't null-terminate the
   destination.  */

char *
copystring (dst, src)
     char *dst;
     char *src;
{
  char c;

  while (c = *src++)
    *dst++ = c;

  return dst;
}
