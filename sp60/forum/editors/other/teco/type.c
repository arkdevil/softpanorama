#include <ctype.h>
#include <stdio.h>
#include <string.h>

type()
{
#include "teco.h"

	int tmp;				/* First  scratch */
	int wrk;				/* Second scratch */

	tmp=bufptx;				/* Save context   */
	if (number < 1) while (1) {		/* Position back  */
		if (!tmp) {
			while (++tmp <= bufptx) {
				echo(buffer[tmp]);
			}
			return;			/* All done  type */
		}
		if (toascii(buffer[--tmp]) == 13) {
			if (! number++){/* Start new line */
				if (toascii(buffer[++tmp]) == 10){
					tmp++;
				}
				while(tmp <= bufptx) {
					echo(buffer[tmp++]);
				}
				return;		/* All done  type */
			}
		}
	}
	if (number > 0) while (1) {		/* Type out stuff */
		if (tmp > bufptr) {		/* Type out stuff */
			wrk=bufptx;
			while (++wrk <= bufptr) {
				echo(buffer[wrk]);
			}
			return;			/* All done  type */
		}
		if (toascii(buffer[++tmp]) == 13) {
			if (toascii(buffer[tmp]) == 10) ++tmp;
			if (! --number) {
				wrk=bufptx;
				while (wrk++ < tmp) {
					echo(buffer[wrk]);
				}
				return;		/* All done  type */
			}
		}
	}
}
