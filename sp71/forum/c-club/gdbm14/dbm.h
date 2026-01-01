/* dbm.h  -  The include file for dbm users.  */

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
 * $Header: e:/gnu/gdbm/RCS/dbm.h'v 1.4.0.1 90/08/16 09:22:56 tho Exp $
 */

/* The data and key structure.  This structure is defined for compatibility. */
typedef struct {
	char *dptr;
	int   dsize;
      } datum;



/* To make some versions work we need the following define. */

#define dbmclose()
/* These are the routines in dbm. */
#ifdef __STDC__
extern  int dbminit (char *file);
extern datum fetch(datum key);
extern int store (datum key, datum content);
extern int delete (datum key);
extern datum firstkey (void);
extern datum nextkey (datum key);
#else /* not __STDC__ */
extern int	dbminit ();
extern datum	fetch ();
extern int	store ();
extern int	delete ();
extern datum	firstkey ();
extern datum	nextkey ();
#endif /* not __STDC__ */
