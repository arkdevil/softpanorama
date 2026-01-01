#include <io.h>

/*
 *	copy_file_dates()
 *
 *	Input:
 *		src_handle - handle of source file
 *		dst_handle - handle of destination file
 *	Comments:
 *		copies the date and time from one file to another
 */

void copy_file_dates(int src_handle, int dst_handle)
{
	struct ftime ftime_buf;

	getftime(src_handle, &ftime_buf);
	setftime(dst_handle, &ftime_buf);
}

