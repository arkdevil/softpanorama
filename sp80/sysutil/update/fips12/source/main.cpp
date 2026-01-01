/*
	FIPS - the First nondestructive Interactive Partition Splitting program

	Module main.cpp

	RCS - Header:
	$Header: c:/daten/fips/source/main/RCS/main.cpp 1.1.1.1 1994/10/13 01:53:43 schaefer Exp schaefer $

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

#include <stdlib.h>
#include "logdr_st.h"
#include "global.h"
#include "input.h"
#include "fat.h"
#include "fipsspec.h"
#include "host_os.h"


void main (int argc,char *argv[])
{
	evaluate_argument_vector (argc,argv);

	atexit (exit_function);

	if (global.debug_mode) global.open_debugfile(argc,argv);

	notice();

	int drive_number;
	if (global.drive_number_cmdline) drive_number = global.drive_number_cmdline;
	else drive_number = ask_for_drive_number ();

	host_os os;
	char infostring[256];

	if (os.ok () != OK)
	{
		printx ("\nWARNING: FIPS has detected that it is running under %s\n"
			"FIPS should not be used under a multitasking OS. If possible, boot from a DOS\n"
			"disk and then run FIPS. Read FIPS.DOC for more information.\n\n",
			os.information (infostring));
		ask_if_proceed ();
	}

	fips_harddrive harddrive (drive_number);

	if (harddrive.errorcode)
		error ("Error reading Drive Geometry: Errorcode %u",harddrive.errorcode);

	harddrive.reset();

	if (harddrive.errorcode)
		error ("Drive Initialization Failure: Errorcode %u",harddrive.errorcode);

	if (harddrive.rootsector->read ())
		error ("Error reading Root Sector");

	if (global.debug_mode)
	{
		fprintf (global.debugfile,"\nRoot Sector Drive %02Xh:\n\n",drive_number);
		hexwrite (harddrive.rootsector->data,512,global.debugfile);
	}

	fips_partition *partition;

	while (true)
	{
		fips_harddrive hd = harddrive;

		hd.partition_table().get (hd.rootsector);

		printx ("\nPartition Table:\n\n");
		hd.print_partition_table ();

		hd.check();

		int partition_number;
		if (global.partition_number_cmdline) partition_number = global.partition_number_cmdline - 1;
		else partition_number = ask_for_partition_number (hd.partition_table().partition_info);

		partition = new fips_partition (&hd,partition_number);

		int system = partition->partition_info->system;
		if (system == 5)
			error ("Can't split extended Partitions");
		if (system == 0)
			error ("Invalid Partition selected: %u",partition_number + 1);
		if ((system != 1) && (system != 4) && (system != 6))
			error ("Unknown Filesystem: %02Xh",system);

		if (partition->bootsector->read ())
			error ("Error reading Boot Sector");

		if (global.debug_mode)
		{
			fprintf (global.debugfile,"\nBoot Sector Drive %02Xh, Partition %u:\n\n",hd.number,partition->number + 1);
			hexwrite (partition->bootsector->data,512,global.debugfile);
		}

		partition->bpb().get (partition->bootsector);

		printx ("\nBootsector:\n\n");
		partition->print_bpb ();

		partition->info().get (partition->bpb());
		if (global.debug_mode) partition->write_info_debugfile ();

		partition->check();

		fat16 fat1 (partition,1);
		fat16 fat2 (partition,2);

		fat1.check_against (&fat2);

		dword new_part_min_sector =
			partition->info().start_data +
			(dword) 4085 * partition->bpb().sectors_per_cluster;

		dword new_part_min_cylinder =
			(new_part_min_sector +
			partition->partition_info->start_sector_abs - 1) /
			(hd.geometry.heads * hd.geometry.sectors) + 1;

		if (new_part_min_cylinder > partition->partition_info->end_cylinder)
			error ("Partition too small - can't split");

		dword min_free_cluster = fat1.min_cluster ();
		dword min_free_sector = partition->info().start_data + (min_free_cluster - 2) * (dword) partition->bpb().sectors_per_cluster;
		dword min_free_cylinder = (min_free_sector + partition->partition_info->start_sector_abs - 1) / (hd.geometry.heads * hd.geometry.sectors) + 1;

		if (min_free_cylinder > partition->partition_info->end_cylinder)
			error ("Last Cylinder is not free");

		if (new_part_min_cylinder < min_free_cylinder) new_part_min_cylinder = min_free_cylinder;

		if (ask_if_save()) save_root_and_boot(&hd,partition);

		dword new_start_cylinder;
		if (global.new_start_cylinder_cmdline)
		{
			new_start_cylinder = global.new_start_cylinder_cmdline;
			if ((new_start_cylinder < new_part_min_cylinder) || (new_start_cylinder > partition->partition_info->end_cylinder))
				error ("Invalid new start cylinder: %lu",new_start_cylinder);
		}
		else
		{
			new_start_cylinder =
				ask_for_new_start_cylinder
				(
					partition->partition_info->start_cylinder,
					new_part_min_cylinder,
					partition->partition_info->end_cylinder,
					hd.geometry.heads * hd.geometry.sectors
				);
		}

		fat2.check_empty (new_start_cylinder * hd.geometry.heads * hd.geometry.sectors - partition->partition_info->start_sector_abs);

		hd.calculate_new_root (new_start_cylinder,partition);

		hd.partition_table().put (hd.rootsector);

		hd.partition_table().get (hd.rootsector);

		printx ("\nNew Partition Table:\n\n");
		hd.print_partition_table ();

		hd.check();

		if (ask_if_continue ())
		{
			harddrive = hd;
			break;
		}
	}

	partition->calculate_new_boot ();

	partition->bpb().put (partition->bootsector);

	partition->bpb().get (partition->bootsector);

	printx ("\nNew Bootsector:\n\n");
	partition->print_bpb ();

	partition->info().get (partition->bpb());
	if (global.debug_mode) partition->write_info_debugfile ();

	partition->check();

	if (!global.test_mode)
	{
		ask_for_write_permission();

		if (harddrive.rootsector->write())
			error ("Error writing Root Sector");

		if (partition->bootsector->write ())
			error ("Error writing Boot Sector");

		printx ("Repartitioning complete\n");
	}
}
