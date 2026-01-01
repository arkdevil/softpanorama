/**/
/*
/*      coproc.c
/*
/*      (C) Copyright by Serge Babkin, 1993
/*
/*      Any part of this code may be freely distributed for
/*      the non-commertial use when it contains this copyright
/*      notice only.
/*
/*      My FIDO address is: 2:5010/4
/*
/**/

#include <setjmp.h>
#include <stdio.h>
#include <malloc.h>

/************************ Configuring ********************************/

/* Uncomment the following line when compiling under MS DOS */
/* #define DOS */

/************************ Types **************************************/

typedef unsigned short ushort;

/* define the coprocess structure */

typedef struct coproc
{
	struct coproc *nxt;	/* next process in a queue */
	struct coproc *prv;	/* previous process in a queue */
	struct sframe *frm;	/* stack frame */
	jmp_buf setjmp;		/* entry point to this coprocess */
	char   *event;		/* which event this process is sleeping on */
	ushort  pri;		/* priority */
	ushort  pid;		/* coprocess id */
}       coproc_t;

/* define the stack frame */

typedef struct sframe
{
	struct sframe *nxt;	/* next frame in a queue */
	struct sframe *prv;	/* previous frame in a queue */
	struct coproc *proc;	/* coprocess in this frame */
	jmp_buf setjmp;		/* jump to header */
	int     maxfrm;		/* maximal number of function frames */
	int     varsz;		/* maximal size of variables */
	int     ( *func ) (  );	/* main function of the current coprocess */
}       sframe_t;

/*************************** Global variables **********************/

/* global queues */

static coproc_t runq = {&runq, &runq};	/* runnable processes */
static coproc_t slepq = {&slepq, &slepq};	/* sleeping processes */
static sframe_t freefq = {&freefq, &freefq};	/* free frames */

/* current context */

static coproc_t *curproc;	/* current process */
static sframe_t *lastframe;	/* last frame */
static ushort nextpid = 0;	/* next pid */

/* temporary variables used for allocation of stack frame */
static int glb_maxfrm,
        glb_varsz;
static jmp_buf get_jmpbuf;

int     lbolt;			/* special address for sleeping, used for
				 * sleep on no event */

/**************************** Constants ********************************/

/* messages for longjmp() */

#define WAKEUP          1	/* wake up process */
#define ADDFRAME        2	/* add new frame to stack */
#define RMPROC          3	/* remove process */

/****************** Predefinitions of functions *************************/

static sframe_t *getnewframe(  );
static  framehead(  );
static  allocspace(  );
static  allocframe(  );
static  rmcoproc(  );

/************************* cosleep ***********************************/
/* cosleep(event,pri) - sleep on event with priority pri             */
/*********************************************************************/

cosleep( event, pri )
	char   *event;
{

	curproc->event = event;
	curproc->pri = ( ushort ) pri;

	if ( event == ( char * ) &lbolt )
	{			/* when simply pass the control */
		coproc_t *pr;

		/* found appropriate place in the runnable queue */
		for ( pr = runq.nxt; pr != &runq && pr->pri <= pri; pr = pr->nxt );

		/* and insert current process before process found */

		curproc->nxt = pr;
		curproc->prv = pr->prv;
		pr->prv->nxt = curproc;
		pr->prv = curproc;
	}
	else
	{
		/* insert it to the begin of sleeping queue */

		curproc->nxt = slepq.nxt;
		curproc->prv = &slepq;
		slepq.nxt->prv = curproc;
		slepq.nxt = curproc;
	}
/* and sleep until woken up */

	if ( setjmp( curproc->setjmp ) == WAKEUP )
		return;

/* reschedule some new coprocess */

	if ( runq.nxt == &runq && slepq.nxt == &slepq )
	{
		exit( 0 );
	}

	while ( runq.nxt == &runq )
	{			/* sleep while no coprocesses to run */
		/* i.e. until the waking up signal in UNIX */
		/* or interrupt in DOS                     */

#       ifndef DOS
		sleep( 100 );
#       endif
	}

	curproc = runq.nxt;
	runq.nxt = curproc->nxt;
	curproc->nxt->prv = &runq;

	longjmp( curproc->setjmp, WAKEUP );
}

/***************************** cofork ***********************************/
/* cofork(func,maxfrm,varsz) - create the new coprocess with the main   */
/*   function func, stack frame for maximal maxfrm function calls and   */
/*   maximal size of local variables varsz.                             */
/************************************************************************/

cofork( func, maxfrm, varsz )
	int     ( *func ) (  );
{
	coproc_t *pr;
	sframe_t *fr;

/* try to get a coprocess table entry */

	if ( ( pr = ( coproc_t * ) malloc( sizeof( coproc_t ) ) ) == 0 )
		return -1;

	glb_maxfrm = maxfrm;
	glb_varsz = varsz;

/* try to use some free frame from the list of free frames */

	for ( fr = freefq.nxt; fr != &freefq; fr = fr->nxt )
	{
		if ( fr->maxfrm >= maxfrm && fr->varsz >= varsz )
			break;
	}

	if ( fr == &freefq )
	{			/* if no free frame, allocate new one */
		if ( ( fr = getnewframe(  ) ) == 0 )
		{
			free( pr );
			return -1;
		}
	}
	else
	{			/* remove it from the queue */
		fr->nxt->prv = fr->prv;
		fr->prv->nxt = fr->nxt;
	}

/* set up frame */

	fr->proc = pr;
	fr->func = func;

/* set up coprocess and add it to begin of the runnable queue */

	pr->pid = nextpid++;
	pr->frm = fr;
	memcpy( pr->setjmp, fr->setjmp, sizeof( jmp_buf ) );

	pr->prv = &runq;
	pr->nxt = runq.nxt;
	runq.nxt->prv = pr;
	runq.nxt = pr;

	pr->pri = 0;

	return 0;
}

/************************* getnewframe *********************************/
/* getnewframe() - gets new stack frame                                */
/***********************************************************************/

static sframe_t *getnewframe(  )
{
	sframe_t *nfrm;

	if ( ( nfrm = lastframe ) == 0 )
		return 0;

	nfrm->maxfrm = glb_maxfrm;
	nfrm->varsz = glb_varsz;

	if ( setjmp( get_jmpbuf ) == WAKEUP )
		return nfrm;
	longjmp( nfrm->setjmp, ADDFRAME );
}

/*********************** framehead ************************************/
/* framehead() - header of stack frame, used to create the new frame  */
/**********************************************************************/

static  framehead(  )
{
	sframe_t *frm;

	if ( ( lastframe = ( sframe_t * ) malloc( sizeof( sframe_t ) ) ) == 0 )
	{
		/* if unable to create the new frame */

		longjmp( get_jmpbuf, WAKEUP );
	}

	lastframe->func = 0;
	frm = lastframe;

	switch ( setjmp( frm->setjmp ) )
	{
		case WAKEUP:
			frm->func(  );
			rmcoproc( frm );
		case ADDFRAME:
			allocspace(  );
		case RMPROC:
			rmcoproc( frm );
	}
	longjmp( get_jmpbuf, WAKEUP );
}

/*************************** allocspace ********************************/
/* allocspace() - allocate one function frame and 1K of space for      */
/*   local variables in the stack                                      */
/***********************************************************************/

static  allocspace(  )
{
	char    v[1024];

	glb_maxfrm--;
	glb_varsz--;

	if ( glb_varsz <= 0 )
		if ( glb_maxfrm <= 0 )
			framehead(  );
		else
			allocframe(  );
	allocspace(  );
}

/************************* allocframe ***********************************/
/* allocframe() - allocate one function frame in the stack              */
/************************************************************************/

static  allocframe(  )
{
	if ( glb_maxfrm-- <= 0 )
		framehead(  );
	allocframe(  );
}

/************************ rmcoproc ****************************************/
/* rmcoproc(frm) - remove coprocess in frame frm                          */
/**************************************************************************/

static  rmcoproc( frm )
	sframe_t *frm;
{
	coproc_t *p;

	p = frm->proc;

/* free process structure */
	free( frm->proc );

/* insert frame to end of free frames queue */

	frm->nxt = &freefq;
	frm->prv = freefq.prv;
	freefq.prv->nxt = frm;
	freefq.prv = frm;

/* reschedule some new coprocess */

	if ( runq.nxt == &runq && slepq.nxt == &slepq )
	{
		exit( 0 );
	}

	while ( runq.nxt == &runq )
	{			/* sleep while no coprocesses to run */
#	ifndef DOS
		sleep( 100 );
#	endif
	}

	curproc = runq.nxt;
	runq.nxt = curproc->nxt;
	curproc->nxt->prv = &runq;

	longjmp( curproc->setjmp, WAKEUP );
}

/****************************** run1coproc **********************************/
/* run1coproc(func,maxfrm,varsz) - create the first coprocess with the main */
/*   function func, stack frame for maximal maxfrm function calls and       */
/*   maximal size of local variables varsz.                                 */
/****************************************************************************/

run1coproc( func, maxfrm, varsz )
	int     ( *func ) (  );
{
	sframe_t *frm;
	coproc_t *pr;

	if ( ( pr = ( coproc_t * ) malloc( sizeof( coproc_t ) ) ) == 0 )
		return -1;

	lastframe = frm = ( sframe_t * ) malloc( sizeof( sframe_t ) );

	if ( frm == 0 )
	{
		free( pr );
		return -1;
	}

	frm->maxfrm = glb_maxfrm = maxfrm;
	frm->varsz = glb_varsz = varsz;
	frm->proc = pr;
	frm->func = func;
	pr->pid = nextpid++;
	pr->frm = frm;

/* runq.nxt=runq.prv=pr; pr->nxt=pr->prv=&runq; */
	curproc = pr;

	switch ( setjmp( frm->setjmp ) )
	{
		case WAKEUP:
			frm->func(  );
			rmcoproc( frm );
		case RMPROC:
			rmcoproc( frm );
	}

	memcpy( frm->proc->setjmp, frm->setjmp, sizeof( jmp_buf ) );
	memcpy( get_jmpbuf, frm->setjmp, sizeof( jmp_buf ) );

	allocspace(  );
}

/************************* cowakeup ************************************/
/* cowakeup(event) - wake up all processes sleeping on event           */
/***********************************************************************/

cowakeup( event )
	char   *event;
{
	coproc_t *cpr,
	       *pr,
	       *tpr;

	for ( cpr = slepq.nxt; cpr != &slepq; cpr = tpr )
	{
		tpr = cpr->nxt;

		if ( cpr->event == event )
		{
			/* remove this process from the sleeping queue */
			cpr->nxt->prv = cpr->prv;
			cpr->prv->nxt = cpr->nxt;

			/* found appropriate place in the runnable queue */
			for ( pr = runq.nxt; pr != &runq && pr->pri <= cpr->pri; pr = pr->nxt );

			/* and insert current process before process found */

			cpr->nxt = pr;
			cpr->prv = pr->prv;
			pr->prv->nxt = cpr;
			pr->prv = cpr;
		}
	}
}

/*********************** coexit *****************************************/
/* coexit() - terminate current process                                 */
/************************************************************************/

coexit(  )
{
	longjmp( curproc->frm->setjmp, RMPROC );
}

/*************************** cogetpid ***********************************/
/* cogetpid() - returns the PID of current coprocess                    */
/************************************************************************/

cogetpid(  )
{
	return curproc->pid;
}
