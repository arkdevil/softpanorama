/*
   For best results in visual layout while viewing this file, set
   tab stops to every 4 columns.
   "DCP" a uucp clone. Copyright Richard H. Lamb 1985,1986,1987
*/

/*
   dcpxfer.c

   Revised edition of dcp

   Stuart Lynne May/87

   Copyright (c) Richard H. Lamb 1985, 1986, 1987
   Changes Copyright (c) Stuart Lynne 1987
   Changes Copyright (c) Jordan Brown 1990, 1991
   Changes Copyright (c) Andrew H. Derbyshire 1989, 1991


   Maintenance Notes:

   01Nov87 - that strncpy should be a memcpy! - Jal
   22Jul90 - Add check for existence of the file before writing
             it.                                                  ahd
   09Apr91 - Add numerous changes from H.A.E.Broomhall and Cliff
             Stanford for bidirectional support                   ahd
   05Jul91 - Merged various changes from Jordan Brown's (HJB)
             version of UUPC/extended to clean up transmission
             of commands, etc.                                    ahd
   09Jul91 - Rewrite to use unique routines for all four kinds of
             transfers to allow for testing and security          ahd

*/


/*--------------------------------------------------------------------*/
/*                        System include files                        */
/*--------------------------------------------------------------------*/

#include <ctype.h>
#include <fcntl.h>
#include <direct.h>
#include <io.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/timeb.h>
#include <errno.h>

/*--------------------------------------------------------------------*/
/*                    UUPC/extended include files                     */
/*--------------------------------------------------------------------*/

#include "lib.h"
#include "dcp.h"
#include "dcpsys.h"
#include "dcpxfer.h"
#include "dcpgpkt.h"
#include "expath.h"
#include "hlib.h"
#include "hostable.h"
#include "import.h"
#include "ulib.h"
#include "screen.h"

/*--------------------------------------------------------------------*/
/*                          Global variables                          */
/*--------------------------------------------------------------------*/

static unsigned char rpacket[MAX_PKTSIZE], spacket[MAX_PKTSIZE];

static int S_size;   /* number of bytes in the spacket buffer */

static char fname[FILENAME_MAX], tname[FILENAME_MAX], dname[FILENAME_MAX];
static char type, who[20], cmdopts[16];

extern long bytes;	/* moved to screen.c */
extern struct timeb start_time; /* moved to screen.c */
extern int requests;
int errors_per_request;
extern long ticks;	/* moved to screen.c */

static char command[BUFSIZ];


static boolean spool = FALSE; /* Received file is into spool dir     */
static char spolname[FILENAME_MAX];
							  /* Final host name of file to be
								 received into spool directory       */
static char tempname[FILENAME_MAX];
							  /* Temp name used to create received
								 file                                */

currentfile();

/*--------------------------------------------------------------------*/
/*                    Internal function prototypes                    */
/*--------------------------------------------------------------------*/

static boolean pktgetstr( char *s);
static boolean pktsendstr( char *s );

static int  bufill(char  *buffer);
static int  bufwrite(char  *buffer,int  len);

/*************** SEND PROTOCOL ***************************/

/*--------------------------------------------------------------------*/
/*    s d a t a                                                       */
/*                                                                    */
/*    Send File Data                                                  */
/*--------------------------------------------------------------------*/

XFER_STATE sdata( void )
{

   if ((*sendpkt)((char *) spacket, S_size) != OK)  /* send data */
	  return XFER_LOST;    /* Trouble!                               */

   if ((S_size = bufill((char *) spacket)) == 0)  /* get data from file */
	  return XFER_SENDEOF; /* if EOF set state to that               */

   return XFER_SENDDATA;   /* Remain in send state                   */
} /*sdata*/


/*--------------------------------------------------------------------*/
/*    b u f i l l                                                     */
/*                                                                    */
/*    Get a bufferful of data from the file that's being sent.        */
/*--------------------------------------------------------------------*/

static int bufill(char *buffer)
{
   size_t count = fread(buffer, sizeof *buffer, pktsize, xfer_stream);

   bytes += count;
   if (count < pktsize && ferror(xfer_stream))
   {
	  printerr("bufill", "read packet");
	  clearerr(xfer_stream);
	  return -1;
   }

   Saddbytes(bytes, SF_SEND);

   return count;

} /*bufill*/


/*--------------------------------------------------------------------*/
/*    b u f w r i t e                                                 */
/*                                                                    */
/*    Write a bufferful of data to the file that's being received.    */
/*--------------------------------------------------------------------*/

static int bufwrite(char *buffer, int len)
{
   int count = fwrite(buffer, sizeof *buffer, len, xfer_stream);

   bytes += count;
   if (count < len)
   {
	  printerr("bufwrite", "write file");
	  clearerr(xfer_stream);
   }

   Saddbytes(bytes, SF_RECV);

   return count;

} /*bufwrite*/

/*--------------------------------------------------------------------*/
/*    s b r e a k                                                     */
/*                                                                    */
/*    Switch from master to slave mode                                */
/*                                                                    */
/*    Sequence:                                                       */
/*                                                                    */
/*       We send "H" to other host to ask if we should hang up        */
/*       If it responds "HN", it has work for us, we become           */
/*          the slave.                                                */
/*       If it responds "HY", it has no work for us, we               */
/*          response "HY" (we have no work either), and               */
/*          terminate protocol and hangup                             */
/*                                                                    */
/*    Note that if more work is queued on the local system while      */
/*    we are in slave mode, schkdir() causes us to become the         */
/*    master again; we just decline here to avoid trying the queue    */
/*    again without intervening work from the other side.             */
/*--------------------------------------------------------------------*/

XFER_STATE sbreak( void )
{
   if (!pktsendstr("H"))      /* Tell slave it can become the master */
	  return XFER_LOST;       /* Xmit fail?  If so, quit transmitting*/

   if (!pktgetstr((char *)spacket)) /* Get their response            */
	  return XFER_LOST;       /* Xmit fail?  If so, quit transmitting*/

   if ((*spacket != 'H') || ((spacket[1] != 'N') && (spacket[1] != 'Y')))
   {
	  printmsg(0,"sbreak: invalid response from remote: %s",spacket);
	  return XFER_ABORT;
   }

   if (spacket[1] == 'N')     /* "HN" (have work) message from host? */
   {                          /* Yes --> Enter Receive mode          */
	  printmsg( 2, "sbreak: switch into slave mode" );
	  return XFER_SLAVE;
   }
   else {                     /* No --> Remote host is done as well  */
	  if (!pktsendstr("HY"))  /* Tell the host we are done as well   */
		return XFER_LOST;
	  return XFER_ENDP;       /* Terminate the protocol              */
   } /* else */

} /*sbreak*/

/*--------------------------------------------------------------------*/
/*    s e o f                                                         */
/*                                                                    */
/*    Send End-Of-File                                                */
/*--------------------------------------------------------------------*/

XFER_STATE seof( const boolean purge_file )
{

   struct tm  *tmx;
   struct timeb now;
   char hostname[FILENAME_MAX];

/*--------------------------------------------------------------------*/
/*    Send end-of-file indication, and perhaps receive a              */
/*    lower-layer ACK/NAK                                             */
/*--------------------------------------------------------------------*/

   switch ((*eofpkt)())
   {
	  case RETRY:                /* retry */
		 printmsg(0, "seof: remote system asks that the file be resent");
		 fseek(xfer_stream, 0L, SEEK_SET);
		 bytes = 0;
		 S_size = bufill((char *)spacket);
		 if ( S_size == -1 )
			return XFER_ABORT;   /* cannot send file */
		 (*filepkt)();           /* warmstart file-transfer protocol */
		 return XFER_SENDDATA;   /* stay in data phase */

	  case FAILED:
		 return XFER_ABORT;      /* cannot send file */

	  case OK:
		 fclose(xfer_stream);
		 xfer_stream = NULL;
		 break;                  /* sent, proceed */

	  default:
		 return XFER_LOST;
   }

   if (!pktgetstr((char *)spacket)) /* Receive CY or CN              */
	  return XFER_LOST;       /* Bomb the connection if no packet    */

   if ((*spacket != 'C') || ((spacket[1] != 'N') && (spacket[1] != 'Y')))
   {
	  printmsg(0,"seof: invalid response from remote: %s",spacket);
	  return XFER_ABORT;
   }

   if (!equaln((char *) spacket, "CY", 2)) {
	  char *s;
	  switch(spacket[2]) {
		case '5':
			s = "can't rename temp file";
			break;
		case '\0':
			s = "unknown";
			break;
		default:
			s = &spacket[2];
			break;
	  }
	  printmsg(0, "seof: remote unable to save %s, reason: %s", tname, s);
	  return XFER_ABORT;
   }

/*--------------------------------------------------------------------*/
/*                   If local spool file, delete it                   */
/*--------------------------------------------------------------------*/

   importpath(hostname, dname, rmtname);
							  /* Local name also used by logging     */

   if (purge_file && !equal(dname,"D.0"))
   {
	 unlink( hostname );
	 printmsg(4,"seof: file %s (%s) deleted", dname, hostname );
   }

/*--------------------------------------------------------------------*/
/*                            Update stats                            */
/*--------------------------------------------------------------------*/

   remote_stats.fsent++;
   remote_stats.bsent += bytes;
   hostp->idlewait = MIN_IDLE;	/* Reset wait time */

   ftime(&now);
   ticks = (now.time - start_time.time) * 1000 +
			((long) now.millitm - (long) start_time.millitm);
   if (ticks <= 0)
		ticks = 1;

   Sftrans(SF_SDONE, hostname, NULL); /* Sending done */

   printmsg(2, "seof: transfer completed, %ld chars/sec",
			   bytes * 1000 / ticks);

   if (syslog != NULL) {
	   tmx = localtime(&now.time);
	   fprintf( syslog, "%s!%s (%s) (%d/%d-%02d:%02d:%02d) -> %ld / %ld.%02d secs\n",
				nodename, tname, hostname,
				(tmx->tm_mon+1), tmx->tm_mday,
				tmx->tm_hour, tmx->tm_min, tmx->tm_sec, bytes,
				ticks / 1000 , (int) ((ticks % 1000) / 10) );
   }

/*--------------------------------------------------------------------*/
/*                          Return to caller                          */
/*--------------------------------------------------------------------*/

   return (spacket[2] == 'M') ?         /* Slave want to become master? */
					XFER_NOLOCAL : 	    /* call sbreak() to allow master */
					XFER_FILEDONE ;     /* go get the next file to send */

} /*seof*/


/*--------------------------------------------------------------------*/
/*    n e w r e q u e s t                                             */
/*                                                                    */
/*    Determine the next request to be sent to other host             */
/*--------------------------------------------------------------------*/

XFER_STATE newrequest( void )
{
   int i;

/*--------------------------------------------------------------------*/
/*                 Verify we have no work in progress                 */
/*--------------------------------------------------------------------*/

   if (!(xfer_stream == NULL)) {
	  printmsg(0, "newrequest: previous request not completed");
	  return XFER_ABORT;      /* Something's already open.  We're in
								 trouble!                            */
   }

   printmsg(3, "newrequest: looking in work file...");

/*--------------------------------------------------------------------*/
/*    Look for work in the current call file; if we do not find       */
/*    any, the job is complete and we can delete all the files we     */
/*    worked on in the file                                           */
/*--------------------------------------------------------------------*/

   if (fgets(command, BUFSIZ, fwork) == nil(char))    /* More data?     */
   {                          /* No --> clean up list of files       */
	  fclose(fwork);
	  fwork = nil(FILE);
	  if (!errors_per_request) {
		  unlink(workfile);       /* Delete completed call file          */
		  requests++;
	  }
	  return XFER_NEXTJOB;    /* Get next C.* file to process     */
   } /* if (fgets(command, BUFSIZ, fwork) == nil(char)) */

/*--------------------------------------------------------------------*/
/*                  We have a new request to process                  */
/*--------------------------------------------------------------------*/

   i = strlen(command) - 1;
   if (command[i] == '\n')            /* remove new_line from card */
	  command[i] = '\0';

   sscanf(command, "%c %s %s %s %s %s",
		 &type, fname, tname, who, cmdopts, dname);

/*--------------------------------------------------------------------*/
/*                           Reset counters                           */
/*--------------------------------------------------------------------*/

   bytes = 0;
   ftime(&start_time);
   (*filepkt)();              /* Init for file transfer */

/*--------------------------------------------------------------------*/
/*             Process the command according to its type              */
/*--------------------------------------------------------------------*/

   switch( type )
   {
	  case 'R':
		 return XFER_GETFILE;

	  case 'S':
		 return XFER_PUTFILE;

	  default:
		 return XFER_FILEDONE;   /* Ignore the line                  */
	} /* switch */

} /* newrequest */

/*--------------------------------------------------------------------*/
/*    s s f i l e                                                     */
/*                                                                    */
/*    Send File Header for file to be sent                            */
/*--------------------------------------------------------------------*/

XFER_STATE ssfile( void )
{
   char hostfile[FILENAME_MAX];
   char *filename, *showname;

   if (equal(dname, "D.0"))   /* Is there a spool file?              */
	  filename = fname;       /* No --> Use the real name            */
   else
	  filename = dname;       /* Yes --> Use it                      */

/*--------------------------------------------------------------------*/
/*              Convert the file name to our local name               */
/*--------------------------------------------------------------------*/

   showname = tname;
   if (strncmp(filename, "D.", 2) == 0)
	   importpath(hostfile, filename, rmtname);
   else {
	   strcpy(hostfile, filename);
	   (void) expand_path(hostfile, NULL, pubdir, NULL);
	   showname = hostfile;
   }

   printmsg(3, "ssfile: opening %s (%s) for sending", filename, hostfile);

/*--------------------------------------------------------------------*/
/*    Try to open the file; if we fail, we just continue, because we  */
/*    may have sent the file on a previous call which failed part     */
/*    way through this job                                            */
/*--------------------------------------------------------------------*/

   xfer_stream = FOPEN( hostfile, "r", BINARY );
									/* Open stream to send           */
   if (xfer_stream == NULL)
   {
	  if (errno != ENOENT)
		errors_per_request ++;
	  printerr("ssfile", hostfile);
	  printmsg(0, "ssfile: cannot open file %s (%s)", filename, hostfile);
	  return XFER_FILEDONE;      /* Try next file in this job  */
   } /* if */

/*--------------------------------------------------------------------*/
/*              The file is open, now set its buffering               */
/*--------------------------------------------------------------------*/

   if (setvbuf( xfer_stream, NULL, _IOFBF, xfer_bufsize))
   {
	  printerr("ssfile", hostfile);
	  printmsg(0, "ssfile: can't buffer=%d file %s (%s)",
				  xfer_bufsize, filename, hostfile);
	  return XFER_ABORT;         /* Clearly not our day; quit  */
   } /* if */


/*--------------------------------------------------------------------*/
/*    Okay, we have a file to process; offer it to the other host     */
/*--------------------------------------------------------------------*/

   printmsg(1, "ssfile: sending \"%s\" (%s) as \"%s\"", fname, hostfile, tname);

   Sftrans(SF_SEND, hostfile, showname); /* Send */

   if (!pktsendstr( command ))   /* Tell them what is coming at them */
	  return XFER_LOST;

   if (!pktgetstr((char *)spacket))
	  return XFER_LOST;

   if ((*spacket != 'S') || ((spacket[1] != 'N') && (spacket[1] != 'Y')))
   {
	  printmsg(0,"ssfile: invalid response from remote: %s",spacket);
	  return XFER_ABORT;
   }

   if (spacket[1] != 'Y')     /* Otherwise reject file transfer?     */
   {                          /* Yes --> Look for next file          */
	  char *s;
	  switch(spacket[2]) {
		case '2':
			s = "not permitted";
			break;
		case '4':
			s = "can't create temp file";
			break;
		case '\0':
			s = "unknown";
			break;
		default:
			s = &spacket[2];
			break;
	  }
	  printmsg(0, "ssfile: %s rejected by remote, reason: %s", tname, s);
	  fclose( xfer_stream );
	  xfer_stream = NULL;
	  return XFER_FILEDONE;
   }

   S_size = bufill((char *) spacket);
   if ( S_size == -1 )
      return XFER_ABORT;   /* cannot send file */

   return XFER_SENDDATA;      /* Enter data transmission mode        */

} /*ssfile*/

/*--------------------------------------------------------------------*/
/*    s r f i l e                                                     */
/*                                                                    */
/*    Send File Header for file to be received                        */
/*--------------------------------------------------------------------*/

XFER_STATE srfile( void )
{
   char hostfile[FILENAME_MAX];
   struct  stat    statbuf;
   char *showname;

/*--------------------------------------------------------------------*/
/*               Convert the filename to our local name               */
/*--------------------------------------------------------------------*/

   showname = tname;
   if (   strncmp(tname, "D.", 2) == 0
	   || strncmp(tname, "X.", 2) == 0
	  )
	   importpath(hostfile, tname, rmtname);
   else {
	   strcpy(hostfile, tname);
	   (void) expand_path(hostfile, NULL, pubdir, NULL);
	   showname = hostfile;
   }

/*--------------------------------------------------------------------*/
/*    If the destination is a directory, put the originating          */
/*    original file name at the end of the path                       */
/*--------------------------------------------------------------------*/

   if ((hostfile[strlen(hostfile) - 1] == '/') ||
	   ((stat(hostfile , &statbuf) == 0) && (statbuf.st_mode & S_IFDIR)))
   {
	  char *slash = strrchr( fname, '/');

	  if ( slash == NULL )
		 slash = fname;
	  else
		 slash ++ ;

	  printmsg(5, "srfile: destination \"%s\" is directory, \
appending filename \"%s\"", hostfile, slash);

	  if (hostfile[strlen(hostfile) - 1] != '/')
		 strcat(hostfile, "/");

	  strcat( hostfile, slash );
   } /* if */

   printmsg(1, "srfile: receiving \"%s\" as \"%s\" (%s)", fname, tname, hostfile);

   Sftrans(SF_RECV, hostfile, showname); /* Receive */

   if (!pktsendstr( command ))
	  return XFER_LOST;

   if (!pktgetstr((char *)spacket))
	  return XFER_LOST;

   if ((*spacket != 'R') || ((spacket[1] != 'N') && (spacket[1] != 'Y')))
   {
	  printmsg(0,"srfile: invalid response from remote: %s",spacket);
	  return XFER_ABORT;
   }

   if (spacket[1] != 'Y')     /* Otherwise reject file transfer?     */
   {                          /* Yes --> Look for next file          */
	  char *s;
	  switch (spacket[2]) {
		case '2':
			s = "not permitted";
			break;
		case '\0':
			s = "unknown";
			break;
		default:
			s = &spacket[2];
			break;
	  }
	  printmsg(0, "srfile: access to %s denied by remote, reason: %s", fname, s);
	  fclose( xfer_stream );
	  xfer_stream = NULL;
	  return XFER_FILEDONE;
   }

/*--------------------------------------------------------------------*/
/*    We should verify the directory exists if the user doesn't       */
/*    specify the -d option, but I've got enough problems this        */
/*    week; we'll just auto-create using FOPEN()                      */
/*--------------------------------------------------------------------*/

   xfer_stream = FOPEN(hostfile, "w", BINARY);
						   /* Allow auto-create of directory      */
   if (xfer_stream == NULL)
   {
	  printerr("srfile", hostfile);
	  printmsg(0, "srfile: cannot create %s", hostfile);
	  return XFER_ABORT;
   }

/*--------------------------------------------------------------------*/
/*                     Set buffering for the file                     */
/*--------------------------------------------------------------------*/

   if (setvbuf( xfer_stream, NULL, _IOFBF, xfer_bufsize))
   {
	  printerr("srfile", hostfile);
	  printmsg(0, "srfile: can't buffer=%d file %s (%s)",
		  xfer_bufsize, tname, hostfile);
	  return XFER_ABORT;
   } /* if */

   spool = FALSE;             /* Do not rename file at completion */
   return XFER_RECVDATA;      /* Now start receiving the data     */

} /*stfile*/

/*--------------------------------------------------------------------*/
/*    s i n i t                                                       */
/*                                                                    */
/*    Send Initiate:  send this host's parameters and get other       */
/*    side's back.                                                    */
/*--------------------------------------------------------------------*/

XFER_STATE sinit( void )
{
   int r = (*openpk)();

   return (r == S_LOST) ? XFER_LOST : (r ? XFER_ABORT : XFER_MASTER);

} /*sinit*/


/*********************** MISC SUB SUB PROTOCOL *************************/

/*
   s c h k d i r

   scan spooling directory for C.* files for the other system
*/

XFER_STATE schkdir( void )
{
   XFER_STATE c;

   c = scandir(rmtname);      /* Determine if data for the host      */
   scandir( NULL );           /* Reset directory search pointers     */

   switch ( c )
   {
	  case XFER_ABORT:        /* Internal error opening file         */
		 return XFER_ABORT;

	  case XFER_NOLOCAL:      /* No work for host                    */
		 if (! pktsendstr("HY") )
			return XFER_LOST;

		 if (!pktgetstr((char *)rpacket))
			return XFER_LOST; /* Didn't get response, die quietly    */
		 else {
			if (*rpacket != 'H' || rpacket[1] != 'Y')
			{
				printmsg(0,"schkdir: invalid response from remote: %s",rpacket);
				return XFER_ABORT;
			}
			return XFER_ENDP; /* Got response, we're out of here     */
		 }

	  case XFER_REQUEST:
		 if (! pktsendstr("HN") )
			return XFER_LOST;
		 else {
			printmsg( 2, "schkdir: switch into master mode" );
			return XFER_MASTER;
         }

	  default:
         panic();
         return XFER_ABORT;

   } /* switch */
} /*schkdir*/

/*--------------------------------------------------------------------*/
/*    e n d p                                                         */
/*                                                                    */
/*    end the protocol                                                */
/*--------------------------------------------------------------------*/

XFER_STATE endp( void )
{
   if ((*closepk)() == S_LOST)
	  return XFER_LOST;

   if (spool)
   {
	  unlink(tempname);
	  spool = FALSE;
   }
   return XFER_EXIT;

} /*endp*/


/*********************** RECIEVE PROTOCOL **********************/

/*--------------------------------------------------------------------*/
/*    r d a t a                                                       */
/*                                                                    */
/*    Receive Data                                                    */
/*--------------------------------------------------------------------*/

XFER_STATE rdata( void )
{
   int   len;

   if ((*getpkt)((char *) rpacket, &len) != OK)
	  return XFER_LOST;

/*--------------------------------------------------------------------*/
/*                         Handle end of file                         */
/*--------------------------------------------------------------------*/

   if (len == 0)
	  return XFER_RECVEOF;

/*--------------------------------------------------------------------*/
/*                  Write incoming data to the file                   */
/*--------------------------------------------------------------------*/

   if (bufwrite((char *) rpacket, len) < len) {                   /* ahd   */
	  printmsg(0, "rdata: error writing data to file.");
	  return XFER_ABORT;
   }

   return XFER_RECVDATA;      /* Remain in data state                */

} /*rdata*/

/*--------------------------------------------------------------------*/
/*    r e o f                                                         */
/*                                                                    */
/*    Process EOF for a received file                                 */
/*--------------------------------------------------------------------*/

XFER_STATE reof( void )
{
   struct tm *tmx;
   struct timeb now;
   char *cy = "CY";
   char *cn = "CN";
   char *response = cy;
   char *fname = spool ? tempname : spolname;

/*--------------------------------------------------------------------*/
/*            Close out the file, checking for I/O errors             */
/*--------------------------------------------------------------------*/

   fclose(xfer_stream);
   if (ferror (xfer_stream ))
   {
	  response = cn;          /* Report we had a problem             */
	  printerr( "reof", fname );
   }

   xfer_stream = NULL;        /* To make sure!                       */

/*--------------------------------------------------------------------*/
/*    If it was a spool file, rename it to its permanent location     */
/*--------------------------------------------------------------------*/

   if (spool && equal(response,cy))
   {
	  unlink( spolname );     /* Should be safe, since we only do it
								 for spool files                     */

	  if ( RENAME(tempname, spolname ))
	  {
		 printmsg(0,"reof: unable to rename %s to %s",
				  tempname, spolname);
		 response = cn;
	  } /* if ( RENAME(tempname, spolname )) */
	  spool = FALSE;
   } /* if (equal(response,cy) && spool) */

   if (!pktsendstr(response)) /* Announce we accepted the file       */
	  return XFER_LOST;       /* No ACK?  Return, if so              */

   if ( !equal(response, cy) )   /* If we had an error, delete file  */
   {
	  printmsg(0,"reof: deleting corrupted file %s", fname );
	  unlink( fname );
	  return XFER_ABORT;
   } /* if ( !equal(response, cy) ) */

/*--------------------------------------------------------------------*/
/*            The file is delivered; compute stats for it             */
/*--------------------------------------------------------------------*/

   remote_stats.freceived++;
   remote_stats.breceived += bytes;
   hostp->idlewait = MIN_IDLE;	/* Reset wait time */

   ftime(&now);
   ticks = (now.time - start_time.time) * 1000 +
		   ((long) now.millitm - (long) start_time.millitm);
   if (ticks <= 0)
		ticks = 1;

   Sftrans(SF_RDONE, fname, NULL); /* Receiving done */

   printmsg(2, "reof: transfer completed, %ld chars/sec",
				  bytes * 1000 / ticks);

   if (syslog != NULL) {
	   tmx = localtime(&now.time);
	   fprintf( syslog,
			"%s!%s (%s) (%d/%d-%02d:%02d:%02d) <- %ld / %ld.%02d secs\n",
				   rmtname, tname, spolname,
				   (tmx->tm_mon+1), tmx->tm_mday,
				   tmx->tm_hour, tmx->tm_min, tmx->tm_sec, bytes,
				   ticks / 1000 , (int) ((ticks % 1000) / 10) );
   }

/*--------------------------------------------------------------------*/
/*                      Return success to caller                      */
/*--------------------------------------------------------------------*/

   return XFER_FILEDONE;
} /* reof */

/*
   r h e a d e r

   Receive File Header
*/

XFER_STATE rheader( void )
{
   if (!pktgetstr(command))
	  return XFER_LOST;

/*--------------------------------------------------------------------*/
/*        Return if the remote system has no more data for us         */
/*--------------------------------------------------------------------*/

   if ((command[0] & 0x7f) == 'H')
	  return XFER_NOREMOTE;   /* Report master has no more data to   */

/*--------------------------------------------------------------------*/
/*                  Begin transforming the file name                  */
/*--------------------------------------------------------------------*/

   printmsg(5, "rheader: command \"%s\"", command);

   sscanf(command, "%c %s %s %s %s %s",
		 &type, fname, tname, who, cmdopts, dname);

/*--------------------------------------------------------------------*/
/*                           Reset counters                           */
/*--------------------------------------------------------------------*/

   ftime(&start_time);
   bytes = 0;
   (*filepkt)();              /* Init for file transfer */

/*--------------------------------------------------------------------*/
/*                 Return with next state to process                  */
/*--------------------------------------------------------------------*/

   switch (type)
   {
	  case 'R':
		 return XFER_GIVEFILE;

	  case 'S':
		 return XFER_TAKEFILE;

	  default:
		 printmsg(0,"rheader: unsupported verb \"%c\" rejected",type);
		 if (!pktsendstr("XN"))  /* Reject the request               */
			return XFER_LOST;    /* Die if reponse fails             */
		 return XFER_FILEDONE;   /* Process next request          */
   } /* switch */

} /* rheader */

/*--------------------------------------------------------------------*/
/*    r r f i l e                                                     */
/*                                                                    */
/*    Setup for receiving a file as requested by the remote host      */
/*--------------------------------------------------------------------*/

XFER_STATE rrfile( void )
{
   char filename[FILENAME_MAX];
   size_t subscript;
   struct  stat    statbuf;
   char *showname;

/*--------------------------------------------------------------------*/
/*       Determine if the file can go into the spool directory        */
/*--------------------------------------------------------------------*/

   spool = ((*tname == 'D' || *tname == 'X') && tname[1] == '.');

   expand_path( strcpy( filename, tname),
	  spool ? "." : pubdir, pubdir , NULL);

   printmsg(5, "rrfile: destination \"%s\"", filename );

/*--------------------------------------------------------------------*/
/*       Check if the name is a directory name (end with a '/')       */
/*--------------------------------------------------------------------*/

   subscript = strlen( filename ) - 1;

   if ((filename[subscript] == '/') ||
	   ((stat(filename , &statbuf) == 0) && (statbuf.st_mode & S_IFDIR)))
   {
	  char *slash = strrchr(fname, '/');
	  if (slash  == NULL)
		 slash = fname;
	  else
		 slash++;

	  printmsg(5, "rrfile: destination is directory \"%s\", adding \"%s\"",
			   filename, slash);

	  if ( filename[ subscript ] != '/')
		 strcat(filename, "/");
	  strcat(filename, slash);
   } /* if */

/*--------------------------------------------------------------------*/
/*          Let host munge filename as appropriate                    */
/*--------------------------------------------------------------------*/

   showname = tname;
   if (spool)
	   importpath(spolname, filename, rmtname);
   else {
	   char *path = strchr(pubdir, ':');
	   char *rpath = strchr(filename, ':');
	   char *s;

	   if (!path || !rpath) {
			if (path)
				path++;
			else
				path = pubdir;
			if (rpath)
				strcpy(filename, rpath + 1);
	   }
	   else
			path = pubdir;
	   for (s = filename; *s; s++)
			if (*s == '/')
				*s = '\\';

	   printmsg(6, "rrfile: valid path for remotes is %s", path);

	   if (   strnicmp(filename, path, strlen(path)) != 0
		   || strstr(filename, "..") != NULL
		  ) {
		  printmsg(0, "rrfile: path not permitted, \"%s\" rejected",
					  filename);
		  if (!pktsendstr("SN2"))    /* Request not permitted  */
			 return XFER_LOST;       /* School is out, die            */
		  return XFER_FILEDONE;   /* Tell them to send next file   */
	   }
	   strcpy(spolname, filename);
	   showname = filename;
   }

/*--------------------------------------------------------------------*/
/*            The filename is transformed, try to open it             */
/*--------------------------------------------------------------------*/

   if (spool)
	  xfer_stream = FOPEN( mktempname( tempname, "SPL" ), "w", BINARY);
   else if (strchr( cmdopts,'d'))
	  xfer_stream = FOPEN( spolname, "w", BINARY );
   else
	  xfer_stream = fopen( spolname, "wb" ); /* Without creating dirs */


   if (xfer_stream == NULL)
   {
	  printerr("rrfile", spool ? tempname : spolname);
	  printmsg(0, "rrfile: cannot open file %s (%s)",
		   filename, spool ? tempname : spolname);
	  if (!pktsendstr("SN4"))    /* Report cannot create file     */
		 return XFER_LOST;       /* School is out, die            */
	  return XFER_FILEDONE;   /* Tell them to send next file   */
   } /* if */

/*--------------------------------------------------------------------*/
/*               The file is open, now try to buffer it               */
/*--------------------------------------------------------------------*/

   if (setvbuf( xfer_stream, NULL, _IOFBF, xfer_bufsize))
   {
	  printerr("rrfile", spool ? tempname : spolname);
	  printmsg(0, "rrfile: can't buffer=%d file %s (%s)",
		  xfer_bufsize, filename, spool ? tempname : spolname);
	  if (!pktsendstr("SN4"))             /* Report cannot create file     */
		return XFER_LOST;
	  return XFER_ABORT;
   } /* if */

/*--------------------------------------------------------------------*/
/*    Announce we are receiving the file to console and to remote     */
/*--------------------------------------------------------------------*/

   printmsg(1, "rrfile: receiving \"%s\" as \"%s\" (%s)",
			   fname,filename,spolname);
   if (spool)
	   printmsg(5,"rrfile: using temp name %s",tempname);

   Sftrans(SF_RECV, spool ? tempname : spolname, showname); /* Receive */

   if (!pktsendstr("SY"))
	  return XFER_LOST;

   return XFER_RECVDATA;   /* Switch to data state                */

} /*rrfile*/

/*--------------------------------------------------------------------*/
/*    r s f i l e                                                     */
/*                                                                    */
/*    Setup to transmit remote requested us to                        */
/*    send                                                            */
/*--------------------------------------------------------------------*/

XFER_STATE rsfile( void )
{
   char filename[FILENAME_MAX];
   char hostname[FILENAME_MAX];
   struct  stat    statbuf;
   size_t subscript;
   boolean localspool;
   char *showname;

/*--------------------------------------------------------------------*/
/*       Determine if the file can go into the spool directory        */
/*--------------------------------------------------------------------*/

   localspool = ((*tname == 'D' || *tname == 'X') && tname[1] == '.');

   expand_path( strcpy(filename, fname ) ,
				localspool ? "." : pubdir, pubdir, NULL);

/*--------------------------------------------------------------------*/
/*               Let host munge filename as appropriate               */
/*--------------------------------------------------------------------*/

   if (localspool)
	   importpath(hostname, filename, rmtname);
   else
	   strcpy(hostname, filename);
   printmsg(3, "rsfile: input \"%s\", source \"%s\", host \"%s\"",
									fname, filename , hostname);

/*--------------------------------------------------------------------*/
/*       Check if the name is a directory name (end with a '/')       */
/*--------------------------------------------------------------------*/

   subscript = strlen( filename ) - 1;

   if ((filename[subscript] == '/') ||
	   ((stat(hostname , &statbuf) == 0) && (statbuf.st_mode & S_IFDIR)))
   {
	  printmsg(0, "rsfile: source is directory \"%s\", rejecting",
			   hostname);
reject:
	  if (!pktsendstr("RN2"))    /* Report cannot send file       */
		 return XFER_LOST;       /* School is out, die            */
	  return XFER_FILEDONE;   /* Tell them to send next file   */
   } /* if */

   showname = tname;
   if (!localspool) {
	  char *path = strchr(pubdir, ':');
	  char *spath = strchr(hostname, ':');
	  char *s;

	  if (!path || !spath) {
			if (path)
				path++;
			else
				path = pubdir;
			if (spath)
				strcpy(hostname, spath + 1);
	  }
	   else
			path = pubdir;
	  for (s = hostname; *s; s++)
			if (*s == '/')
				*s = '\\';

	  printmsg(6, "rsfile: valid path for remotes is %s", path);

	  if (   strnicmp(hostname, path, strlen(path)) != 0
		  || strstr(hostname, "..") != NULL
		 ) {
		  printmsg(0, "rsfile: path not permitted, \"%s\" rejected",
			   hostname);
		  goto reject;
	  }
	  showname = hostname;
   }

/*--------------------------------------------------------------------*/
/*            The filename is transformed, try to open it             */
/*--------------------------------------------------------------------*/

   printmsg(3, "rsfile: opening %s (%s) for sending", fname, hostname);
   xfer_stream = FOPEN( hostname, "r" , BINARY);
							  /* Open stream to transmit       */
   if (xfer_stream == NULL)
   {
	  printerr("rsfile", hostname);
	  printmsg(0, "rsfile: cannot open file %s (%s)", fname, hostname);
	  if (!pktsendstr("RN2"))    /* Report cannot send file       */
		 return XFER_LOST;       /* School is out, die            */
	  return XFER_FILEDONE;   /* Tell them to send next file   */
   } /* if */

   if (setvbuf( xfer_stream, NULL, _IOFBF, xfer_bufsize))
   {
	  printerr("rsfile", hostname);
	  printmsg(0, "rsfile: can't buffer=%d file %s (%s)",
					   xfer_bufsize, fname, hostname);
	  if (!pktsendstr("RN2"))         /* Tell them we cannot handle it */
		return XFER_LOST;
	  return XFER_ABORT;
   } /* if */

/*--------------------------------------------------------------------*/
/*  We have the file open, announce it to the log and to the remote   */
/*--------------------------------------------------------------------*/

   if (!pktsendstr("RY"))
	  return XFER_LOST;

   printmsg(1, "rsfile: sending \"%s\" (%s) as \"%s\"", fname, hostname, tname);

   Sftrans(SF_SEND, hostname, showname); /* Send */

   S_size = bufill((char *) spacket);
   if ( S_size == -1 )
	  return XFER_ABORT;   /* cannot send file */

   return XFER_SENDDATA;   /* Switch to send data state        */

} /*rsfile*/


/*--------------------------------------------------------------------*/
/*    r i n i t                                                       */
/*                                                                    */
/*    Receive Initialization                                          */
/*--------------------------------------------------------------------*/

XFER_STATE rinit( void )
{

   return (*openpk)() == OK  ? XFER_SLAVE : XFER_LOST;

} /*rinit*/

/*--------------------------------------------------------------------*/
/*    p k t s e n d s t r                                             */
/*                                                                    */
/*    Transmit a control packet                                       */
/*--------------------------------------------------------------------*/

static boolean pktsendstr( char *s )
{
   printmsg(2, ">>> %s", s);

   if((*wrmsg)(s) != OK )
	  return FALSE;

   /* remote_stats.bsent += strlen(s) + 1; */

   return TRUE;
} /* pktsendstr */

/*--------------------------------------------------------------------*/
/*    p k t g e t s t r                                               */
/*                                                                    */
/*    Receive a control packet                                        */
/*--------------------------------------------------------------------*/

static boolean pktgetstr( char *s)
{
   if ((*rdmsg)(s) != OK )
	 return FALSE;

   /* remote_stats.breceived += strlen( s ) + 1; */
   printmsg(2, "<<< %s", s);

   return TRUE;
} /* pktgetstr */

