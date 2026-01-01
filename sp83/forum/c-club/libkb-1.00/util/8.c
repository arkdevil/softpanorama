/* 8.c -- Linux emergency keyboard restorer
 * Copyright (C) 1996 Markus F.X.J. Oberhumer
 * For conditions of distribution and use, see copyright notice in kb.h 
 */


/***********************************************************************
// Put this program into your path. 
// If a program crashes and the keyboard is still in
// raw or mediumraw mode, do the following:
// 
// Press the left Alt key (scancode 56 -> '8') and then
// the equal key (scancode 13 -> '\n').  This program will
// be started and the keyboard should be useable again.
// 
// You can modify the default values below to suit your needs,
// but probably not.
************************************************************************/

#if !defined(__linux__)
#  error this program is for Linux only
#endif

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>
#include <sys/types.h>
#include <sys/ioctl.h>
#include <linux/kd.h>


int main(int argc, char *argv[])
{
	int fd;
	int mode;
	struct termios t;
	int restore = 1;

	/* option -d: display the current values */
	if (argc == 2 && strncmp(argv[1],"-d",2) == 0)
		restore = 0;

	fd = open("/dev/console", O_RDONLY);
	if (fd < 0)
	{
		perror("cannot open /dev/console");
		return 1;
	}

	if (ioctl(fd, KDGKBMODE, &mode) != 0)
		perror("ioctl KDGKBMODE");
	printf("KDGKBMODE: kbmode=%d\n", mode);

/* that's the most important thing */
	if (restore)
	{
		mode = K_XLATE;
		if (ioctl(fd, KDSKBMODE, mode) != 0)
			perror("ioctl KDSKBMODE");
		if (ioctl(fd, KDGKBMODE, &mode) != 0)
			perror("ioctl KDGKBMODE");
		printf("KDSKBMODE: kbmode=%d\n", mode);
	}

	/* set termios */
	t.c_iflag = t.c_oflag = t.c_lflag = 0;
	if (tcgetattr(fd, &t) != 0)
		perror("tcgetattr");
	printf("tcgetattr: iflag=0x%04lx oflag=0x%04lx lflag=0x%04lx %d %d\n", 
		t.c_iflag, t.c_oflag, t.c_lflag, t.c_cc[VMIN], t.c_cc[VTIME]);
	t.c_iflag |= (IXOFF | IXON | ICRNL);
	t.c_oflag |= (OPOST | ONLCR);
	t.c_lflag |= (ISIG | ICANON | ECHO);
	t.c_lflag |= (ECHOE | ECHOK | ECHOKE);
	t.c_cc[VMIN] = 1;
	t.c_cc[VTIME] = 0;
	if (restore)
	{
		if (tcsetattr(fd, TCSANOW, &t) != 0)
			perror("tcsetattr");
		if (tcgetattr(fd, &t) != 0)
			perror("tcgetattr");
		printf("tcgetattr: iflag=0x%04lx oflag=0x%04lx lflag=0x%04lx %d %d\n", 
			t.c_iflag, t.c_oflag, t.c_lflag, t.c_cc[VMIN], t.c_cc[VTIME]);
	}

	/* a good idea to add this here */
#if 1
	/* note: you must run 'savetextmode' before */
	if (restore)
		system("textmode");
#endif
	
	return 0;
}


/*
vi:ts=4
*/
