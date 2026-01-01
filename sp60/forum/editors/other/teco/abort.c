#include <ctype.h>
#include <stdio.h>
#include <string.h>

abort()
{
#include "teco.h"

	fclose(in);				/* Close inp file */
	fclose(ot);				/* Close out file */
	unlink(otpath);				/* Erase tmp file */
	exit(0);				/*  ...sys return */
}
