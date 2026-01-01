#include <sys/stat.h>



/*
 * delete_file
 *
 * given the name of a file, attempt to delete it and return zero on success,
 * non-zero if not.  'force' parameter, if non-zero, will try to change the
 * mode of a file from read-only to delete it.
 */
int delete_file(char *file, char force)

{
	if (force) {
		struct stat statbuf;

		if ((!stat(file, &statbuf)) && (!(statbuf.st_mode & S_IWRITE)))
			chmod(file, statbuf.st_mode | S_IWRITE);
	}

	return unlink(file);
}

