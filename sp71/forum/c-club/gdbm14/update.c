/* update.c - The routines for updating the file to a consistent state. */

/*  This file is part of GDBM, the GNU data base manager, by Philip A. Nelson.
    Copyright (C) 1990  Free Software Foundation, Inc.

    GDBM is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 1, or (at your option)
    any later version.

    GDBM is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with GDBM; see the file COPYING.  If not, write to
    the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

    You may contact the author by:
       e-mail:  phil@wwu.edu
      us-mail:  Philip A. Nelson
                Computer Science Department
                Western Washington University
                Bellingham, WA 98226
        phone:  (206) 676-3035
       
*************************************************************************/

/*
 * MS-DOS port (c) 1990 by Thorsten Ohl, ohl@gnu.ai.mit.edu
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
 * $Header: e:/gnu/gdbm/RCS/update.c'v 1.4.0.1 90/08/16 09:22:53 tho Exp $
 */

#include <stdio.h>
#include <sys/types.h>
#ifndef MSDOS
#include <sys/file.h>
#endif /* not MSDOS */
#include "gdbmdefs.h"
#include "systems.h"

#ifdef __STDC__
static void write_header (gdbm_file_info *dbf);
#endif /* __STDC__ */

/* This procedure writes the header back to the file described by DBF. */

static VOID
write_header (dbf)
     gdbm_file_info *dbf;
{
  LONG num_bytes;

  num_bytes = lseek (dbf->desc, (LONG) 0, L_SET);
  if (num_bytes != 0) _gdbm_fatal (dbf, "lseek error");
#ifdef MSDOS
  num_bytes = write (dbf->desc, (char *) dbf->header, dbf->header->block_size);
#else /* not MSDOS */
  num_bytes = write (dbf->desc, dbf->header, dbf->header->block_size);
#endif /* not MSDOS */
  if (num_bytes != dbf->header->block_size)
    _gdbm_fatal (dbf, "write error");

  /* Wait for all output to be done. */
  fsync (dbf->desc);
}


/* After all changes have been made in memory, we now write them
   all to disk. */
VOID
_gdbm_end_update (dbf)
     gdbm_file_info *dbf;
{
  LONG num_bytes;	/* Return value for lseek and write. */
  
  /* Write the current bucket. */
  if (dbf->bucket_changed)
    {
      _gdbm_write_bucket (dbf, dbf->cache_entry);
      dbf->bucket_changed = FALSE;
    }

  /* Write the other changed buckets if there are any. */
  if (dbf->second_changed)
    {
      int index;

      for (index = 0; index < CACHE_SIZE; index++)
	if (dbf->bucket_cache[index].ca_changed)
	  {
	    _gdbm_write_bucket (dbf, &dbf->bucket_cache[index]);
	  }
      dbf->second_changed = FALSE;
    }
  
  /* Write the directory. */
  if (dbf->directory_changed)
    {
      num_bytes = lseek (dbf->desc, dbf->header->dir, L_SET);
      if (num_bytes != dbf->header->dir) _gdbm_fatal (dbf, "lseek error");
#ifdef MSDOS			/* shut up the compiler!  */
      num_bytes = write (dbf->desc, (char *) dbf->dir, dbf->header->dir_size);
#else /* not MSDOS */
      num_bytes = write (dbf->desc, dbf->dir, dbf->header->dir_size);
#endif /* not MSDOS */
      if (num_bytes != dbf->header->dir_size)
	_gdbm_fatal (dbf, "write error");
      dbf->directory_changed = FALSE;
      if (!dbf->header_changed) fsync (dbf->desc);
    }

  /* Final write of the header. */
  if (dbf->header_changed)
    {
      write_header (dbf);
      dbf->header_changed = FALSE;
    }
}


/* If a fatal error is detected, come here and exit. VAL tells which fatal
   error occured. */
VOID
_gdbm_fatal (dbf, val)
     gdbm_file_info *dbf;
     char *val;
{
  if (dbf->fatal_err != NULL)
    (*dbf->fatal_err) (val);
  else
    fprintf (stderr, "gdbm fatal: %s.\n", val);
  exit (-1);
}

