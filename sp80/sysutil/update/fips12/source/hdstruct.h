/*
	FIPS - the First nondestructive Interactive Partition Splitting program

	Module hdstruct.h

	RCS - Header:
	$Header: c:/daten/fips/source/main/RCS/hdstruct.h 1.1.1.1 1994/10/13 01:54:27 schaefer Exp schaefer $

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

#ifndef HDSTRUCT_H
#define HDSTRUCT_H

#include "types.h"
#include "disk_io.h"
#include "logdr_st.h"

/* ----------------------------------------------------------------------- */
/* Class rootsector - derived from structure sector                        */
/* Must be initialized with a pointer to a physical_drive object           */
/* Read() and Write() read/write sector 0 of physical drive                */
/* ----------------------------------------------------------------------- */

class rootsector:public sector
{
	physical_drive *drive;
public:
	int read (void) { return sector::read (drive,0); }
	int write (void) { return sector::write (drive,0); }

	rootsector (physical_drive *drive) { rootsector::drive = drive; }
	rootsector (rootsector &rs);
	void operator= (rootsector &rs);
};

/* ----------------------------------------------------------------------- */
/* Partition Info Structure                                                */
/* Each entry in the partition table contains this information             */
/* ----------------------------------------------------------------------- */

struct partition_info
{
	byte bootable;                  // 80h or 0
	byte start_head;                // location of first sector (bootsector)
	word start_cylinder;
	byte start_sector;
	byte system;			// 1 = 12-bit FAT
					// 4 = 16-bit FAT & 16-bit sector number
					// 6 = 16-bit FAT & 32-bit sector number (BIGDOS)
	byte end_head;                  // location of last sector
	word end_cylinder;
	byte end_sector;
	dword start_sector_abs;         // = start_cylinder * heads * sectors
					// + start_head * sectors + start_sector - 1
	dword no_of_sectors_abs;        // = end_cylinder * heads * sectors + end_head * sectors
					// + end_sector - start_sector_abs
};

/* ----------------------------------------------------------------------- */
/* Partition Table Structure                                               */
/* The partition table consists of 4 entries for the 4 possible partitions */
/* Get() reads the partition table from the rootsector, put() writes the   */
/* data back into the rootsector buffer                                    */
/* ----------------------------------------------------------------------- */

struct partition_table
{
	partition_info partition_info[4];
	void get (rootsector *rootsector);
	void put (rootsector *rootsector);
};

/* ----------------------------------------------------------------------- */
/* Harddrive Class, derived from physical_drive                            */
/* Represents one physical harddrive. Must be initialized with the drive   */
/* number (0x80 for 1st HDD). Contains the rootsector and partition table. */
/* ----------------------------------------------------------------------- */

class harddrive:public physical_drive
{
	partition_table pr_partition_table;
public:
	rootsector *rootsector;
	virtual partition_table &partition_table() { return pr_partition_table; }

	harddrive (int number):physical_drive (number)
	{
		rootsector = new class rootsector (this);
	}
	harddrive (harddrive &hd):physical_drive (hd)
	{
		rootsector = new class rootsector (*(hd.rootsector));
		partition_table () = hd.partition_table();
	}
	void operator= (harddrive &hd);
	~harddrive (void) { delete rootsector; }
};

/* ----------------------------------------------------------------------- */
/* Raw Partition Class                                                     */
/* Represents one partition from the partition table (may be non-DOS)      */
/* Initialization with the pointer to the harddrive object and the         */
/* partition number (0-3)                                                  */
/* ----------------------------------------------------------------------- */

class raw_partition
{
public:
	int number;
	physical_drive *drive;
	partition_info *partition_info;

	raw_partition (class harddrive *drive,int number)
	{
		raw_partition::number = number;
		raw_partition::drive = drive;
		partition_info = &(drive->partition_table().partition_info[number]);
	}
};
	
/* ----------------------------------------------------------------------- */
/* Partition Class, derived from logical_drive and raw_partition           */
/* Represents one primary DOS partition. Read_sector() and write_sector()  */
/* are instances of the virtual functions in the logical_drive class       */
/* ----------------------------------------------------------------------- */

class partition:public logical_drive,public raw_partition
{
public:
	int read_sector (dword number,sector *sector)
	{
		return (sector->read (drive,partition_info->start_sector_abs + number));
	}
	int write_sector (dword number,sector *sector)
	{
		return (sector->write (drive,partition_info->start_sector_abs + number));
	}

	partition (class harddrive *drive,int number):raw_partition(drive,number)
	{
		bootsector = new class bootsector (this);
	}
	~partition (void) { delete bootsector; }
};

#endif
