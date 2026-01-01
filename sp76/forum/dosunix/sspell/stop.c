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

/* This set of routines provides the stop list */

/* The stop list implementation is grossly inefficient, however, the  */
/* stop list should be very short so the time penalty should be small */
/* in comparison to the processing time. If the stop list gets large  */
/* then the rules are wrong or inefficient. It is recommended that    */
/* the offending rules producing the large number of wrong results be */
/* removed and the correct words provided by the rule be added to the */
/* dictionary                                                         */

#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#if !defined(pyr)
#include <stdlib.h>
#endif
#include "error.h"
#include "config.h"
#include "stop.h"
#include "strfn.h"

typedef struct liststr
{
   char *name;
   struct liststr *next;
   } LIST;

static int maxcachesize;
static LIST *list;

static void memfail()
{
   errormesg("Error: Out of Memory! Terminating",-3);
   }

void initstop(stop)
char *stop;
{
	FILE *f;
	char instr[MAXSTR];
	LIST *cur;
	char *c;
	int i;

	f = fopen(stop,"rt");
	if (f == NULL)
		return;

	i = 0;
	if (fgets(instr, MAXSTR, f) == NULL)
		return;
	c = strrchr(instr,'\n');
	if (c != NULL)
		*c = NULL;

	list = (LIST *) malloc(sizeof(LIST));
	if (list == NULL) 
		memfail();
	list->name = (char *) malloc(strlen(instr)+1);
	if (list->name == NULL) 
		memfail();
	strcpy(list->name, instr);
	list->next = NULL;

	cur = list;
	
	while (!feof(f))
	{              
		if (fgets(instr, MAXSTR, f) == NULL)
			break;
		c = strrchr(instr,'\n');
		if (c != NULL)
			*c = NULL;
		cur->next = (LIST *) malloc(sizeof(LIST));
		if (cur->next == NULL)
			memfail();
		cur = cur->next;
		cur->name = (char *) malloc(strlen(instr)+1);
		if (cur->name == NULL)
			memfail();
		strcpy(cur->name, instr);
		cur->next = NULL;
		i++;
		if (i > MAXSTOP)
		{
			fprintf(stderr, "Warning: Stop list file too large\n");
			fprintf(stderr, "Ignoring entries beyond: %s\n", instr);
			fprintf(stderr, "Revise rule file and edit stop list\n");
			break;
			}
		}
	fclose(f);
	}

int instop(s)
char *s;
{
	LIST *cur;
	cur = list;
	while (cur != NULL)
	{
		if (!strcmp(cur->name, s))
			return(1);
		cur = cur->next;
		}
	return(0);
	}
