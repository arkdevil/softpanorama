#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "queue.h"

/****************************************************************************
 *  InitQueue initializes a queue for use by the other queue functions.     *
 ****************************************************************************/

void InitQueue (QUE_DEF *Q)
{
	Q->Head = Q->Current = NULL;
	Q->Count = 0;
}

/****************************************************************************
 *  Enque  creates a queue entry linked to the other entries in FIFO order  *
 *  and puts the string passed into the queue entry.  It returns a pointer  *
 *  to the entry created [NULL if there is not enough memory for the entry. *
 ****************************************************************************/

QUE_ENTRY *Enque (QUE_DEF *Q, void *Body)
{
	QUE_ENTRY *p;

	if ((p = malloc(sizeof(QUE_ENTRY))) == NULL ) return(NULL);
	p->Next = NULL;
	if ((p->Body = malloc(strlen(Body) + 1)) == NULL) return(NULL);
	strcpy(p->Body, Body);
	if (Q->Head == NULL) Q->Head = p;
	else Q->Current->Next = p;
	Q->Current = p;
	++Q->Count;
	return(p);
}
