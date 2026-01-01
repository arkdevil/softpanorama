/*  cp.c  -- file copying (main routines)
    Copyright (C) 1989, 1990 Free Software Foundation.

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

    Written by Torbjorn Granlund and David MacKenzie. */

/* MS-DOS port (c) 1990 by Thorsten Ohl, ohl@gnu.ai.mit.edu
   This port is also distributed under the terms of the
   GNU General Public License as published by the
   Free Software Foundation.

   Please note that this file is not identical to the
   original GNU release, you should have received this
   code as patch to the official release.  */

static char RCS_Id[] =
  "$Header: e:/gnu/fileutil/RCS/cp.c 1.4.0.2 90/09/19 11:18:06 tho Exp $";

static char Program_Id[] = "cp";
static char RCS_Revision[] = "$Revision: 1.4.0.2 $";

#define VERSION \
  "GNU %s, Version %.*s (compiled %s %s for MS-DOS)\n", Program_Id, \
  (sizeof RCS_Revision - 14), (RCS_Revision + 11), __DATE__, __TIME__

#define COPYING \
  "This is free software, distributed under the terms of the\n" \
  "GNU General Public License.  For details, see the file COPYING.\n"

/* Yet to be done:

 * Symlink translation. */

#include <stdio.h>
#include <getopt.h>
#include "cp.h"
#include "backupfile.h"

#ifdef MSDOS
#include <assert.h>

extern enum backup_type get_version (char *version);
extern char *savedir (char *dir, unsigned name_size);

#define strip_trailing_slashes(path)	strip_trailing_slashes (&path)
#define is_ancestor(statb, ancestors)	0
#define hash_init(module, size)
#define remember_copied(path, ino, dev)	NULL
#define remember_created(path)		0
#define forget_all()
char new_file;

#endif

#ifdef MKFIFO_MISSING
/* This definition assumes that MODE has the S_IFIFO bit set. */
#define mkfifo(path, mode) (mknod ((path), (mode), 0))
#endif

enum backup_type get_version ();
int eaccess_stat ();

/* Initial number of entries in each hash table entry's table of inodes.  */
#define INITIAL_HASH_MODULE 100

/* Initial number of entries in the inode hash table.  */
#define INITIAL_ENTRY_TAB_SIZE 70

/* A pointer to either lstat or stat, depending on
   whether dereferencing of symlinks is done.  */
#ifdef MSDOS
int (*xstat) (char *, struct stat *);
#else
int (*xstat) ();
#endif

/* The invocation name of this program.  */
char *program_name;

/* If nonzero, copy all files except directories and, if not dereferencing
   them, symbolic links, as if they were regular files. */
int flag_copy_as_regular = 1;

/* If nonzero, dereference symbolic links (copy the files they point to). */
int flag_dereference = 1;

/* If nonzero, remove existing target nondirectories. */
int flag_force = 0;

/* If nonzero, query before overwriting existing targets with regular files. */
int flag_interactive = 0;

/* If nonzero, give the copies the original files' permissions,
   ownership, and timestamps. */
int flag_preserve = 0;

/* If nonzero, copy directories recursively and copy special files
   as themselves rather than copying their contents. */
int flag_recursive = 0;

/* If nonzero, when copying recursively, skip any subdirectories that are
   on different filesystems from the one we started on. */
int flag_one_file_system = 0;

/* If nonzero, do not copy a nondirectory that has an existing destination
   with the same or newer modification time. */
int flag_update = 0;

/* If nonzero, display the names of the files before copying them. */
int flag_verbose = 0;

/* The error code to return to the system. */
int exit_status = 0;

/* The bits to preserve in created files' modes. */
int umask_kill;

struct option long_opts[] =
{
#ifdef MSDOS
  {"copying", 0, NULL, 30},
  {"version", 0, NULL, 31},
#endif
  {"backup", 0, NULL, 'b'},
  {"force", 0, NULL, 'f'},
  {"interactive", 0, NULL, 'i'},
  {"no-dereference", 0, &flag_dereference, 0},
  {"one-file-system", 0, &flag_one_file_system, 1},
  {"preserve", 0, &flag_preserve, 1},
  {"recursive", 0, NULL, 'R'},
  {"suffix", 1, NULL, 'S'},
  {"update", 0, &flag_update, 1},
  {"verbose", 0, &flag_verbose, 1},
  {"version-control", 1, NULL, 'V'},
  {NULL, 0, NULL, 0}
};

void
main (argc, argv)
     int argc;
     char *argv[];
{
  int c;
  int ind;
  int make_backups = 0;
  char *version;

  program_name = argv[0];

  version = getenv ("SIMPLE_BACKUP_SUFFIX");
  if (version)
    simple_backup_suffix = version;
  version = getenv ("VERSION_CONTROL");

  /* Find out the current file creation mask, to knock the right bits
     when using chmod.  The creation mask is set to to be liberal, so
     that created directories can be written, even if it would not
     have been allowed with the mask this process was started with.  */

#ifdef MSDOS			/* not 100%ly correct ... */
  umask_kill = 07777 ^ umask (0);
#else
  umask_kill = 0777777 ^ umask (0);
#endif

  while ((c = getopt_long (argc, argv, "bdfipruvxRS:V:", long_opts, &ind))
	 != EOF)
    {
      switch (c)
	{
	case 0:
	  break;

	case 'b':
	  make_backups = 1;
	  break;

	case 'd':
	  flag_dereference = 0;
	  break;

	case 'f':
	  flag_force = 1;
	  flag_interactive = 0;
	  break;

	case 'i':
	  flag_force = 0;
	  flag_interactive = 1;
	  break;

	case 'p':
	  flag_preserve = 1;
	  break;

	case 'r':
	  flag_recursive = 1;
	  flag_copy_as_regular = 1;
	  break;

	case 'R':
	  flag_recursive = 1;
	  flag_copy_as_regular = 0;
	  break;

	case 'u':
	  flag_update = 1;
	  break;

	case 'v':
	  flag_verbose = 1;
	  break;

	case 'x':
	  flag_one_file_system = 1;
	  break;

	case 'S':
	  simple_backup_suffix = optarg;
	  break;

	case 'V':
	  version = optarg;
	  break;

#ifdef MSDOS
	case 30:
	  fprintf (stderr, COPYING);
	  exit (0);
	  break;

	case 31:
	  fprintf (stderr, VERSION);
	  exit (0);
	  break;
#endif

	default:
	  usage ((char *) 0);
	}
    }

  if (make_backups)
    backup_type = get_version (version);

  if (flag_preserve == 1)
#ifdef MSDOS			/* not 100%ly correct ... */
    umask_kill = 07777;
#else
    umask_kill = 0777777;
#endif

  /* The key difference between -d (+no-dereference) and not is the version
     of `stat' to call.  */

  if (flag_dereference)
    xstat = stat;
  else
    xstat = lstat;

  /* Allocate space for remembering copied and created files.  */

  hash_init (INITIAL_HASH_MODULE, INITIAL_ENTRY_TAB_SIZE);

  exit_status |= do_copy (argc, argv);

  exit (exit_status);
}

/* Scan the arguments, and copy each by calling copy.
   Return 0 if successful, 1 if any errors occur. */

int
do_copy (argc, argv)
     int argc;
     char *argv[];
{
  char *target;
  struct stat sb;
  int new_dst = 0;
  int ret = 0;

  if (optind >= argc)
    usage ("missing file arguments");
  if (optind >= argc - 1)
    usage ("missing file argument");

  target = argv[argc - 1];

  strip_trailing_slashes (target);

  if (lstat (target, &sb))
    {
      if (errno != ENOENT)
	{
	  error (0, errno, "%s", target);
	  return 1;
	}
      else
	new_dst = 1;
    }
  else
    {
      struct stat sbx;

      /* If `target' is not a symlink to a nonexistent file, use
	 the results of stat instead of lstat, so we can copy files
	 into symlinks to directories. */
      if (stat (target, &sbx) == 0)
	sb = sbx;
    }

  if (!new_dst && (sb.st_mode & S_IFMT) == S_IFDIR)
    {
      /* cp e_file_1...e_file_n e_dir
	 copy the files `e_file_1' through `e_file_n'
	 to the existing directory `e_dir'. */

      for (;;)
	{
	  char *arg;
	  char *ap;
	  char *dst_path;

	  arg = argv[optind];

	  strip_trailing_slashes (arg);

	  /* Append the last component of `arg' to `target'.  */

	  ap = rindex (arg, '/');
	  if (ap == 0)
	    ap = arg;
	  else
	    ap++;
	  dst_path = xmalloc (strlen (target) + strlen (ap) + 2);
#ifdef MSDOS
	  /* Here a trailing slash might still be present (needed for
	     stat()'ing root directories), take care of that. */
	  if (target[strlen(target) - 1] == '/')
	    stpcpy (stpcpy (dst_path, target), ap);
	  else
#endif /* MSDOS */
	  stpcpy (stpcpy (stpcpy (dst_path, target), "/"), ap);

	  ret |= copy (arg, dst_path, new_dst, 0, (struct dir_list *) 0);
	  forget_all ();

	  ++optind;
	  if (optind == argc - 1)
	    break;
	}
      return ret;
    }
  else if (argc - optind == 2)
    return copy (argv[optind], target, new_dst, 0, (struct dir_list *) 0);
  else
    usage ("when copying multiple files, last argument must be a directory");
}

/* Copy the file SRC_PATH to the file DST_PATH.  The files may be of
   any type.  NEW_DST should be non-zero if the file DST_PATH cannot
   exist because its parent directory was just created; NEW_DST should
   be zero if DST_PATH might already exist.  DEVICE is the device
   number of the parent directory, or 0 if the parent of this file is
   not known.  ANCESTORS points to a linked, null terminated list of
   devices and inodes of parent directories of SRC_PATH.
   Return 0 if successful, 1 if an error occurs. */

int
copy (src_path, dst_path, new_dst, device, ancestors)
     char *src_path;
     char *dst_path;
     int new_dst;
     dev_t device;
     struct dir_list *ancestors;
{
  struct stat src_sb;
  struct stat dst_sb;
  int src_mode;
#ifdef MSDOS
  unsigned int src_type;
#else /* not MSDOS */
  int src_type;
#endif /* not MSDOS */
  char *earlier_file;
  char *dst_backup = NULL;
  int dir_mode_changed = 0;

  if ((*xstat) (src_path, &src_sb))
    {
      error (0, errno, "%s", src_path);
      return 1;
    }

  /* Are we crossing a file system boundary?  */
  if (flag_one_file_system && device != 0 && device != src_sb.st_dev)
    return 0;

  /* We wouldn't insert a node unless nlink > 1, except that we need to
     find created files so as to not copy infinitely if a directory is
     copied into itself.  */

  earlier_file = remember_copied (dst_path, src_sb.st_ino, src_sb.st_dev);

  /* Did we just create this file?  */

  if (earlier_file == &new_file)
    return 0;

  src_mode = src_sb.st_mode;
  src_type = src_sb.st_mode & S_IFMT;
  if (flag_copy_as_regular && src_type != S_IFDIR
#ifdef S_IFLNK
      && src_type != S_IFLNK
#endif
      )
    src_type = S_IFREG;

  if (src_type == S_IFDIR && !flag_recursive)
    {
      error (0, 0, "%s: omitting directory", src_path);
      return 1;
    }

  if (!new_dst)
    {
      if ((*xstat) (dst_path, &dst_sb))
	{
	  if (errno != ENOENT)
	    {
	      error (0, errno, "%s", dst_path);
	      return 1;
	    }
	  else
	    new_dst = 1;
	}
      else
	{
	  /* The file exists already.  */
#ifdef MSDOS
	  if (strcmp (dst_path, src_path) == 0)
	    {
	      error (0, 0, "`%s': can't copy file to itself", src_path);
	      return 1;
	    }
#else /* not MSDOS */
	  if (src_sb.st_ino == dst_sb.st_ino && src_sb.st_dev == dst_sb.st_dev)
	    {
	      error (0, 0, "`%s' and `%s' are the same file",
		     src_path, dst_path);
	      return 1;
	    }
#endif /* not MSDOS */

	  if (src_type != S_IFDIR)
	    {
	      if ((dst_sb.st_mode & S_IFMT) == S_IFDIR)
		{
		  error (0, 0,
			 "%s: cannot overwrite directory with non-directory",
			 dst_path);
		  return 1;
		}

	      if (flag_update && src_sb.st_mtime <= dst_sb.st_mtime)
		return 0;
	    }

	  if (src_type == S_IFREG && !flag_force)
	    {
	      /* Treat the file as nonwritable if it lacks write permission
		 bits, even if we are root.  */
	      if (eaccess_stat (&dst_sb, W_OK) != 0
		  || (dst_sb.st_mode & 0222) == 0)
		{
		  error (0, 0, "%s: Permission denied", dst_path);
		  return 1;
		}

	      if (flag_interactive)
		{
		  fprintf (stderr, "%s: overwrite `%s'? ", program_name,
			   dst_path);
		  if (!yesno ())
		    return 0;
		}
	    }

	  if (backup_type != none && (dst_sb.st_mode & S_IFMT) != S_IFDIR)
	    {
	      dst_backup = find_backup_file_name (dst_path);
	      if (dst_backup == NULL)
		error (1, 0, "virtual memory exhausted");
	      if (rename (dst_path, dst_backup))
		{
		  if (errno != ENOENT)
		    {
		      error (0, errno, "cannot backup `%s'", dst_path);
		      free (dst_backup);
		      return 1;
		    }
		  else
		    {
		      free (dst_backup);
		      dst_backup = NULL;
		    }
		}
	      new_dst = 1;
	    }
	  else if (flag_force)
	    {
	      if ((dst_sb.st_mode & S_IFMT) == S_IFDIR)
		{
		  /* Temporarily change mode to allow overwriting. */
		  if (eaccess_stat (&dst_sb, W_OK | X_OK) != 0)
		    {
		      if (chmod (dst_path, 0700))
			{
			  error (0, errno, "%s", dst_path);
			  return 1;
			}
		      else
			dir_mode_changed = 1;
		    }
		}
	      else
		{
		  if (unlink (dst_path) && errno != ENOENT)
		    {
		      error (0, errno, "cannot remove old link to `%s'",
			     dst_path);
		      return 1;
		    }
		  new_dst = 1;
		}
	    }
	}
    }

  if (flag_verbose)
    printf ("%s -> %s\n", src_path, dst_path);

  /* Did we copy this inode somewhere else (in this command line argument)
     and therefore this is a second hard link to the inode?  */

  if (!flag_dereference && src_sb.st_nlink > 1 && earlier_file)
    {
      if (link (earlier_file, dst_path))
	{
	  error (0, errno, "%s", dst_path);
	  goto un_backup;
	}
      if (dst_backup)
	free (dst_backup);
      return 0;
    }

  switch (src_type)
    {
#ifdef S_IFIFO
    case S_IFIFO:
      if (mkfifo (dst_path, src_mode & umask_kill))
	{
	  error (0, errno, "cannot make fifo `%s'", dst_path);
	  goto un_backup;
	}
      break;
#endif

#ifndef MSDOS
    case S_IFBLK:
    case S_IFCHR:
#ifdef S_IFSOCK
    case S_IFSOCK:
#endif
      if (mknod (dst_path, src_mode & umask_kill, src_sb.st_rdev))
	{
	  error (0, errno, "cannot create special file `%s'", dst_path);
	  goto un_backup;
	}
      break;
#endif /* not MSDOS */

    case S_IFDIR:
      {
	struct dir_list *dir;

	/* If this directory has been copied before during the
           recursion, there is a symbolic link to an ancestor
           directory of the symbolic link.  It is impossible to
           continue to copy this, unless we've got an infinite disk.  */

	if (is_ancestor (&src_sb, ancestors))
	  {
	    error (0, 0, "%s: cannot copy cyclic symbolic link", src_path);
	    goto un_backup;
	  }

	/* Insert the current directory in the list of parents.  */

	dir = (struct dir_list *) alloca (sizeof (struct dir_list));
#ifdef MSDOS			/* always short of stack space ... */
	if (!dir)
	  error (1, 0, "%s: stack overflow", src_path);
#endif

	dir->parent = ancestors;
	dir->ino = src_sb.st_ino;
	dir->dev = src_sb.st_dev;

	if (new_dst || (dst_sb.st_mode & S_IFMT) != S_IFDIR)
	  {
	    /* Create the new directory writable and searchable, so
	       we can create new entries in it.  */

	    if (mkdir (dst_path, 0700))
	      {
		error (0, errno, "cannot create directory `%s'", dst_path);
		goto un_backup;
	      }

	    /* Insert the created directory's inode and device
	       numbers into the search structure, so that we can
	       avoid copying it again.  */

	    if (remember_created (dst_path))
	      goto un_backup;
	  }

	/* Copy the contents of the directory.  */

	if (copy_dir (src_path, dst_path, new_dst, &src_sb, dir))
	  goto err_return;
      }
      break;

    case S_IFREG:
      if (copy_reg (src_path, dst_path))
	goto un_backup;
      break;

#ifdef S_IFLNK
    case S_IFLNK:
      {
	char *link_val = (char *) alloca (src_sb.st_size + 1);

	if (readlink (src_path, link_val, src_sb.st_size) < 0)
	  {
	    error (0, errno, "cannot read symbolic link `%s'", src_path);
	    goto un_backup;
	  }
	link_val[src_sb.st_size] = '\0';

	if (symlink (link_val, dst_path))
	  {
	    error (0, errno, "cannot create symbolic link `%s'", dst_path);
	    goto un_backup;
	  }
      }
      return 0;
#endif

    default:
      error (0, 0, "%s: unknown file type", src_path);
      goto un_backup;
    }

  if ((flag_preserve || new_dst)
      && (src_type == S_IFREG || src_type == S_IFDIR))
    {
      if (chmod (dst_path, src_mode & umask_kill))
	{
	  error (0, errno, "%s", dst_path);
	  goto err_return;
	}
    }
  else if (dir_mode_changed)
    {
      /* Reset the temporarily changed mode.  */
      if (chmod (dst_path, dst_sb.st_mode))
	{
	  error (0, errno, "%s", dst_path);
	  goto err_return;
	}
    }

  /* Adjust the times (and if possible, ownership) for the copy. */

  if (flag_preserve)
    {
      struct utimbuf utb;

      utb.actime = src_sb.st_atime;
      utb.modtime = src_sb.st_mtime;

      if (utime (dst_path, &utb))
	{
	  error (0, errno, "%s", dst_path);
	  goto err_return;
	}

      if (chown (dst_path, src_sb.st_uid, src_sb.st_gid) && errno != EPERM)
	{
	  error (0, errno, "%s", dst_path);
	  goto err_return;
	}
    }

  if (dst_backup)
    free (dst_backup);
  return 0;

err_return:
  if (dst_backup)
    free (dst_backup);
  return 1;

un_backup:
  if (dst_backup)
    {
      if (rename (dst_backup, dst_path))
	error (0, errno, "cannot un-backup `%s'", dst_path);
      free (dst_backup);
    }
  return 1;
}

/* Read the contents of the directory SRC_PATH_IN, and recursively
   copy the contents to DST_PATH_IN.  NEW_DST is non-zero if
   DST_PATH_IN is a directory that was created previously in the
   recursion.   SRC_SB and ANCESTORS describe SRC_PATH_IN.
   Return 0 if successful, -1 if an error occurs. */

int
copy_dir (src_path_in, dst_path_in, new_dst, src_sb, ancestors)
     char *src_path_in;
     char *dst_path_in;
     int new_dst;
     struct stat *src_sb;
     struct dir_list *ancestors;
{
  char *name_space;
  char *namep;
  char *src_path;
  char *dst_path;
  int ret = 0;

  errno = 0;
#ifdef MSDOS
  assert (src_sb->st_size < 0xffffL);
  name_space = savedir (src_path_in, (size_t) src_sb->st_size);
#else
  name_space = savedir (src_path_in, src_sb->st_size);
#endif
  if (name_space == 0)
    {
      if (errno)
	{
	  error (0, errno, "%s", src_path_in);
	  return -1;
	}
      else
	error (1, 0, "virtual memory exhausted");
    }

  namep = name_space;
  while (*namep != '\0')
    {
      int fn_length = strlen (namep) + 1;

      dst_path = xmalloc (strlen (dst_path_in) + fn_length + 1);
      src_path = xmalloc (strlen (src_path_in) + fn_length + 1);

      stpcpy (stpcpy (stpcpy (src_path, src_path_in), "/"), namep);
      stpcpy (stpcpy (stpcpy (dst_path, dst_path_in), "/"), namep);

      ret |= copy (src_path, dst_path, new_dst, src_sb->st_dev, ancestors);

      /* Free the memory for `src_path'.  The memory for `dst_path'
	 cannot be deallocated, since it is used to create multiple
	 hard links.  */

      free (src_path);

      namep += fn_length;
    }
  free (name_space);
  return -ret;
}

/* Copy a regular file from SRC_PATH to DST_PATH.  Large blocks of zeroes,
   as well as holes in the source file, are made into holes in the
   target file.  (Holes are read as zeroes by the `read' system call.)
   Return 0 if successful, -1 if an error occurred. */

int
copy_reg (src_path, dst_path)
     char *src_path;
     char *dst_path;
{
  char *buf;
  int buf_size;
  int target_desc;
  int source_desc;
  int n_read;
  int n_written;
  struct stat sb;
  int return_val = 0;
  long n_read_total = 0;
  char *cp;
  int *ip;
  int last_write_made_hole = 0;

#ifdef MSDOS
  source_desc = open (src_path, O_BINARY | O_RDONLY);
#else
  source_desc = open (src_path, O_RDONLY);
#endif
  if (source_desc < 0)
    {
      error (0, errno, "%s", src_path);
      return -1;
    }

  /* Create the new regular file with small permissions initially,
     to not create a security hole.  */

#ifdef MSDOS
  target_desc = open (dst_path, O_BINARY|O_WRONLY|O_CREAT|O_TRUNC, 0600);
#else
  target_desc = open (dst_path, O_WRONLY | O_CREAT | O_TRUNC, 0600);
#endif
  if (target_desc < 0)
    {
      error (0, errno, "cannot create regular file `%s'", dst_path);
      return_val = -1;
      goto ret2;
    }

  /* Find out the appropriate buffer length.  */

  if (fstat (target_desc, &sb))
    {
      error (0, errno, "%s", dst_path);
      return_val = -1;
      goto ret;
    }

  buf_size = ST_BLKSIZE (sb);

  /* Make a buffer with space for a sentinel at the end.  */

  buf = (char *) alloca (buf_size + sizeof (int));
#ifdef MSDOS
  if (!buf)
    error (2, 0, "%s: stack overflow", src_path);
#endif

  for (;;)
    {
      n_read = read (source_desc, buf, buf_size);
      if (n_read < 0)
	{
	  error (0, errno, "%s", src_path);
	  return_val = -1;
	  goto ret;
	}
      if (n_read == 0)
	break;

#ifdef MSDOS
      n_read_total += (long) n_read;
#else
      n_read_total += n_read;
#endif

      buf[n_read] = 1;		/* Sentinel to stop loop.  */

      /* Find first non-zero *word*, or the word with the sentinel.  */

      ip = (int *) buf;
      while (*ip++ == 0)
	;

      /* Find the first non-zero *byte*, or the sentinel.  */

      cp = (char *) (ip - 1);
      while (*cp++ == 0)
	;

      /* If we found the sentinel, the whole input block was zero,
	 and we can make a hole.  */

      if (cp > buf + n_read)
	{
	  /* Make a hole.  */
	  if (lseek (target_desc, (off_t) n_read, L_INCR) < 0L)
	    {
	      error (0, errno, "%s", dst_path);
	      return_val = -1;
	      goto ret;
	    }
	  last_write_made_hole = 1;
	}
      else
	{
	  n_written = write (target_desc, buf, n_read);
	  if (n_written < n_read)
	    {
	      error (0, errno, "%s", dst_path);
	      return_val = -1;
	      goto ret;
	    }
	  last_write_made_hole = 0;
	}
    }

  /* If the file ends with a `hole', something needs to be written at
     the end.  Otherwise the kernel would truncate the file at the end
     of the last write operation.  */

  if (last_write_made_hole)
    {
      /* Seek backwards one character and write a null.  */
      if (lseek (target_desc, (off_t) -1, L_INCR) < 0L
	  || write (target_desc, "", 1) != 1)
	{
	  error (0, errno, "%s", dst_path);
	  return_val = -1;
	}
    }

ret:
  close (target_desc);
ret2:
  close (source_desc);

  return return_val;
}
