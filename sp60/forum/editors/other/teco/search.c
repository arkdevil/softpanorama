#include <ctype.h>
#include <stdio.h>
#include <string.h>
search() /* Search for (alt terminated) string */
{
#include "teco.h"

	int match=0;				/* Comparison cnt */
	int tmp;				/* Scratch var #1 */

	bufptx++;				/* Advance to nxt */

	if (getbuf[getptx] == 27) goto done;	/* Found string   */
	while (bufptx <= bufptr ) {		/* Scan the array */
	if (toupper(buffer[bufptx+match]) != toupper(getbuf[getptx+match])) {
			bufptx++;		/* Punt, no match */
			match=0;		/*  ..reset count */
		} else {
			match++;		/* Record a match */
			if (getbuf[getptx+match] == 27) goto done;
		}
	}
	bufptx=0;				/* Pointer to beg */
done:;
}
