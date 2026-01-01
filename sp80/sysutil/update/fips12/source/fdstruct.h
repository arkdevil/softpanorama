#ifndef FDSTRUCT_H
#define FDSTRUCT_H

#include "disk_io.h"
#include "logdr_st.h"

class floppydrive:public logical_drive,public physical_drive
{
public:
	int read_sector (dword number,sector *sector)
	{
		return (sector->read (this,number));
	}
	int write_sector (dword number,sector *sector)
	{
		return (sector->write (this,number));
	}

	floppydrive (int number):physical_drive(number)
	{
		bootsector = new class bootsector (this);
	}
	~floppydrive (void) { delete bootsector; }
};

#endif
