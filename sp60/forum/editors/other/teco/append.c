#include <ctype.h>
#include <stdio.h>
#include <string.h>
append() /* Append next page into buffer */
{
#include "teco.h"

	char c;
	int croak=(bufsiz/3)*2;

	memset(&buffer[bufptr+1],'\0',bufsiz-bufptr);

	while (1) {
		c=getc(in);
		if (feof(in)) return;
		if (ferror(in)) {
			fprintf(stderr,"?INP, Input error\n\7");
			clearerr(in);
			return;
		}
		buffer[++bufptr]=c;
		c=toascii(c);
		if (c == 12) return;
		if (c == 13 & bufptr > croak) {
			buffer[++bufptr]=getc(in);
			c=toascii(buffer[bufptr]);
			if (c != 10) ungetc(buffer[bufptr--],in);
			return;
		}
	}
}
