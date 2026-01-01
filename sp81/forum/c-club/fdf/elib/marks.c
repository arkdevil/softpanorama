#include <ctype.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <dir.h>

#include "elib.h"



/*
 * mark_list
 *
 * given a list of numbers (separated by commas with ranges specified by -'s),
 * fill in the given character array with 0's for numbers not specified and
 * 1's for numbers specified.  The size of the character array is also given.
 * Return 0 on success, non-zero means failure, such as an out-of-range number
 * in the given list.
 */
int mark_list(char *num_list, char *mark_list, int max_num)

{
	char *cur_pos, *new_pos;
	int i, j;

	for (i=0; i<max_num; i++)
		mark_list[i] = '\0';

	for (cur_pos = num_list; *cur_pos != '\0'; cur_pos = ++new_pos) {
		if (((i = (int) strtol(cur_pos, &new_pos, 10)) < 1) || (i > max_num) ||
			(new_pos == NULL))
			return 1;
		
		if (*(new_pos = skip_whitespace(new_pos)) == '-') {
			cur_pos = new_pos+1;
			if (((j = (int) strtol(cur_pos, &new_pos, 10)) < i) ||
				(j > max_num) || (new_pos == NULL))
				return 1;
			for (i--, j--; i <= j; i++)
				mark_list[i] = '\1';
		}
		else if (*new_pos == ',')
			mark_list[i-1] = '\1';
		else if (*new_pos ==  '\0') {
			mark_list[i-1] = '\1';
			return 0;
		}
		else if (isdigit(*new_pos)) {
			mark_list[i-1] = '\1';
			new_pos--;
		}
	}

	return 0;
}
