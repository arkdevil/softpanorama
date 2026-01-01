/* **************************************************************** */
/*             sspell - similar to Unix spell                       */
/*                        version 1.4                               */
/*                                                                  */
/* Author: Maurice Castro                                           */
/* Release Date:  4 Jul 1992                                         */
/* Bug Reports: maurice@bruce.cs.monash.edu.au                      */
/*                                                                  */
/* This code has been placed by the Author into the Public Domain.  */
/* The code is NOT covered by any warranty, the user of the code is */
/* solely responsible for determining the fitness of the program    */
/* for their purpose. No liability is accepted by the author for    */
/* the direct or indirect losses incurred through the use of this   */
/* program.                                                         */
/*                                                                  */
/* Segments of this code may be used for any purpose that the user  */
/* deems appropriate. It would be polite to acknowledge the source  */
/* of the code. If you modify the code and redistribute it please   */
/* include a message indicating your changes and how users may      */
/* contact you for support.                                         */
/*                                                                  */
/* The author reserves the right to issue the official version of   */
/* this program. If you have useful suggestions or changes for the  */
/* code, please forward them to the author so that they might be    */
/* incorporated into the official version                           */
/*                                                                  */
/* Please forward bug reports to the author via Internet.           */
/*                                                                  */
/* **************************************************************** */

#include "utility.h"
#include <stdio.h>
#include "strfn.h"

char *strip(a,b)
char *a;
char *b;
{
    char *match;
    char *pt;
    /* if the string 'a' contains any of string 'b' then chop them off */
    pt = a;
    while (*pt != NULL)
    {
        match = b;
        while (*match != NULL)
        {
            if (*match == *pt)
            {
               *pt = NULL;
               return(a);
               }
            match++;
            }
        pt++;
        }
    return(a);
    }

char *strltok(st,c,sthold)
char *st;
char *c;
char **sthold;
{
    char *stpt;
    char *sth;
    char *cp;
    int flag;
    char ch;

    if ((st == NULL) && (**sthold == NULL)) return(NULL); 

    if (st != NULL)
    {
        *sthold = st; 
	}

    /* skip leading */
    stpt = *sthold;
    while (*stpt)
    {
        cp = c;
        flag = 1;
        ch = *stpt;
        while (*cp)
        {
            if (ch == *cp)
               flag = 0;
            cp++;
            }
        if (flag) break;
        stpt++;
        }

    if (*stpt == NULL) return(NULL);  /* hit end of string */

    sth = stpt;

    /* if trailing clobber and exit */
    while (*sth) 
    {
        ch = *sth;
        cp = c;
        while (*cp)
	{
	    if (ch == *cp)
	    {
                *sth = NULL;
                *sthold = ++sth;
		return(stpt);
		}
	    cp++;
	    }
	sth++;    
	}
    *sthold = sth;
    return(stpt);
    }

/* some machines have difficulties with a NULL being presented as a string
   to the string copy operation. This new function prevents the problem,
   unfortunately it causes a minor performance loss - so it is only used
   in the root routine where the problem has been observed */

char *lstrcpy(s, ct)               /* the requirement for this check */
char *s;                           /* was found by Mike O'Carroll */
char *ct;                          /* M. Castro 4/3/92 */
{
     if (ct == NULL)
     {
         return(strcpy(s,""));
         }
     else
     {
         return(strcpy(s,ct));
         }
     }
