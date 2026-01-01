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

#include "cache.h"
#include <stdio.h>
#if !defined(pyr)
#include <stdlib.h>
#endif
#include "strfn.h"

#define NOTINCACHE (0)
#define INCACHE (1)

/* this provides a cache of enteries in a list format. The format is a 
   move to front linked list. */

/* Author: Maurice Castro */

typedef struct liststr
{
   char *name;
   struct liststr *next;
   } LIST;

static int maxcachesize;
static int incache;
static LIST *list;

void initcache(size)
int size;
{
   list = NULL;
   maxcachesize = size;
   incache = 0;
   }

int searchcache(match, actual)
char *match;
char *actual;
{ 
   LIST *cur;
   LIST *prev;
   int mtc;
  
   if (list == NULL) return(NOTINCACHE);

   cur = list;
   prev = NULL;
   mtc = 0;

   while (cur != NULL)
   {
      if (!stricmp(match, cur->name)) 
      {
         mtc = 1;
         break;
         }
      prev = cur;
      cur = cur->next;
      }
   if (!mtc) 
      return(NOTINCACHE);
   if (prev != NULL)
   {
      prev->next = cur->next;
      cur->next = list;
      list = cur;
      }
   strcpy(actual, cur->name);
   return(INCACHE);
   }

int addtocache(item)
char *item;
{
    int i;
    LIST *cur;
    LIST *prev;
    LIST *newel;

    /* make new element */
    newel = (LIST *) malloc(sizeof(LIST));
    if (newel == NULL)
       return(0);
    newel->name = (char *) malloc(sizeof(char)*(strlen(item)+1));
    strcpy(newel->name, item);
    newel->next = NULL;

    /* cache full */
    if (incache >= maxcachesize)   
    {
       /* traverse cache */
       i = 0;
       cur = list;
       while (i < maxcachesize)
       {
          prev = cur;
          cur = cur->next;
          i++;
          }

       /* add new element */
       prev->next = NULL;
       newel->next = list;
       list = newel;
       incache = maxcachesize;

       /* fix overspill */
       while (cur != NULL)
       {
          prev = cur;
          cur = cur->next; 
          free(prev->name);
          free(prev);
          }
       return(1);
       }

    /* cache not full yet */
    incache++;

    if (list == NULL)
    {
       list = newel;
       return(1);
       }
    newel->next = list;
    list = newel;
    return(1);
    }

/* for debugging use only */

void printcache()
{
    LIST *cur;
    cur = list;
    while (cur != NULL)
    {
        printf("%s\n", cur->name);
        cur = cur->next;
        }
    }
