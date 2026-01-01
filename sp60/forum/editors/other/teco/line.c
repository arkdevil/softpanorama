#include <ctype.h>
#include <stdio.h>
#include <string.h>

line()
{
#include "teco.h"

	int iter;				/* Iteration  < > count */
	if (number < 1) while (1) {		/* Position back  */
		if (!bufptx) return;		/*  ...all done   */
		if (toascii(buffer[bufptx--]) == 13) {
			if (! number++) {	/* Start new line *
				++bufptx;
				if (toascii(buffer[bufptx+1]) == 10) {
					++bufptx;
				}
				return;
			}
		}
	}
	if (number > 0) while (1) {		/* Position front */
		if (bufptx+1 >= bufptr) return;
		if (toascii(buffer[++bufptx]) == 13) {
			if (toascii(buffer[bufptx+1]) == 10) ++bufptx;
			if (! --number) return;
		}
	}
}
