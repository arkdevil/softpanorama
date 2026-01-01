#include <ctype.h>
#include <stdio.h>
#include <string.h>

kill()
{
#include "teco.h"

	int tmp;				/* Scratch variable     */
	int wrk;				/* Another scratch var. */

	tmp=bufptx;				/*  ...end of dlt */
	if (number < 1) while (1) {		/* delete backwrd */
		if (!bufptx) goto axe;
		if (toascii(buffer[--bufptx]) == 13) {
			if (! number++) {
				if (toascii(buffer[bufptx+1]) == 10) {
					bufptx++;
				}
				goto axe;
			}
		}
	}
	if (number > 0) while (1) {		/* delete forward */
		if (tmp+1 > bufptr) goto axe;
		if (toascii(buffer[++tmp]) == 13) {
			if (toascii(buffer[tmp+1]) == 10) ++tmp;
			if (! --number) goto axe;
		}
	}

axe:	memcpy(&buffer[bufptx+1],&buffer[tmp+1],bufptr-bufptx);
	bufptr=bufptr+bufptx-tmp;		/* Show deleted.. */
	if (bufptr < bufptx) {			/* Impose  sanity */
		bufptx=bufptr;			/*  ...stop this  */
	}
	return;					/* Eat more stuff */
}
