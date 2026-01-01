/* kblinux.c -- internal Linux stuff
 * Copyright (C) 1996 Markus F.X.J. Oberhumer
 * For conditions of distribution and use, see copyright notice in kb.h 
 */


#if !defined(__linux__)
#  error this file is for Linux only
#endif

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>
#include <sys/types.h>
#include <sys/ioctl.h>
#include <linux/kd.h>
#include <linux/vt.h>

#include <kb.h>
#include "_kb.h"


/***********************************************************************
// virtual terminal switching
// termios should be saved because svgalib enables ISIG in c_lflag
************************************************************************/

int _kb_linux_switch_vt(int fd, int vt)
{
	int x = -1;
	int r;
	int my_vt;
	struct vt_stat vtinfo;
	long first_non_opened = 0;
	struct termios t;
	int sigalrm_was_running;

	if (vt <= 0)
		return -1;


	/* get current VT info */
	if (ioctl(fd, VT_GETSTATE, &vtinfo) != 0)
	{
#if defined(KB_DEBUG)
		perror("libkb VT: ioctl VT_GETSTATE");
#endif
		return -1;
	}
	my_vt = vtinfo.v_active;
	if (vt == my_vt)
		return 0;				/* no need to switch */


	/* get number of virtual terminals */
	if (ioctl(fd, VT_OPENQRY, &first_non_opened) != 0)
	{
#if defined(KB_DEBUG)
		perror("libkb VT: ioctl VT_OPENQRY");
#endif
		return -1;
	}
	if (vt >= first_non_opened)
		return -1;


	/* pause the alarm() timer */
	sigalrm_was_running = _kb_signal_alarm_pause();


	/* save current termios */
	r = tcgetattr(fd, &t);
#if defined(KB_DEBUG)
	if (r != 0)
		perror("libkb VT: tcgetattr");
#endif
#if defined(KB_DEBUG) && (KB_DEBUG >= 3)
	if (r == 0)
		fprintf(stderr,"libkb VT info: fd: %d tcgetattr: "
			"iflag=0x%04lx oflag=0x%04lx lflag=0x%04lx %d %d\n", 
			fd, t.c_iflag, t.c_oflag, t.c_lflag,
			t.c_cc[VMIN], t.c_cc[VTIME]);
#endif


	/* Do the switching.
	 * This will also generate a signal catched by svgalib to restore textmode.
 	 */
	if (ioctl(fd, VT_ACTIVATE, vt) != 0)
	{
#if defined(KB_DEBUG)
		perror("libkb VT: ioctl VT_ACTIVATE");
#endif
	}
	else
	{
		/* We've sucessfully returned from the VT switch. */
		x = 0;

		if (_kb_flags & KB_FLAG_LINUX_VT_NO_KEY)
		{
			/* assume that no key is pressed */
			int i;

			for (i = 0; i < 128; i++)
				if (_kb_key[i])
				{
					_kb_key[i] = 0;
					_kb_keys_pressed--;
				}
#if defined(KB_DEBUG)
			if (_kb_keys_pressed != 0)
				fprintf(stderr,"libkb VT: _kb_keys_pressed = %d !\n",
					_kb_keys_pressed);
#endif
			_kb_keys_pressed = 0;
			_kb_shift &= 0x3f;	/* all shift keys off */
		}
	}


	/* restore termios */
	if (r == 0)
	{
		r = tcsetattr(fd, TCSANOW, &t);
#if defined(KB_DEBUG)
		if (r != 0)
			perror("libkb VT: tcsetattr");
#endif
	}


	/* resume the alarm() timer */
	if (sigalrm_was_running == 1)
		_kb_signal_alarm_resume();

	return x;
}


/***********************************************************************
// Only switch if either Alt or AltGr is pressed.
//
// We are more restrictive than the standard behavior because 
// we try to avoid the situation that a now pressed key is released
// after the terminal switch and we still think it is pressed 
// when we switch back to this console.
// This means we prefer missing a key-press to missing a key-release
// in a different console.
************************************************************************/

int _kb_linux_is_switch(int *vt, int vtnum1, int vtnum2)
{
	/* either Alt or AltGr must be pressed */
	if (_kb_key[KB_SCAN_ALT] == _kb_key[KB_SCAN_ALTGR])
		return 0;

	if (vtnum2 == 0)
		vtnum2 = vtnum1 + 12;

#if 0
	/* while libkb is still in beta, we always do the switch if SCRLOCK
	 * is pressed. If there is a bug and _kb_keys_pressed gets out
	 * of sync, no switching would be possible.
	 */
	if (_kb_key[KB_SCAN_SCRLOCK])
	{
		*vt = _kb_key[KB_SCAN_ALT] ? vtnum1 : vtnum2;
		return 1;
	}
#endif

	/* no other keys may be pressed */
	if (_kb_keys_pressed != 1)
		return 0;

	/* a valid key combination */
	*vt = _kb_key[KB_SCAN_ALT] ? vtnum1 : vtnum2;
	return 1;
}


/***********************************************************************
// update the keyboard
************************************************************************/

int _kb_linux_update(const unsigned char *buf, int len, 
                     void (*key_handler)(unsigned char))
{
	const unsigned char *p;
	int vt;
	
	if (_kb_flags & KB_FLAG_LINUX_NO_VT)
	{
		/* optimized version for no virtual terminal switching */
		for (p = buf; p < &buf[len]; p++)
			key_handler(*p);
		return 0;
	}

	/* enable virtual terminal switching */
	vt = 0;
	for (p = buf; p < &buf[len]; p++)
	{
		int scan = *p;

		if (scan >= KB_SCAN_F1 && scan <= KB_SCAN_F12)
		{
			if (scan <= KB_SCAN_F10)
			{
				if (_kb_linux_is_switch(&vt, scan - (KB_SCAN_F1 - 1), 0))
					continue;		/* ignore this keypress */
			}
			else if (scan >= KB_SCAN_F11)
			{
				if (_kb_linux_is_switch(&vt, scan - (KB_SCAN_F11 - 11), 0))
					continue;		/* ignore this keypress */
			}
			else if (scan == KB_SCAN_LAST_CONSOLE)
			{
				/* TODO: is there a system call ? */
			}
		}

		/* TODO: what about Incr_Console, Decr_Console ? */

		key_handler(*p);
	}

	return vt;
}



/*
vi:ts=4
*/

