/* #ifdef-format output routines for GNU DIFF.
   Copyright (C) 1989 Free Software Foundation, Inc.

This file is part of GNU DIFF.

GNU DIFF is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY.  No author or distributor
accepts responsibility to anyone for the consequences of using it
or for whether it serves any particular purpose or works at all,
unless he says so in writing.  Refer to the GNU DIFF General Public
License for full details.

Everyone is granted permission to copy, modify and redistribute
GNU DIFF, but only under the conditions described in the
GNU DIFF General Public License.   A copy of this license is
supposed to have been given to you along with GNU DIFF so you
can know your rights and responsibilities.  It should be in a
file named COPYING.  Among other things, the copyright notice
and this notice must be preserved on all copies.  */
/* MS-DOS port (c) 1990 by Thorsten Ohl, ohl@gnu.ai.mit.edu
This port is also distributed under the terms of the GNU General
Public License as published by the Free Software Foundation.

Please note that this file is not identical to the original GNU release,
you should have received this code as patch to the official release.

$Header: e:/gnu/diff/RCS/ifdef.c 1.15.0.1 91/03/11 22:12:20 tho Exp $  */

#include "diff.h"

#ifdef __STDC__
static  void print_ifdef_hunk(struct change *);
#else
static void print_ifdef_hunk ();
struct change *find_change ();
#endif /* __STDC__ */

static int next_line;

/* Print the edit-script SCRIPT as a merged #ifdef file.  */

void
print_ifdef_script (script)
     struct change *script;
{
  next_line = 0;
  print_script (script, find_change, print_ifdef_hunk);
  while (next_line < files[0].buffered_lines)
    print_1_line ("", &files[0].linbuf[next_line++]);
}

/* Print a hunk of an ifdef diff.
   This is a contiguous portion of a complete edit script,
   describing changes in consecutive lines.  */

static void
print_ifdef_hunk (hunk)
     struct change *hunk;
{
  int first0, last0, first1, last1, deletes, inserts;
  register int i;

  /* Determine range of line numbers involved in each file.  */
  analyze_hunk (hunk, &first0, &last0, &first1, &last1, &deletes, &inserts);
  if (!deletes && !inserts)
    return;

  /* Print out lines up to this change.  */
  while (next_line < first0)
    print_1_line ("", &files[0].linbuf[next_line++]);

  /* Print out stuff deleted from first file.  */
  if (deletes)
    {
      fprintf (outfile, "#ifndef %s\n", ifdef_string);
      for (i = first0; i <= last0; i++)
	print_1_line ("", &files[0].linbuf[i]);
      next_line = i;
    }

  /* Print out stuff inserted from second file.  */
  if (inserts)
    {
      if (deletes)
	fprintf (outfile, "#else /* %s */\n", ifdef_string);
      else
	fprintf (outfile, "#ifdef %s\n", ifdef_string);
      for (i = first1; i <= last1; i++)
	print_1_line ("", &files[1].linbuf[i]);
    }

  if (inserts)
    fprintf (outfile, "#endif /* %s */\n", ifdef_string);
  else
    fprintf (outfile, "#endif /* not %s */\n", ifdef_string);
}
