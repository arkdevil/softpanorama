/*  spawn.c - replacements for MSC spawn*() functions
    Copyright (C) 1990 by Thorsten Ohl, ohl@gnu.ai.mit.edu

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
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

    IMPORTANT:

    This code is not an official part of the GNU project and the
    author is not affiliated to the Free Software Foundation.
    He just likes their code and spirit.  */

static char RCS_id[] =
"$Header: e:/gnu/make/RCS/spawn.c'v 0.18 90/07/22 14:42:38 tho Exp $";


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <process.h>
#include <malloc.h>
#include <errno.h>
#include <direct.h>
#include <dos.h>
#include <io.h>
#include <sys/types.h>


#define MAX_MSDOS_CMDLINE	126
#define MAX_MSDOS_PATH		144

/* IMPORTED DECLARATIONS */

enum swapping_mode
{
  none, disk, ems, xms
};

extern int
spawn_child (enum swapping_mode mode, char *path, char *cmdline, char *env,
	     int len, char *swap_file);


/* PRIVATE DECLARATIONS */

static void swapping_mode_hook (enum swapping_mode * swapping_ptr, char *dev);
static int commandline_hook (char *cmd, char **argv, char **env0,
			     char **respond_file_name_ptr);
static char *putenv_cmdline (char *cmd, char **argv);
static int build_environment (char _far ** envbuf, char *cmdline,
			      char **envvec);
static char *build_link_respond_file (char **argv);
static char *build_lib_respond_file (char **argv);
static char *build_zip_respond_file (char **argv);
static int build_cmdline (char **argv);
static char *expand_path (char *name, char *env, char *(*select) (char *));
static char *executable_p (char *path);
extern void *xmalloc (size_t size);
extern void *xrealloc (void *ptr, size_t size);

static char *extensions[] =/* extensions recognized during */
{				/* path search */
  ".bat",			/* this will be passed to the shell */
  ".exe",
  ".com",
  NULL,
};

#define PATH_SEP	';'
#define FSLASH		'/'
#define BSLASH		'\\'


/* PUBLIC DECLARATIONS */

extern char *mktmpname (char *prefix);


/* The main entry points, work just like spawnvpe?() from the standard MSC
   library.  */

int swap_and_spawnvp (char *device, char *cmd, char **argv);
int swap_and_spawnvpe (char *device, char *cmd, char **argv, char **envvec);

int
swap_and_spawnvp (char *device, char *cmd, char **argv)
{
  return swap_and_spawnvpe (device, cmd, argv, NULL);
}

int
swap_and_spawnvpe (char *device, char *cmd, char **argv, char **envvec)
{
  int len;
  int rc;
  char _far *env = (char _far *) 0;
  char *env0 = NULL;
  char *respond_file_name = NULL;
  char *swap_file_name = mktmpname ("vm");
  enum swapping_mode swapping = xms;

  if (device != NULL)
    swapping_mode_hook (&swapping, device);

  argv[0] = expand_path (cmd, "PATH", executable_p);
  if (argv[0] == NULL)
    return ENOENT;

  rc = commandline_hook (cmd, argv, &env0, &respond_file_name);
  if (rc)
    return rc;

  len = build_environment (&env, env0, (envvec == NULL) ? environ : envvec);
  if (!len)
    return E2BIG;

  rc = spawn_child (swapping, argv[0], argv[1], env, len, swap_file_name);

  if (env0)
    free (env0);
  if (env)
    free (env);
  if (*argv[1])
    free (argv[1]);
  free (swap_file_name);

  if (respond_file_name)	/* clean up disk */
    unlink (respond_file_name);

  return rc;
}


/* Look if DEV corresponds to a known swapping device and set *SWAPPING_PTR
   accordingly;  */

void
swapping_mode_hook (enum swapping_mode * swapping_ptr, char *dev)
{
  if (dev)
    {
      strlwr (dev);
      if (!strcmp ("xms", dev))
	*swapping_ptr = xms;
      else if (!strcmp ("ems", dev))
	{
	  fprintf (stderr, "Swapping to expanded memory is not supported yet, "
		   "will try extended memory.\n");
	  *swapping_ptr = xms;
	}
      else if (!strcmp ("disk", dev))
	*swapping_ptr = disk;
      else if (!strcmp ("none", dev))
	{
	  fprintf (stderr, "No swapping is not supported yet, "
			    "will swap to disk.\n");
	  *swapping_ptr = disk;
	}
      else
	{
	  fprintf (stderr, "Can't swap to `%s' (no such device), "
		   "will try extended memory.\n", dev);
	  *swapping_ptr = xms;
	}
    }
}

/* Look if CMD allows or requires special treatment, manipulate ARGV
   accordingly. If necessary, create ENV0 and RESPOND_FILE_NAME_PTR.
   In any case, merge ARGV[1], ... into ARGV[1].
   ~~~~~~~~~~~
   Note that the special treatment can be switched off by giving CMD
   uppercase!  */

int
commandline_hook (char *cmd, char **argv, char **env0,
		  char **respond_file_name_ptr)
{
  if (!strcmp ("cl", cmd) || !strcmp ("fl", cmd) || !strcmp ("masm", cmd))
    *env0 = putenv_cmdline (cmd, argv);
  else if (!strcmp ("link", cmd))
    {
      *respond_file_name_ptr = build_link_respond_file (argv);
      if (*respond_file_name_ptr == NULL)
	return E2BIG;
    }
  else if (!strcmp ("lib", cmd))
    {
      *respond_file_name_ptr = build_lib_respond_file (argv);
      if (*respond_file_name_ptr == NULL)
	return E2BIG;
    }
  else if (!strcmp ("pkzip", cmd) || !strcmp ("pkunzip", cmd))
    {
      *respond_file_name_ptr = build_zip_respond_file (argv);
      if (*respond_file_name_ptr == NULL)
	return E2BIG;
    }
  else if (!build_cmdline (argv))
    return E2BIG;

  return 0;			/* success */
}


/* Manipulating the environment.  */

/* Merge CMDLINE, ENVVEC[0], ... into ENVBUF as a well formed MS-DOS
   environment (will be malloc()'d).  Returns the length (incl. the
   trailing '\0's)  of the resulting environment.  */

int
build_environment (char _far ** envbuf, char *cmdline, char **envvec)
{
  char *p;
  char **envptr = envvec;
  int len = 1;

  if (envvec == NULL && cmdline == NULL)
    return 0;

  if (cmdline != NULL)
    len += strlen (cmdline) + 1;
  if (envvec != NULL)
    while (*envptr)
      len += strlen (*envptr++) + 1;

  p = *envbuf = (char *) xmalloc (len);

  if (cmdline != NULL)
    {
      strcpy (p, cmdline);
      p += strlen (cmdline) + 1;
    }
  envptr = envvec;
  if (envvec != NULL)
    while (*envptr)
      {
	strcpy (p, *envptr);
	p += strlen (*envptr++) + 1;
      }
  *p++ = '\0';			/* end of environment! */

  return (len);
}


/* Manipulating the commandline.  */

/* The following functions for manipulating the commandline do NOT free
   the storage of the ARGV[] strings, since they can't know how it was
   allocated (separately or as single block).  */

/* Build an environment entry for passing options to the Microsoft C
   and Fortran Compilers and Macro Assembler.  CMD is the command to
   execute.  ARGV[1],... will be moved to an environment entry "CMD" and
   we will have ARGV[1] == "".  */

char *
putenv_cmdline (char *cmd, char **argv)
{
  int nologo_flag = 0;
  char **av = argv + 1;
  char *p;
  char *env;
  int len = 3 + strlen (cmd);

  /* `fl' and `cl' understand the "-nologo" option to suppress the banner,
      `masm' not.  */
  if (!strcmp (cmd, "fl") || !strcmp (cmd, "cl"))
    {
      nologo_flag = 1;
      len += 8;
    }

  while (*av)
    len += strlen (*av++) + 1;

  p = env = (char *) xmalloc (len);

  strcpy (p, strupr (cmd));
  p += strlen (cmd);
  *p++ = '=';

  if (nologo_flag)
    {
      strcpy (p, "-nologo");
      p += 7;
    }

  av = argv + 1;
  while (*av)			/* paste arguments together */
    {
      *p++ = ' ';
      strcpy (p, *av);
      p += strlen (*av++);
    }

  *argv[1] = '\0';		/* commandline terminated */

  return env;
}


/* Build a respondfile for the Microsoft linker from ARGV[0].  Returns the
   name of the generated file on success, NULL otherwise.  The new
   commandline ARGV[1] holds the proper command for instructing the linker
   to use this respondfile.  */

char *
build_link_respond_file (char **argv)
{
  int len = 0;
  char **av = argv;
  FILE *respond_file;
  char *respond_file_name = mktmpname ("lk");

  if (!(respond_file = fopen (respond_file_name, "w")))
    {
      fprintf (stderr, "can't open link respond_file %s.\n",
	       respond_file_name);
      return NULL;
    }

  while (*++av)
    {
      char *cp;

      if (strlen (*av) + len > 50)
	{
	  fprintf (respond_file, "+\n");
	  len = 0;
	}

      while (cp = strchr (*av, ','))	/* new respond group? */
	{
	  *cp = '\n';
	  len = *av - cp - 1;	/* precompensate */
	}

      len += fprintf (respond_file, "%s ", *av);
    }

  fprintf (respond_file, ";\n");/* avoid prompts! */

  fclose (respond_file);

  argv[1] = (char *) xmalloc (strlen (respond_file_name) + 9);
  sprintf (argv[1], "/batch @%s", respond_file_name);

  return respond_file_name;
}


/* Build a respondfile for the Microsoft library manager from ARGV[0].
   Returns the name of the generated file on success, NULL otherwise.  The
   new commandline ARGV[1] holds the proper command for instructing the
   library manager to use this respondfile.   A module without command
   inherits the one of it's predecessor.  This allows constructions like
   `lib foo.lib -+ $?' in the makefiles (idea stolen from Kneller's
   `ndmake').  */

char *
build_lib_respond_file (char **argv)
{
  int len = 0;
  char **av = argv;
  FILE *respond_file;
  char *respond_file_name = mktmpname ("lb");
  static char lib_action[3] = "+";

  if (!(respond_file = fopen (respond_file_name, "w")))
    {
      fprintf (stderr, "can't open lib respond_file %s.\n",
	       respond_file_name);
      return NULL;
    }

  fprintf (respond_file, " %s\n ", *++av);	/* easy: the lib file  */

  if (access (*av, 0))		/* new library */
    fprintf (respond_file, "y\n ");	/* create it! */

  while (*++av)
    {
      char *cp;

      if (strchr ("+-*", **av))
	{
	  lib_action[0] = *(*av)++;

	  if (strchr ("+-*", **av))
	    lib_action[1] = *(*av)++;
	  else
	    lib_action[1] = '\0';
	}

      if (**av)
	{
	  if (strlen (*av) + len > 50)
	    {
	      fprintf (respond_file, "&\n ");
	      len = 0;
	    }

	  len += fprintf (respond_file, "%s", lib_action) + 1;

	  while (cp = strchr (*av, ','))	/* new respond group? */
	    {
	      *cp = '\n';
	      len = *av - cp - 1;	/* precompensate */
	      lib_action[0] = '\0';	/* no more actions! */
	    }

	  len += fprintf (respond_file, "%s ", *av) + 1;
	}
    }

  fprintf (respond_file, ";\n");/* avoid prompts! */

  fclose (respond_file);

  argv[1] = (char *) xmalloc (strlen (respond_file_name) + 10);
  sprintf (argv[1], "/nologo @%s", respond_file_name);

  return respond_file_name;
}


/* Build a respondfile for the pk(un)?zip archive managers from ARGV[0].
   Returns the name of the generated file on success, NULL otherwise.  The
   new commandline ARGV[1] holds the proper command for instructing
   pk(un)?zip to use this respondfile.  */

char *
build_zip_respond_file (char **argv)
{
  char *cmdline = (char *) xmalloc (127 * sizeof (char));
  char *ptr = cmdline;
  char **av = argv + 1;
  int len = 0;
  FILE *respond_file = NULL;
  char *respond_file_name = mktmpname ("zi");

  respond_file = fopen (respond_file_name, "w");
  if (respond_file == NULL)
    {
      fprintf (stderr, "can't open zip respondfile %s.\n", respond_file_name);
      return NULL;
    }

  while (**av == '-')		/* leave options on the commandline */
    {
      if (ptr - cmdline + strlen (*av) > 126)
	{
	  free (cmdline);
	  return NULL;
	}
      strcpy (ptr, *av);
      ptr += strlen (*av);
      *ptr++ = ' ';
      av++;
    }

  if (*av == NULL		/* missing zipfilename? */
      || ptr - cmdline + strlen (*av) + strlen (respond_file_name) > 124)
    {
      free (cmdline);
      return NULL;
    }

  sprintf (ptr, "%s @%s", *av++, respond_file_name);

  while (*av)
    fprintf (respond_file, "%s\n", *av++);

  fprintf (respond_file, "\n");
  fclose (respond_file);

  argv[1] = cmdline;

  return respond_file_name;
}


/* Build a MS-DOS commandline from the supplied argument vector ARGV and
   put it into ARGV[1].  Storage of the old argv[1], ... is NOT free()'d,
   since we can't know how it was allocated (separately or as single
   block)! ARGV[0] is assumed to be a fully expanded pathname incl
   extension.  If ARGV[0] ends int ".bat", we will pass the command to the
   shell.  Returns 1 on success, 0 if the commandline is too long.  */

int
build_cmdline (char **argv)
{
  char *cmdline = (char *) xmalloc (128 * sizeof (char));
  char *p = cmdline;
  char *tmp;
  char **av;

  if ((tmp = strrchr (argv[0], '.'))	/* .bat files will be passed */
      && !strcmp (tmp + 1, "bat"))	/* to the shell ...  */
    {
      *tmp = '\0';		/* terminate */

      strcpy (p, "/c ");	/* return after execution */
      p += 3;

      if ((tmp = strrchr (argv[0], BSLASH))	/* strip path */
	  || (tmp = strrchr (argv[0], FSLASH)))
	strcpy (p, tmp + 1);
      else
	strcpy (p, argv[0]);

      p += strlen (p);
      *p++ = ' ';

      if (!(argv[0] = getenv ("COMSPEC")))
	{
	  fprintf (stderr, "command processor not found!");
	  exit (1);
	}
    }

  av = argv;			/* paste arguments together */
  while (*++av)
    {
      strcpy (p, *av);
      p += strlen (*av);
      *p++ = ' ';
      if ((p - cmdline) > 126)
	return (0);		/* commandline to long for MeSy-DOS */
    }

  *p = '\0';
  argv[1] = cmdline;

  return (1);			/* success */
}



/* $PATH search.  */

/* Look for NAME in the directories from $ENV ($PATH, if ENV is NULL),
   satisfying SELECT.  */

char *
expand_path (char *name, char *env, char *(*select) (char *))
{
  size_t name_len = strlen (name) + 6;	/*  SELECT may append 4 chars! */
  char *exp = (char *) xmalloc (name_len);

  strcpy (exp, name);

  if ((*select) (exp))		/* first look in current directory. */
    return exp;

  /* If not an absolute path, scan $PATH  */

  if (exp[1] != ':' && *exp != BSLASH && *exp != FSLASH)
    {
      char *ptr = getenv ((env == NULL) ? "PATH" : env);
      if (ptr != NULL)
	{
	  char *path = (char *) alloca (strlen (ptr) + 1);
	  strcpy (path, ptr);	/* get a copy strtok() can butcher. */

	  ptr = strtok (path, ";");

	  while (ptr != NULL)
	    {
	      exp = (char *) xrealloc (exp, strlen (ptr) + name_len);
	      if ((*select) (strcat (strcat (strcpy (exp, ptr), "/"), name)))
		return exp;
	      ptr = strtok (NULL, ";");
	    }
	}
    }

  free (exp);
  return NULL;			/* We've failed!  */
}


/* Return the expanded path with extension iff PATH is an executable MS-DOS
   program, NULL otherwise.  */

static char *
executable_p (char *path)
{
  char *base;
  const char **ext = extensions;

  base = strrchr (strrchr (path, BSLASH), FSLASH);
  if (base == NULL)
    base = path;

  if (strchr (base, '.'))	/* explicit extension? */
    {
      if (!access (path, 0))
	return path;
    }
  else
    {
      while (*base)		/* point to the end */
	*base++;

      while (*ext)		/* try all extensions */
	{
	  strcpy (base, *ext++);
	  if (!access (path, 0))
	    return path;
	}
    }

  return NULL;			/* failed */
}


/* Get a unique filename in the temporary directory from the environment
   entry TMP or TEMP, if this fails, use current directory.  (replacement
   for tempnam(), whish is *too* touchy about trailing path separators!) */

char *
mktmpname (char *prefix)
{
  register int len;
  register char *ptr;
  register char *tmpname;
  static char default_prefix[3] = "vm";

  if (!prefix[0] || !prefix[1])	/* did the user supply a prefix? */
    prefix = default_prefix;

  if (!(ptr = getenv ("TMP")) && !(ptr = getenv ("TEMP")))
    {

      ptr = ".";
      len = 1;
    }
  else
    {
      len = strlen (ptr) - 1;
      if ((ptr[len] == FSLASH) || (ptr[len] == BSLASH))
	ptr[len] = '\0';
    }

  tmpname = xmalloc (len + 10);

  sprintf (tmpname, "%s\\%2sXXXXXX", ptr, prefix);
  mktemp (tmpname);

  return tmpname;
}


#ifdef TEST

extern void main (int ac, char **av);

void *
xmalloc (size_t size)
{
  void *result = malloc (size);
  if (result == NULL)
    {
      fprintf (stderr, "virtual memory exhausted");
      abort ();
    }
  return result;
}

void *
xrealloc (void *ptr, size_t size)
{
  void *result = realloc (ptr, size);
  if (result == NULL)
    {
      fprintf (stderr, "virtual memory exhausted");
      abort ();
    }
  return result;
}

void
main (int ac, char **av)
{
  int n = 0;
  int j = 2;
  char **argv;

  argv = (char **) xmalloc ((ac - 1) * sizeof (char **));

  while (j < ac)
    {
      argv[n] = (char *) xmalloc (strlen (av[j]) + 1);
      strcpy (argv[n++], av[j++]);
    }
  argv[n] = NULL;

  swap_and_spawnvp (av[1], *argv, argv);
}

#endif /* TEST */


/*
 * Local Variables:
 * mode:C
 * ChangeLog:ChangeLog
 * compile-command:cl -DTEST -W3 vmspawn.c swapcore
 * End:
 */
