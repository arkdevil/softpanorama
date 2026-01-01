
/*
	mkmb.c -- make message "database"
*/

/*
	Message Base Format:
	
		; === header ===
		Signature	db	11h, 'M', 'B', 10h
		DirOffset	dw	?	; file offset of directory
		
		; === messages (C strings) ===
		Message1	db	'line', {10, 'line...',} 0
		Message2	db	'...', 0
		...
		
		; === directory ===
		TotalMsgs	dw	?	; number of messages
		Message1Offset	dw	?	; file offset of 1st message
		Message2Offset	dw	?
		...
		
		<EOF>
*/

#include <stdio.h>
#include <string.h>


typedef	signed char	BYTE;
typedef	signed int	WORD;
typedef	signed long	LONG;
typedef	unsigned char	UBYTE;
typedef	unsigned int	UWORD;
typedef	unsigned long	ULONG;


#define	ProgName	"mkmb"


FILE	* inStream, * outStream;


#define	MAXLINE	1024
#define	MAXMSGS	10240

typedef	ULONG	FILEPOS;

FILEPOS	BasePos = 0;

void	WriteBase (void * data, UWORD size)	{
	fwrite (data, size, 1, outStream);
	BasePos += size;
}

void	BuildBase (void)	{
	static	UBYTE	BaseSign [] = {0x11, 'M', 'B', 0x10};
	FILEPOS	DirOffset = 0;

	FILEPOS	MsgOffs [MAXMSGS];

	UBYTE	instr [MAXLINE + 1], * inp,
                outstr [MAXLINE + 1], * outp;

	int	lines;

	/* writing header */
	WriteBase (& BaseSign, sizeof (BaseSign));
	WriteBase (& DirOffset, sizeof (DirOffset));

	/* writing strings */
	for ( lines = 0 ; lines < MAXMSGS &&
		fgets (instr, MAXLINE, inStream) != NULL ; lines ++ )	{

                /* translate string */
		for (inp = instr, outp = outstr ; * inp != 0 ; inp ++)	{
			switch (* inp)	{
				case	'\\':
					if (inp [1] == 'n')	{
						inp ++;
						* outp ++ = '\n';
					} else	{
						* outp ++ = * inp;
					}
					break;
				case	'\n':
					break;
				default:
					* outp ++ = * inp;
			}
		}
		* outp ++ = 0;

		MsgOffs [lines] = BasePos;
		WriteBase (outstr, strlen (outstr) + 1);
	}

	/* updating header */
	DirOffset = BasePos;
        fseek (outStream, sizeof (BaseSign), SEEK_SET);
	WriteBase (& DirOffset, sizeof (DirOffset));
        fseek (outStream, DirOffset, SEEK_SET);

	/* writing directory */
	WriteBase (& lines, sizeof (lines));
	WriteBase (MsgOffs, lines * sizeof (MsgOffs [0]));
}


/*	main ()
	======= */

int	ErrorFlag = 0,
	CreateFlag = 0;

char	* inFilename = NULL,
	* outFilename = NULL;


main (int argc,	char **argv)	{

	printf (ProgName "  Version 1.0  (C)\xFF Compact Soft\n\n");

	{
		char	** p;
		for	(p = argv + 1; *p != NULL; p ++)	{
			switch	((*p) [0])	{
				case	'-':
				case	'/':
					switch	((*p) [1])	{
						case    'c':
							CreateFlag = 1;
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

		if (ErrorFlag || ! CreateFlag)	{
			printf (" Usage:\n"
				"	" ProgName " switch infile outfile\n"
				"  Switches:\n"
				"	-c	: create database\n"
			);
			return	1;
		}
	}

	inStream = fopen (inFilename, "rt");
	outStream = fopen (outFilename, "wb");
	if (inStream == NULL || outStream == NULL)	{
		fprintf (stderr, ProgName ": Can't open file(s)\n");
		return	1;
	}

        setvbuf (inStream, NULL, _IOFBF, 4096);
        setvbuf (inStream, NULL, _IOFBF, 4096);

	BuildBase ();

	fclose (inStream);
	fclose (outStream);

	return	0;
}
