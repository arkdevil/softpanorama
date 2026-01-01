/* sigalrm.c -- test of the emergency alarm feature of libkb
 * Copyright (C) 1995, 1996 Markus F.X.J. Oberhumer
 * For conditions of distribution and use, see copyright notice in kb.h 
 */


#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <signal.h>

#include <kb.h>
#include "intro.h"


/***********************************************************************
// 
************************************************************************/

int main(int argc, char *argv[])
{
	char s[80+1];
	unsigned long f = 0;

	if (argc < 0 || argv == NULL)	/* avoid warning about unused args */
		return 0;

	fputs("\n",stdout);
	fputs(_kb_intro_text(s),stdout);
	fputs("\n\n",stdout);

#if 0 && defined(SIGALRM)
	/* for testing the correct settings of kb_kbflags() */
	signal(SIGALRM,SIG_IGN);
#endif

	f |= KB_FLAG_EMERGENCY_EXIT | KB_FLAG_EMERGENCY_SIGALRM;
	if (kb_install(f) != 0)
	{
		printf("Couldn't install keyboard handler !\n");
		exit(1);
	}
	if (!(kb_flags() & KB_FLAG_EMERGENCY_SIGALRM))
	{
		kb_remove();
		printf("Couldn't install KB_FLAG_EMERGENCY_SIGALRM !\n");
		exit(1);
	}

	printf(KB_INSTALLED_MSG);
	printf("\n");

#if defined(__KB_LINUX)
	printf("\nPlease be patient, program should terminate in 30 seconds.\n");
#else
	printf("Press LControl-RControl-C to quit.\n");
	printf("\nProgram should terminate in 30 seconds.\n");
#endif

	/* This loop causes the program to hang under Linux because 
	 * kb_update() is not called. KB_FLAG_EMERGENCY_SIGALRM will 
	 * raise SIGALRM if kb_update() is not called for 30 seconds.
	 */

	for (;;)
	{
		if (kb_key(KB_SCAN_Q))
		{
			if ((kb_key(KB_SCAN_LCONTROL) || kb_key(KB_SCAN_RCONTROL)) &&
				(kb_key(KB_SCAN_LSHIFT) || kb_key(KB_SCAN_RSHIFT)))
				break;
			if (kb_key(KB_SCAN_ALTGR))
				break;
		}
	}

	return 0;
}


/*
vi:ts=4
*/
