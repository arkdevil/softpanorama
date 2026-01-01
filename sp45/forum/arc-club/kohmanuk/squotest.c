/*
	Test for squo.c package
*/


#include <stdio.h>
#include <alloc.h>
#include <time.h>


#include "style.h"
#include "squo.h"


/*	Utility Functions
	================= */

void	FreeHeap (void)	{
	printf ("coreleft () = %lu\n", coreleft ());
}


/*	File variables
	============== */

FILE	* inStream, * outStream;


/*	User-supplied i/o functions
	=========================== */

ReadFunc	readf	{
	return	fread (buffer, size, 1, inStream);
}

WriteFunc	writef	{
	return	fwrite (buffer, size, 1, outStream);
}


/*	main ()
	======= */

main (int argc,	char **argv)	{

	int	ErrorFlag = 0,
		PackFlag = 0,
		UnpackFlag = 0;

	char	* inFilename = NULL,
		* outFilename = NULL;

	clock_t	startTime,
		stopTime;

	startTime = clock ();

	printf ("LZ  Version %s  (C)\xFF Compact Soft\n\n", SquoVersion);

	#ifdef	DEBUG
	printf ("Max Distance = %d, Max Length = %d\n"
		"Partial Shift Length = %d\n",
		MD, ML,	SHLEN);
	#endif

	{
		char	** p;

		argc = argc; /* Warning: parameter 'argc' is never used */
		for	(p = argv + 1; *p != NULL; p ++)	{
			switch	((*p) [0])	{
				case	'-':
				case	'/':
					switch	((*p) [1])	{
						case	'u':
							UnpackFlag = 1;
							break;
						case	'p':
							PackFlag = 1;
							break;
						default:
							ErrorFlag = 1;
							break;
					}
					break;
				default:
					if (inFilename == NULL)
						inFilename = *p;
					else if (outFilename == NULL)
						outFilename = *p;
					else
						ErrorFlag = 1;
					break;
			}	/* switch ((*p) [0]) */
		}	/* for (p) */

		if (ErrorFlag || ! (PackFlag ^ UnpackFlag) )	{
			printf (" Usage:\n"
				"	LZ switch infile outfile\n"
				"  Switches:\n"
				"	-p	: packing\n"
				"	-u	: unpacking\n"
			);
			return	1;
		}
	}

	inStream = fopen (inFilename, "rb");
	outStream = fopen (outFilename, "wb");
	if (inStream == NULL || outStream == NULL)	{
		fprintf (stderr, "LZ: Can't open file(s)\n");
		return	1;
	}

	if (PackFlag)	{

	/* use almost all memory for buffers */
	{
		ULONG	bufSize;

		bufSize = (coreleft () - 2048) / 2;
		if (bufSize > 0x7fff)	bufSize = 0x7fff;

		/* !!! small buffers for benchmarking */
		bufSize = 4096;

		FreeHeap ();
		setvbuf (inStream, NULL, _IOFBF, (unsigned) bufSize);
		setvbuf (outStream, NULL, _IOFBF, (unsigned) bufSize);
		FreeHeap ();
	}

	SquoPack (readf, writef);

	} else	{	/* unpacking */

	SquoUnpack (readf, writef);

	}

	fclose (inStream);
	fclose (outStream);

	stopTime = clock ();
	printf ("Elapsed time: %lu ms.\n",
		(stopTime - startTime) * 10000 / 182);

	return	0;
}


/*
	!!! it should be a class:
	ctor allocates buffer (filename and buffer size are params)
		and opens file in unbuffered mode,
	dtor flushes buffer and frees it,
	read gets from buffer (and calls fread if necessary),
	write puts to buffer (and may be flushes it via fwrite);
*/

#if	0

typedef	struct	{
	UBYTE	buf [60000];
	UWORD	used;
	FILE	* file;
}	fileBuffer;

fileBuffer	* readBuffer,
		* writeBuffer;

#endif
