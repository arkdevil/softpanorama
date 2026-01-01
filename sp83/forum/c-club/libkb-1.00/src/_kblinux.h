/* _kblinux.h -- Linux keyboard handler installation
 * Copyright (C) Markus F.X.J. Oberhumer, Harm Hanemaayer and others
 * For conditions of distribution and use, see copyright notice in kb.h 
 */

/* WARNING: this file should *not* be used by applications. It is
   part of the implementation of the keyboard library and is
   subject to change. Applications should only use kb.h.
 */


#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>
#include <sys/types.h>
#include <sys/ioctl.h>
#include <linux/kd.h>
#include <linux/vt.h>


/* IMPORTANT NOTE: you have to update the keyboard manually under Linux 
 *                 !!! there are NO INTERRUPTS !!! 
 *
 * see also: svgalib 1.2.x: src/keyboard/keyboard.c
 * see also: kbd 0.91: src/showkey.c
 */



/***********************************************************************
// keyboard handler 
************************************************************************/

#if defined(__i386__)
#  undef KB_LINUX_MEDIUMRAW			/* use RAW mode */
#else
#  define KB_LINUX_MEDIUMRAW
#endif

#include "_handler.h"


/***********************************************************************
// 
************************************************************************/

static int get_fd_info(int fd, int *mode, struct termios *t)
{
	int dummy_mode;
	struct termios dummy_termios;

	if (fd < 0)
		return -1;

	if (mode == NULL)
		mode = &dummy_mode;
	if (t == NULL)
		t = &dummy_termios;

	if (ioctl(fd, KDGKBMODE, mode) != 0)
	{
#if defined(KB_DEBUG)
		perror("libkb: cannot get keyboard mode");
#endif
		return -1;
	}
#if defined(KB_DEBUG) && (KB_DEBUG >= 2)
	fprintf(stderr,"libkb info: fd: %d ioctl: kbmode=%d\n", fd, *mode);
#endif

	if (tcgetattr(fd, t) != 0)
	{
#if defined(KB_DEBUG)
		perror("libkb: tcgetattr");
#endif
		return -1;
	}
#if defined(KB_DEBUG) && (KB_DEBUG >= 2)
	fprintf(stderr,"libkb info: fd: %d tcgetattr: iflag=0x%04lx "
		"oflag=0x%04lx lflag=0x%04lx %d %d\n", 
		fd, t->c_iflag, t->c_oflag, t->c_lflag, t->c_cc[VMIN], t->c_cc[VTIME]);
#endif

	return 0;
}


/***********************************************************************
// 
************************************************************************/

static int _my_kbd_fd = -1;

static int oldkbmode = K_XLATE;
static struct termios oldkbdtermios;

static int keyboard_init_return_fd(void)
{
	int r = 0;
	struct termios newkbdtermios;
	struct vt_stat vtinfo;
	int my_vt;
	long first_non_opened;


/* STEP 1a: open /dev/console */
	if (_my_kbd_fd == -1)
		_my_kbd_fd = open("/dev/console", O_RDONLY);
	if (_my_kbd_fd == -1)
	{
#if defined(KB_DEBUG)
		perror("libkb: cannot open /dev/console");
#endif
		return -1;
	}
	if (_my_kbd_fd < 0)
	{
#if defined(KB_DEBUG)
		fprintf(stderr,"libkb: fd: %d, strange\n",_my_kbd_fd);
#endif
		return -1;
	}


/* STEP 1b: get current settings */
	if (get_fd_info(_my_kbd_fd, &oldkbmode, &oldkbdtermios) != 0)
		return -1;
#if defined(KB_DEBUG) && (KB_DEBUG >= 2)
	if (oldkbmode != K_XLATE)	/* what about K_UNICODE ? */
		fprintf(stderr,"libkb info: keyboard not in K_XLATE, strange\n");
#endif


/* STEP 1c: get my VT info */
	if (ioctl(_my_kbd_fd, VT_GETSTATE, &vtinfo) != 0)
	{
#if defined(KB_DEBUG)
		perror("libkb: ioctl VT_GETSTATE");
#endif
		return -1;
	}
	else
	{
#if defined(KB_DEBUG) && (KB_DEBUG >= 2)
		fprintf(stderr,"libkb info: fd: %d vt_stat: v_active=%d "
			"v_signal=0x%x v_state=0x%x\n", _my_kbd_fd, (int) vtinfo.v_active,
			(unsigned) vtinfo.v_signal, (unsigned) vtinfo.v_state);
#endif
	}
	my_vt = vtinfo.v_active;


/* STEP 1d: get number of virtual terminals */
	if (ioctl(_my_kbd_fd, VT_OPENQRY, &first_non_opened) != 0)
	{
#if defined(KB_DEBUG)
		perror("libkb: ioctl VT_OPENQRY");
#endif
		return -1;
	}
	else
	{
#if defined(KB_DEBUG) && (KB_DEBUG >= 2)
		fprintf(stderr,"libkb info: first non opened VT: %ld\n",
			first_non_opened);
#endif
	}
	if (my_vt <= 0 || my_vt >= first_non_opened)
	{
#if defined(KB_DEBUG)
		fprintf(stderr,"libkb: VT %d, first non opened VT: %ld\n",
			my_vt, first_non_opened);
#endif
		return -1;
	}




/* STEP 2a: set new termios */
	newkbdtermios = oldkbdtermios;
#if 1
	newkbdtermios.c_iflag = 0;
#else
	newkbdtermios.c_iflag &= ~(ISTRIP | IGNCR | ICRNL | INLCR | IXOFF | IXON);
#endif
	newkbdtermios.c_lflag &= ~(ISIG | ICANON | ECHO);
	/* Making these 0 seems to have the desired effect. */
	newkbdtermios.c_cc[VMIN] = 0;
	newkbdtermios.c_cc[VTIME] = 0;

	if (tcsetattr(_my_kbd_fd, TCSANOW, &newkbdtermios) != 0)
	{
		r = -2;
#if defined(KB_DEBUG)
		perror("libkb: tcsetattr");
#endif
	}


/* STEP 2b: set new kbmode */
#if defined(KB_LINUX_MEDIUMRAW)
	if (ioctl(_my_kbd_fd, KDSKBMODE, K_MEDIUMRAW) != 0)
	{
		r = -2;
#if defined(KB_DEBUG)
		perror("libkb: ioctl KDSKBMODE K_MEDIUMRAW");
#endif
	}
#else
	if (ioctl(_my_kbd_fd, KDSKBMODE, K_RAW) != 0)
	{
		r = -2;
#if defined(KB_DEBUG)
		perror("libkb: ioctl KDSKBMODE K_RAW");
#endif
	}
#endif


/* all done */
	if (r < 0)
		return r;
#if defined(KB_DEBUG) && (KB_DEBUG >= 2)
	get_fd_info(_my_kbd_fd, NULL, NULL);	/* print the new settings */
#endif
	return _my_kbd_fd;	/* OK, return fd */
}


/***********************************************************************
// 
************************************************************************/

static void _kb_remove(int final)
{
	int r = 0;

	if (_my_kbd_fd < 0)
		return;

#if defined(KB_DEBUG)
	fprintf(stderr,"_kb_remove 1: fd: %d  final: %d\n", _my_kbd_fd, final);
	get_fd_info(_my_kbd_fd, NULL, NULL);	/* print the current settings */
#endif

	if (ioctl(_my_kbd_fd, KDSKBMODE, oldkbmode) != 0)
		r |= 1;
	if (tcsetattr(_my_kbd_fd, 0, &oldkbdtermios) != 0)
		r |= 2;
#if defined(KB_DEBUG) && (KB_DEBUG >= 2)
	get_fd_info(_my_kbd_fd, NULL, NULL);	/* print the current settings */
#endif

	if (final)
	{
		if (close(_my_kbd_fd) != 0)
			r |= 4;
		_my_kbd_fd = -1;
	}

#if defined(KB_DEBUG)
	fprintf(stderr,"_kb_remove 2: fd: %d  error code: %d\n", _my_kbd_fd, r);
#endif
}


static int _kb_install(void)
{
	int fd = keyboard_init_return_fd();
	if (fd == -1)
		return -1;
	else if (fd < 0)
	{
		_kb_remove(1);
		return -1;
	}
	else
		return 0;
}


/***********************************************************************
// update the keyboard
************************************************************************/

void kb_update(void)
{
	unsigned char buf[128];
	int bytesread;
	int vt = 0;

	if (!_kb_mode)
		return;
	
	while ((bytesread = read(_my_kbd_fd, buf, sizeof(buf))) > 0)
	{
		int x;

#if defined(KB_LINUX_MEDIUMRAW)
		x = _kb_linux_update(buf,bytesread,_my_mediumraw_handler);
#else
		x = _kb_linux_update(buf,bytesread,_my_raw_handler);
#endif

		if (x > 0)
			vt = x;

		/* Control-C check */
		if (_kb_flags & KB_FLAG_SIGINT)
		{
			if (_kb_key[KB_SCAN_C] && 
				(_kb_key[KB_SCAN_LCONTROL] || _kb_key[KB_SCAN_RCONTROL]))
				raise(SIGINT);
		}
	}


	if (vt > 0)
		_kb_linux_switch_vt(_my_kbd_fd,vt);
	

	if (_kb_flags & KB_FLAG_EMERGENCY_SIGALRM)
		_kb_signal_alarm_update();
}


/*
vi:ts=4
*/

