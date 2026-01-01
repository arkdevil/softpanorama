/* Normal-format output routines for GNU DIFF.
   Copyright (C) 1988, 1989 Free Software Foundation, Inc.

This file is part of GNU DIFF.

GNU DIFF is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 1, or (at your option)
any later version.

GNU DIFF is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with GNU DIFF; see the file COPYING.  If not, write to
the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.  */

/* MS-DOS port (c) 1990 by Thorsten Ohl, ohl@gnu.ai.mit.edu
This port is also distributed under the terms of the GNU General
Public License as published by the Free Software Foundation.

Please note that this file is not identical to the original GNU release,
you should have received this code as patch to the official release.

$Header: e:/gnu/diff/RCS/normal.c 1.15.0.1 91/03/12 10:45:17 tho Exp $  */

#include "diff.h"

#ifdef __STDC__
static  void print_normal_hunk(struct change *);
#else
static  void print_normal_hunk ();
void print_number_range ();
struct change *find_change ();
#endif /* __STDC__ */


/* Print the edit-script SCRIPT as a normal diff.
   INF points to an array of descriptions of the two files.  */

void
print_normal_script (script)
     struct change *script;
{
  print_script (script, find_change, print_normal_hunk);
}

/* Print a hunk of a normal diff.
   This is a contiguous portion of a complete edit script,
   describing changes in consecutive lines.  */

void
print_normal_hunk (hunk)
     struct change *hunk;
{
  int first0, last0, first1, last1, deletes, inserts;
  register int i;

  /* Determine range of line numbers involved in each file.  */
  analyze_hunk (hunk, &first0, &last0, &first1, &last1, &deletes, &inserts);
  if (!deletes && !inserts)
    return;

  /* Print out the line number header for this hunk */
  print_number_range (',', &files[0], first0, last0);
  fprintf (outfile, "%c", change_letter (inserts, deletes));
  print_number_range (',', &files[1], first1, last1);
  fprintf (outfile, "\n");

  /* Print the lines that the first file has.  */
  if (deletes)
    for (i = first0; i <= last0; i++)
      print_1_line ("<", &files[0].linbuf[i]);

  if (inserts && deletes)
    fprintf (outfile, "---\n");

  /* Print the lines that the second file has.  */
  if (inserts)
    for (i = first1; i <= last1; i++)
      print_1_line (">", &files[1].linbuf[i]);
}
