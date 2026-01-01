/*
   For best results in visual layout while viewing this file, set
   tab stops to every 4 columns.
*/

/*
   dcpsys.c

   Revised edition of dcp

   Stuart Lynne May/87

   Copyright (c) Richard H. Lamb 1985, 1986, 1987
   Changes Copyright (c) Stuart Lynne 1987
   Changes Copyright (c) Andrew H. Derbyshire 1989, 1990

   Updated:

	  13May89  - Modified checkname to only examine first token of name.
				 Modified rmsg to initialize input character before use.
				 - ahd
      16May89  - Moved checkname to router.c - ahd
	  17May89  - Wrote real checktime() - ahd
      17May89  - Changed getsystem to return 'I' instead of 'G'
	  25Jun89  - Added Reach-Out America to keyword table for checktime
      22Sep89  - Password file support for hosts
	  25Sep89  - Change 'ExpectStr' message to debuglevel 2
      01Jan90  - Revert 'ExpectStr' message to debuglevel 1
	  28Jan90  - Alter callup() to use table driven modem driver.
				 Add direct(), qx() procedures.
      8 Jul90  - Add John DuBois's expectstr() routine to fix problems
                 with long input buffers.
	  11Nov90  - Delete QX support, add ddelay, ssleep calls
*/

/* "DCP" a uucp clone. Copyright Richard H. Lamb 1985,1986,1987 */


/* Support routines */

/*--------------------------------------------------------------------*/
/*                        system include files                        */
/*--------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <ctype.h>

/*--------------------------------------------------------------------*/
/*                    UUPC/extended include files                     */
/*--------------------------------------------------------------------*/

#include "lib.h"
#include "arpadate.h"
#include "checktim.h"
#include "dcp.h"
#include "dcpgpkt.h"
#include "dcplib.h"
#include "dcpsys.h"
#include "hlib.h"
#include "hostable.h"
#include "modem.h"
#include "ndir.h"
#include "ulib.h"
#include "comm.h"
#include "ssleep.h"
#include "screen.h"

currentfile();

#define  PROTOS   "Gg"        /* available protocols */
#define MSGTIME 20            /* Timeout for many operations */

Proto Protolst[] = {
   'G', ggetpkt, gsendpkt, Gopenpk, gclosepk,
		grdmsg,  gwrmsg,   geofpkt, gfilepkt,
   'g', ggetpkt, gsendpkt, gopenpk, gclosepk,
		grdmsg,  gwrmsg,   geofpkt, gfilepkt,
   '\0'};

procref  getpkt, sendpkt, openpk, closepk, rdmsg, wrmsg, eofpkt, filepkt;

char *flds[60];
int kflds;
static char proto[5];
static char S_sysline[BUFSIZ];
extern char* phonerate[32];
extern boolean reseek;
extern attempts, requests, errors_per_request;
boolean remote_debug = FALSE;
boolean WorthTrying = FALSE;
int Max_Attempts, Seq_Attempts, attempts, Max_Idle;
static char local_proto_parms[30],remote_proto_parms[30];
extern boolean g_setup(char *, boolean);
extern  boolean NoCheckCarrier;

static void setproto(char wanted);

/****************************************/
/*              Sub Systems             */
/****************************************/

/*--------------------------------------------------------------------*/
/*    g e t s y s t e m                                               */
/*                                                                    */
/*    Process a systems file (L.sys) entry.                           */
/*    Null lines or lines starting with '#' are comments.             */
/*--------------------------------------------------------------------*/

CONN_STATE getsystem()
{
   int i;
   char *s, **phone;

Again:
   do {  /* flush to next non-comment line */
	  if (fgets(S_sysline, BUFSIZ, fsys) == nil(char)) {
		 printmsg(8, "getsystem: EOF");
		 if (reseek && WorthTrying) {
			reseek = FALSE;
			if (Max_Attempts == 0 || attempts < Max_Attempts) {
				rewind(fsys);
				WorthTrying = FALSE;
				goto Again;
			}
		 }
		 return CONN_EXIT;
	  }
	  i = strlen(S_sysline);
	  while (i > 0 && isspace(S_sysline[i-1]))
		  S_sysline[--i] = '\0';
   } while (i == 0 || *S_sysline == '#');

   printmsg(8, "sysline=\"%s\"", S_sysline);

   kflds = getargs(S_sysline, flds);
   strcpy(rmtname, flds[FLD_REMOTE]);
   Seq_Attempts = 1;
   if ((s = strrchr(rmtname, '/')) != NULL) {
	 *s++ = '\0';
	 if ((Seq_Attempts = atoi(s)) <= 0) {
		printmsg(0, "getsystem: bad sequental attempts field for %s", rmtname);
		return CONN_EXIT;
	 }
   }
   strcpy(proto, flds[FLD_PROTO]);
   if ((Max_Attempts = atoi(flds[FLD_COUNT])) < 0) {
	 printmsg(0, "getsystem: bad maximal attempts field for %s", rmtname);
	 return CONN_EXIT;
   }
   Max_Idle = 0;
   if ((s = strrchr(flds[FLD_CCTIME], ';')) != NULL) {
	 *s++ = '\0';
	 if ((Max_Idle = atoi(s)) < 0) {
		printmsg(0, "getsystem: bad sequental attempts field for %s", rmtname);
		return CONN_EXIT;
	 }
   }
   if (!checktime(flds[FLD_CCTIME], (time_t) 0)) {
		printmsg(8, "getsystem: wrong time now to call %s", rmtname);
		return CONN_INITIALIZE;
   }

/*--------------------------------------------------------------------*/
/*                      Summarize the host data                       */
/*--------------------------------------------------------------------*/

   printmsg(2,
		  "remote=%s, call-time=%s, device=%s, phone(s)=%s, count=%d, protocol=%s, pktsizes=%s",
		  rmtname, flds[FLD_CCTIME], flds[FLD_TYPE], flds[FLD_PHONE], Max_Attempts,
		  proto, flds[FLD_PKTSIZES]);

/*--------------------------------------------------------------------*/
/*                  Determine if the remote is valid                  */
/*--------------------------------------------------------------------*/

   hostp = checkreal( rmtname );
   checkref( hostp );

/*--------------------------------------------------------------------*/
/*                   Display the send/expect fields                   */
/*--------------------------------------------------------------------*/

   if (debuglevel >= 4) {
	  int   i;
	  for (i = FLD_EXPECT; i < kflds; i += 2)
		 printmsg(6, "expect [%02d]: %s\nsend   [%02d]: %s",
			i, flds[i], i + 1, flds[i + 1]);
   }

/* Extract phone/speed numbers to 'phonerate' */

	phone = phonerate;
	s = flds[FLD_PHONE];
	do {
		if (!*s)
			break;
		if (*s == ':') {
			*s = '\0';
			break;
		}
		*phone++ = s;
		if ((s = strchr(s, ':')) != NULL)
			*s++ = '\0';
	}
	while (s != NULL);
	*phone = NULL;
	if (phonerate[0] == NULL) {
		printmsg(0, "getsystem: empty speed/phone list field for %s", rmtname);
		return CONN_EXIT;
	}

/* Extract packets sizes */

	if (   sscanf(flds[FLD_PKTSIZES], "%[^ /\n\t]/%s",
									local_proto_parms,
									remote_proto_parms) != 2
		|| !*local_proto_parms || !*remote_proto_parms
	   ) {
		printmsg(0, "getsystem: bad protocol parameters - %s for %s",
								flds[FLD_PKTSIZES], rmtname);
		return CONN_EXIT;
	}
	if (   strpbrk(proto, "gG") != NULL
		&& (   !g_setup(remote_proto_parms, FALSE)
			|| !g_setup(local_proto_parms, TRUE)
		   )
	   )
		return CONN_EXIT;

/*--------------------------------------------------------------------*/
/*               Determine if we want to call this host               */
/*                                                                    */
/*    The following if statement breaks down to:                      */
/*                                                                    */
/*       if host not successfully called this run and                 */
/*             (  we are calling all hosts or                         */
/*                we are calling this host or                         */
/*                we are hosts with work and this host has work )     */
/*       then call this host                                          */
/*--------------------------------------------------------------------*/

   printmsg(10, "getsystem: %s status: %d", rmtname, hostp->hstatus);

   fwork = nil(FILE);
   if (
		 hostp->hstatus != called &&
		 (
			equal(Rmtname, "all") ||
			equal(Rmtname, rmtname) ||
			(
			   equal(Rmtname, "any") && (scandir(rmtname) == XFER_REQUEST)
			)
		 )
	   )
	{

	  if (fwork != nil(FILE)) /* in case matched with scandir     */
		 fclose(fwork);
	  scandir( NULL );        /* Reset directory search as well   */

	  memset( &remote_stats, 0, sizeof remote_stats);
	  attempts = hostp->hattempts;
	  requests = 0;
	  return CONN_CALLUP;    /* startup this system */

   } else
	  return CONN_INITIALIZE;    /* Look for next system to process   */

} /*getsystem*/

/*--------------------------------------------------------------------*/
/*    s y s e n d                                                     */
/*                                                                    */
/*    End UUCP session negotiation                                    */
/*--------------------------------------------------------------------*/

CONN_STATE sysend()
{
   char msg[80];

   if (hostp->hstatus == inprogress)
	  hostp->hstatus = call_failed;

   msg[1] = '\0';
   if (wmsg("OOOOOO", TRUE) == S_LOST)
		return CONN_DROPLINE;
   set_connected(FALSE);
   if (rmsg(msg, TRUE, 5) == TIMEOUT || strstr(msg, "OOOOOO") == NULL)
	   if (wmsg("OOOOOO", TRUE) == S_LOST)
			return CONN_DROPLINE;
   if (!NoCheckCarrier && carrier(TRUE))
	   ssleep(2);                 /* Wait for it to be transmitted       */

   return CONN_DROPLINE;
} /*sysend*/


/*
   w m s g

   write a ^P type msg to the remote uucp
*/

int wmsg(char *msg, const boolean synch)
{

   if (synch)
	  if (swrite("\0\020", 2) < S_OK)
		goto lost;

   if (swrite(msg, strlen(msg)) < S_OK)
		goto lost;

   if (synch)
	  if (swrite("\0", 1) < S_OK)
		goto lost;

   return 0;

lost:
	hostp->hstatus = call_failed;
	printmsg(0, "wmsg: LOST CARRIER, connection aborted");
	return S_LOST;
} /*wmsg*/


/*
   r m s g

   read a ^P msg from UUCP
*/

int rmsg(char *msg, const boolean synch, unsigned int msgtime)
{
   int i;
   static int max_len = 60;
   char ch = '?';       /* Initialize to non-zero value  */    /* ahd   */

/*--------------------------------------------------------------------*/
/*                        flush until next ^P                         */
/*--------------------------------------------------------------------*/

   if (synch == 1)
   {
	  do {
		 switch (sread(&ch, 1, msgtime)) {
		 case S_TIMEOUT:
			hostp->hstatus = call_failed;
			return TIMEOUT;
		 case S_LOST:
			goto lost;
		 }

	  } while ((ch & 0x7f) != '\020');
   }

/*--------------------------------------------------------------------*/
/*   Read until timeout, next newline, or we fill the input buffer    */
/*--------------------------------------------------------------------*/

   for (i = 0; (i < max_len) && (ch != '\0'); ) {
	  switch (sread(&ch, 1, msgtime)) {
	  case S_TIMEOUT:
		 hostp->hstatus = call_failed;
		 return TIMEOUT;
	  case S_LOST:
		 goto lost;
	  }
	  if ( synch == 2 )
		 if (swrite( &ch, 1) < S_OK)
			goto lost;
	  ch &= 0x7f;
	  if (ch == '\r' || ch == '\n')
		 ch = '\0';
	  msg[i++] = ch;
   }
   msg[i] = '\0';

   return i;

lost:
   hostp->hstatus = call_failed;
   printmsg(0, "rmsg: LOST CARRIER, connection aborted");
   return S_LOST;
} /*rmsg*/


/*--------------------------------------------------------------------*/
/*    s t a r t u p _ s e r v e r                                     */
/*                                                                    */
/*    Exchange host and protocol information for a system calling us  */
/*--------------------------------------------------------------------*/

CONN_STATE startup_server()
{
   char msg[80];
   char *s;
   int r;

/*--------------------------------------------------------------------*/
/*                      Begin normal processing                       */
/*--------------------------------------------------------------------*/

   if ((r = rmsg(msg, TRUE, PROTOCOL_TIME)) < 0)
   {
	  if (r == TIMEOUT) {
		  printmsg(1,"startup_server: timeout for first message");
		  printmsg(0,"startup_server: can't login, check your login name and password");
	  }
	  return CONN_DROPLINE;
   }
   printmsg(2, "1st msg = %s", msg);

/*--------------------------------------------------------------------*/
/*              The first message must begin with Shere               */
/*--------------------------------------------------------------------*/

   if (!equaln(msg,"Shere",5))
   {
	  printmsg(0,"startup_server: first message not 'Shere'");
	  return CONN_DROPLINE;
   }

/*--------------------------------------------------------------------*/
/*    The host can send either a simple Shere, or Shere=hostname;     */
/*    we allow either.                                                */
/*--------------------------------------------------------------------*/

   if ((msg[5] == '=') && !equaln(&msg[6], rmtname, HOSTLEN))
   {
	  printmsg(0,"startup_server: wrong host %s, expected %s",
			   &msg[6], rmtname);
	  hostp->hstatus = wrong_host;
	  return CONN_DROPLINE; /* wrong host */              /* ahd */
   }

   if (remote_debug)	  /* -Q0 -x16 remote debuglevel set */
	 (void) sprintf(msg, "S%s -Q0 -x%d -P%s", nodename,
											  debuglevel,
											  remote_proto_parms);
   else
	 (void) sprintf(msg, "S%s -Q0 -P%s", nodename, remote_proto_parms);
   printmsg(4, "startup_server: parameters '%s'", msg+1);
   if (wmsg(msg, TRUE) == S_LOST)
		return CONN_DROPLINE;

   if ((r = rmsg(msg, TRUE, PROTOCOL_TIME)) < 0)
   {
	  if (r == TIMEOUT)
		  printmsg(0,"startup_server: timeout for second message");
	  return CONN_DROPLINE;
   }

/*--------------------------------------------------------------------*/
/*                Second message is protocol exchange                 */
/*--------------------------------------------------------------------*/

   printmsg(2, "2nd msg = %s", msg);

   if (!equaln(msg, "ROK", 3)) {
		if (equaln(msg, "RLCK", 4))
			printmsg(0, "startup_server: %s thinks it's already talking to %s",
				rmtname, nodename);
		else if (equaln(msg, "RCB", 3))
			printmsg(0, "startup_server: %s wants to call %s back",
				rmtname, nodename);
		else if (equaln(msg, "RBADSEQ", 7))
			printmsg(0, "startup_server: call sequence number is wrong");
		else if (equaln(msg, "RLOGIN", 6))
			printmsg(0, "startup_server: %s login name isn't known to %s uucp",
				nodename, rmtname);
		else if (equaln(msg, "RYou", 4) || equaln(msg, "RUnknown", 8))
			printmsg(0, "startup_server: %s", &msg[1]);
		else
			printmsg(0,"startup_server: unexpected second message: %s", msg);
		return CONN_DROPLINE;
	}

   if ((r = rmsg(msg, TRUE, PROTOCOL_TIME)) < 0) {
	  if (r == TIMEOUT)
		  printmsg(0, "startup_server: timeout for third message");
	  return CONN_DROPLINE;
   }
   printmsg(2, "3rd msg = %s", msg);
   if (*msg != 'P')
   {
	  printmsg(0,"startup_server: unexpected third message: %s",&msg[1]);
	  return CONN_DROPLINE;
   }

/*--------------------------------------------------------------------*/
/*                      Locate a common procotol                      */
/*--------------------------------------------------------------------*/

   s = strpbrk( PROTOS, &msg[1] );
   if ( s == NULL )
   {
	  printmsg(0,"startup_server: no common protocol (%s)", &msg[1]);
	  (void) wmsg("UN", TRUE);
	  return CONN_DROPLINE; /* no common protocol */
   }
   else {
	  sprintf(msg, "U%c", *s);
	  if (wmsg(msg, TRUE) == S_LOST)
		return CONN_DROPLINE;
   }

   setproto(*s);

   printmsg(1,"startup_server: %s connected to host %s using %c protocol",
		 nodename, rmtname, *s);

   hostp->hstatus = inprogress;

   Slink(SL_CONNECTED, rmtname, arpadate());	/* Connected */

   return CONN_SERVER;
} /*startup_server*/

/*--------------------------------------------------------------------*/
/*    s t a r t u p _ c l i e n t                                     */
/*                                                                    */
/*    Setup a host connection with a system which has called us       */
/*--------------------------------------------------------------------*/

CONN_STATE startup_client()
{
   char tmp1[20], tmp2[20], plist[20];
   char msg[80];
   int xdebug = debuglevel;
   char *sysname = rmtname;
   Proto *tproto;
   char *s;

/*--------------------------------------------------------------------*/
/*    Challange the host calling in with the name defined for this    */
/*    login (if available) otherwise our regular node name.  (It's    */
/*    a valid session if the securep pointer is NULL, but this is     */
/*    trapped below in the call to ValidateHost()                     */
/*--------------------------------------------------------------------*/

   sprintf(msg, "Shere=%s", nodename);
   if (wmsg(msg, TRUE) == S_LOST)
	  return CONN_DROPLINE;

   if (rmsg(msg, TRUE, PROTOCOL_TIME) < 0)
	  return CONN_DROPLINE;
   sscanf(&msg[1], "%s %s %s", sysname, tmp1, tmp2);
   sscanf(tmp2, "-x%d", &xdebug);
   printmsg(2, "1st msg from remote = %s", msg);

/*--------------------------------------------------------------------*/
/*                Verify the remote host name is good                 */
/*--------------------------------------------------------------------*/

   hostp = checkreal( sysname );
   if ( hostp == BADHOST )
   {
	  if (anonymous != NULL)
	  {
		 hostp = checkreal( ANONYMOUS_HOST );      /* Find dummy entry */
		 if ( hostp == BADHOST )       /* Was it there?              */
			panic();                   /* No --> Drop wing, run in
									   circles like sky is falling*/
		 if (!checktime( anonymous , (time_t) 0))     /* Good time to call?      */
		 {
			(void)wmsg("RLCK",TRUE);
			printmsg(1,"startup_client: Wrong time for anonymous system \"%s\"",sysname);
			return CONN_DROPLINE;
		 }    /* if */

		 hostp->via = strdup( sysname );
		 sysname = ANONYMOUS_HOST;

		 if (xdebug > 3)
		 {
			(void)wmsg("RDebug (-x) level too high for anonymous UUCP - rejected",
				  TRUE);
			printmsg(1,"startup_client: Excessive debug for anonymous system \"%s\"",sysname);
			return CONN_TERMINATE;
		 } /* if (xdebug > 3) */

	  }    /* if (anonymous != NULL) */
	  else {
		 (void)wmsg("RYou are unknown to me",TRUE);
		 printmsg(0,"startup_client: Unknown host \"%s\"", sysname);
		 return CONN_DROPLINE;
	  } /* else */
   } /* if ( hostp == BADHOST ) */
   else
	  hostp->via = hostp->hostname;

   strcpy(rmtname,hostp->hostname);       /* Make sure we use the
											 full host name       */

/*--------------------------------------------------------------------*/
/*                     Set the local debug level                      */
/*--------------------------------------------------------------------*/

   if ( xdebug > debuglevel )
   {
	  debuglevel = xdebug;
	  printmsg(1, "startup_client: Debuglevel set to %d by remote", debuglevel);
   }

/*--------------------------------------------------------------------*/
/*                     Build local protocol list                      */
/*--------------------------------------------------------------------*/

   s = plist;
   for (tproto = Protolst; tproto->type != '\0' ; tproto++)
	  *s++ = tproto->type;

   *s = '\0';                 /* Terminate our string                */

/*--------------------------------------------------------------------*/
/*              The host name is good; get the protocol               */
/*--------------------------------------------------------------------*/

   if (wmsg("ROK", TRUE) == S_LOST)
	  return CONN_DROPLINE;

   sprintf(msg, "P%s", plist);
   if (wmsg(msg, TRUE) == S_LOST)
	  return CONN_DROPLINE;

   if (rmsg(msg, TRUE, PROTOCOL_TIME) < 0)
	  return CONN_DROPLINE;

   if (msg[0] != 'U')
   {
	  printmsg(0,"startup_client: Unexpected second message: %s", msg);
	  return CONN_DROPLINE;
   }

   if (strchr(plist, msg[1]) == nil(char))
   {
	  printmsg(0,"startup_client: Host does not support our protocols");
	  return CONN_DROPLINE;
   }

   setproto(msg[1]);

/*--------------------------------------------------------------------*/
/*            Report that we connected to the remote host             */
/*--------------------------------------------------------------------*/

   printmsg(1,"startup_client: %s called by %s using %c protocol",
		 nodename,
		 hostp->via,
		 msg[1]);

   if ( hostp == BADHOST )
	  panic();

   Slink(SL_CALLEDBY, hostp->hostname, arpadate()); /* Called by */

   hostp->hstatus = inprogress;
   time( &remote_stats.lconnect );
   return CONN_CLIENT;

} /*startup_client*/

/*--------------------------------------------------------------------*/
/*    s e t p r o t o                                                 */
/*                                                                    */
/*    set the protocol to be used                                     */
/*--------------------------------------------------------------------*/

static void setproto(char wanted)
{
   Proto *tproto;

   for (tproto = Protolst;
	  tproto->type != '\0' && tproto->type != wanted;
	  tproto++) {
	  printmsg(3, "setproto: wanted '%c', have '%c'", wanted, tproto->type);
   }
   if (tproto->type == '\0') {
	  printmsg(0, "setproto: you said I have protocol '%c' but I cant find it!",
			wanted);
	  panic();
   }

   getpkt  = tproto->getpkt;
   sendpkt = tproto->sendpkt;
   openpk  = tproto->openpk;
   closepk = tproto->closepk;
   rdmsg   = tproto->rdmsg;
   wrmsg   = tproto->wrmsg;
   eofpkt  = tproto->eofpkt;
   filepkt = tproto->filepkt;
} /*setproto*/

/*
	  s c a n d i r

	  Scan spooling directory for C.* files for the remote host
	  (rmtname)

	  Assumes the parameter remote is from static storage!
*/

XFER_STATE scandir(char *remote)
{
   static DIR *dirp;
   static char *saveremote = NULL;
   static char remotedir[FILENAME_MAX];
   char buf[20];
   struct direct *dp;

/*--------------------------------------------------------------------*/
/*          Determine if we must restart the directory scan           */
/*--------------------------------------------------------------------*/

   if (fwork != NULL )
   {
	  fclose( fwork );
	  fwork = NULL;
   }

   if ( (remote == NULL) || (saveremote == NULL ) ||
		!equal(remote, saveremote) )
   {
	  if ( saveremote != NULL )  /* Clean up old directory? */
	  {                          /* Yes --> Do so           */
		 closedir(dirp);
		 saveremote = NULL;
	  } /* if */

	  if ( remote == NULL )      /* Clean up only, no new search? */
		 return XFER_NOLOCAL;    /* Yes --> Return to caller      */

	  sprintf(buf,"%.8s/C",remote);
	  mkfilename(remotedir, spooldir, buf);
	  if ((dirp = opendir(remotedir)) == nil(DIR))
	  {
		 printmsg(2, "scandir: couldn't opendir() %s", remotedir);
		 return XFER_NOLOCAL;
	  } /* if */

	  saveremote = (char *) remote;
							  /* Flag we have an active search    */
   } /* if */

/*--------------------------------------------------------------------*/
/*              Look for the next file in the directory               */
/*--------------------------------------------------------------------*/

   if ((dp = readdir(dirp)) != nil(struct direct))
   {
	  mkfilename(workfile, remotedir, dp->d_name);
	  printmsg(5, "scandir: matched \"%s\"",workfile);
	  if ((fwork = FOPEN(workfile, "r", TEXT)) == nil(FILE))
	  {
		 printerr("scandir", workfile);
		 printmsg(0, "scandir: can't open %s", workfile);
		 saveremote = NULL;
		 return XFER_ABORT;   /* Very bad, since we just read its
								 directory entry!                 */
	  }

	  errors_per_request = 0;
	  return XFER_REQUEST; /* Return success                   */
   }

/*--------------------------------------------------------------------*/
/*     No hit; clean up after ourselves and return to the caller      */
/*--------------------------------------------------------------------*/

   printmsg(5, "scandir: \"%s\" not matched", remotedir);
   closedir(dirp);
   saveremote = NULL;
   return XFER_NOLOCAL;

} /*scandir*/

