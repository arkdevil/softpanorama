#include <ctype.h>
#include <stdio.h>
#include <string.h>

verify()
{
#include "teco.h"

	int tmp;				/* First  scratch */
	int wrk;				/* Second scratch */

	number=abs(number);			/* Take magnitude */
	tmp=bufptx;				/* Save temporary */
	wrk=number;				/* Save   counter */
	while (1) {				/* Position back  */
		if (!tmp) goto type;		/* Scan back line */
		if (toascii(buffer[--tmp]) == 13) {
			if (! --wrk) {
				if (toascii(buffer[tmp+1]) == 10){
					tmp++;
				}
				goto type;
			}
		}
	}
type:	wrk=bufptx;				/* Save  context  */
	while (1) {				/* Position front */
		if (wrk > bufptr) {		/* Type out stuff */
			while (++tmp < wrk) {
				echo(buffer[tmp]);
			}
			return;		/* all done  type */
		}
		if (toascii(buffer[++wrk]) == 13) {
			if (toascii(buffer[tmp]) == 10) ++wrk;
			if (! --number) {
				while (tmp++ < wrk) {
					echo(buffer[tmp]);
				}
				return;
			}
		}
	}
}
