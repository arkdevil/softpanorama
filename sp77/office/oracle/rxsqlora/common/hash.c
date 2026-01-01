/***********************************************************************/
/* hash.c - REXX/SQL for Oracle                                        */
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
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "hash.h"



/*
 * Calculate the hash function of a given string.
 */
	
static int
#if __STDC__
Hash(char *s, int table_size)
#else
Hash(s, table_size)
    char	*s;
    int		table_size;
#endif
{
    int		h=0;
    int		ch=0;

    while ((ch = *s++))
        h = (3*h + ch) % table_size;
    return (h);
}



void*
#if __STDC__
NewObject(int size)
#else
NewObject(size)
    int	 size;
#endif
{
    /* Allocate space for a new object contained within a bucket structure.
     * Return a pointer to the object (not the encapsulating bucket).
     */
    BUCKET  *obj=NULL;

    if (!(obj = (BUCKET*)calloc(size+sizeof(BUCKET), 1))) {
        return NULL;
    }
    return (void*)(obj+1);	/* Return pointer to user object */
}


/*
 * Free a user object (and encapsulating bucket).
 */
void
#if __STDC__
FreeObject(void *obj)
#else
FreeObject(obj)
    void  *obj;
#endif
{
    free((BUCKET*)obj-1);
}



/*
 * Insert an object into the hashed table.
 */
void*
#if __STDC__
InsertObject(void *obj, BUCKET *tbl[], int tblsz)
#else
InsertObject(obj, tbl, tblsz)
    void    *obj;
    BUCKET  *tbl[];
    int     tblsz;
#endif
{
    BUCKET	**p=NULL, *tmp=NULL;
    BUCKET	*bkt = (BUCKET*)obj - 1;

    p = &tbl[Hash((char*)obj, tblsz)];
    tmp = *p;
    *p = bkt;
    bkt->prev = p;
    bkt->next = tmp;

    if (tmp)
        tmp->prev = &bkt->next;

    return (void*)(bkt+1);
}



/*
 * Remove an object from the table.
 */
void
#if __STDC__
RemoveObject(void *obj)
#else
RemoveObject(obj)
    void	*obj;
#endif
{
    BUCKET	*bkt = (BUCKET*)obj - 1;

    if (*(bkt->prev) = bkt->next)
        bkt->next->prev = bkt->prev;
}



void*
#if __STDC__
FindObject(char *name, BUCKET *tbl[], int tblsz)
#else
FindObject(name, tbl, tblsz)
    char    *name;
    BUCKET  *tbl[];
    int     tblsz;
#endif
{
    BUCKET  *p=NULL;

    p = tbl[Hash(name,tblsz)];
    while (p && (strcmp(name,(char*)(p+1))))
        p = p->next;
    return (void*)(p ? p+1 : NULL);
}



void*
#if __STDC__
FirstObject(int idx, BUCKET *tbl[])
#else
FirstObject(idx, tbl)
    int     idx;
    BUCKET  *tbl[];
#endif
{
    BUCKET  *p=NULL;

    p = tbl[idx];
    return (void*)(p ? p+1 : NULL);
}


void*
#if __STDC__
NextObject(void *obj)
#else
NextObject(obj)
    void	*obj;
#endif
{
    BUCKET	*bkt = (BUCKET*)obj - 1;

    bkt = bkt->next;
    return (void*)(bkt ? bkt+1 : NULL);
}
