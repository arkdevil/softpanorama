/*
	FIPS - the First nondestructive Interactive Partition Splitting program

	Module cmdl_arg.cpp

	RCS - Header:
	$Header: c:/daten/fips/source/main/RCS/cmdl_arg.cpp 1.1.1.1 1994/10/13 01:53:22 schaefer Exp schaefer $

	Copyright (C) 1993 Arno Schaefer

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.


	Report problems and direct all questions to:

	schaefer@rbg.informatik.th-darmstadt.de
*/

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include "global.h"

/* ----------------------------------------------------------------------- */
/* Replacement for atoi                                                    */
/* ----------------------------------------------------------------------- */

static int atoint (char *string)
{
	long int value = 0;
	while (isdigit (*string))
	{
		value = value * 10 + (*string - '0');
		if (value > 32767) return (-1);
		string++;
	}
	if (*string != '\0') return (-1);
	return (int) value;
}

/* ----------------------------------------------------------------------- */
/* Usage instructions                                                      */
/* ----------------------------------------------------------------------- */

static void usage (void)
{
	printf ("\nFIPS {[-t][-d][-h|-?][-d<num>][-p<num>][-c<num>][-o<error>]}:\n\n");
	printf ("-t        : test mode (no writes to disk)\n");
	printf ("-d        : debug mode\n");
	printf ("-h/-?     : this help page\n");
	printf ("-d<num>   : select drive <num>\n");
	printf ("-p<num>   : select partition <num>\n");
	printf ("-c<num>   : new start cylinder = <num>\n");
	printf ("-o<error> : override error message\n\n");
	printf ("where <error> is\n\n");
	printf ("mb - more than one bootable partition\t");
	printf ("bf - invalid bootable-flag\n");
	printf ("lf - FAT too large\t\t\t");
	printf ("sf - FAT too small\n");
	printf ("md - wrong media descriptor byte\t");
	printf ("re - rootdir entries not multiple of 16\n");
}

/* ----------------------------------------------------------------------- */
/* Process commandline parameters                                          */
/* ----------------------------------------------------------------------- */

void evaluate_argument_vector (int argc,char *argv[])
{
	while (--argc > 0)
	{
		int switchar = (*++argv)[0];
		char *sw = *argv + 1;

		if (switchar != '/' && switchar != '-') error ("Invalid Commandline Parameter: %s",*argv);

		else if (!strcmp (sw,"t") || !strcmp (sw,"test")) global.test_mode = true;
		else if (!strcmp (sw,"d") || !strcmp (sw,"debug")) global.debug_mode = true;
		else if (!strcmp (sw,"h") || !strcmp (sw,"help") || !strcmp (sw,"?"))
		{
			usage ();
			exit (0);
		}
		else if (!strcmp (sw,"omb")) global.override_multiple_boot = true;
		else if (!strcmp (sw,"obf")) global.override_bootable_flag = true;
		else if (!strcmp (sw,"ore")) global.override_rootdir_entries = true;
		else if (!strcmp (sw,"olf")) global.override_large_fat = true;
		else if (!strcmp (sw,"osf")) global.override_small_fat = true;
		else if (!strcmp (sw,"omd")) global.override_media_descriptor = true;

		else switch ((*argv)[1])
		{
			case 'd':
			{
				if ((global.drive_number_cmdline = atoint (*argv + 2)) == -1) error ("Invalid Argument: %s",*argv);
				if ((global.drive_number_cmdline < 0x80) || (global.drive_number_cmdline > 0xff)) error ("Invalid Drive number: %d",global.drive_number_cmdline);
				break;
			}
			case 'p':
			{
				if ((global.partition_number_cmdline = atoint (*argv + 2)) == -1) error ("Invalid Argument: %s",*argv);
				if ((global.partition_number_cmdline < 1) || (global.partition_number_cmdline > 4)) error ("Invalid Partition number: %d",global.partition_number_cmdline);
				break;
			}
			case 'c':
			{
				int h = atoint (*argv + 2);
				if (h == -1) error ("Invalid Argument: %s",*argv);
				global.new_start_cylinder_cmdline = h;
				break;
			}
			default: error ("Invalid Commandline Parameter: %s",*argv);
		}
	}
}
