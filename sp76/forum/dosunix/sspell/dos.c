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

#ifdef __MSDOS__
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* fix the slashes before submitting a command to MS-DOS */
void dosfix(s)
char *s;
{
char *t;
    t=s;
    while (*t != NULL)
    {
	if (*t == '/')
	    *t = '\\';
	t++;
	}
    t=s;
    while (*t != NULL)
    {
	if (*t == '\\' && *(t+1) == '\\')
	    memmove(t,t+1,strlen(t));	/* remove duplicate separators */
	else
	    t++;
	}
    }
#endif
