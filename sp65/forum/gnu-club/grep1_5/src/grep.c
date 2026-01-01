/* grep - print lines matching an extended regular expression
   Copyright (C) 1988 Free Software Foundation, Inc.
                      Written June, 1988 by Mike Haertel
	              BMG speedups added July, 1988
			by James A. Woods and Arthur David Olson

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

/* MS-DOS port (c) 1990 by Thorsten Ohl <ohl@gnu.ai.mit.edu>

   This port is also distributed under the terms of the
   GNU General Public License as published by the
   Free Software Foundation.

   Please note that this file is not identical to the
   original GNU release, you should have received this
   code as patch to the official release.

   $Header: e:/gnu/grep/RCS/grep.c 1.5.0.6 90/09/21 11:48:14 tho Exp $  */

#include <ctype.h>
#include <stdio.h>
#ifdef USG
#include <memory.h>
#include <string.h>
#else
#include <strings.h>
#endif
#include "dfa.h"
#include "regex.h"

#ifdef __STDC__

#ifdef MSDOS
#include <stdlib.h>
extern getopt (int, char **, const char *);
extern read (int, void *, int);
extern open (const char *, int,...);
extern void close (int fd);
static void initialize_buffer (void);
static int fill_buffer_retaining (int n);
static int print_line (char *p, int number, int matching);
static int grep (void);
extern void usage_and_die (void);
extern void main (int argc, char **argv);
extern void regerror (char const * s);
extern char *execute (struct regexp * r, char *begin, char *end, int newline,
		      int *count, int *try_backref);
extern char *bmg_search (unsigned char *buffer, int buflen);
extern void bmg_setup (char *pat, int folded);
#endif /* MSDOS */

#else /* not __STDC__ */

extern char *strrchr();

extern errno;
extern char *sys_errlist[];

#endif /* not __STDC__ */

extern char *optarg;
extern optind, opterr;

#define MAX(a, b) ((a) > (b) ? (a) : (b))

/* Exit status codes. */
#define MATCHES_FOUND 0		/* Exit 0 if no errors and matches found. */
#define NO_MATCHES_FOUND 1	/* Exit 1 if no matches were found. */
#define ERROR 2			/* Exit 2 if some error occurred. */

/* Error is set true if something awful happened. */
static int error;

/* The program name for error messages. */
static char *prog;

/* We do all our own buffering by hand for efficiency. */
static char *buffer;		/* The buffer itself, grown as needed. */
static bufbytes;		/* Number of bytes in the buffer. */
static size_t bufalloc;		/* Number of bytes allocated to the buffer. */
static bufprev;			/* Number of bytes that have been forgotten.
				   This is used to get byte offsets from the
				   beginning of the file. */
static bufread;			/* Number of bytes to get with each read(). */

static void
initialize_buffer()
{
  bufread = 8192;
  bufalloc = bufread + bufread / 2;
  buffer = malloc(bufalloc);
  if (! buffer)
    {
      fprintf(stderr, "%s: Memory exhausted (%s)\n", prog,
	      sys_errlist[errno]);
      exit(ERROR);
    }
}

/* The current input file. */
static fd;
static char *filename;
static eof;

/* Fill the buffer retaining the last n bytes at the beginning of the
   newly filled buffer (for backward context).  Returns the number of new
   bytes read from disk. */
static
fill_buffer_retaining(n)
     int n;
{
  char *p, *q;
  int i;

  /* See if we need to grow the buffer. */
  if (bufalloc - n <= bufread)
    {
      while (bufalloc - n <= bufread)
	{
	  bufalloc *= 2;
	  bufread *= 2;
	}
      buffer = realloc(buffer, bufalloc);
      if (! buffer)
	{
	  fprintf(stderr, "%s: Memory exhausted (%s)\n", prog,
		  sys_errlist[errno]);
	  exit(ERROR);
	}
    }

  bufprev += bufbytes - n;

  /* Shift stuff down. */
  for (i = n, p = buffer, q = p + bufbytes - n; i--; )
    *p++ = *q++;
  bufbytes = n;

  if (eof)
    return 0;

  /* Read in new stuff. */
  i = read(fd, buffer + bufbytes, bufread);
  if (i < 0)
    {
      fprintf(stderr, "%s: read on %s failed (%s)\n", prog,
	      filename ? filename : "<stdin>", sys_errlist[errno]);
      error = 1;
    }

  /* Kludge to pretend every nonempty file ends with a newline. */
  if (i == 0 && bufbytes > 0 && buffer[bufbytes - 1] != '\n')
    {
      eof = i = 1;
      buffer[bufbytes] = '\n';
    }

  bufbytes += i;
  return i;
}

/* Various flags set according to the argument switches. */
static trailing_context;	/* Lines of context to show after matches. */
static leading_context;		/* Lines of context to show before matches. */
static byte_count;		/* Precede output lines the byte count of the
				   first character on the line. */
static no_filenames;		/* Do not display filenames. */
static line_numbers;		/* Precede output lines with line numbers. */
static silent;			/* Produce no output at all.  This switch
				   is bogus, ever hear of /dev/null? */
static nonmatching_lines;	/* Print lines that don't match the regexp. */

static bmgexec;			/* Invoke Boyer-Moore-Gosper routines */

/* The compiled regular expression lives here. */
static struct regexp reg;

/* The compiled regular expression for the backtracking matcher lives here. */
static struct re_pattern_buffer regex;

/* Pointer in the buffer after the last character printed. */
static char *printed_limit;

/* True when printed_limit has been artifically advanced without printing
   anything. */
static int printed_limit_fake;

/* Print a line at the given line number, returning the number of
   characters actually printed.  Matching is true if the line is to
   be considered a "matching line".  This is only meaningful if
   surrounding context is turned on. */
static
print_line(p, number, matching)
     char *p;
     int number;
     int matching;
{
  int count = 0;

  if (silent)
    {
      do
	++count;
      while (*p++ != '\n');
      printed_limit_fake = 0;
      printed_limit = p;
      return count;
    }

  if (filename && !no_filenames)
    printf("%s%c", filename, matching ? ':' : '-');
  if (byte_count)
    printf("%d%c", p - buffer + bufprev, matching ? ':' : '-');
  if (line_numbers)
    printf("%d%c", number, matching ? ':' : '-');
  do
    {
      ++count;
      putchar(*p);
    }
  while (*p++ != '\n');
  printed_limit_fake = 0;
  printed_limit = p;
  return count;
}

/* Print matching or nonmatching lines from the current file.  Returns a
   count of matching or nonmatching lines. */
static
grep()
{
  int retain = 0;		/* Number of bytes to retain on next call
				   to fill_buffer_retaining(). */
  char *search_limit;		/* Pointer to the character after the last
				   newline in the buffer. */
  char saved_char;		/* Character after the last newline. */
  char *resume;			/* Pointer to where to resume search. */
  int resume_index = 0;		/* Count of characters to ignore after
				   refilling the buffer. */
  int line_count = 1;		/* Line number. */
  int try_backref;		/* Set to true if we need to verify the
				   match with a backtracking matcher. */
  int initial_line_count;	/* Line count at beginning of last search. */
  char *match;			/* Pointer to the first character after the
				   string matching the regexp. */
  int match_count = 0;		/* Count of matching lines. */
  char *matching_line;		/* Pointer to first character of the matching
				   line, or of the first line of context to
				   print if context is turned on. */
  char *real_matching_line;	/* Pointer to the first character of the
				   real matching line. */
  char *next_line;		/* Pointer to first character of the line
				   following the matching line. */
  int pending_lines = 0;	/* Lines of context left over from last match
				   that we have to print. */
  static first_match = 1;	/* True when nothing has been printed. */
  int i;
  char *tmp;
  char *execute();

  printed_limit_fake = 0;
  
  while (fill_buffer_retaining(retain) > 0)
    {
      /* Find the last newline in the buffer. */
      search_limit = buffer + bufbytes;
      while (search_limit > buffer && search_limit[-1] != '\n')
	--search_limit;
      if (search_limit == buffer)
	{
	  retain = bufbytes;
	  continue;
	}

      /* Save the character after the last newline so regexecute can write
	 its own sentinel newline. */
      saved_char = *search_limit;

      /* Search the buffer for a match. */
      printed_limit = buffer;
      resume = buffer + resume_index;
      initial_line_count = line_count;

      while (match = execute(&reg, resume, search_limit, 0, &line_count, &try_backref))
	{
	  ++match_count;

	  /* Find the beginning of the matching line. */
	  matching_line = match;
	  while (matching_line > resume && matching_line[-1] != '\n')
	    --matching_line;
	  real_matching_line = matching_line;

	  /* Find the beginning of the next line. */
	  next_line = match;
	  while (next_line < search_limit && *next_line++ != '\n')
	    ;

	  /* If a potential backreference is indicated, try it out with
	     a backtracking matcher to make sure the line is a match. */
	  if (try_backref && re_search(&regex, matching_line,
				       next_line - matching_line - 1,
				       0,
				       next_line - matching_line - 1,
				       NULL) < 0)
	    {
	      resume = next_line;
	      if (resume == search_limit)
		break;
	      else
		continue;
	    }

	  /* Print leftover lines from last time.  If nonmatching_lines is
	     turned on, print these as if they were matching lines. */
	  while (resume < matching_line && pending_lines)
	    {
	      resume += print_line(resume, initial_line_count++,
				   nonmatching_lines);
	      --pending_lines;
	    }

	  /* Print out the matching or nonmatching lines as necessary. */
	  if (! nonmatching_lines)
	    {
	      /* Back up over leading context if necessary. */
	      for (i = leading_context; matching_line > printed_limit
		   && i; --i)
		{
		  while (matching_line > printed_limit
			 && (--matching_line)[-1] != '\n')
		    ;
		  --line_count;
		}

	      /* If context is enabled, we may have to print a separator. */
	      if ((leading_context || trailing_context) && !silent
		  && !first_match && (printed_limit_fake || matching_line
				      > printed_limit))
		printf("----------\n");
	      first_match = 0;

	      /* Print the matching line and its leading context. */
	      while (matching_line < real_matching_line)
		matching_line += print_line(matching_line, line_count++, 0);
	      matching_line += print_line(matching_line, line_count++, 1);

	      /* If there's trailing context, leave some lines pending until
		 next time. */
	      pending_lines = trailing_context;
	    }
	  else if (matching_line > resume)
	    {
	      char *real_resume = resume;

	      /* Back up over leading context if necessary. */
	      for (i = leading_context; resume > printed_limit && i; --i)
		{
		  while (resume > printed_limit && (--resume)[-1] != '\n')
		    ;
		  --initial_line_count;
		}

	      /* If context is enabled, we may have to print a separator. */
	      if ((leading_context || trailing_context) && !silent
		  && !first_match && (printed_limit_fake || resume
				      > printed_limit))
		printf("----------\n");
	      first_match = 0;

	      /* Print out the presumably matching leading context. */
	      while (resume < real_resume)
		resume += print_line(resume, initial_line_count++, 0);

	      /* Print out the nonmatching lines prior to the matching line. */
	      while (resume < matching_line)
		resume += print_line(resume, initial_line_count++, 1);

	      /* Deal with trailing context. */
	      if (trailing_context)
		{
		  print_line(matching_line, line_count, 0);
		  pending_lines = trailing_context - 1;
		}

	      /* Count the current line. */
	      ++line_count;
	    }
	  else
	    {
	      /* The line immediately after a matching line has to be printed
		 because it was pending. */
	      if (pending_lines > 0)
		{
		  --pending_lines;
		  print_line(matching_line, line_count, 0);
		}
	      ++line_count;
	    }

	  /* Resume searching at the beginning of the next line. */
	  initial_line_count = line_count;
	  resume = next_line;

	  if (resume == search_limit)
	    break;
	}
 
      /* Restore the saved character. */
      *search_limit = saved_char;

      if (! nonmatching_lines)
	{
	  while (resume < search_limit && pending_lines)
	    {
	      resume += print_line(resume, initial_line_count++, 0);
	      --pending_lines;
	    }
	}
      else if (search_limit > resume)
	{
	  char *initial_resume = resume;

	  /* Back up over leading context if necessary. */
	  for (i = leading_context; resume > printed_limit && i; --i)
	    {
	      while (resume > printed_limit && (--resume)[-1] != '\n')
		;
	      --initial_line_count;
	    }

	  /* If context is enabled, we may have to print a separator. */
	  if ((leading_context || trailing_context) && !silent
	      && !first_match && (printed_limit_fake || resume
				  > printed_limit))
	    printf("----------\n");
	  first_match = 0;

	  /* Print out all the nonmatching lines up to the search limit. */
	  while (resume < initial_resume)
	    resume += print_line(resume, initial_line_count++, 0);
	  while (resume < search_limit)
	    resume += print_line(resume, initial_line_count++, 1);

	  pending_lines = trailing_context;
	  resume_index = 0;
	  retain = bufbytes - (search_limit - buffer);
	  continue;
	}
      
      /* Save the trailing end of the buffer for possible use as leading
	 context in the future. */
      i = leading_context;
      tmp = search_limit;
      while (tmp > printed_limit && i--)
	while (tmp > printed_limit && (--tmp)[-1] != '\n')
	  ;
      resume_index = search_limit - tmp;
      retain = bufbytes - (tmp - buffer);
      if (tmp > printed_limit)
	printed_limit_fake = 1;
    }

  return nonmatching_lines ? (line_count - 1) - match_count : match_count;
}

void
usage_and_die()
{
  fprintf(stderr,
"usage: %s [-CVbchilnsvwx] [-<num>] [-AB <num>] [-f file] [-e] expr [files]\n",
          prog);
  exit(ERROR);
}

#ifndef MSDOS
static char version[] = "GNU e?grep, version 1.5";
#else /* MSDOS */
static char version[] =
  "GNU e?grep, version 1.5  (compiled " __DATE__ " " __TIME__ " for MS-DOS)";

void
#endif /* MSDOS */
main(argc, argv)
     int argc;
     char **argv;
{
  int c;
  int ignore_case = 0;		/* Compile the regexp to ignore case. */
  char *the_regexp = 0;		/* The regular expression. */
  int regexp_len;		/* Length of the regular expression. */
  char *regexp_file = 0;	/* File containing parallel regexps. */
  int count_lines = 0;		/* Display only a count of matching lines. */
  int list_files = 0;		/* Display only the names of matching files. */
  int whole_word = 0;		/* Insist that the regexp match a word only. */
  int whole_line = 0;		/* Insist on matching only whole lines. */
  int line_count = 0;		/* Count of matching lines for a file. */
  int matches_found = 0;	/* True if matches were found. */
  char *regex_errmesg;		/* Error message from regex routines. */
  char translate[_NOTCHAR];	/* Translate table for case conversion
				   (needed by the backtracking matcher). */

  if (prog = strrchr(argv[0], '/'))
    ++prog;
  else
    prog = argv[0];

  opterr = 0;
  while ((c = getopt(argc, argv, "0123456789A:B:CVbce:f:hilnsvwx")) != EOF)
    switch (c)
      {
      case '?':
	usage_and_die();
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
	trailing_context = 10 * trailing_context + c - '0';
	leading_context = 10 * leading_context + c - '0';
	break;

      case 'A':
	if (! sscanf(optarg, "%d", &trailing_context)
	    || trailing_context < 0)
	  usage_and_die();
	break;

      case 'B':
	if (! sscanf(optarg, "%d", &leading_context)
	    || leading_context < 0)
	  usage_and_die();
	break;

      case 'C':
	trailing_context = leading_context = 2;
	break;

      case 'V':
	fprintf(stderr, "%s\n", version);
	break;

      case 'b':
	byte_count = 1;
	break;

      case 'c':
	count_lines = 1;
	silent = 1;
	break;

      case 'e':
	/* It doesn't make sense to mix -f and -e. */
	if (regexp_file)
	  usage_and_die();
	the_regexp = optarg;
	break;

      case 'f':
	/* It doesn't make sense to mix -f and -e. */
	if (the_regexp)
	  usage_and_die();
	regexp_file = optarg;
	break;

      case 'h':
	no_filenames = 1;
	break;

      case 'i':
	ignore_case = 1;
	for (c = 0; c < _NOTCHAR; ++c)
	  if (isupper(c))
	    translate[c] = tolower(c);
	  else
	    translate[c] = c;
	regex.translate = translate;
	break;

      case 'l':
	list_files = 1;
	silent = 1;
	break;

      case 'n':
	line_numbers = 1;
	break;

      case 's':
	silent = 1;
	break;

      case 'v':
	nonmatching_lines = 1;
	break;

      case 'w':
	whole_word = 1;
	break;

      case 'x':
	whole_line = 1;
	break;

      default:
	/* This can't happen. */
	fprintf(stderr, "%s: getopt(3) let one by!\n", prog);
	usage_and_die();
	break;
      }

  /* Set the syntax depending on whether we are EGREP or not. */
#ifdef EGREP
  regsyntax(RE_SYNTAX_EGREP, ignore_case);
  re_set_syntax(RE_SYNTAX_EGREP);
#else
  regsyntax(RE_SYNTAX_GREP, ignore_case);
  re_set_syntax(RE_SYNTAX_GREP);
#endif

  /* Compile the regexp according to all the options. */
  if (regexp_file)
    {
      FILE *fp = fopen(regexp_file, "r");
      int len = 256;
      int i = 0;

      if (! fp)
	{
	  fprintf(stderr, "%s: %s: %s\n", prog, regexp_file,
		  sys_errlist[errno]);
	  exit(ERROR);
	}

      the_regexp = malloc(len);
      while ((c = getc(fp)) != EOF)
	{
	  the_regexp[i++] = c;
	  if (i == len)
	    the_regexp = realloc(the_regexp, len *= 2);
	}
      fclose(fp);
      /* Nuke the concluding newline so we won't match the empty string. */
      if (i > 0 && the_regexp[i - 1] == '\n')
	--i;
      regexp_len = i;
    }
  else if (! the_regexp)
    {
      if (optind >= argc)
	usage_and_die();
      the_regexp = argv[optind++];
      regexp_len = strlen(the_regexp);
    }
  else
    regexp_len = strlen(the_regexp);
  
  if (whole_word || whole_line)
    {
      char *n = malloc(regexp_len + 8);
      int i = 0;

      if (whole_line)
	n[i++] = '^';
      else
	n[i++] = '\\', n[i++] = '<';
#ifndef EGREP
      n[i++] = '\\';
#endif
      n[i++] = '(';
      memcpy(n + i, the_regexp, regexp_len);
      i += regexp_len;
#ifndef EGREP
      n[i++] = '\\';
#endif
      n[i++] = ')';
      if (whole_line)
	n[i++] = '$';
      else
	n[i++] = '\\', n[i++] = '>';
      the_regexp = n;
      regexp_len = i;
    }

  regcompile(the_regexp, regexp_len, &reg, 1);
  
  if (regex_errmesg = re_compile_pattern(the_regexp, regexp_len, &regex))
    regerror(regex_errmesg);
  
  /*
    Find the longest metacharacter-free string which must occur in the
    regexpr, before short-circuiting regexecute() with Boyer-Moore-Gosper.
    (Conjecture:  The problem in general is NP-complete.)  If there is no
    such string (like for many alternations), then default to full automaton
    search.  regmust() code and heuristics [see dfa.c] courtesy
    Arthur David Olson.
    */
  if (line_numbers == 0 && nonmatching_lines == 0)
    {
      if (reg.mustn == 0 || reg.mustn == MUST_MAX ||
  	  strchr(reg.must, '\0') != reg.must + reg.mustn)
	bmgexec = 0;
      else
	{
	  reg.must[reg.mustn] = '\0';
	  if (getenv("MUSTDEBUG") != NULL)
	    (void) printf("must have: \"%s\"\n", reg.must);
	  bmg_setup(reg.must, ignore_case);
	  bmgexec = 1;
	}
    }
  
  if (argc - optind < 2)
    no_filenames = 1;

  initialize_buffer();

  if (argc > optind)
    while (optind < argc)
      {
	bufprev = eof = 0;
	filename = argv[optind++];
	fd = open(filename, 0, 0);
	if (fd < 0)
	  {
	    fprintf(stderr, "%s: %s: %s\n", prog, filename,
		    sys_errlist[errno]);
	    error = 1;
	    continue;
	  }
	if (line_count = grep())
	  matches_found = 1;
	close(fd);
	if (count_lines)
	  if (!no_filenames)
	    printf("%s:%d\n", filename, line_count);
	  else
	    printf("%d\n", line_count);
	else if (list_files && line_count)
	  printf("%s\n", filename);
      }
  else
    {
      if (line_count = grep())
	matches_found = 1;
      if (count_lines)
	printf("%d\n", line_count);
      else if (list_files && line_count)
	printf("<stdin>\n");
    }

  if (error)
    exit(ERROR);
  if (matches_found)
    exit(MATCHES_FOUND);
  exit(NO_MATCHES_FOUND);
}

/* Needed by the regexp routines.  This could be fancier, especially when
   dealing with parallel regexps in files. */
void
regerror(s)
     const char *s;
{
  fprintf(stderr, "%s: %s\n", prog, s);
  exit(ERROR);
}

/*
   bmg_setup() and bmg_search() adapted from:
     Boyer/Moore/Gosper-assisted 'egrep' search, with delta0 table as in
     original paper (CACM, October, 1977).  No delta1 or delta2.  According to
     experiment (Horspool, Soft. Prac. Exp., 1982), delta2 is of minimal
     practical value.  However, to improve for worst case input, integrating
     the improved Galil strategies (Apostolico/Giancarlo, Siam. J. Comput.,
     February 1986) deserves consideration.

     James A. Woods				Copyleft (C) 1986, 1988
     NASA Ames Research Center
*/

char *
execute(r, begin, end, newline, count, try_backref)
  struct regexp *r;
  char *begin;
  char *end;
  int newline;
  int *count;
  int *try_backref;
{
  register char *p, *s;
  char *match;
  char *start = begin;
  char save;			/* regexecute() sentinel */
  int len;
  char *bmg_search();

  if (!bmgexec)			/* full automaton search */
    return(regexecute(r, begin, end, newline, count, try_backref));
  else
    {
      len = end - begin; 
      while ((match = bmg_search((unsigned char *) start, len)) != NULL)
	{
	  p = match;		/* narrow search range to submatch line */
	  while (p > begin && *p != '\n')
	    p--;
	  s = match;
	  while (s < end && *s != '\n')
	    s++;
	  s++;

	  save = *s;
	  *s = '\0';
	  match = regexecute(r, p, s, newline, count, try_backref);
	  *s = save;

	  if (match != NULL)
	    return((char *) match);
	  else
	    {
	      start = s;
	      len = end - start;
	    }
	}
      return(NULL);
    }
}

#include <ctype.h>
int		delta0[256];
unsigned char   cmap[256];		/* (un)folded characters */
unsigned char	pattern[5000];
int		patlen;

char *
bmg_search(buffer, buflen)
  unsigned char *buffer;
  int buflen;
{
  register unsigned char *k, *strend, *s, *buflim;
  register int t;
  int j;

  if (patlen > buflen)
    return NULL;

  buflim = buffer + buflen;
  if (buflen > patlen * 4)
    strend = buflim - patlen * 4;
  else
    strend = buffer;

  s = buffer;
  k = buffer + patlen - 1;

  for (;;)
    {
      /* The dreaded inner loop, revisited. */
      while (k < strend && (t = delta0[*k]))
	{
	  k += t;
	  k += delta0[*k];
	  k += delta0[*k];
	}
      while (k < buflim && delta0[*k])
	++k;
      if (k == buflim)
	break;
    
      j = patlen - 1;
      s = k;
      while (--j >= 0 && cmap[*--s] == pattern[j])
	;
      /* 
	delta-less shortcut for literati, but 
	short shrift for genetic engineers.
      */
      if (j >= 0)
	k++;
      else 		/* submatch */
	return ((char *)k);
    }
  return(NULL);
}

#ifdef MSDOS
void
#endif
bmg_setup(pat, folded)			/* compute "boyer-moore" delta table */
  char *pat;
  int folded;
{					/* ... HAKMEM lives ... */
  int j;

  patlen = strlen(pat);

  if (folded) 				/* fold case while saving pattern */
    for (j = 0; j < patlen; j++) 
      pattern[j] = (isupper((int) pat[j]) ?
	(char) tolower((int) pat[j]) : pat[j]);
  else
      memcpy(pattern, pat, patlen);

  for (j = 0; j < 256; j++)
    {
      delta0[j] = patlen;
      cmap[j] = (char) j;		/* could be done at compile time */
    }
  for (j = 0; j < patlen - 1; j++)
    delta0[pattern[j]] = patlen - j - 1;
  delta0[pattern[patlen - 1]] = 0;

  if (folded)
    {
      for (j = 0; j < patlen - 1; j++)
	if (islower((int) pattern[j]))
	  delta0[toupper((int) pattern[j])] = patlen - j - 1;
	if (islower((int) pattern[patlen - 1]))
	  delta0[toupper((int) pattern[patlen - 1])] = 0;
      for (j = 'A'; j <= 'Z'; j++)
	cmap[j] = (char) tolower((int) j);
    }
}

#ifndef USG

/* (groan) compatibility */

char *
strchr(s, c)
     char *s;
{
  return index(s, c);
}

char *
strrchr(s, c)
     char *s;
{
  return rindex(s, c);
}

char *
memcpy(d, s, n)
     char *d, *s;
{
  return bcopy(s, d, n);
}

#endif /* not USG */
