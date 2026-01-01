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
 * $Header: e:/gnu/make/RCS/rule.h'v 3.58.0.1 90/07/17 01:00:07 tho Exp $
 */

/* Structure used for pattern rules.  */

struct rule
  {
    struct rule *next;
    char **targets;		/* Targets of the rule.  */
    unsigned int *lens;		/* Lengths of each target.  */
    char **suffixes;		/* Suffixes (after `%') of each target.  */
    struct dep *deps;		/* Dependencies of the rule.  */
    struct commands *cmds;	/* Commands to execute.  */
    char terminal;		/* If terminal (double-colon).  */
    char subdir;		/* If references nonexistent subdirectory.  */
    char in_use;		/* If in use by a parent pattern_search.  */
  };

/* For calling install_pattern_rule.  */
struct pspec
  {
    char *target, *dep, *commands;
  };


extern struct rule *pattern_rules;
extern struct rule *last_pattern_rule;
extern unsigned int num_pattern_rules;

extern unsigned int max_pattern_deps;
extern unsigned int max_pattern_dep_length;

extern struct file *suffix_file;
extern unsigned int maxsuffix;

#ifdef  MSDOS
extern  void install_pattern_rule (struct pspec *p, int terminal);
#else /* not MSDOS */
extern void install_pattern_rule ();
#endif /* not MSDOS */
