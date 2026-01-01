/*--------------------------------------------------------------------*/
/*    m o d e m . c                                                   */
/*                                                                    */
/*    High level modem control routines for UUPC/extended             */
/*                                                                    */
/*    Copyright (c) 1991 by Andrew H. Derbyshire                      */
/*                                                                    */
/*    Change history:                                                 */
/*       21 Apr 91      Create from dcpsys.c                          */
/*--------------------------------------------------------------------*/

#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <sys/types.h>
#include <ctype.h>

#include "lib.h"
#include "arpadate.h"
#include "checktim.h"
#include "dcp.h"
#include "dcpsys.h"
#include "hlib.h"
#include "hostable.h"
#include "modem.h"
#include "script.h"
#include "ssleep.h"
#include "ulib.h"
#include "comm.h"
#include "mnp.h"
#include "screen.h"

char *device = NULL;    /*Public to show in login banner     */

#define DEF_WAIT_TICS 0
#define DEF_TIMEOUT 3
/* Modem information table */
#define MDM_INIT 0
#define MDM_RING 1
#define MDM_ANSWER 2
#define MDM_DIAL 3

#define MDM_NKIND 4

typedef boolean (*modemp)(void);

typedef struct {
	char*	mdsend;
	char*	mdexp;
	int	mdtime;
} mdinit;

char* commrate[32];
char* phonerate[32];
int	set_speed;
boolean Direct;
boolean echochk = FALSE;
boolean ModemMode = FALSE;
extern  boolean NoCheckCarrier;
extern  boolean WorthTrying;
extern  char respbuf[256];

#define MAXCMDI 32
#define MAXCMSG 16
static mdinit commd[MDM_NKIND][MAXCMDI+2];
static mdmsgs commsg[MAXCMSG+2];


INTEGER chardelay = 100,	/* Default delay after character send */
		dialTimeout,
		modemTimeout,
		scriptTimeout = 15;
static	modemp	 driver;
extern char	 *brand;
static char 	 *ModemName = NULL;
extern char	 *S_sysspeed;
extern char  *rate;
static  char *hang_str;
int WaitRing;
extern Max_Attempts, attempts, Max_Idle, Seq_Attempts;
int MaxTry = 2;
extern MnpEmulation, MnpWaitTics;
extern void (*p_hangup)(void);
static boolean direct(void);
static boolean SetModem(char *);
static boolean cdial(mdinit*, int, int);

/*--------------------------------------------------------------------*/
/*                    Internal function prototypes                    */
/*--------------------------------------------------------------------*/

static boolean sendalt( char *string, int timeout);

/*--------------------------------------------------------------------*/
/*              Define current file name for references               */
/*--------------------------------------------------------------------*/

currentfile();

void increase_idle(void)
{
   hostp->idlewait *= 3;
   hostp->idlewait /= 2;
   if (Max_Idle > 0 && hostp->idlewait > 60L * Max_Idle)
	 hostp->idlewait = Max_Idle * 60L;
}

/*--------------------------------------------------------------------*/
/*    c a l l u p                                                     */
/*                                                                    */
/*    script processor - nothing fancy!                               */
/*--------------------------------------------------------------------*/

CONN_STATE callup()
{
   char *exp;
   int i;

   /* Dial a modem  */
   driver = NULL;
   p_hangup = NULL;
   MnpEmulation = 0;
   MnpWaitTics = DEF_WAIT_TICS;
   ModemName = flds[FLD_TYPE];
/*--------------------------------------------------------------------*/
/*      Determine if the window for calling this system is open       */
/*--------------------------------------------------------------------*/

   if ( !callnow && equal(flds[FLD_CCTIME],"Never" ))
											 /* Don't update if we   */
	  return CONN_INITIALIZE;                /* never try calling    */

   time(&hostp->hstats->ltime); /* Save time of last attempt to call   */

/*--------------------------------------------------------------------*/
/*    Check the time of day and whether or not we should call now.    */
/*                                                                    */
/*    If calling a system to set the clock and we determine the       */
/*    system clock is bad (we fail the sanity check of the last       */
/*    connected a host to being in the future), then we ignore the    */
/*    time check field.                                               */
/*--------------------------------------------------------------------*/

   if (!(callnow || checktime(flds[FLD_CCTIME],(time_t) 0)))
   {

		 hostp->hstatus = wrong_time;
		 return CONN_INITIALIZE;
   } /* if */

/*--------------------------------------------------------------------*/
/*             Announce we are trying to call the system              */
/*--------------------------------------------------------------------*/

   printmsg(1, "callup: calling \"%s\" via %s at %s on %s",
		  rmtname, ModemName, flds[FLD_PHONE], arpadate());

   hostp->hstatus = dial_failed; /* Assume failure in the dial */

/*--------------------------------------------------------------------*/
/*                     Get the modem information                      */
/*--------------------------------------------------------------------*/

	if ( equal(ModemName, "DIR") )
		driver = direct;
	else {   /* Modem from Dialers */
		if (!SetModem(ModemName))
			return CONN_INITIALIZE;
	}
	brand = ModemName;

   if (driver == NULL)
   {
	  printmsg(0,"callup: Unsupported modem type \"\%s\"",
			   ModemName);
	  return CONN_INITIALIZE;
   }

/*--------------------------------------------------------------------*/
/*                         Dial the telephone                         */
/*--------------------------------------------------------------------*/

   Slink(SL_CALLING, rmtname, arpadate());

   set_answer_mode(FALSE);

   if (!driver())	/* Check lost carrier now */
	   return CONN_DROPLINE;

   if (!set_connected(TRUE))	/* Check lost carrier now */
	   return CONN_DROPLINE;

/*--------------------------------------------------------------------*/
/*             The modem is connected; now login the host             */
/*--------------------------------------------------------------------*/

   hostp->hstatus =  script_failed; /* Assume failure          */
   for (i = FLD_EXPECT; i < kflds; i += 2) {

	  exp = flds[i];
	  printmsg(2, "expecting %d of %d \"%s\"", i, kflds, exp);
	  if (!sendalt( exp, scriptTimeout ))
	  {
		 printmsg(0, "Login script FAILED, bad line quality (maybe)");
		 return CONN_DROPLINE;
	  } /* if */

	  printmsg(2, "callup: sending %d of %d \"%s\"",
				   i + 1, kflds, flds[i + 1]);
	  if (sendstr(flds[i + 1]) != S_OK)
		return CONN_DROPLINE;

   } /*for*/

   return CONN_PROTOCOL;

} /*callup*/

/*--------------------------------------------------------------------*/
/*    c a l l i n                                                     */
/*                                                                    */
/*    Answer the modem in passive mode                                */
/*--------------------------------------------------------------------*/

CONN_STATE callin( const char *logintime )
{
   int    offset;             /* Time to wait for telephone          */

/*--------------------------------------------------------------------*/
/*    Determine how long we can wait for the telephone, up to         */
/*    MAX_INT seconds.  Aside from Turbo C limits, this insures we    */
/*    kick the modem once in a while.                                 */
/*--------------------------------------------------------------------*/

   if  (logintime == NULL)    /* Any time specified?                 */
	  offset = INT_MAX;       /* No --> Run almost forever           */
   else {                     /* Yes --> Determine elapsed time      */
	  int delta = 4096;       /* Rate at which we change offset      */
	  boolean split = FALSE;

	  if (!checktime(logintime,(time_t) 0)) /* Still want system up? */
         return CONN_EXIT;             /* No --> shutdown            */

	  offset = 0;             /* Wait until end of this minute       */
	  while ( ((INT_MAX - delta) > offset ) && (delta > 0))
	  {
		 printmsg(4,"Current time is %s, offset is %d, offset is %d",
					 arpadate(), offset, delta);
		 if (checktime(logintime,(time_t) offset + delta))
			offset += delta;
		 else
			split = TRUE;     /* Once we starting splitting, we
								 never stop                          */
		 if ( split )
			delta /= 2;
	  } /* while */
   } /* else */

/*--------------------------------------------------------------------*/
/*                        Open the serial port                        */
/*--------------------------------------------------------------------*/

   if (E_inmodem == NULL)
   {
	  printmsg(0,"callin: No modem name supplied for incoming calls!");
	  panic();
   } /* if */

   p_hangup = NULL;
   ModemName = E_inmodem;
   MnpEmulation = 0;
   MnpWaitTics = DEF_WAIT_TICS;
   if ( equal(E_inmodem, "DIR") )
	 Direct = TRUE;
   else if (!SetModem(E_inmodem))  /* Initialize modem configuration      */
	  panic();                /* Avoid loop if bad modem name        */
   brand = E_inmodem;

   if ((!Direct && commd[MDM_RING][0].mdexp == NULL) || (E_inspeed == NULL))
   {
	  printmsg(0,"callin: Missing inspeed and/or ring values in modem \
configuration file.");
	  panic();
   } /* if */

/*--------------------------------------------------------------------*/
/*                    Open the communications port                    */
/*--------------------------------------------------------------------*/

   if (openline(E_indevice, (unsigned short)atol(E_inspeed)))
	  panic();

   if (!Direct) {
/*--------------------------------------------------------------------*/
/*                        Initialize the modem                        */
/*--------------------------------------------------------------------*/

   if (!cdial(&commd[MDM_INIT], MDM_INIT, 0))
   {
	  printmsg(0,"callin: Modem failed to initialize");
	  panic();
   }
   if (!NoCheckCarrier && carrier(TRUE))
   {
	  printmsg(0, "callin: Why carrier present? Check your modem.");
	  panic();
   }

/*--------------------------------------------------------------------*/
/*                   Wait for the telephone to ring                   */
/*--------------------------------------------------------------------*/

   WaitRing = offset;
   if (!cdial(&commd[MDM_RING], MDM_RING, 0))
							  /* Did it ring?                        */
   {
	  shutdown();
	  return CONN_INITIALIZE;     /* No --> Return to caller       */
   }

   set_answer_mode(TRUE);

   if (!cdial(&commd[MDM_ANSWER], MDM_ANSWER, 0))
							  /* Pick up the telephone               */
   {
	  printmsg(1,"callin: modem failed to connect to incoming call");
	  shutdown();
	  return CONN_INITIALIZE;
   }

   }	/* !Direct */

   printmsg(14, "callin: got CONNECT");

   memset( &remote_stats, 0, sizeof remote_stats);
							  /* Clear remote stats for login        */
   time(&remote_stats.ltime); /* Remember time of last attempt conn  */
   remote_stats.calls ++ ;
   return CONN_LOGIN;

} /* callin */


/*--------------------------------------------------------------------*/
/*    s e n d a l t                                                   */
/*                                                                    */
/*    Expect a string, with alternates                                */
/*--------------------------------------------------------------------*/

static boolean sendalt( char *exp, int timeout)
{
   boolean ok = FALSE;
   int r;

   while (ok != TRUE) {
	  char *alternate = strchr(exp, '-');

	  if (alternate != nil(char))
		 *alternate++ = '\0';

	  r = expectstr(exp, timeout);

	  switch (r) {
	  case S_LOST:
		 return FALSE;
	  case S_TIMEOUT:
		 break;
	  default:
		 printmsg(2, "got that");
		 return TRUE;
	  }

	  if (alternate == nil(char))
		 return FALSE;

	  exp = strchr(alternate, '-');
	  if (exp != nil(char))
		 *exp++ = '\0';

	  printmsg(4, "sending alternate");
	  if (sendstr(alternate) != S_OK)
		return FALSE;
   } /*while*/
   return TRUE;

} /* sendalt */

/*--------------------------------------------------------------------*/
/*    s l o w w r i t e                                               */
/*                                                                    */
/*    Write characters to the serial port at a configurable           */
/*    snail's pace.                                                   */
/*--------------------------------------------------------------------*/

#define MAXLEN 47

int slowwrite( unsigned char *s, int len)
{
   int r = swrite( s , len );

   if (r > 0 && ModemMode) {
	  if (echochk && len == 1) {
		  char buf[1];
		  int i;

		  if (w_flush() < 0)
			  return S_LOST;
		  for (i = 0; i < MAXLEN; i++) {
			  r = sread(buf,1,1);
			  if (r > 0) {
				  if (*buf != *s) {
					  if (*buf == '\0' || strchr("\n\r\b ", *buf) != NULL)
						continue;
					  return S_LOST;
				  }
				  else
					break;
			  }
			  else
				break;
		  }
		  if (i >= MAXLEN)
			  return S_LOST;
	  }
	  else if (chardelay > 0)
		ddelay(chardelay);
   }
   return r;
} /* slowwrite */

/*
   d i r e c t

   Opens a line for a direct connection
 */
static boolean direct()
{
   Direct = TRUE;
   WorthTrying = TRUE;
   if (openline(flds[FLD_DEV], (unsigned short)atol(flds[FLD_PHONE])) == -1) {
	 printmsg(0, "direct: can't open direct serial port %s", flds[FLD_TYPE]);
	 return FALSE;
   }
   time( &remote_stats.lconnect );
   remote_stats.calls ++ ;
   increase_idle();

   return TRUE;         /* Return success */
}


static boolean cdial(mdinit* script0, int kind, int dial) {
	static int irate;
	static int frate;
	int maxwait;
	int answer, trycount;
	mdinit *script;
	int iii, wtime, i;
	char *s;
	boolean firsttime = TRUE, changed;
	time_t waittime;

  trycount = 0;
  changed = FALSE;

  if (dial)
	irate = frate = 0;

  for (;;) {	/* Loop in Speeds */
	if (dial && trycount >= MaxTry) {
		irate++;
		trycount = 0;
	}
	rate = dial ? commrate[irate] : E_inspeed;

redial:
	if (dial && (changed || firsttime && attempts > 0)) {
		if (hostp->hstatus == call_failed) {
			waittime = hostp->idlewait - (time(NULL) - hostp->hstats->lconnect);
			if (waittime <= 0)
				waittime = MIN_IDLE;
		}
		else
			waittime = hostp->idlewait;

		if (Max_Attempts > 0 && attempts >= Max_Attempts) {
			printmsg(-1,"cdial: all %d attempts done", Max_Attempts);
			closeline();
			return FALSE;
		}

		if (changed) {
			hostp->hattempts = attempts;
			printmsg(-1, "cdial: attempt #%d done", attempts + 1);
			attempts++;
			closeline();
			return FALSE;
		}

		if ((attempts + 1) % Seq_Attempts == 0) {
			if (Max_Attempts > 0)
				printmsg(-1, "cdial: attempt #%d (from %d max), idle wait %ld secs",
							 attempts + 1, Max_Attempts, waittime);
			else
				printmsg(-1, "cdial: attempt #%d, idle wait %ld secs",
							 attempts + 1, waittime);
			if (ssleep(waittime)) {
				hostp->idlewait = MIN_IDLE;
				printmsg(-1, "cdial: reset idle wait time to %ld", hostp->idlewait);
			}
			else
				increase_idle();
		}
		else {
			if (Max_Attempts > 0)
				printmsg(-1, "cdial: attempt #%d (from %d max)",
							 attempts + 1, Max_Attempts);
			else
				printmsg(-1, "cdial: attempt #%d",
							 attempts + 1);
		}
	}
	firsttime = FALSE;

	Direct = FALSE;
	if (dial) {
		if (openline(flds[FLD_DEV], (unsigned short)atol(rate))) {
			printmsg(0, "cdial: can't open modem serial port %s", flds[FLD_TYPE]);
			return FALSE;
		}
	}
	script = script0;
	answer = 1;
	iii = 0;
	echochk = FALSE;
	for( ; script->mdexp != NULL && answer > 0; script++) {
		wtime = (iii == 0 && kind == MDM_RING) ? WaitRing : script->mdtime;
		printmsg(3, "cdial: %s baud initialize: %d", rate, iii);
		Smodem(SM_INIT, iii++);
		ModemMode = TRUE;
		answer = sendexpect(script->mdsend, script->mdexp, wtime);
		ModemMode = FALSE;
	}
	if ( answer < S_OK ) {
		printmsg(2, "cdial: no answer at %s", rate);
		Smodem(SM_NOBAUD, 0); /* ??? */
		if (dial) {
			hangup();
			closeline();
			if (++trycount >= MaxTry && commrate[irate + 1] == NULL) {
			/* End of speed list reached */
				irate = 0;
				trycount = 0;
				changed = TRUE;
			}
			continue;
		}
		else
			return FALSE;
	}
	if (!dial && kind != MDM_ANSWER)
		return TRUE;

	if (dial) {
		if (trycount >= MaxTry) {
			frate++;
			trycount = 0;
		}
		S_sysspeed = phonerate[frate];    /* Phone loop */
	}

	if ( script->mdsend == NULL )
		 answer = 0;
	else
	{
		maxwait = script -> mdtime;
		printmsg(8, "cdial: max wait time for modem answer is %d", maxwait);
		ModemMode = TRUE;
		r_flush();
		if (sendstr(script->mdsend) != S_OK)  /* Begin dialing phone num in S_sysspeed  */
			goto Failed;
		MnpSupport();
		if (dial) {
			printmsg(3, "cdial: dialing %s", S_sysspeed);
			Smodem(SM_DIALING, maxwait);
		}
		answer = response(commsg, maxwait);
		ModemMode = FALSE;
	}

	switch(answer) {
	case S_LOST:
	case S_TIMEOUT:
	default:
	Failed:
		ModemMode = FALSE;
		printmsg(2, "cdial: (%d) no reply from modem in %d seconds",
					trycount + 1, maxwait);
		Smodem(SM_NOREPLY, trycount + 1);
		break;

	case 0:
	case 1:
	case 2:
	case 3:
	case 4:
	case 5:
	case 6:
		if ( irate != answer )
		{
			rate = commrate[answer];
			if ( set_speed ) {
				SIOSpeed((unsigned short)atol(rate));
				printmsg(-1, "cdial: baud rate changed to %s", rate);
			}
		}
		else {
			i = strcspn(respbuf, "0123456789");
			if (i < strlen(respbuf)) {
				s = rate = &respbuf[i];
				while (isdigit(*s)) s++;
				*s = '\0';
			}
		}
		printmsg(3, "cdial: connected at %s", rate);
		Smodem(SM_CONNECT, 0);
		return TRUE;

	case 11:
		printmsg(0, "cdial: (%d) phone is BUSY", trycount + 1);
		Smodem(SM_BUSY, trycount + 1);
		trycount = MaxTry - 1;
		break;

	case 12:
		printmsg(0, "cdial: (%d) no modem CARRIER", trycount + 1);
		Smodem(SM_NOCARRY, trycount + 1);
		break;

	case 13:
		printmsg(0, "cdial: (%d) no DIALTONE. Check phone or cable",
					trycount + 1);
		Smodem(SM_NOTONE, trycount + 1);
		break;
	}

	if (!dial)
		return FALSE;

	hangup();
	closeline();
	if (++trycount >= MaxTry && phonerate[frate + 1] == NULL) {
	/* End of phone list reached */
		frate = 0;
		if (phonerate[frate] == NULL) {
			printmsg(0, "cdial: bad phone list, aborting");
			closeline();
			return FALSE;
		}
		if (commrate[irate + 1] == NULL) {		/* One more speed ? */
			irate = 0;
			trycount = 0;
			changed = TRUE;
		}
		continue;
	}
	goto redial;
  }

} /* cdial */

static boolean commdm(void)
{
	WorthTrying = TRUE;
	if (commd[MDM_DIAL][0].mdsend != NULL) { /* New dialer format */
		if (!NoCheckCarrier && carrier(TRUE)) {
			  printmsg(0, "commdm: Why carrier present? Check your modem.");
			  return FALSE;
		}
		if (!cdial(&commd[MDM_DIAL], MDM_DIAL, 1))
			return FALSE;
	}
	else {
		if (!cdial(&commd[MDM_INIT], MDM_INIT, 1))
			return FALSE;
	}
	time( &remote_stats.lconnect );
	remote_stats.calls ++;
	increase_idle();

	return TRUE;
}

static
void
do_hangup(void)
{
	ModemMode = TRUE;
	(void)sendstr(hang_str);
	ModemMode = FALSE;
}

static	boolean SetModem(char *nm)
{
	char s_dialer[FILENAME_MAX];
	register char *cp, **pp;
	char *cp1;
	char S_sysline[BUFSIZ];
	char *flds[128];
	int t, kind;
	int i, Kfld;
	FILE *dlf;
	register int i_mdi, i_mds= 0, i_baud = 0;
	boolean old_format = TRUE;

	mkfilename(s_dialer, confdir, DIALERS);
	if ( (dlf = FOPEN(s_dialer,"r",TEXT)) == nil(FILE)) {
		printerr("SetModem", s_dialer);
		printmsg(0, "SetModem: can't open %s", s_dialer);
		return FALSE;
	}
	while ( (cp = fgets(S_sysline, BUFSIZ, dlf)) != (char *)0 )
	{
		i = strlen(S_sysline);
		if (i > 0 && S_sysline[i-1] == '\n')
			S_sysline[i-1] = '\0';
		if ( S_sysline[0] == '#' || S_sysline[0] == '\0' )
			continue;
		Kfld = getargs(S_sysline, flds);
		if ( equal(S_sysline,nm) )
			break;
	}
	fclose(dlf);

	if ( !cp ) {
		printmsg(0, "SetModem: Modem %s not found in %s", nm, DIALERS);
		return FALSE;
	}
	flds[Kfld] = NULL;
	cp = flds[1];
	if ( *cp == '!' )
	{
		set_speed = 1;
		cp++;
	}
	cp1 = cp;
	do
		{
	if ( *cp == ',' || !*cp )
		{
			if ( cp == cp1 ) break;
			if ( *cp == ',' ) *cp++ = '\0';
			if (commrate[i_baud] != NULL)
				free(commrate[i_baud]);
			commrate[i_baud++] = strdup(cp1);
		cp1 = cp;
		if ( !*cp ) break;
	}
		else
		{
			if ( *cp < '0' || *cp > '9' )
			{
				printmsg(0, "SetModem: Bad baud rate for modem %s: %s",nm, cp1);
				return FALSE;
			}
			cp++;
		}
	}
	while ( 1 );

	i_mdi = 0;
	/* Cleanup first entry only */
	if (commsg[0].msg_text != NULL)
		free(commsg[0].msg_text);
	commsg[0].msg_text = NULL;
	if (hang_str != NULL)
		free(hang_str);
	hang_str = NULL;
	for (pp = flds+2;*pp && *(cp = *pp) == '-'; pp++)
	{
		switch (*++cp)
		{
		case '\0':
		case '0':
		case '1':
		case '2':
		case '3':
		case '4':
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			goto TSE;
		case 'h':
			if (hang_str != NULL)
				free(hang_str);
			hang_str = strdup(cp+1);
			p_hangup = do_hangup;
			break;
		case 'c':
			i = 0;
			goto setc;
		case 'C':
			cp++;
			if ( *cp < '0' || *cp-'0' >= i_baud)
			{
				printmsg(0, "SetModem: Bad rate index in -CNExpect:%s", pp[-1]);
				return FALSE;
			}
			i = *cp -'0';
			goto setc;
		case 'b':
			i = 11;
			goto setc;
		case 'l':
			i = 12;
			goto setc;
		case 'e':
			i = 13;
setc:
			commsg[i_mds].msg_code = i;
			if (commsg[i_mds].msg_text != NULL)
				free(commsg[i_mds].msg_text);
			commsg[i_mds].msg_text = strdup(cp+1);
			if ( ++i_mds > MAXCMSG-1 )
				i_mds--;
			/* Cleanup last entry */
			if (commsg[i_mds].msg_text != NULL)
				free(commsg[i_mds].msg_text);
			commsg[i_mds].msg_text = NULL;
			break;
		case 'S':
			if (E_inspeed != NULL)
				free(E_inspeed);
			E_inspeed = strdup(cp + 1);
			printmsg(5, "SetModem: inspeed set to %s", E_inspeed);
			break;
		case 'P':
			i = atoi(cp + 1);
			if (i >= 0) {
				chardelay = i;
				printmsg(5, "SetModem: chardelay set to %d", chardelay);
			}
			else
				printmsg(0, "SetModem: %s -- bad -P[chardelay] value", cp + 1);
			break;
		case 'M':
			i = atoi(cp + 1);
			if (i == 0 || i == 2 || i == 4 || i == 5) {
				MnpEmulation = i;
				printmsg(5, "SetModem: MnpEmulation set to %d", MnpEmulation);
			}
			else
				printmsg(0, "SetModem: %s -- bad -M[npEmulation] value {0,2,4,5}", cp + 1);
			break;
		case 'E':
			i = atoi(cp + 1);
			if (i >= 1 || i <= 200) {
				MnpWaitTics = i;
				printmsg(5, "SetModem: MnpWaitTics set to %d", MnpWaitTics);
			}
			else
				printmsg(0, "SetModem: %s -- bad -E[MnpWaitTics] value {1-200}", cp + 1);
			break;
		case 'N':
			NoCheckCarrier = TRUE;
			break;
		case 'A':
		case 'R':
		case 'D':
			goto init_err;
		case 'I':
			i_mdi = -1;
			old_format = FALSE;
			goto TSE;
		case 'T':
		case 'W':
			printmsg(0, "SetModem: switch -%s obsoleted and ignored, remove it from '%s'", cp, DIALERS);
			break;
		default:
			printmsg(0, "SetModem: unknown -%s in '%s', chat script aborted", cp, DIALERS);
			return FALSE;
		}
	}
TSE:
	/* Clean up first entries only */
	for (i = 0; i < MDM_NKIND; i++) {
		if (commd[i][0].mdsend != NULL) {
			free(commd[i][0].mdsend);
			commd[i][0].mdsend = NULL;
		}
		if (commd[i][0].mdexp != NULL) {
			free(commd[i][0].mdexp);
			commd[i][0].mdexp = NULL;
		}
	}
	t = DEF_TIMEOUT;
	kind = MDM_INIT;
	while ((cp = *pp++) != NULL) {
		if ( *cp == '-' ) {
			switch (cp[1]) {
			default:
				if ( cp[1] >= '0' && cp[1] <= '9' ) {
					t = atoi(cp+1);
					if ( t < 1 ) t = 15;
				}
				else if (cp[1] || !old_format) {
					printmsg(0, "SetModem: unknown switch %s in '%s'", cp, DIALERS);
					return FALSE;
				}
				break;
			case 'A':
				if (old_format || i_mdi == 0 || commd[MDM_INIT][0].mdsend == NULL) {
init_err:
					printmsg(0, "SetModem: no initialization section -I in '%s'", DIALERS);
					return FALSE;
				}
				i_mdi = 0;
				kind = MDM_ANSWER;
				break;
			case 'R':
				if (old_format || i_mdi == 0 || commd[MDM_INIT][0].mdsend == NULL)
					goto init_err;
				i_mdi = 0;
				kind = MDM_RING;
				break;
			case 'D':
				if (old_format || i_mdi == 0 || commd[MDM_INIT][0].mdsend == NULL)
					goto init_err;
				kind = MDM_DIAL;
				/* Copy initialization seq */
				for (i = 0; i < MAXCMDI && commd[MDM_INIT][i].mdsend != NULL; i++) {
					if (commd[MDM_DIAL][i].mdsend != NULL)
						free(commd[MDM_DIAL][i].mdsend);
					commd[MDM_DIAL][i].mdsend = strdup(commd[MDM_INIT][i].mdsend);
					if (commd[MDM_DIAL][i].mdexp != NULL)
						free(commd[MDM_DIAL][i].mdexp);
					commd[MDM_DIAL][i].mdexp =
						(commd[MDM_INIT][i].mdexp?strdup(commd[MDM_INIT][i].mdexp):NULL);
					commd[kind][i].mdtime = commd[MDM_INIT][i].mdtime;
				}
				i_mdi = i;
				break;
			case 'I':
				if (old_format || i_mdi == 0)
					goto init_err;
				i_mdi = 0;
				kind = MDM_INIT;
				break;
			}
			/* Skip to next field */
			continue;
		}
		/* Get exp field */
		if ((cp1 = *pp) != NULL && *cp1 == '-') /* If switch, get it back */
			cp1 = NULL;
		if (i_mdi >= 0) {
			if ( t == DEF_TIMEOUT && !cp1 ) t = 60;
			if (commd[kind][i_mdi].mdsend != NULL)
				free(commd[kind][i_mdi].mdsend);
			commd[kind][i_mdi].mdsend = strdup(cp);
			if (commd[kind][i_mdi].mdexp != NULL)
				free(commd[kind][i_mdi].mdexp);
			commd[kind][i_mdi].mdexp  = (cp1 ? strdup(cp1) : cp1);
			commd[kind][i_mdi].mdtime = t;
			if ( ++i_mdi > MAXCMDI )
			{
				printmsg(0,"SetModem: too many init strings for modem %s in '%s'", nm, DIALERS);
				return FALSE;
			}
			/* Clear last entry */
			if (commd[kind][i_mdi].mdsend != NULL)
				free(commd[kind][i_mdi].mdsend);
			commd[kind][i_mdi].mdsend = NULL;
			if (commd[kind][i_mdi].mdexp != NULL)
				free(commd[kind][i_mdi].mdexp);
			commd[kind][i_mdi].mdexp = NULL;
		}
		if (*pp == NULL)
			break;
		if (cp1 != NULL)
			pp++;
	}
	if (i_mdi <= 0)
		goto init_err;
	driver = commdm;
	return TRUE;
}

/*--------------------------------------------------------------------*/
/*    s h u t d o w n                                                 */
/*                                                                    */
/*    Terminate modem processing via hangup                           */
/*--------------------------------------------------------------------*/

void shutdown( void )
{
   static boolean recurse = FALSE;

   if (!port_active)
		return;
   if ( !recurse )
   {
	  recurse = TRUE;
	  hangup();
	  recurse = FALSE;
   }
   closeline();
}
