#include <ctype.h>
#include <stdio.h>
#include <string.h>
next() /* Search file for (alt terminated) string */
{
#include "teco.h"

	while (bufptr) {			/* Scan thru file */
		search();			/*  ... scan page */
		if (bufptx) break;		/* Found the item */
		page();				/*  ... next page */
	}
}
