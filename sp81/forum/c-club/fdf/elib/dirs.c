#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dir.h>
#include <ctype.h>

#include "elib.h"



/*
 * is_special
 *
 * given a directory name, return non-zero if it is 'special' (i.e. '.' or
 * '..') or zero if it is normal
 */
int is_special(char *d_name)

{
	int d_len;

	if ((d_name == NULL) || ((d_len = strlen(d_name)) > 2))
		return 0;
	else if (d_len == 2)
		return (!strcmp(d_name, ".."));
	else if (d_len == 1)
		return (d_name[0] == '.');
	else	/* null directory name */
		return 0;
}


/*
 * append_dir_to_path
 *
 * given a path and a directory name, return a pointer to memory with
 * the directory appended to the path
 */


char *append_dir_to_path(char *path, char *dir)

{
	static char *dir_sep = PATH_SEPARATOR;
	char *ret_val, sep_byte;
	int path_len, mem_nec;

	mem_nec = (path_len = strlen(path)) +
			  (sep_byte = ((path[path_len-1] != dir_sep[0]) ? 1 : 0)) +
			  strlen(dir) + 1;
	if ((ret_val = malloc((size_t) mem_nec)) == NULL) {
		printf("append_dir_to_path: memory allocation failure!\n");
		exit(-1);
	}
	else {
		strcpy(ret_val, path);
		if (sep_byte)
			strcat(ret_val, dir_sep);
		strcat(ret_val, dir);

		return ret_val;
	}
}


/*
 *	format_dir()
 *
 *	Input:
 *		dir - the directory as specified by user
 *	Output:
 *		formatted_dir - a formatted version of 'dir'
 */

void format_dir(char *dir, char app_slash, char *formatted_dir)
{
	char cur_dir[MAXPATH];
	char other_cwd[MAXPATH];


	getcwd(cur_dir, MAXPATH);
	if (strlen(dir) > 1){
		if (*(dir + 1) == ':'){
			if (isupper(*dir))
				tolower(*dir);
			setdisk(*dir - 'a');
		}
	}
	getcwd(other_cwd, MAXPATH);
	chdir(dir);
	getcwd(formatted_dir, MAXPATH);

	chdir(other_cwd); /* return to cwd of disk to be formatted */

	if ((app_slash) &&
	    (*(formatted_dir + strlen(formatted_dir) - 1) != '\\'))
		strcat(formatted_dir, "\\");
	setdisk(*cur_dir - 'A');
	chdir(cur_dir);
}
