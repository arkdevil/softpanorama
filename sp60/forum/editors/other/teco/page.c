#include <ctype.h>
#include <stdio.h>
#include <string.h>
page() /* Push out this page, read next into buffer */
{
#include "teco.h"

	bufptx=0;			/* Initialize start */

	while (++bufptx <= bufptr) {	/* While work to do */
		putc(buffer[bufptx],ot);/* Write out  char  */
		if (ferror(ot)) {
			fprintf(stderr,"?OUT, Output error\n\7");
			clearerr(ot);
		}
	}
	bufptr=0;			/* Buffer now empty */
	bufptx=0;			/*  ..reset context */
	if (feof(in)) {			/* No more to page  */
		fprintf(stderr,"[Eof]\n");
	} else {
		append();		/* Append mt buffer */
		if (buffer[bufptr]  == '\14') fprintf(stderr,"[Page]\n");
	}
}
