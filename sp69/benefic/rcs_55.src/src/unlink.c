/* DOS version of UNIX compatible unlink()
 *
 * Unlinks a file even if its attributes say READ-ONLY.
 *
 * NOTE: SMALL MEMORY MODEL ONLY
 */

#pragma inline

#include <dos.h>

static char RCSid[] = "$Id: unlink.c%v 1.2 1991/08/23 14:46:21 SGP Exp $";

int unlink (const char *fname)
{
	/* Set file attributes to allow READ AND WRITE access */

	asm	{
		mov		cx,0;				// Read & Write
		mov		dx,fname;
		mov		ax,4301h;			// DOS Set File Attribute
		int		21h;
	};

	/* Delete the file */

	asm {
		mov		dx,fname;
		mov		ah,41h;				// Delete file
		int		21h;
		jc		delete_failed;
	};

	return (0);

delete_failed:

	return (_AX);
}
