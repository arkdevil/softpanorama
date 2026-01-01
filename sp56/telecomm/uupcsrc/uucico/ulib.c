/*
   For best results in visual layout while viewing this file, set
   tab stops to every 4 columns.
*/

/*
   ibmpc/ulib.c

   DCP system-dependent library

   Services provided by ulib.c:

   - login
   - UNIX commands simulation
   - serial I/O
   - rnews

   Updated:

      14May89  - Added hangup() procedure                               ahd
	  21Jan90  - Replaced code for rnews() from Wolfgang Tremmel
				 <tremmel@garf.ira.uka.de> to correct failure to
                 properly read compressed news.                         ahd
   6  Sep 90   - Change logging of line data to printable               ahd
	  8 Sep 90 - Split ulib.c into dcplib.c and ulib.c                  ahd
*/

#include <assert.h>
#include <dos.h>
#include <fcntl.h>
#include <io.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <process.h>
#include <errno.h>

#ifdef __TURBOC__
#include <dir.h>
#else
#include <direct.h>
#endif

#include "lib.h"
#include "hostable.h"
#include "dcp.h"
#include "dcpsys.h"
#include "dcplib.h"
#include "hlib.h"
#include "ulib.h"
#include "comm.h"
#include "fossil.h"
#include "ssleep.h"
#include "pushpop.h"
#include "arpadate.h"
#include "screen.h"

boolean   port_active = FALSE;  /* TRUE = port handler handler active  */
boolean fossil = FALSE;
extern fs_isize;
extern boolean use_old_status;

/* IBM-PC I/O routines */

/* "DCP" a uucp clone. Copyright Richard H. Lamb 1985,1986,1987 */

/*************** BASIC I/O ***************************/
/* Saltzers serial package (aka Info-IBMPC COM_PKG2):
 * Some notes:  When packets are flying in both directions, there seems to
 * be some interrupt handling problems as far as receiving.  Checksum errors
 * may therefore occur often even though we recover from them.  This is
 * especially true with sliding windows.  Errors are very few in the VMS
 * version.  RH Lamb
 */


#define  STOPBIT  1
char LINELOG[] = "LineData.Log";      /* log serial line data here */

extern boolean Direct, Makelog;
int logmode = 0;             /* Not yet logging            */
#define WRITING 1
#define READING 2
FILE *log_stream = NULL;
extern void setflow(boolean);

/*
   openline - open the serial port for I/O
*/

int openline(char *name, unsigned short baud)
{
   int   value;

   if (port_active)              /* Was the port already active?     ahd   */
	  closeline();               /* Yes --> Shutdown it before open  ahd   */
   assert(!port_active);         /* Don't open the port if active!   ahd   */

   sscanf(name, "COM%d", &value);
   if (value < 1 || value > 4)
		return -1;
   select_port(value);
   if (!install_com())
		return -1;

	open_com(baud, (char)(Direct?'D':'M'), 'N', STOPBIT, 'D');

	if (log_stream == NULL && Makelog) {
		if ((log_stream = FOPEN(LINELOG, "a", BINARY)) != NULL)
			printmsg(15, "logging serial line data to %s", LINELOG);
		else
			printerr ("openline", LINELOG);
	}

	dtr_on();

	if (log_stream != NULL)
		fprintf(log_stream, "\r\n<<< Open line %s, %u baud, at %s >>\r\n", name, baud, arpadate());

	port_active = TRUE;     /* record status for error handler */

	return 0;
} /*openline*/

void reopen_com(boolean flow)
{
	close_com();
	open_com(fs_baud, (char)(Direct?'D':'M'), 'N', STOPBIT, flow ? 'E' : 'D');
}

/*
   sread - read from the serial port
*/

/* Non-blocking read essential to "g" protocol.
   See "dcpgpkt.c" for description.
   This all changes in a multi-tasking system.  Requests for
   I/O should get queued and an event flag given.  Then the
   requesting process (e.g. gmachine()) waits for the event
   flag to fire processing either a read or a write.
   Could be implemented on VAX/VMS or DG but not MS-DOS. */

int sread(register char *buffer, int wanted, int timeout)
{
   time_t   start, elapsed;
   static time_t lastout = 0;
   int	i, r_pending, c;
   int oldpending;

	if (log_stream != NULL && logmode != READING) {
		fputs("\r\nRead:", log_stream);
		logmode = READING;
	}

	oldpending = -1;
	(void) time(&start);
#if 0
	if (start - lastout == 0)
		if (ddelay(100))
			goto tout;
#endif

	for ( ; ; ) {
		r_pending = (wanted > 1 ? r_count_pending() : r_1_pending());
		if (r_pending < 0) {
Lost:
			if (log_stream != NULL)
				fputs("<<LOST CARRIER>>\r\n", log_stream);
			return S_LOST;
		}

		if (oldpending != r_pending) {
			printmsg(20, "sread: pending=%d, wanted=%d, timeout=%d",
						  r_pending, wanted, timeout);
			oldpending = r_pending;
		}

		if (r_pending >= wanted) {
			if (fossil) {
				if (read_block(wanted, buffer) < wanted)
						goto Lost;
			}
			else {
				for (i = 0; i < wanted; i++) {
					if ((c = receive_com()) < 0)
							goto Lost;
					buffer[i] = c;
				}
			}
			if (log_stream != NULL) {
				for (i = 0; i < wanted; i++)
					putc(buffer[i], log_stream);
			}
			lastout = 0;

			return r_pending;
		}
		else {
			if (timeout <= 0)
				goto tout;

			elapsed = time(nil(time_t)) - start;
			if (elapsed > timeout) {
	tout:
				if (!carrier(FALSE))
					goto Lost;
#if 0
				(void) time(&lastout);
#endif
				if (log_stream != NULL)
					fputs("<<TIMEOUT>>\r\n", log_stream);
				return S_TIMEOUT;
			}
			if (ddelay(100))
				goto tout;
		}
	}
} /*sread*/


/*
   swrite - write to the serial port
*/

int swrite(char *data, int len)
{
	int j, s_free, s;

	if (len < 0)
		return len;

	if (log_stream != NULL && logmode != WRITING) {
		fputs("\r\nWrite:", log_stream);
		logmode = WRITING;
	}

	printmsg(20, "swrite: len=%d", len);

	for ( ; ;) {
		s_free = (len == 1 ? s_1_free() : s_count_free());
		if (s_free < 0) {
Lost:
			if (log_stream != NULL)
				fputs("<<LOST CARRIER>>\r\n", log_stream);
			return S_LOST;
		}

		if (s_free >= len) {
			if (!fossil) {
				for (j = 0; j < len; j++)
					if (send_com(data[j]) < 0)
						goto Lost;
			}
			else {
				if (len == 1) {
					(void) transmit_char(*data);
					if (need_carrier) {
						use_old_status = TRUE;
						s = carrier(FALSE);
						use_old_status = FALSE;
						if (!s)
							goto Lost;
					}
				}
				else {
					if (write_block(len, data) < len)
						goto Lost;
				}
			}

			if (log_stream != NULL) {
				for (j = 0; j < len; j++)
					putc( data[j] , log_stream);
			}

			return len;
		}
		else {
			if (ddelay(100)) {
				if (!carrier(FALSE))
					goto Lost;
				if (log_stream != NULL)
					fputs("<<TIMEOUT>>\r\n", log_stream);
				return S_TIMEOUT;
			}
		}
	}
} /*swrite*/


/*
   ssendbrk - send a break signal out the serial port
*/

void ssendbrk(int duration)
{

   printmsg(12, "ssendbrk: %d", duration);

   break_com(duration);

} /*ssendbrk*/


/*
   closeline - close the serial port down
*/

void closeline(void)
{
   port_active = FALSE; /* flag port closed for error handler  */

   dtr_off();
   close_com();
   if (!fossil)
		restore_com();

   if (log_stream != NULL) {  /* close serial line log file */
	  fflush(log_stream);
	  real_flush(fileno(log_stream));
   }

   printmsg(3,"closeline: done.");
} /*closeline*/


/*    Hangup the telephone by dropping DTR.  Works with HAYES and many  */
/*    compatibles.  - 14 May 89 Drew Derbyshire                         */
void (*p_hangup)(void);

void hangup( void )
{
	  dtr_off();              /* Hang the phone up                         */
	  dtr_on();               /* Bring the modem back on-line              */

	  printmsg(3,"hangup: Dropped DTR");

	  if ( p_hangup )
		  (*p_hangup)();

	  r_flush();
}



/*
   S I O S p e e d

   Re-specify the speed of an opened serial port

   Dropped the DTR off/on calls because this makes a Hayes drop the
   line if configured properly, and we don't want the modem to drop
   the phone on the floor if we are performing autobaud.

   (Configured properly = standard method of making a Hayes hang up
   the telephone, especially when you can't get it into command state
   because it is at the wrong speed or whatever.)
															ahd
 */


void SIOSpeed(unsigned short baud)
{
   fs_baud = baud;
   printmsg(4, "SIOSpeed: set to %u baud", fs_baud);
   reopen_com(FALSE);
} /*SIOSpeed*/

/*--------------------------------------------------------------------*/
/*    f l o w c o n t r o l                                           */
/*                                                                    */
/*    Enable/Disable in band (XON/XOFF) flow control                  */
/*--------------------------------------------------------------------*/
void flowcontrol( boolean flow )
{
	if (fossil)
		setflow(flow);
	else
		reopen_com(flow ? 'E' : 'D');
} /*flowcontrol*/

void
r_flush(void)
{
	if (log_stream != NULL)
		fputs("<<PURGE INPUT>\r\n", log_stream);
	if (fossil)
		r_purge();
	else
		_r_flush();
}

void
close_log_stream(void)
{
	if (log_stream != NULL) {
		fclose(log_stream);
		log_stream = NULL;
	}
}

