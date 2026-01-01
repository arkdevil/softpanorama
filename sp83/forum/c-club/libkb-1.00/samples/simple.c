/* simple.c -- very simple usage example of the libkb keyboard library
 * Copyright (C) 1995, 1996 Markus F.X.J. Oberhumer
 * For conditions of distribution and use, see copyright notice in kb.h 
 */


#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <kb.h>
#include "intro.h"


/***********************************************************************
// 
************************************************************************/

static int q_pressed(void)
{
	kb_update();

	if (kb_key(KB_SCAN_Q))
	{
		if ((kb_key(KB_SCAN_LCONTROL) || kb_key(KB_SCAN_RCONTROL)) &&
			(kb_key(KB_SCAN_LSHIFT) || kb_key(KB_SCAN_RSHIFT)))
			return 1;
		if (kb_key(KB_SCAN_ALTGR))
			return 1;
	}
	return 0;
}


/***********************************************************************
// 
************************************************************************/

int main(int argc, char *argv[])
{
	int i;
	char s[80+1];
	unsigned last_key = 0;
	unsigned long f = 0;

	if (argc < 0 || argv == NULL)	/* avoid warning about unused args */
		return 0;

	fputs("\n",stdout);
	fputs(_kb_intro_text(s),stdout);
	fputs("\n\n",stdout);


	if (argc > 1)
	{
		printf("reading with kb_os_waitkey(), press 'Q' to end\n");
		for (;;)
		{
			int k = kb_os_waitkey();
			if (k)
			{
				printf("%3d  0x%02x  '%c'\n", k, k, 
					k >= 32 && k < 127 ? k : '.');
			}
			if (k == 'q' || k == 'Q')
				break;
		}
		fputs("\n\n",stdout);
	}


	if (argc > 1)
		f |= KB_FLAG_EMERGENCY_EXIT | KB_FLAG_EMERGENCY_SIGALRM;
	if (kb_install(f) != 0)
	{
		printf("Couldn't install keyboard handler !\n");
		exit(1);
	}

	printf(KB_INSTALLED_MSG);
	printf("\nHit any key to test, Ctrl-Shift-Q or AltGr-Q to quit\n\n");

	while (!q_pressed())
	{
		int c = 0;

		if ((last_key = kb_last_key()) != 0)
		{
			int k = last_key & 0x7f;
			kb_last_key_set(0);
			printf("%3d  0x%02x  %s\n", k, k, kb_keyname(k));
		}

		while (KB_ANY_MASK(kb_shift(), KB_SHIFT_ANY_CONTROL) &&
			KB_ANY_MASK(kb_shift(), KB_SHIFT_ANY_ALT) &&
			(kb_key(KB_SCAN_DELETE) || kb_key(KB_SCAN_PERIOD_PAD)))
		{
			kb_update();
			if (c == 0)
			{
				printf("Control-Alt-Del pressed\n");
				c = 1;
			}
		}

		if (kb_shift() & KB_SHIFT_CONTROL_BREAK)
		{
			printf("Control-Break pressed\n");
			kb_shift_off(KB_SHIFT_CONTROL_BREAK);
		}

		if (kb_shift() & KB_SHIFT_PAUSE)
		{
			if (KB_ALL_MASK(kb_shift(), KB_SHIFT_ANY_CONTROL))
				printf("LControl-RControl-Break pressed\n");
			else
				printf("Pause pressed\n");
			kb_shift_off(KB_SHIFT_PAUSE);
		}
	}

	printf("\n");
	printf("%d keys now pressed: ", kb_keys_pressed());
	for (i = 0; i < 128; i++)
		if (kb_key(i))
			printf("%02x ", i);
	printf("\n");
	fflush(stdout);

	return 0;
}


/*
vi:ts=4
*/
