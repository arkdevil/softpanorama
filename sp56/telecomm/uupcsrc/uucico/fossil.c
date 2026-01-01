#include <stdio.h>
#include <time.h>
#include <io.h>
#include <fcntl.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <dos.h>

#include "lib.h"
#include "hlib.h"
#include "ulib.h"
#include "fossil.h"
#include "comm.h"
#include "mnp.h"
#include "ssleep.h"
#include "ulib.h"
#include "pushpop.h"

extern void Sinfo(char *s);
void setflow(boolean);

static unsigned fs_maxfn = 0,
		fs_revis, fs_direct;

static boolean buggy_avail = FALSE;

unsigned fs_port, fs_baud;
unsigned char fs_tim_int;
unsigned char fs_tics_per_sec;
unsigned fs_ms_per_tic;
boolean need_carrier = FALSE;
static time_t waittime = 0;
boolean NoCheckCarrier = FALSE;
static boolean fs_install_timer = FALSE;
static boolean new_fossil_type;
volatile static unsigned fs_tics;
int fs_isize, fs_osize;
int fs_status;
boolean use_old_status = FALSE;
extern boolean fossil;
extern int MnpEmulation;
extern char *calldir;
void fossil_exit(void);

void
select_port(int port)
{
	fs_port = port - 1;
	_select_port(port);
	save_com();
}


int
status(void)
{
	union REGS inregs, outregs;

	if (use_old_status)
		return fs_status;
	inregs.h.ah = FS_GET_STATUS;
	inregs.x.dx = fs_port;
	return (fs_status = int86(FOSSIL, &inregs, &outregs));
}

boolean
carrier(boolean test)
{
	boolean CD;

	if (!test && !need_carrier)
		return TRUE;

	if (!fossil)
		CD = _carrier();
	else
		CD = !!(status() & FS_DCD);

	if (test)
		return CD;

	if (!CD) {
		if (waittime == 0)
			time(&waittime);
		else if (time((long)NULL) > waittime + 1) /* Wait 1 sec */
			return FALSE;
	}
	else
		waittime = 0;

	return TRUE;
}


int
transmit_char(char c)
{
	union REGS inregs, outregs;

	inregs.h.ah = FS_TRANSMIT_CHAR;
	inregs.h.al = c;
	inregs.x.dx = fs_port;
	return (fs_status = int86(FOSSIL, &inregs, &outregs));
}

int
receive_char(void)
{
	union REGS inregs, outregs;

	inregs.h.ah = FS_RECEIVE_CHAR;
	inregs.x.dx = fs_port;
	return int86(FOSSIL, &inregs, &outregs);
}

int
peek_ahead(void)
{
	union REGS inregs, outregs;

	inregs.h.ah = FS_PEEK_AHEAD;
	inregs.x.dx = fs_port;
	return int86(FOSSIL, &inregs, &outregs);
}


boolean
set_connected(boolean need)
{
	int l;

	if (!need)
		need_carrier = FALSE;

	if (!fossil)
		_set_connected(need);

	if (!need)
		return TRUE;

	if (!fs_direct) {
		ssleep(1);
		if (!NoCheckCarrier) {
			need_carrier = TRUE;
			waittime = 0;
			if (!carrier(FALSE))
				return FALSE;
		}
		if (!fossil)
			return TRUE;
		if (mx5_present() && (l = get_mnp_level()) > 0) {
			l = mnp_active() ? mnp_level() : 0;
			if (l)
				printmsg(-1, "set_connected: got MNP%d level", l);
			else
				printmsg(0, "set_connected: can't connect with MNP");
		}
	}
	else
		printmsg(4, "set_connected: LINK at %u baud (port)", fs_baud);
	return TRUE;
}

#if 0
void
timer_params(void)
{
	union REGS inregs, outregs;

	inregs.h.ah = FS_TIMER_PARAMS;
	int86(FOSSIL, &inregs, &outregs);
	fs_tim_int = outregs.h.al;
	fs_tics_per_sec = outregs.h.ah;
	fs_ms_per_tic = outregs.x.dx;
	printmsg(19, "timer_params: int %d, tics/sec %u, ms/tic %u",
		fs_tim_int, fs_tics_per_sec, fs_ms_per_tic);
}

int
timer_function(void (interrupt *ff)(void), int ins)
{
	union REGS inregs, outregs;
	struct SREGS segregs;

	inregs.h.ah = FS_TIMER_FUNC;
	inregs.h.al = !!ins;
	segregs.es = FP_SEG(ff);
	inregs.x.dx = FP_OFF(ff);
	return int86x(FOSSIL, &inregs, &outregs, &segregs);
}

static
void
interrupt
tick_count(void)
{
	fs_tics--;
}
#endif

void
fossil_delay(unsigned tics)
{
	if (tics == 0)
		return;

	if (mx5_present()) {
		wait_tics(tics);
		return;
	}

	if (!fs_install_timer) {
		(void) ddelay(tics * fs_ms_per_tic);
		return;
	}

	fs_tics = tics;
	while (fs_tics > 0)
		;
}


static
struct fs_info *
get_info(void)
{
	union REGS inregs, outregs;
	struct SREGS segregs;
	static struct fs_info info;

	inregs.h.ah = FS_GET_INFO;
	inregs.x.dx = fs_port;
	segregs.es = FP_SEG(&info);
	inregs.x.di = FP_OFF(&info);
	inregs.x.cx = sizeof(info) - 3;  /* Hack HERE!!! last 3 not needed */
	int86x(FOSSIL, &inregs, &outregs, &segregs);

	return &info;
}


static
boolean
fossil_present(void)
{
	union REGS inregs, outregs;
	struct fs_info *info;
	char buf[256];
	static int done = -1;
	char *s;

	if (done != -1)
		return done;

	done = FALSE;

	new_fossil_type = TRUE;
	inregs.h.ah = FS_INIT_DRIVER;
	inregs.x.dx = fs_port;
	inregs.x.bx = 0;
	outregs.x.ax = 0;	/* Make shure */
	int86(FOSSIL, &inregs, &outregs);

	if (outregs.x.ax != FS_SIGNATURE) {
		new_fossil_type = FALSE;
		inregs.h.ah = FS_OLD_INIT_DRIVER;
		int86(FOSSIL, &inregs, &outregs);
		if (outregs.x.ax != FS_SIGNATURE) {
			sprintf(buf, "Can't connect to FOSSIL, use internal driver (COM%d)", fs_port + 1);
			Sinfo(buf);
			printmsg(1, "fossil_present: %s", buf);
			return done;
		}
	}

	fs_maxfn = outregs.h.bl;
	fs_revis = outregs.h.bh;
	if (fs_maxfn < FS_MAXFN) {
		printmsg(0, "fossil_present: Maximum Function=%X too small", fs_maxfn);
		return done;
	}

	if (mx5_present())
		set_mnp_level(0);
	else {
/*******************
	   if (timer_function(tick_count, TRUE) != 0)
		   printmsg(0, "fossil_present: can't install tick_count");
	   else
		   fs_install_timer = TRUE;
*******************/
	}

	info = get_info();
	fs_isize = info->ibufr;
	fs_osize = info->obufr;
	if (info->oavail == 0) {
		buggy_avail = TRUE;
		printmsg(-1, "fossil_present: Your FOSSIL has status bug: avail size == 0 [CORRECTED]");
	}
	else
		fs_osize = info->oavail;
	atexit(fossil_exit);

	sprintf(buf, "FOSSILv%u, MaxFn %Xh, v%u.%u, %.80Fs",
				 fs_revis, fs_maxfn, info->majver, info->minver, info->ident);
	buf[80] = '\0';
	if ((s = strchr(buf, '\n')) != NULL)
		*s = '\0';
	printmsg(2, "fossil_present: %s", buf);
	Sinfo(buf);

	printmsg(2, "fossil_present: input buffer: %d chars, output buffer: %d chars",
				fs_isize, fs_osize);
#if 0
	timer_params();
#endif
	done = TRUE;

	return done;
}

void
fossil_exit(void)
{
#if 0
	if (fs_install_timer) {
		fs_install_timer = FALSE;
		if (timer_function(tick_count, FALSE) != 0)
			printmsg(0, "fossil_exit: can't delete tick_count");
	}
#endif
}

boolean
install_com(void)
{
   fossil = fossil_present();
   if (fossil)
		return fossil;
   if (!_install_com())
		return FALSE;
   fs_isize = r_count_size();
   fs_osize = s_count_size();
   return TRUE;
}

void
open_com(unsigned short baud, char modem, char parity, int stopbits, char xon)
{
	union REGS inregs, outregs;
	unsigned mask;
	boolean x;

	printmsg(15, "open_com(%u, '%c', '%c', %d, '%c') called",
		 baud, modem, parity, stopbits, xon);

	fs_direct = (modem != 'M');
	fs_baud = baud;
	need_carrier = FALSE;

	if (!fossil) {
		_open_com(baud, modem, parity, stopbits, xon);
		goto ret;
	}

	inregs.h.ah = new_fossil_type ? FS_INIT_DRIVER : FS_OLD_INIT_DRIVER;
	inregs.x.dx = fs_port;
	inregs.x.bx = 0;
	int86(FOSSIL, &inregs, &outregs);

	if (mx5_present())
		set_mnp_level(0);

	mask = 0;

	switch (baud) {
	case 38400U:
		mask |= FS_38400;
		break;
	case 19200U:
		mask |= FS_19200;
		break;
	case 9600U:
		mask |= FS_9600;
		break;
	case 4800U:
		mask |= FS_4800;
		break;
	default:
		baud = 2400;
	case 2400U:
		mask |= FS_2400;
		break;
	case 1200U:
		mask |= FS_1200;
		break;
	case 600U:
		mask |= FS_600;
		break;
	case 300U:
		mask |= FS_300;
		break;
	}

	switch(parity) {
	default:
	case 'N':
		mask |= FS_NOPAR;
		break;
	case 'O':
		mask |= FS_ODD;
		break;
	case 'E':
		mask |= FS_EVEN;
		break;
	}

	switch (stopbits) {
	default:
	case 1:
		mask |= FS_ONESTOP;
		break;
	case 2:
		mask |= FS_TWOSTOP;
		break;
	}

	mask |= FS_CHAR8;

	inregs.h.ah = FS_SET_BAUD;
	inregs.h.al = mask;
	inregs.x.dx = fs_port;
	int86(FOSSIL, &inregs, &outregs);

	switch (xon) {
	default:
	case 'D':
		x = FALSE;
		break;
	case 'E':
		x = TRUE;
		break;
	}

	setflow(x);

	inregs.h.ah = FS_CHK_TRANSMIT;
	inregs.h.al = 0;
	inregs.x.dx = fs_port;
	int86(FOSSIL, &inregs, &outregs);

ret:
	ddelay(500);
}

void
close_com(void)
{
	union REGS inregs, outregs;

	need_carrier = FALSE;

	if (!fossil) {
		_close_com();
		goto ret;
	}
	if (mx5_present())
		set_mnp_level(0);

	inregs.h.ah = new_fossil_type ? FS_DEINIT_DRIVER : FS_OLD_DEINIT_DRIVER;
	inregs.x.dx = fs_port;
	int86(FOSSIL, &inregs, &outregs);

ret:
	ddelay(500);
}


void
dtr_on()
{
	union REGS inregs, outregs;

	need_carrier = FALSE;

	if (!fossil)
		_dtr_on();
	{
		w_purge();

		if (mx5_present())
			set_mnp_level(0);

		inregs.h.ah = FS_DTR_CHANGE;
		inregs.h.al = FS_RAISE_DTR;
		inregs.x.dx = fs_port;
		int86(FOSSIL, &inregs, &outregs);
	}

	ssleep(2);
}

void
dtr_off()
{
	union REGS inregs, outregs;

	need_carrier = FALSE;

	if (!fossil)
		_dtr_off();
	{
		w_purge();

		if (mx5_present())
			set_mnp_level(0);

		inregs.h.ah = FS_DTR_CHANGE;
		inregs.h.al = FS_LOWER_DTR;
		inregs.x.dx = fs_port;
		int86(FOSSIL, &inregs, &outregs);
	}

	ddelay(500);
}

void
break_com(int length)
{
	union REGS inregs, outregs;

	if (!fossil) {
		_break_com();
		return;
	}

	inregs.h.ah = FS_SEND_BREAK;
	inregs.h.al = FS_START_BREAK;
	inregs.x.dx = fs_port;
	int86(FOSSIL, &inregs, &outregs);

	ddelay(length);

	inregs.h.ah = FS_SEND_BREAK;
	inregs.h.al = FS_STOP_BREAK;
	inregs.x.dx = fs_port;
	int86(FOSSIL, &inregs, &outregs);
}

void
r_purge(void)
{
	union REGS inregs, outregs;

	inregs.h.ah = FS_PURGE_INPUT;
	inregs.x.dx = fs_port;
	int86(FOSSIL, &inregs, &outregs);
}

void
w_purge(void)
{
	union REGS inregs, outregs;

	inregs.h.ah = FS_PURGE_OUTPUT;
	inregs.x.dx = fs_port;
	int86(FOSSIL, &inregs, &outregs);
}


int
not_empty_out(void)
{
	int s = status();
	int c;

	if (need_carrier) {
		use_old_status = TRUE;
		c = carrier(FALSE);
		use_old_status = FALSE;
		if (!c)
			return -1;
	}
	if (s & FS_TSRE)
		return 0;
	return 1;
}


int
s_count_pending(void)
{
	int r;

	if (!fossil) {
		if (!carrier(FALSE))
			r = -1;
		else
			r = fs_osize - s_count_free();
	}
	else {
		r = not_empty_out();
		if (r > 0) {
			if (buggy_avail)
				r = get_info()->oavail;
			else
				r = fs_osize - get_info()->oavail;
		}
	}
	return r;
}

extern boolean false(void);

int
w_flush(void)
{
	int i;
	time_t limit;

	i = s_count_pending();
	if (i < 0)
		return i;
	if (i == 0)
		return fs_osize;
	limit = time(NULL) + (unsigned)i / fs_baud + 1;
	for (;;) {
		i = fossil ? not_empty_out() : s_count_pending();
		if (i < 0)
			return i;
		if (i == 0)
			return fs_osize;
		if (time(NULL) > limit || WaitEvent(0, false))
			return 0;
	}
}


int
r_count_pending(void)
{
	int s, r, c;

	if (!fossil) {
		if (!carrier(FALSE))
			r = -1;
		else
			r = _r_count_pending();
	}
	else {
		s = status();
		if (need_carrier) {
			use_old_status = TRUE;
			c = carrier(FALSE);
			use_old_status = FALSE;
			if (!c)
				r = -1;
			else
				goto Next;
		}
		else
	Next:
		if (s & FS_OVRN)
			printmsg(0, "r_count_pending: internal FOSSIL input buffer (%d bytes) overrun, increase it!", fs_isize);
		if (!(s & FS_RDA))
			r = 0;
		else if (buggy_avail)
			r = get_info()->iavail;
		else
			r = fs_isize - get_info()->iavail;
	}

	return r;
}

int
r_1_pending(void)
{
	int s, c;

	if (!fossil) {
		if (!carrier(FALSE))
			return -1;
		return _r_count_pending() != 0;
	}
	s = status();
	if (need_carrier) {
		use_old_status = TRUE;
		c = carrier(FALSE);
		use_old_status = FALSE;
		if (!c)
			return -1;
	}
	if (s & FS_OVRN)
		printmsg(0, "r_1_pending: internal FOSSIL input buffer (%d bytes) overrun, increase it!", fs_isize);
	return !!(s & FS_RDA);
}


int
s_count_free(void)
{
	int s, r, c;

	if (!fossil) {
		if (!carrier(FALSE))
			r = -1;
		else
			r = _s_count_free();
	}
	else {
		s = status();
		if (need_carrier) {
			use_old_status = TRUE;
			c = carrier(FALSE);
			use_old_status = FALSE;
			if (!c)
				r = -1;
			else
				goto Next;
		}
		else
	Next:
		if (s & FS_TSRE)
			r = fs_osize;
		else if (buggy_avail)
			r = fs_osize - get_info()->oavail;
		else
			r = get_info()->oavail;
	}

	return r;
}

int
s_1_free(void)
{
	int s, c;

	if (!fossil) {
		if (!carrier(FALSE))
			return -1;
		return _s_count_free() != 0;
	}

	s = status();
	if (need_carrier) {
		use_old_status = TRUE;
		c = carrier(FALSE);
		use_old_status = FALSE;
		if (!c)
			return -1;
	}
	return !!(s & FS_THRE);
}


unsigned
read_block(unsigned wanted, char *buf)
{
	union REGS inregs, outregs;
	struct SREGS segregs;

	inregs.h.ah = FS_READ_BLOCK;
	inregs.x.dx = fs_port;
	inregs.x.cx = wanted;
	segregs.es = FP_SEG(buf);
	inregs.x.di = FP_OFF(buf);
    return int86x(FOSSIL, &inregs, &outregs, &segregs);
}

unsigned
write_block(unsigned wanted, char *buf)
{
	union REGS inregs, outregs;
	struct SREGS segregs;

	inregs.h.ah = FS_WRITE_BLOCK;
	inregs.x.dx = fs_port;
	inregs.x.cx = wanted;
	segregs.es = FP_SEG(buf);
	inregs.x.di = FP_OFF(buf);
	return int86x(FOSSIL, &inregs, &outregs, &segregs);
}

void
setflow(boolean xon)
{
	union REGS inregs, outregs;
	unsigned mask;

	w_purge();

	if (xon)
		mask = FS_RECEIVE_XON|FS_TRANSMIT_XON;
	else
		mask = FS_CTS_RTS;

	inregs.h.ah = FS_FLOW_CONTROL;
	inregs.h.al = mask | 0xF0;
	inregs.x.dx = fs_port;
	int86(FOSSIL, &inregs, &outregs);
}