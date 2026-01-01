#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define INCL_DOS
#define INCL_DOSFILEMGR
#include <os2.h>

#define BUFSIZE 0x4000
unsigned char buffer[BUFSIZE];
unsigned char filename[128], destination[128];

int doCopy(char *name, char *dd1, char *dd2);
void main(int argc, char **argv)
{
    unsigned char dosos2;
    HFILE file;
    USHORT readlen, actionTaken;
    USHORT rc;
    FILESTATUS FileInfoBuf;
    char *dd1, *dd2;

    DosGetMachineMode(&dosos2);
    if (argc == 1) {
	strcpy(filename,argv[0]);
	strupr(filename);
	dd1 = strstr(filename,"WDISPLAY");
	strcpy(dd1,"SYSTEM.INI");
    } else if (argc == 2) {
	strcpy(filename,argv[1]);
	strupr(filename);
	if (strstr(filename,"SYSTEM.INI") == NULL)
	    goto usage;
    }
    if (argc > 2) {
	usage:
	printf("Usage: wdisplay [path\\system.ini]\n");
	printf("       Changes SYSTEM.INI to use the appropriate display driver\n");
	printf("       and copies appropriate files for DOS or OS/2.\n");
	printf("       NOTE: The path is only needed if running in DOS from\n");
	printf("             a different directory.\n");
	exit(1);
    }

    if ( (rc = DosOpen( filename, &file, &actionTaken, 0L,FILE_NORMAL,
			FILE_OPEN, OPEN_ACCESS_READONLY|OPEN_SHARE_DENYNONE, 0L)
	) != 0) {
	printf("%s: file not found\n",filename);
	exit(1);
    }
    DosQFileInfo(file,1,&FileInfoBuf, sizeof(FILESTATUS));

    DosRead(file,buffer,BUFSIZE,&readlen);

    DosClose(file);
    dd1 = strstr(buffer,"display.");
    dd2 = strstr(dd1+1,"display.");
    if (!dd1) {
	printf("No display driver found\n");
	exit(1);
    }
    if (!dd2) {
	printf("Only one display driver found\n");
	exit(1);
    }
    if (*(dd1+8) == 'o' || *(dd2+8) == 'o') {	/* os2 */
	if (dosos2 == 1) {
	    printf("Setting %s for OS/2\n",filename);
	    if (*(dd1+8) == 'o') {
	       *(dd1+ 8) = 'd';
	       *(dd1+ 9) = 'r';
	       *(dd1+10) = 'v';

	       *(dd2+ 9) = 'o';
	       *(dd2+10) = 's';
	    } else {
	       *(dd2+ 8) = 'd';
	       *(dd2+ 9) = 'r';
	       *(dd2+10) = 'v';

	       *(dd1+ 9) = 'o';
	       *(dd1+10) = 's';
	    }
	    if ( (rc = DosOpen( filename, &file, &actionTaken, 0L,FILE_NORMAL,
			OPEN_ACTION_REPLACE_IF_EXISTS|OPEN_ACTION_CREATE_IF_NEW,
			OPEN_ACCESS_WRITEONLY|OPEN_SHARE_DENYNONE, 0L)
		  ) != 0) {
		printf("Can't open %s - %d\n", filename,rc);
		exit(1);
	    }
	    DosSetFileInfo(file,1,(PBYTE)&FileInfoBuf,sizeof(FILESTATUS));
	    DosWrite(file,buffer,readlen,&readlen);
	    DosClose(file);
	} else {
	    printf("WIN-OS2 already in DOS mode\n");
	}
    } else if (*(dd1+9) == 'o' || *(dd2+9) == 'o') {  /* dos */
	if (dosos2 == 0) {
	    printf("Setting %s for DOS\n",filename);
	    if (*(dd1+9) == 'o') {
	       *(dd1+ 9) = 'r';
	       *(dd1+10) = 'v';

	       *(dd2+ 8) = 'o';
	       *(dd2+ 9) = 's';
	       *(dd2+10) = '2';
	    } else {
	       *(dd2+ 9) = 'r';
	       *(dd2+10) = 'v';

	       *(dd1+ 8) = 'o';
	       *(dd1+ 9) = 's';
	       *(dd1+10) = '2';
	    }
	    if ( (rc = DosOpen( filename, &file, &actionTaken, 0L,FILE_NORMAL,
			OPEN_ACTION_REPLACE_IF_EXISTS|OPEN_ACTION_CREATE_IF_NEW,
			OPEN_ACCESS_WRITEONLY|OPEN_SHARE_DENYNONE, 0L)
		  ) != 0) {
		printf("Can't open %s - %d\n", filename,rc);
		exit(1);
	    }
	    DosSetFileInfo(file,1,(PBYTE)&FileInfoBuf,sizeof(FILESTATUS));
	    DosWrite(file,buffer,readlen,&readlen);
	    DosClose(file);
	} else {
	    printf("WIN-OS2 already in OS/2 mode\n");
	}
    }
    dd1 = strstr(filename,".INI");
    *dd1 = 0;
    strcpy(destination,filename);
    if (dosos2)
	strcpy(dd1,"\\OS2\\");
    else
	strcpy(dd1,"\\DOS\\");
    dd1 = dd1+strlen(dd1);
    dd2 = destination+strlen(destination);
    *dd2++ = '\\';
    *dd2 = 0;
    doCopy("gdi.exe",dd1,dd2);
    doCopy("user.exe",dd1,dd2);
    doCopy("mouse.drv",dd1,dd2);

}

int doCopy(char *name, char *dd1, char *dd2)
{
    HFILE source, dest;
    USHORT readlen, actionTaken;
    USHORT rc;
    FILESTATUS FileInfoBuf;

    strcpy(dd1,name);
    strcpy(dd2,name);
    if ( (rc = DosOpen( filename, &source, &actionTaken, 0L,FILE_NORMAL,
			FILE_OPEN, OPEN_ACCESS_READONLY|OPEN_SHARE_DENYNONE, 0L)
	) != 0) {
	printf("Can't open %s - %d\n", filename,rc);
	return 0;
    }
    DosQFileInfo(source,1,&FileInfoBuf, sizeof(FILESTATUS));

    if ( (rc = DosOpen( destination, &dest, &actionTaken, 0L,FILE_NORMAL,
			OPEN_ACTION_REPLACE_IF_EXISTS|OPEN_ACTION_CREATE_IF_NEW,
			OPEN_ACCESS_WRITEONLY|OPEN_SHARE_DENYNONE, 0L)
	) != 0) {
	printf("Can't open %s - %d\n", destination,rc);
	return 0;
    }
    DosSetFileInfo(dest,1,(PBYTE)&FileInfoBuf,sizeof(FILESTATUS));
    readlen = BUFSIZE;
    while (readlen == BUFSIZE) {
	DosRead(source,buffer,BUFSIZE,&readlen);
	DosWrite(dest,buffer,readlen,&readlen);
    }
    DosClose(source);
    DosClose(dest);

    return 0;
}
