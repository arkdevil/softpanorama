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
/* Contributors: mao@physics.su.oz.au                               */
/*                                                                  */
/* **************************************************************** */

#include <stdio.h>
#include "string.h"

int toupper(a)
int a;
{
    if (('a' <= a) && (a <= 'z'))
       a = a - 'a' + 'A';
    return(a);
    }

char *strtok(st,c)
char *st;
char *c;
{
    static char *sthold;
    static forevernull;
    char *stpt;
    int cl;
    int flag;

    if (!forevernull) sthold++;

    if (st != NULL)
    {
        sthold = st; 
        forevernull = 0;
	}

    if (forevernull) return(NULL);

    /* skip leading */
    stpt = sthold;
    while (*stpt != NULL)
    {
        cl = 0;
        flag = 1;
        while (c[cl] != NULL)
        {
            if (*stpt == c[cl])
               flag = 0;
            cl++;
            }
        if (flag) break;
        stpt++;
        }

    if (*stpt == NULL) return(NULL);  /* hit end of string */

    sthold = stpt;

    /* if trailing clobber and exit */
    while (*sthold != NULL) 
    {
        cl = 0;
        while (c[cl] != NULL)
	{
	    if (*sthold == c[cl])
	    {
		*sthold = NULL;
		return(stpt);
		}
	    cl++;
	    }
	sthold++;
	}
    forevernull = 1;
    return(stpt);
    }

char *strstr(cs,ct)
char *cs;
char *ct;
{
    int i;
    int j;

    i = 0;
    while (cs[i] != NULL)
    {
	j = 0;
	while ((ct[j] != NULL) && (cs[i+j] == ct[j]))
	    j++;
	if (ct[j] == NULL)
	    return(&(cs[i]));
	i++;
	}
    return(NULL);
    }

void *memcpy(st, ct, n)
char *st;
char *ct;
long n;
{
    long i;

    for (i=0; i<n; i++)
    {
        *st = *ct;
        ct++;
        st++;
        }
    return ((void *) st);
    }

int memcmp(st, ct, n)
char *st;
char *ct;
long n;
{
    long i;
    
    for (i=0; i <n; i++)
    {
        if (*st < *ct) return (-1);
        if (*st > *ct) return (1); 
        st++;
        ct++;
        }
    return(0);
    }

char *strchr(cs, c)
char *cs;
int c;
{
    int csearch;

    csearch = (char) c;
    while (*cs != NULL)
    {
        if (*cs == csearch)
           return(cs);
        cs++;
        }
    return(NULL);
    }

char *strrchr(cs, c)
char *cs;
int c;
{
    int csearch;
    char *cc;

    cc = cs;
    csearch = (char) c;
    while (cs != cc)
    {
        if (*cc == csearch)
           return(cc);
        cc--;
        }
    if (*cc == csearch)
       return(cc);
    return(NULL);
    }

int stricmp(a, b)
char *a;
char *b;
{
    while ((*a != NULL) && (*b != NULL) && (toupper(*a) == toupper(*b)))
    {
       a++;
       b++;
       }
    if ((*a == NULL) && (*b == NULL)) return(0); /* they are equal */
    if (toupper(*a) > toupper(*b)) return(1);
    return(-1);
    }

int strnicmp(a, b, n)
char *a;
char *b;
{
    int i;
    i = 0;
    while ((*a != NULL) && (*b != NULL) && (toupper(*a) == toupper(*b)) && (++i < n))
    {
       a++;
       b++;
       }
    if (i == n) return(0);
    if ((*a == NULL) && (*b == NULL)) return(0); /* they are equal */
    if (toupper(*a) > toupper(*b)) return(1);
    return(-1);
    }
