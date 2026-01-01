/*
 * History:4,1
 * Mon May 15 19:56:44 1989 Add c_break handler                   ahd
 * 20 Sep 1989 Add check for SYSDEBUG in MS-DOS environment       ahd
 * 22 Sep 1989 Delete kermit and password environment
 *             variables (now in password file).                  ahd
 * 30 Apr 1990  Add autoedit support for sending mail              ahd
 *  2 May 1990  Allow set of booleans options via options=         ahd
 * 29 Jul 1990  Change mapping of UNIX to MS-DOS file names        ahd
 */

/*
   ibmpc/host.c

   IBM-PC host program
*/

#include <assert.h>
#include <dos.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <setjmp.h>

#include "lib.h"
#include "dcp.h"
#include "hlib.h"
#include "hostable.h"
#include "pushpop.h"
#include "getopt.h"
#include "modem.h"
#include "timestmp.h"
#include "ulib.h"
#include "screen.h"

unsigned _stklen = 0x2000;

currentfile();

int c_break( void );
extern int report(void);
int c_ign(void) { return 1; }

jmp_buf  dcpexit;
char *logintime = nil(char);  /* Length of time to wait for login */
boolean PressBreak = FALSE;
boolean Makelog = FALSE;
extern boolean remote_debug;
extern int poll_mode;
extern int screen;
extern MaxTry;


static void parse_options(int argc, char *argv[])
{
  int option;

/*--------------------------------------------------------------------*/
/*                        Process our options                         */
/*--------------------------------------------------------------------*/

   while ((option = getopt(argc, argv, "A:r:s:u:x:X:S0nL")) != EOF)
	  switch (option) {
	  case 'A':
		 MaxTry = atoi(optarg);
		 break;
	  case 'n':
		 callnow = TRUE;
		 break;
	  case 'r':
		 poll_mode = atoi(optarg);
		 break;
	  case 's':
		 Rmtname = strdup(optarg);
		 break;
	  case 'u':
		 logintime = strdup(optarg);
		 break;
	  case 'X':
		 logecho = TRUE;
		 /* FALL THRU */
	  case 'x':
		 debuglevel = atoi(optarg);
		 break;
	  case 'S':
		screen = 0;
		break;
	  case '0':
		remote_debug = TRUE;
		break;
	  case 'L':
		Makelog = TRUE;
		break;
	  default:
	  case '?':
   usage:
		 fprintf(stderr, "Usage:\tuucico [-A <attempts>] [-s <system>|all|any]\n\
\t[-r 1|0] [-x|X <debug_level>] [-u <time>] [-n] [-S] [-L]\n");
		 exit(4);
	  }

/*--------------------------------------------------------------------*/
/*                Abort if any options were left over                 */
/*--------------------------------------------------------------------*/

   if (optind != argc) {
	  fprintf(stderr, "Extra parameter(s) at end.\n");
	  goto usage;
   }
}


int main( int argc, char *argv[])
{
   int status;

   parse_options(argc, argv);

   if (debuglevel < 0) {
	debuglevel = -debuglevel;
	logecho = TRUE;
   }
/*--------------------------------------------------------------------*/
/*          Report our version number and date/time compiled          */
/*--------------------------------------------------------------------*/
   Ssaveplace(0);
   atexit(Srestoreplace);

   banner( argv );

   if (!configure())
	  panic();

/*--------------------------------------------------------------------*/
/*                        Trap control C exits                        */
/*--------------------------------------------------------------------*/

#ifdef __TURBOC__
   ctrlbrk(c_break);
   setcbrk(1);
#endif

   printmsg(5,"main: Control C handler set");

   PushDir(spooldir);
   atexit( PopDir );

/*--------------------------------------------------------------------*/
/*                   setup longjmp for error exit's                   */
/*--------------------------------------------------------------------*/

   status = 10;   /* set default in case we get out via a longjmp */
   if (setjmp(dcpexit) == 0)
	  status = dcpmain();

   shutdown();

   if (status == 0)
	  cleantmp();

   return status;
} /*main*/


/*--------------------------------------------------------------------*/
/*   c_break   -- control break handler to allow graceful shutdown    */
/*                    of interrupt handlers, etc.                     */
/*--------------------------------------------------------------------*/

int c_break( void )
{
   setcbrk(0);
   ctrlbrk(c_ign);
   PressBreak = TRUE;

   printmsg(0,"c_break: program aborted by user Ctrl-Break");

   shutdown();

   report();

   exit(100);  /* Allow program to abort              */

   return 0;
} /* c_break */
