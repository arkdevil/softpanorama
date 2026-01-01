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
 * $Header: e:/gnu/make/RCS/commands.h'v 3.58.0.2 90/07/17 03:32:49 tho Exp $
 */

/* Structure that gives the commands to make a file
   and information about where these commands came from.  */

struct commands
  {
    char *filename;		/* File that contains commands.  */
    unsigned int lineno;	/* Line number in file.  */
    char *commands;		/* Commands text.  */
    char **command_lines;	/* Commands chopped up into lines.  */
    char *lines_recurse;	/* One flag for each line.  */
    char any_recurse;		/* Nonzero if any `lines_recurse' elt is.  */
  };

/* commands.c */
#ifdef MSDOS
extern  void chop_commands (struct commands *cmds);
extern  void execute_file_commands (struct file *file);
extern  int fatal_error_signal (int sig);
extern  void delete_child_targets (struct child *child);
extern  void print_commands (struct commands *cmds);
#else /* not MSDOS */
extern void execute_file_commands ();
extern void print_commands ();
extern void delete_child_targets ();
#endif /* not MSDOS */

