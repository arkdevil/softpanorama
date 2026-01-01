#include <stdio.h>

/*
 *	ask_user()
 *
 *	Input:
 *	Output:
 *	Comments:
 */

int ask_user(char *buf)
{
	int done = 0;
	char ans[10];
	int retval;

	while(!done){
		fprintf(stderr, "%s", buf);
		if (gets(ans) != NULL){
			switch(*ans){
				case 'n':
				case 'N':
					retval = 0;
					done = 1;
					break;
				case 'y':
				case 'Y':
					retval = 1;
					done = 1;
					break;
				case 'q':
				case 'Q':
					exit(0);
				default:
					break;
			}
		} else
			exit(-1);
	}
	return(retval);
}
