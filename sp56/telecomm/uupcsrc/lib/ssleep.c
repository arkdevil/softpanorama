/*--------------------------------------------------------------------*/
/*    s s l e e p . c                                                 */
/*                                                                    */
/*    Smart sleep routines for UUPC/extended                          */
/*                                                                    */
/*    Written by Dave Watts, modified by Drew Derbyshire              */
/*                                                                    */
/*    Generates DOS specific code with Windows support by default,    */
/*--------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <dos.h>
#include <conio.h>
#include <signal.h>
#include <setjmp.h>
#include <bios.h>
#include <io.h>

#include "lib.h"
#include "ssleep.h"
#include "screen.h"
#include "arpadate.h"
#include "hlib.h"
#if 0
#include "mnp.h"
#endif

#include <sys/timeb.h>
#define MULTIPLEX 0x2F

currentfile();

extern boolean port_active;
boolean force_redirect = FALSE;

/*--------------------------------------------------------------------*/
/*              Use this first to see if the rest are OK              */
/*                                                                    */
/*                  MOV AX,1600h   ; Check for win386/win3.0          */
/*                                   present                          */
/*                  INT 2Fh                                           */
/* Return AL = 0 -> No Windows, AL = 80 -> No WIn386 mode             */
/*        AL = 1 or AL = FFh -> Win386 2.xx running                   */
/*   else AL = Major version (3), AH = Minor version                  */
/*--------------------------------------------------------------------*/
/* --------------- Release time slice                                 */
/*                  MOV AX,1680h   ; **** Release time slice          */
/*                  INT 2Fh        ; Let someone else run             */
/* Return code is AL = 80H -> service not installed, AL = 0 -> all    */
/*                                                              OK    */
/*--------------------------------------------------------------------*/
/* --------------- Enter critical section (disable task switch)       */
/*                  MOV AX,1681H   ; Don't tread on me!               */
/*                  INT 2Fh                                           */
/*--------------------------------------------------------------------*/
/* --------------- End critical section (Permit task switching)       */
/*                  MOV AX,1682h                                      */
/*                  INT 2Fh                                           */
/*--------------------------------------------------------------------*/

/*--------------------------------------------------------------------*/
/*    R u n n i n g U n d e r W i n d o w s W i t h 3 8 6             */
/*                                                                    */
/*    Easily the longest function name in UUPC/extended.              */
/*                                                                    */
/*    Determines if we are running under MS-Windows 386 or            */
/*    MS-Windows 3.  We save the result, to avoid excessively         */
/*    disabling interrupts when in a spin loop.                       */
/*--------------------------------------------------------------------*/

static boolean	RunningUnderWindowsWith386(void)
{
   static int result = 2;
   union REGS inregs, outregs;

   if (result != 2)           /* First call?                         */
      return result;          /* No --> Return saved result          */

   inregs.x.ax = 0x1600;
   int86(MULTIPLEX, &inregs, &outregs);
   result = ((outregs.h.al & 0x7f) != 0);
   return result;
} /* RunningUnderWindowsWith386 */

/*--------------------------------------------------------------------*/
/*    G i v e U p T i m e S l i c e                                   */
/*                                                                    */
/*    Surrender our time slice when executing under Windows/386       */
/*    or Windows release 3.                                           */
/*--------------------------------------------------------------------*/

static void GiveUpTimeSlice(void)
{
   union REGS inregs, outregs;

   if (RunningUnderWindowsWith386()) {
		inregs.x.ax = 0x1680;
		int86(MULTIPLEX, &inregs, &outregs);
		if (outregs.h.al != 0) {
			printmsg(0, "GiveUpTimeSlice: problem giving up timeslice:  %u", outregs.h.al);
			panic();
		}
   }
   else
		int86(0x28, &inregs, &outregs); /* Dos time slice */

} /* GiveUpTimeSlice */


/*--------------------------------------------------------------------*/
/*    ssleep() - wait n seconds					      */
/*                                                                    */
/*    Simply delay until n seconds have passed.                       */
/*--------------------------------------------------------------------*/

boolean ssleep(time_t interval)
{
   time_t start;
   boolean done = FALSE;

   time(&start);
   while (time((time_t *)NULL) - start < interval) {
	  done = TRUE;
	  if (ddelay(1000))
		  return TRUE;
   }
   if (!done)
	  if (ddelay(0))
		return TRUE;
   return FALSE;
} /*ssleep*/

boolean
keyb_control(void)
{
	int val;
	char *ad;
	boolean stdin_redirect = force_redirect || !isatty(fileno(stdin));

	extern boolean logecho, Makelog, remote_debug;
	extern FILE *log_stream, *logfile;
	extern char LINELOG[];
	extern int logmode;

	if (stdin_redirect ? (bioskey(1) > 0) : kbhit()) {
		if (stdin_redirect) {
			(void) bioskey(0);
			return TRUE;
		}
		else {
			switch (val = getch()) {
			case 'd':
				printmsg(-1, "keyb_control: enter new debug level (echo to file, if < 0): ");
				cscanf("%d", &val);
				if (val < 0) {
					logecho = TRUE;
					val = -val;
				}
				debuglevel = val;
				if (debuglevel > 0 && logecho && logfile == stdout) {
					if ((logfile = FOPEN(LOGFILE, "a", TEXT)) == nil(FILE)) {
						logfile = stdout;
						printerr("keyb_control", LOGFILE);
					}
					else
						printmsg(1, "keyb_control: open %s at %s", LOGFILE, arpadate());
				}
				printmsg(1, "keyb_control: new debug level set to %d", debuglevel);
				if (logfile != stdout && (!debuglevel || !logecho)) {
					fclose(logfile);
					logfile = stdout;
				}
				return FALSE;
			case 't':
				if (!port_active)
					return FALSE;
				printmsg(-1, "keyb_control: enter 'y' to log port data or 'n': ");
				Makelog = (getche() == 'y');
				ad = arpadate();
				if (Makelog && log_stream == NULL) {
					if ((log_stream = FOPEN(LINELOG, "a", BINARY)) == NULL)
						printerr("keyb_control", LINELOG);
					else {
						logmode = 0;
						printmsg(15, "logging serial line data to %s at %s", LINELOG, ad);
						fprintf(log_stream, "\r\n<<< Open %s at %s >>\r\n", LINELOG, ad);
					}
				}
				if (!Makelog && log_stream != NULL) {
					fclose(log_stream);
					log_stream = NULL;
					printmsg(15, "finish logging serial line data to %s at %s", LINELOG, ad);
				}
				return FALSE;
			case 'e':
			case 'l':
			case 'p':
			case 'h':
			case 's':
				if (remote_debug)
					ungetch(val);
				break;
			case '\0':
				(void) getch();
				break;
#ifdef	__TURBOC__
			case '\3':
				raise(SIGINT);
#endif
			case '\33':
				return TRUE;
		   }
		}
	}

	GiveUpTimeSlice();

	return FALSE;
}

boolean
WaitEvent(int milliseconds, boolean (*code)(void))
{
   struct timeb t;
   time_t seconds;
#if 0
   extern unsigned fs_ms_per_tic;
#endif
   unsigned last;

/*--------------------------------------------------------------------*/
/*       Handle the special case of 0 delay, which is simply a        */
/*                  request to give up our timeslice                  */
/*--------------------------------------------------------------------*/
   if (milliseconds < 0)
		return TRUE;

   if (milliseconds == 0)     /* Make it compatible with DosSleep    */
   {
	  if ((*code)())
		return FALSE;

	  return keyb_control();
   } /* if */

   ftime(&t);                 /* Get a starting time                 */
   last = t.millitm;          /* Save milliseconds portion           */
   seconds = t.time;          /* Save seconds as well                */

   while( milliseconds > 0)   /* Begin the spin loop                 */
   {
	  if ((*code)())
		return FALSE;

	  if (keyb_control())
		return TRUE;

#if 0
	  if (mx5_present() && milliseconds >= fs_ms_per_tic)
		wait_tics(1);
#endif
	  ftime(&t);              /* Take a new time check               */
	  if (t.time == seconds)  /* Same second as last pass?           */
		 milliseconds -= t.millitm - last; /* Yes --> mSecond delta*/
	  else
		 milliseconds -= 1000 * (t.time - seconds)
				  + t.millitm - last;
							  /* No --> Handle wrap of mSeconds      */
	  last = t.millitm;       /* Update last tick indicator          */
	  seconds = t.time;       /* Update this as well; only needed if
								 it changed (see above), but it
								 kills time (which is our job)       */
   } /* while */

   return FALSE;

} /* ddelay */


boolean
false(void) {return FALSE;}

extern w_flush(void);

/*--------------------------------------------------------------------*/
/*    d e l a y 						      */
/*                                                                    */
/*    Delay for an interval of milliseconds                           */
/*--------------------------------------------------------------------*/
boolean
ddelay(int milliseconds)
{
	if (port_active && w_flush() < 0)
		return TRUE;
	return WaitEvent(milliseconds, false);
}
