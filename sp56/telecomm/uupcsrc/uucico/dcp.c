/*
   For best results in visual layout while viewing this file, set
   tab stops to every 4 columns.
*/

/*
   dcp.c

   Revised edition of dcp

   Stuart Lynne May/87

   Copyright (c) Richard H. Lamb 1985, 1986, 1987
   Changes Copyright (c) Stuart Lynne 1987
   Changes Copyright (c) Andrew H. (Drew) Derbyshire 1989, 1990

   Maintenance Notes:

   25Aug87 - Added a version number - Jal
   25Aug87 - Return 0 if contact made with host, or 5 otherwise.
   04Sep87 - Bug causing premature sysend() fixed. - Randall Jessup.
   13May89 - Add date to version message  - Drew Derbyshire
   17May89 - Add '-u' (until) option for login processing
   01 Oct 89      Add missing function prototypes                    ahd
   28 Nov 89      Add parse of incoming user id for From record      ahd
   18 Mar 90      Change checktime() calls to Microsoft C 5.1        ahd
*/

/* "DCP" a uucp clone. Copyright Richard H. Lamb 1985,1986,1987 */

/*
   This program implements a uucico type file transfer and remote
   execution protocol.

   Usage:   uuio [-s sys] [-r 0|1] [-x debug]

   e.g.

   uuio [-x n] -r 0 [-u time]    client mode, wait for an incoming call
			 until 'time'.
   uuio [-x n] -s HOST     call the host "HOST".
   uuio [-x n] -s all      call all known hosts in the systems file.
   uuio [-x n] -s any      call any host we have work queued for.
   uuio [-x n]          same as the above.
*/

#include <assert.h>                                               /* ahd   */
#include <stdio.h>                                                /* ahd   */
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <io.h>

/*--------------------------------------------------------------------*/
/*                      UUPC/extended prototypes                      */
/*--------------------------------------------------------------------*/

#include "lib.h"
#include "arpadate.h"
#include "checktim.h"
#include "dcp.h"
#include "dcplib.h"
#include "dcpstats.h"
#include "dcpsys.h"
#include "dcpxfer.h"
#include "hlib.h"
#include "hostable.h"
#include "hostatus.h"
#include "modem.h"
#include "ssleep.h"
#include "screen.h"
#include "ulib.h"

/*--------------------------------------------------------------------*/
/*    Define passive and active polling modes; passive is             */
/*    sometimes refered to as "slave", "active" as master.  Since     */
/*    the roles can actually switch during processing, we avoid       */
/*    the terms here                                                  */
/*--------------------------------------------------------------------*/

typedef enum {
	  POLL_PASSIVE = 0,       /* We answer the telephone          */
	  POLL_ACTIVE  = 1        /* We call out to another host      */
	  } POLL_MODE ;

/*--------------------------------------------------------------------*/
/*                          Global variables                          */
/*--------------------------------------------------------------------*/

size_t pktsize;         /* packet size for this protocol*/
FILE *xfer_stream = NULL;        /* stream for file being handled    */
boolean callnow = FALSE;           /* TRUE = ignore time in L.SYS        */
FILE *fwork = NULL, *fsys= NULL ;
FILE *syslog = NULL;
char workfile[FILENAME_MAX];  /* name of current workfile         */
char *Rmtname = nil(char);    /* system we want to call           */
char rmtname[20];             /* system we end up talking to      */
char s_systems[FILENAME_MAX]; /* full-name of systems file        */
struct HostTable *hostp;
int poll_mode = POLL_ACTIVE;   /* Default = dial out to system     */
extern char *logintime;
boolean reseek = FALSE;
static boolean dialed = FALSE;/* True = We attempted a phone call */
extern Max_Attempts, attempts;
int requests = 0, totreqs = 0;
static boolean Contacted = FALSE;
static boolean AnyContacted = FALSE;
extern void close_log_stream(void);
extern boolean PressBreak;

currentfile();

/*--------------------------------------------------------------------*/
/*                     Local function prototypes                      */
/*--------------------------------------------------------------------*/

static CONN_STATE process( const POLL_MODE poll_mode );
static char *conn_state(CONN_STATE c);
static char *xfer_state(XFER_STATE c);

static void cant(char *file);

static void closelog(void)
{
   fclose(logfile);
   logfile = stdout;
}

int report(void)
{
/*--------------------------------------------------------------------*/
/*                         Report our results                         */
/*--------------------------------------------------------------------*/

   if (!PressBreak) {
	   if (!AnyContacted) {
		  if (dialed)
			 printmsg(-1, "report: could not connect to remote system(s) or connection aborted");
		  else
			 printmsg(-1, "report: modem error or no work for any system(s) or wrong time to call");
	   }
	   else {
		  if (totreqs == 0)
			  printmsg(-1, "report: all done, no messages sent");
		  else
			  printmsg(-1, "report: all done, total %d message(s) sent", totreqs);
	   }
	}

   dcupdate();

   fclose(syslog);
   syslog = NULL;

   return AnyContacted ? 0 : 5;
}

/*--------------------------------------------------------------------*/
/*    d c p m a i n                                                   */
/*                                                                    */
/*    main program for DCP, called by uuhost                          */
/*--------------------------------------------------------------------*/

int dcpmain(void)
{

   fwork = nil(FILE);

   if (Rmtname == nil(char))
	  Rmtname = "any";

/*--------------------------------------------------------------------*/
/*        Initialize logging and the name of the systems file         */
/*--------------------------------------------------------------------*/

	if (debuglevel > 0 && logecho &&
		(logfile = FOPEN(LOGFILE, "w", TEXT)) == nil(FILE)) {
		logfile = stdout;
		cant(LOGFILE);
	}
	if (logfile != stdout)
		atexit(closelog);
	atexit(close_log_stream);

   if (access(SYSLOG,2) == 0 &&
	   (syslog = FOPEN(SYSLOG, "a", TEXT)) == nil(FILE))
	  cant(SYSLOG);

/*--------------------------------------------------------------------*/
/* logecho = ((poll_mode == POLL_ACTIVE) ? TRUE : FALSE);             */
/*--------------------------------------------------------------------*/

   /*logecho = FALSE;            /* ahd - One too many missed messages  */


   mkfilename(s_systems, confdir, SYSTEMS);
   printmsg(5, "Using system file '%s'",s_systems);

/*--------------------------------------------------------------------*/
/*              Load connection stats for previous runs               */
/*--------------------------------------------------------------------*/

   HostStatus();

/*--------------------------------------------------------------------*/
/*                     Begin main processing loop                     */
/*--------------------------------------------------------------------*/

   if (poll_mode == POLL_ACTIVE) {

	  CONN_STATE m_state = CONN_INITIALIZE;

	  printmsg(2, "calling \"%s\", debug=%d", Rmtname, debuglevel);

	  if ((fsys = FOPEN(s_systems, "r", TEXT)) == nil(FILE)) {
		 printerr("dcpmain", s_systems);
		 printmsg(0, "dcpmain: can't open %s", s_systems);
		 panic();
	  }

	  reseek = FALSE;
	  while (m_state != CONN_EXIT )
	  {
		 printmsg(4, "Master state = %s", conn_state(m_state));
		 switch (m_state)
		 {
			case CONN_INITIALIZE:
			   Contacted = FALSE;
			   if ((m_state = getsystem()) == CONN_CALLUP)
				   cleantmp();
			   break;

			case CONN_CALLUP:
			   Sundo();
			   m_state = callup();
			   break;

			case CONN_PROTOCOL:
			   dialed = TRUE;
			   m_state = startup_server();
			   break;

			case CONN_SERVER:
			   m_state = process( poll_mode );
			   break;

			case CONN_TERMINATE:
			   m_state = sysend();
			   break;

			case CONN_DROPLINE:
			   shutdown();
			   hostp->hattempts = attempts;
			   if (!AnyContacted)
					reseek = TRUE;
			   dcstats();
			   m_state = CONN_INITIALIZE;
			   break;

			case CONN_EXIT:
			   break;

			default:
			   printmsg(0,"dcpmain: Unknown master state = %c",m_state );
			   panic();
			   break;
		 } /* switch */
	  } /* while */
	  fclose(fsys);

   }
   else { /* client mode */

	  CONN_STATE s_state = CONN_INITIALIZE;

	  if (logintime != NULL)
	  {
		 if (!checktime(logintime,(time_t) 0))
			printmsg(1,"dcpmain: awaiting login window %s",logintime);

		 while(!checktime(logintime,(time_t) 0) )  /* Wait for window   */
				 ssleep(60);                   /* Checking one per minute    */

		 printmsg(2,"Enabling %s for remote login until '%s'",
					E_inmodem, logintime);
	  }

	  while (s_state != CONN_EXIT )
	  {
		 printmsg(4, "Slave state = %s", conn_state(s_state));
		 switch (s_state) {
			case CONN_INITIALIZE:
			   Contacted = FALSE;
			   if (Max_Attempts > 0 && attempts >= Max_Attempts)
				   s_state = CONN_EXIT;
			   else {
				   cleantmp();
				   s_state = CONN_ANSWER;
			   }
			   break;

			case CONN_ANSWER:
			   Sundo();
			   s_state = callin( logintime  );
			   break;

			case CONN_LOGIN:
			   s_state = login();
			   break;

			case CONN_PROTOCOL:
			   s_state = startup_client();
			   break;

			case CONN_CLIENT:
			   s_state = process( poll_mode );
			   break;

			case CONN_TERMINATE:
			   s_state = sysend();
			   break;

			case CONN_DROPLINE:
			   shutdown();
			   if (hostp != BADHOST)
				   dcstats();
			   s_state = AnyContacted ? CONN_EXIT : CONN_INITIALIZE;
			   break;

			case CONN_EXIT:
			   break;

			default:
			   printmsg(0,"dcpmain: Unknown slave state = %c",s_state );
			   panic();
			   break;
		 } /* switch */
	  } /* while */
   } /* else */

/*--------------------------------------------------------------------*/
/*               Cleanup communicatons port, if active                */
/*--------------------------------------------------------------------*/

   if(port_active)
   {
	  shutdown();
	  printmsg(0,"Error: port was still active after dcp shutdown!");
	  panic();
   }

   return report();

} /*dcpmain*/


/*--------------------------------------------------------------------*/
/*    p r o c e s s                                                   */
/*                                                                    */
/*    The procotol state machine                                      */
/*--------------------------------------------------------------------*/

static CONN_STATE process( const POLL_MODE poll_mode )
{
   boolean master;
   XFER_STATE state = ( poll_mode == POLL_ACTIVE ) ? XFER_SENDINIT :
													 XFER_RECVINIT;
   XFER_STATE old_state = XFER_EXIT;
							  /* Initialized to any state but the
								 original value of "state"           */
   XFER_STATE save_state = XFER_EXIT;

/*--------------------------------------------------------------------*/
/*  Yea old state machine for the high level file transfer procotol   */
/*--------------------------------------------------------------------*/

   while( state != XFER_EXIT )
   {
	  printmsg(state == old_state ? 14 : 4 ,
			   "Machine state = %s", xfer_state(state));
	  old_state = state;

	  switch( state )
	  {

		 case XFER_SENDINIT:  /* Initialize outgoing protocol        */
			state = sinit();
			break;

		 case XFER_RECVINIT:  /* Initialize Receive protocol         */
			state = rinit();
			break;

		 case XFER_MASTER:    /* Begin master mode                   */
			master = TRUE;
			state = XFER_NEXTJOB;
			break;

		 case XFER_SLAVE:     /* Begin slave mode                    */
			master = FALSE;
			state = XFER_RECVHDR;
			break;

		 case XFER_NEXTJOB:   /* Look for work in local queue        */
			state = scandir( rmtname );
			break;

		 case XFER_REQUEST:   /* Process next file in current job
								 in queue                            */
			state = newrequest();
			break;

		 case XFER_PUTFILE:   /* Got local tranmit request           */
			state = ssfile();
			break;

		 case XFER_GETFILE:   /* Got local tranmit request           */
			state = srfile();
			break;

		 case XFER_SENDDATA:  /* Remote accepted our work, send data */
			state = sdata();
			break;

		 case XFER_SENDEOF:   /* File xfer complete, send EOF        */
			state = seof( master );
			break;

		 case XFER_FILEDONE:  /* Receive or transmit is complete     */
			state = master ? XFER_REQUEST : XFER_RECVHDR;
			break;

		 case XFER_NOLOCAL:   /* No local work, remote have any?     */
			state = sbreak();
			break;

		 case XFER_NOREMOTE:  /* No remote work, local have any?     */
			state = schkdir();
			break;

		 case XFER_RECVHDR:   /* Receive header from other host      */
			state = rheader();
			break;

		 case XFER_TAKEFILE:  /* Set up to receive remote requested
								 file transfer                       */
			state = rrfile();
			break;

		 case XFER_GIVEFILE:  /* Set up to transmit remote
								 requuest file transfer              */
			state = rsfile();
			break;

		 case XFER_RECVDATA:  /* Receive file data from other host   */
			state = rdata();
			break;

		 case XFER_RECVEOF:
			state = reof();
			break;

		 case XFER_LOST:      /* Lost the other host, flame out      */
		 case XFER_ABORT:
			if (state == XFER_LOST)
				printmsg(0,"process: connection lost to %s, \
previous state = %s", rmtname, xfer_state(save_state) );
			else
				printmsg(1,"process: aborting connection to %s, \
previous state = %s", rmtname, xfer_state(save_state) );
			hostp->hstatus = call_failed;
			if (xfer_stream != NULL) {
				fclose(xfer_stream);
				xfer_stream = NULL;
			}
			if (fwork != NULL) {
				fclose(fwork);
				fwork = NULL;
			}
			if (state == XFER_LOST)
				return CONN_DROPLINE;
			else
				goto Close;

		 case XFER_ENDP:      /* Terminate the protocol              */
			AnyContacted = Contacted = TRUE;
			if (hostp->hstatus == inprogress)
				hostp->hstatus = called;
	Close:
			state = endp();
			break;

		 default:
			printmsg(0,"process: Unknown state = %c, \
previous system state = %c", state, save_state );
			state = XFER_ABORT;
			break;
	  } /* switch */
	  save_state = old_state; /* Used only if we abort               */
   } /* while( state != XFER_EXIT ) */

/*--------------------------------------------------------------------*/
/*           Protocol is complete, terminate the connection           */
/*--------------------------------------------------------------------*/

   return CONN_TERMINATE;

} /* process */

static char *conn_state(CONN_STATE c)
{
	char *s;

	switch(c) {
	case CONN_INITIALIZE:       /* Select system to call, if any       */
		s = "INITIALIZE";
		break;
	case CONN_CALLUP:           /* Dial out to another system          */
		s = "CALLUP";
		break;
	case CONN_ANSWER:           /* Wait for phone to ring and user to  */
		s = "ANSWER";
		break;
	case CONN_LOGIN:            /* Modem is connected, do a login      */
		s = "LOGIN";
		break;
	case CONN_PROTOCOL:         /* Exchange protocol information       */
		s = "PROTOCOL";
		break;
	case CONN_SERVER:           /* Process files after dialing out     */
		s = "SERVER";
		break;
	case CONN_CLIENT:           /* Process files after being called    */
		s = "CLIENT";
		break;
	case CONN_TERMINATE:        /* Terminate procotol                  */
		s = "TERMINATE";
		break;
	case CONN_DROPLINE:         /* Hangup the telephone                */
		s = "DROPLINE";
		break;
	case CONN_EXIT:             /* Exit state machine loop             */
		s = "EXIT";
		break;
	default:
		s = "UNKNOWN";
		break;
	}
	return s;
}

static char *xfer_state(XFER_STATE c)
{
	char *s;

	switch(c) {
	case XFER_SENDINIT:          /* Initialize outgoing protocol        */
		s = "SENDINIT";
		break;
	case XFER_MASTER:            /* Begin master mode                   */
		s = "MASTER";
		break;
	case XFER_FILEDONE:          /* Receive or transmit is complete     */
		s = "FILEDONE";
		break;
	case XFER_NEXTJOB:           /* Look for work in local queue        */
		s = "NEXTJOB";
		break;
	case XFER_REQUEST:           /* Process work in local queue         */
		s = "REQUEST";
		break;
	case XFER_PUTFILE:           /* Send a file to remote host at our req */
		s = "PUTFILE";
		break;
	case XFER_GETFILE:           /* Retrieve a file from a remote host req */
		s = "GETFILE";
		break;
	case XFER_SENDDATA:          /* Remote accepted our work, send data */
		s = "SENDDATA";
		break;
	case XFER_SENDEOF:           /* File xfer complete, send EOF        */
		s = "SENDEOF";
		break;
	case XFER_NOLOCAL:           /* No local work, remote have any?     */
		s = "NOLOCAL";
		break;
	case XFER_SLAVE:             /* Begin slave mode                    */
		s = "SLAVE";
		break;
	case XFER_RECVINIT:          /* Initialize Receive protocol         */
		s = "RECVINIT";
		break;
	case XFER_RECVHDR:           /* Receive header from other host      */
		s = "RECVHDR";
		break;
	case XFER_GIVEFILE:          /* Send a file to remote host at their req */
		s = "GIVEFILE";
		break;
	case XFER_TAKEFILE:          /* Retrieve a file from a remote host req	 */
		s = "TAKEFILE";
		break;
	case XFER_RECVDATA:          /* Receive file data from other host   */
		s = "RECVDATA";
		break;
	case XFER_RECVEOF:           /* Close file received from other host */
		s = "RECVEOF";
		break;
	case XFER_NOREMOTE:          /* No remote work, local have any?     */
		s = "NOREMOTE";
		break;
	case XFER_LOST:              /* Lost the other host, flame out      */
		s = "LOST";
		break;
	case XFER_ABORT:             /* Internal error, flame out           */
		s = "ABORT";
		break;
	case XFER_ENDP:              /* End the protocol                    */
		s = "ENDP";
		break;
	case XFER_EXIT:              /* Return to caller                    */
		s = "EXIT";
		break;
	default:
		s = "UNKNOWN";
		break;
	}
	return s;
}

/*--------------------------------------------------------------------*/
/*    c a n t                                                         */
/*                                                                    */
/*    report that we cannot open a critical file                      */
/*--------------------------------------------------------------------*/

static void cant(char *file)
{

   fprintf(stderr, "Can't open: \"%s\"\n", file);
   perror( file );
   abort();
} /*cant*/
