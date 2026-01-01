
#include	<stdio.h>

#define	NP	251	/* must be *prime* number, <= 256 (so 251 is max) */

FILE	* outStream;

main ()	{
	int		i, j;
	unsigned char	ch;

	outStream = fopen ("_hard_", "wb");
	if (outStream == NULL)	{
		printf ("Can't open file\n");
		return	1;
	}

	for (i = 1; i < NP; i ++)	{
		ch = 0;
		for (j = 1; j < NP; j ++)	{
			ch += ' ';
			fwrite (&ch, 1, 1, outStream);
			ch -= ' ';
			ch = (ch + i) % NP;
		}
	}

	fclose (outStream);

	return	0;
}
