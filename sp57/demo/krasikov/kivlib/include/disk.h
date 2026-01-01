/***************************************************************/
/*                                                             */
/*                 KIVLIB include file  DISK.H                 */
/*                                                             */
/*                                                             */
/*        Copyright (c)  1993   by  KIV without Co             */
/***************************************************************/

#ifndef ___DISK_LIB___
#define ___DISK_LIB___

#include <structs.h>

#ifdef __cplusplus
extern "C" {
#endif

char  cdecl substDrive(char Drive);
void  cdecl checkDisk(unsigned char dr, unsigned int * Status, unsigned char * media, int * error);
/*
  dr         1 - A etc.
  Status     and 0x9200 != 0 => SUBST/ASSIGN/NETWORK
  media         0 => 320/360K
		1 => 1.2 M
		2 => 720 K
		3 => SD 8"
		4 => DD 8"
		5 => fixed;
		6 => tape
		7 => 1.44M
*/

int cdecl DiskParam(unsigned char drv,
                    unsigned int * tracks,
                    unsigned char * heads,
                    unsigned char * secs);

int cdecl validBoot(BootRec far * B);

DPT * cdecl get_dpt();

void  cdecl disk_cfg(DISK_CONFIG * cfg);

HDPT  far * cdecl get_hdp(int i);

/****************************************************************
0- success, ~0 - error by BIOS
drive 0-first hard, 1- secoond hard
****************************************************************/
int   cdecl getmboot(MBOOT * master_boot, int drive);


unsigned int cdecl RootSector(char drive);

long cdecl absSector(char drive, unsigned int Cluster);

int cdecl EndEntry(FileEntry * f);

long cdecl FindEntryLocal(char drive, long sector, char * name,
                         int *No, unsigned int *Cluster);
//name - name.ext!!!
//return - sector with entry

long cdecl FindEntry(char * path, int * Num, unsigned int * Clust);
//Num - number in File Entry table
//Clust - cluster of begin


#ifdef __cplusplus
}
#endif



#endif
