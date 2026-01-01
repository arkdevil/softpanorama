/* global.c - The external variables needed for "original" interface and
   error messages. */

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
 * $Header: e:/gnu/gdbm/RCS/global.c'v 1.4.0.1 90/08/16 09:22:36 tho Exp $
 */

#include <stdio.h>
#include "gdbmdefs.h"
#include "gdbmerrno.h"


/* The global variables used for the "original" interface. */
gdbm_file_info  *_gdbm_file = NULL;

/* Memory for return data for the "original" interface. */
datum _gdbm_memory = {NULL, 0};	/* Used by firstkey and nextkey. */
char *_gdbm_fetch_val = NULL;	/* Used by fetch. */

/* The dbm error number is placed in the variable GDBM_ERRNO. */
#ifdef MSDOS		/* won't go into library if not initialized!  */
gdbm_error gdbm_errno = GDBM_NO_ERROR;
#else /* not MSDOS */
gdbm_error gdbm_errno;
#endif /* not MSDOS */
