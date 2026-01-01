/***********************************************************************/
/* hash.h - REXX/SQL for Oracle                                        */
/***********************************************************************/
/*
 * REXX/SQL. A REXX interface to SQL databases.
 * Copyright Impact Systems Pty Ltd, 1994, 1995.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to:
 *
 *    The Free Software Foundation, Inc.
 *    675 Mass Ave,
 *    Cambridge, MA 02139 USA.
 *
 *
 * If you make modifications to this software that you feel increases
 * it usefulness for the rest of the community, please email the
 * changes, enhancements, bug fixes as well as any and all ideas to 
 * address below.
 * This software is going to be maintained and enhanced as deemed
 * necessary by the community.
 *
 * Mark Hessling                     email: M.Hessling@qut.edu.au
 * 36 David Road                     Phone: +61 7 849 7731
 * Holland Park                      
 * QLD 4121
 * Australia
 *
 * Author:	Chris O'Sullivan  Ph (Australia) 015 123414
 *
 * This is the header file for the hash routines. These routines allow
 * creation, insertion, location, deletion and destruction of objects
 * in a symbol table. The only restrictions on objects is that the first
 * data item must be the object's name as a char array (null terminated).
 * Any number of symbol tables may be used. The BUCKET structure is pre-
 * pended on the front of any object before storing in the table but this
 * is transparent to the caller.
 *
 */

typedef struct _BUCKET	{
    struct _BUCKET	*next;
    struct _BUCKET	**prev;
} BUCKET;

#ifdef __STDC__
void*  NewObject	(int size);
void   FreeObject	(void *obj);
void*  InsertObject	(void *obj, BUCKET *tbl[], int tblsz);
void   RemoveObject	(void *obj);
void*  FindObject	(char *name, BUCKET *tbl[], int tblsz);
void*  FirstObject	(int idx, BUCKET *tbl[]);
void*  NextObject	(void *obj);
#else
void*  NewObject	();
void   FreeObject	();
void*  InsertObject	();
void   RemoveObject	();
void*  FindObject	();
void*  FirstObject	();
void*  NextObject	();
#endif
