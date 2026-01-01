// Alternative getcwd() for use with RCS as ported to Borland C++
//
// Returns path elements seperated by '/' rather than '\'
//

#include <dir.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

static char RCSid[] = "$Id: getcwd.c%v 1.2 1991/08/23 13:26:54 SGP Exp $";

char *getcwd(char *buf, int buflen)
{
	char buffer[MAXDIR+3];
	char *s, *d, *rbuf = buf;
	int drive = getdisk();

	if (buf == NULL){
		// malloc a buffer for the return value if one isn't supplied
		if ((rbuf = (char *)malloc(MAXDIR+3)) == NULL){
			errno = ENOMEM;
			return (NULL);
		}
	}

	if (getcurdir(0,buffer) < 0){
		// Shouldn't fail - maybe no such device ?!?!?
		errno = ENODEV;
		return (NULL);
	}

	if (buflen-3 < (int)strlen(buffer)){
		// No room in the return buffer
		errno = ERANGE;
		return (NULL);
	}

	// Set up the return value

	rbuf[0] = tolower('A' + drive);
	rbuf[1] = ':';
	rbuf[2] = '/';

	for (s = buffer, d = &rbuf[3]; *s != '\0'; s++)
		*d++ = *s != '\\' ? tolower(*s) : '/';

	*d = '\0';
	errno = 0;
	return (rbuf);
}
