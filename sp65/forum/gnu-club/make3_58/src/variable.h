/* Copyright (C) 1988, 1989, 1990 Free Software Foundation, Inc.
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
 * $Header: e:/gnu/make/RCS/variable.h'v 3.58.0.2 90/07/17 03:32:57 tho Exp $
 */

/* Codes in a variable definition saying where the definition came from.
   Increasing numeric values signify less-overridable definitions.  */
enum variable_origin
  {
    o_default,		/* Variable from the default set.  */
    o_env,		/* Variable from environment.  */
    o_file,		/* Variable given in a makefile.  */
    o_env_override,	/* Variable from environment, if -e.  */
    o_command,		/* Variable given by user.  */
    o_override, 	/* Variable from an `override' directive.  */
    o_automatic,	/* Automatic variable -- cannot be set.  */
    o_invalid		/* Core dump time.  */
  };

/* Structure that represents one variable definition.
   Each bucket of the hash table is a chain of these,
   chained through `next'.  */

struct variable
  {
    struct variable *next;	/* Link in the chain.  */
    char *name;			/* Variable name.  */
    char *value;		/* Variable value.  */
    enum variable_origin
      origin ENUM_BITFIELD (3);	/* Variable origin.  */
    unsigned int recursive:1;	/* Gets recursively re-evaluated.  */
    unsigned int expanding:1;	/* Is currently expanding.  */
  };

/* Structure that represents a variable set.  */

struct variable_set
  {
    struct variable **table;	/* Hash table of variables.  */
    unsigned int buckets;	/* Number of hash buckets in `table'.  */
  };

/* Structure that represents a list of variable sets.  */

struct variable_set_list
  {
    struct variable_set_list *next;	/* Link in the chain.  */
    struct variable_set *set;		/* Variable set.  */
  };

extern struct variable_set_list *current_variable_set_list;


/* variable.c */
extern  void print_variable_data_base (void);

#ifdef  MSDOS
extern  char *variable_buffer_output (char *ptr, char *string,
				      unsigned int length);
extern  char *initialize_variable_output (void);
extern  char *save_variable_output (void);
extern  void restore_variable_output (char *save);
#else /* not MSDOS */
extern char *variable_buffer_output ();
extern char *initialize_variable_output ();
extern char *save_variable_output ();
extern void restore_variable_output ();
#endif /* not MSDOS */

#ifdef  MSDOS
extern  void push_new_variable_scope (void);
extern  void pop_variable_scope (void);
#else /* not MSDOS */
extern void push_new_variable_scope (), pop_variable_scope ();
#endif /* not MSDOS */

#ifdef  MSDOS
extern  int handle_function (char **op, char **stringp);
#else /* not MSDOS */
extern int handle_function ();
#endif /* not MSDOS */
  
#ifdef  MSDOS
extern  char *allocated_variable_expand (char *line);
extern  char *allocated_var_exp_for_file (char *line, struct file *file);
extern  char *expand_argument (char *str, char *end);
extern  char *variable_expand (char *line);
extern  char *variable_expand_for_file (char *line, struct file *file);
#else /* not MSDOS */
extern char *variable_expand (), *allocated_variable_expand ();
extern char *variable_expand_for_file ();
extern char *allocated_variable_expand_for_file ();
extern char *expand_argument ();
#endif /* not MSDOS */

#ifdef  MSDOS
extern  void define_automatic_variables (void);
extern  void initialize_file_variables (struct file *file);
#else /* not MSDOS */
extern void define_automatic_variables ();
extern void initialize_file_variables ();
#endif /* not MSDOS */

extern void print_file_variables ();

#ifdef MSDOS
extern void merge_variable_set_lists (struct variable_set_list **setlist0,
				      struct variable_set_list *setlist1);
#else /* not MSDOS */
extern void merge_variable_set_lists ();
#endif /* not MSDOS */


#ifdef  MSDOS
extern  int try_variable_definition (char *line, enum variable_origin origin);
#else /* not MSDOS */
extern int try_variable_definition ();
#endif /* not MSDOS */

#ifdef  MSDOS
extern  struct variable *define_variable (char *name, unsigned int length,
		char *value, enum variable_origin origin, int recursive);
extern  struct variable *define_variable_for_file (char *name,
		unsigned int length, char *value,
		enum variable_origin origin, int recursive, struct file *file);
extern  struct variable *lookup_variable (char *name, unsigned int length);
#else /* not MSDOS */
extern struct variable *lookup_variable (), *define_variable ();
extern struct variable *define_variable_for_file ();
#endif /* not MSDOS */

#ifdef  MSDOS
extern int pattern_matches (char *pattern, char *percent, char *word);
extern char *patsubst_expand (char *o, char *text, char *pattern,
		char *replace, char *pattern_percent, char *replace_percent);
extern char *subst_expand (char *o, char *text, char *subst, char *replace,
		unsigned int slen, unsigned int rlen, int by_word,
		int suffix_only);
#else /* not MSDOS */
extern int pattern_matches ();
extern char *subst_expand (), *patsubst_expand ();
#endif /* not MSDOS */

#ifdef  MSDOS
extern  char **target_environment (struct file *file);
#else /* not MSDOS */
extern char **target_environment ();
#endif /* not MSDOS */
