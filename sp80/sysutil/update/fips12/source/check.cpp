/*
	FIPS - the First nondestructive Interactive Partition Splitting program

	Module check.cpp

	RCS - Header:
	$Header: c:/daten/fips/source/main/RCS/check.cpp 1.1.1.1 1994/10/13 01:53:19 schaefer Exp schaefer $

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

#include "hdstruct.h"
#include "global.h"
#include "fipsspec.h"

void fips_harddrive::check (void)
{
	int i,j,k;
	boolean bootable = false;

	byte *rootsector = harddrive::rootsector->data;
	partition_info *parts = partition_table().partition_info;

	int order[4] = {-1,-1,-1,-1};

	printx ("\nChecking Rootsector ... ");

	if ((*(rootsector+510) != 0x55) || (*(rootsector+511) != 0xaa))
		error ("Invalid Rootsector Signature: %02X %02X",*(rootsector+510),*(rootsector+511));

	for (i=0;i<4;i++)
	{
		if (parts[i].bootable == 0x80)
		{
			if (bootable)
			{
				if (!global.override_multiple_boot)
					error ("More than one bootable Partition");
			}
			else bootable = true;
		}
		else if (parts[i].bootable != 0)
			if (!global.override_bootable_flag)
				error ("Invalid bootable-flag: partition %u: %02Xh",i+1,parts[i].bootable);
			// must be 0 or 80h

		if (parts[i].system)
		{
			if ((parts[i].start_sector == 0) || (parts[i].start_sector > geometry.sectors))
				error ("Invalid Start Sector: partition %u: %u",i+1,parts[i].start_sector);
			if ((parts[i].end_sector == 0) || (parts[i].end_sector > geometry.sectors))
				error ("Invalid End Sector: partition %u: %u",i+1,parts[i].end_sector);
			if (parts[i].start_head > (geometry.heads - 1))
				error ("Invalid Start Head: partition %u: %u",i+1,parts[i].start_head);
			if (parts[i].end_head > (geometry.heads - 1))
				error ("Invalid End Head: partition %u: %u",i+1,parts[i].end_head);

			while (parts[i].start_sector_abs > (parts[i].start_cylinder * geometry.heads * geometry.sectors +
				parts[i].start_head * geometry.sectors + parts[i].start_sector - 1))
			{
				parts[i].start_cylinder += 1024;	// more than 1024 cylinders
			}

			if (parts[i].start_sector_abs != (parts[i].start_cylinder * geometry.heads * geometry.sectors +
				parts[i].start_head * geometry.sectors + parts[i].start_sector - 1))
				error ("Partition Table Corrupt - start: partition %u",i+1);
				// physical start sector does not match logical start sector

			while ((parts[i].start_sector_abs + parts[i].no_of_sectors_abs - 1) >
				(parts[i].end_cylinder * geometry.heads * geometry.sectors +
				parts[i].end_head * geometry.sectors + parts[i].end_sector - 1))
			{
				parts[i].end_cylinder += 1024;		// more than 1024 cylinders
			}

			if ((parts[i].start_sector_abs + parts[i].no_of_sectors_abs - 1) !=
				(parts[i].end_cylinder * geometry.heads * geometry.sectors +
				parts[i].end_head * geometry.sectors + parts[i].end_sector - 1))
				error ("Partition Table Corrupt - end: partition %u",i+1);
				// physical end sector does not match logical end sector

			for (j=0;j<4;j++)       // insert partition in ordered table
			{
				if (order[j] == -1)
				{
					order[j] = i;
					break;
				}
				else if (parts[i].start_sector_abs < parts[order[j]].start_sector_abs)
				{
					for (k=3;k>j;k--) order[k] = order[k-1];
					order[j] = i;
					break;
				}
			}
		}
		else            // system = 0
		{
			for (j=0;j<16;j++)
			{
				if (*(rootsector + 0x1be + 16*i + j))
				{
					warning ("Invalid Partition entry: partition %u",i+1);
					break;
				}
			}
		}
	}
	for (i=0;i<4;i++)
	{
		if ((k=order[i]) != -1)         // valid partition
		{
			if ((parts[k].end_sector != geometry.sectors) || (parts[k].end_head != (geometry.heads - 1)))
				warning ("Partition does not end on Cylinder boundary: partition %u",k+1);
			if (i != 0) if ((parts[k].start_sector != 1) || (parts[k].start_head != 0))
				warning ("Partition does not begin on Cylinder boundary: partition %u",k+1);

			if (i<3) if ((j=order[i+1]) != -1)       // following valid partition
			{
				if ((parts[k].start_sector_abs + parts[k].no_of_sectors_abs) > parts[j].start_sector_abs)
					error ("Overlapping Partitions: %u and %u",k+1,j+1);
				if ((parts[k].start_sector_abs + parts[k].no_of_sectors_abs) < parts[j].start_sector_abs)
					warning ("Free Space between Partitions: %u and %u",k+1,j+1);
			}
		}
	}

	for (i=3; i>=0; i--)	// if more than 1024 cylinder, adjust geometry
	{
		if ((k = order[i]) != -1)
		{
			if (parts[k].end_cylinder + 1 > geometry.cylinders)
				geometry.cylinders = parts[k].end_cylinder + 1;
			break;
		}
	}

	printx ("OK\n");
}


void fips_partition::check (void)
{
	printx ("Checking Bootsector ... ");

	byte *bootsector = partition::bootsector->data;

	if (*(bootsector) == 0xeb)
	{
		if (*(bootsector + 2) != 0x90)
			error ("Invalid Jump Instruction in Bootsector: %02X %02X %02X",*(bootsector),*(bootsector+1),*(bootsector+2));
	}
	else if (*(bootsector) != 0xe9)
		error ("Invalid Jump Instruction in Bootsector: %02X %02X %02X",*(bootsector),*(bootsector+1),*(bootsector+2));

	if ((*(bootsector+510) != 0x55) || (*(bootsector+511) != 0xaa))
		error ("Invalid Bootsector: %02X %02X",*(bootsector+510),*(bootsector+511));
	if (bpb().bytes_per_sector != 512)
		error ("Can't handle number of Bytes per Sector: %u",bpb().bytes_per_sector);
	switch (bpb().sectors_per_cluster)
	{
		case 1:case 2:case 4:case 8:case 16:case 32:case 64:case 128: break;
		default:
			error ("Number of Sectors per Cluster must be a power of 2: actually it is %u",bpb().sectors_per_cluster);
	}
	if (bpb().reserved_sectors != 1)
		warning ("Number of reserved sectors should be 1: actually it is %u",bpb().reserved_sectors);
	if (bpb().no_of_fats != 2)
		error ("Partition must have 2 FATs: actually it is %u",bpb().no_of_fats);
	if (bpb().no_of_rootdir_entries % 16)
		if (!global.override_rootdir_entries)
			error ("Number of Rootdir entries must be multiple of 16: actually it is %u",bpb().no_of_rootdir_entries);
	if (bpb().no_of_rootdir_entries == 0)
		error ("Number of Rootdir entries must not be zero");
	if (bpb().media_descriptor != 0xf8)
		if (!global.override_media_descriptor)
			error ("Wrong Media Descriptor Byte in Bootsector: %02X",bpb().media_descriptor);
	if (bpb().sectors_per_fat > 256)
		if (!global.override_large_fat)
			error ("FAT too large: %u sectors",bpb().sectors_per_fat);
	if (bpb().sectors_per_fat < (info().no_of_clusters + 1) / 256 + 1)
		if (!global.override_small_fat)
			error ("FAT too small: %u sectors (should be %u)",bpb().sectors_per_fat, (unsigned int) ((info().no_of_clusters + 1) / 256 + 1));
	if (bpb().sectors_per_track != drive->geometry.sectors)
		warning ("Sectors per track incorrect: %u instead of %u",bpb().sectors_per_track,(int) drive->geometry.sectors);
	if (bpb().drive_heads != drive->geometry.heads)
		warning ("Number of drive heads incorrect: %u instead of %u",bpb().drive_heads,(int) drive->geometry.heads);
	if (bpb().hidden_sectors != partition_info->start_sector_abs)
		error ("Number of hidden sectors incorrect: %lu instead of %lu",bpb().hidden_sectors,partition_info->start_sector_abs);

	if (info().no_of_clusters <= 4084)
		error ("12-bit FAT not supported: number of clusters is %u",(int) info().no_of_clusters);

	if (bpb().no_of_sectors)
	{
		if (partition_info->no_of_sectors_abs > 0xffff)
			error ("Number of sectors (short) must be zero");
		if (bpb().no_of_sectors != partition_info->no_of_sectors_abs)
			error ("Number of sectors (short) does not match Partition Info:\n%u instead of %lu",bpb().no_of_sectors,partition_info->no_of_sectors_abs);
		if (partition_info->system != 4)
			warning ("Wrong System Indicator Byte: %u instead of 4",partition_info->system);
	}
	else
	{
		if (bpb().no_of_sectors_long != partition_info->no_of_sectors_abs)
			error ("Number of Sectors (long) does not match Partition Info:\n%lu instead of %lu",bpb().no_of_sectors_long,partition_info->no_of_sectors_abs);
		if (bpb().signature != 0x29)
			warning ("Wrong Signature: %02Xh",bpb().signature);
		if (bpb().phys_drive_no != drive->number)
			warning ("Drive number in bootsector does not match actual drivenumber:\n%02Xh instead of %02Xh"
			,bpb().phys_drive_no,drive->number);
		if (partition_info->system != 6)
			warning ("Wrong System Indicator Byte: %u instead of 6",partition_info->system);
	}

	printx ("OK\n");
}

