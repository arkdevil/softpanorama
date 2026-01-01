#include <dir.h>

/*
 * cmptime
 *
 * given two files, return positive if the first has a more recent modification
 * date/time, zero if the files have the same modification date/time or
 * negative if the second is more recent.
 */
long cmptime(const struct ffblk *a, const struct ffblk *b)
{
	return (((unsigned long)a->ff_fdate) << 16 | (unsigned long)a->ff_ftime) -
		   (((unsigned long)b->ff_fdate) << 16 | (unsigned long)b->ff_ftime);
}
