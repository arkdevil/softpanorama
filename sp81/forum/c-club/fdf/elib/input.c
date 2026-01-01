#include <ctype.h>
#include <stdio.h>



/*
 * skip_whitespace
 *
 * given a string pointer, skip the whitespace and return the pointer to
 * the new spot.
 */
char *skip_whitespace(char *str)

{
	while (isspace(*str))
		str++;

	return str;
}



/*
 * zap_trailing_nl
 *
 * on strings which have been read in using fgets(), take out the trailing
 * newline.  If no newline, read the input stream until one is encountered.
 */
void zap_trailing_nl(char *str, int max_ch, FILE *stream)

{
	int i = strlen(str), ch;

	if ((i > 0) && (str[i-1] == '\n'))
		str[i-1] = '\0';
	else if (i >= max_ch)
		while (((ch = getc(stream)) != EOF) && (ch != '\n'));
}
