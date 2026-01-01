/* vt.c -- Linux VT test program
 * Copyright (C) 1996 Markus F.X.J. Oberhumer
 * For conditions of distribution and use, see copyright notice in kb.h 
 */



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
#include <linux/vt.h>


/***********************************************************************
// test if VT-ioctl stuff works with any valid file descriptor
************************************************************************/

int vt_test(int fd, int print, int *vt, int *vt_fno)
{
	struct vt_stat vtinfo;
	long first_non_opened;

	if (ioctl(fd, VT_GETSTATE, &vtinfo) != 0)
	{
		perror("ioctl VT_GETSTATE");
		return -1;
	}
	else if (print)
	{
		fprintf(stdout,"info: fd: %d  vt_stat: v_active=%d "
			"v_signal=0x%x v_state=0x%x\n", fd, (int) vtinfo.v_active,
			(unsigned) vtinfo.v_signal, (unsigned) vtinfo.v_state);
	}


	if (ioctl(fd, VT_OPENQRY, &first_non_opened) != 0)
	{
		perror("ioctl VT_OPENQRY");
		return -1;
	}
	else if (print)
	{
		fprintf(stdout,"info: fd: %d  first non opened VT: %ld\n",
			fd, first_non_opened);
	}

	if (vt)
		*vt = vtinfo.v_active;
	if (vt_fno)
		*vt_fno = first_non_opened;
	return 0;
}
	

/***********************************************************************
// 
************************************************************************/

int main(int argc, char *argv[])
{
	int opt_timings = 0;
	int fd;
	int i;
	int vt = 0, vt_fno = 0;

	/* option -t: */
	if (argc == 2 && strncmp(argv[1],"-t",2) == 0)
		opt_timings = 1;


	fd = fileno(stdin);		/* ok */
	fd = -1;				/* doesn't work */
	fd = 0;					/* ok */

	if (opt_timings)
	{
		for (i = 100000; i > 0; i--)
			vt_test(fd,0,NULL,NULL);
	}
	else
		vt_test(fd,1,&vt,&vt_fno);


#if 0
	/* switch to the next console */
	if (vt > 0 && vt + 1 < vt_fno)
	{
		if (ioctl(fd, VT_ACTIVATE, vt + 1) != 0)
			perror("ioctl VT_ACTIVATE");
	}
#endif
		

	return 0;
}


/*
vi:ts=4
*/
