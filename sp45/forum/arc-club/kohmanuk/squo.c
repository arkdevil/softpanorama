
/*
	Yet Another LZ-compression algorithm
*/


#include <stdio.h>


#include "style.h"
#include "squo.h"


char	SquoVersion [] = "1.5";


#define	dptr	_ds *


/*	Conditional compilation symbols
	=============================== */

#define	BIGTREE		/* use bigger buffer and trees */
#define	PARTSH		/* perform only partial shift */
#define	SHLEN	0	/* length of partial shift (0 = none) */

#if	defined(PARTSH) && (SHLEN == 0)
#define	STATICTREE	/* fast tree with no rearrangement at all */
#endif


/* !!! don't mix HASH and NEWHASH */
#define	noHASH		/* hash second byte for speed search */
#define	NEWHASH		/* hash 2-, 3- and 4-byte sequences */


#define	FASTPACK	/* skip repeating series to prevent slowdowns */


#define	UNPACKER	/* include Unpacker code */


#define	noSTATS		/* collect full statistics */
#define	noDBGSTR		/* generate five not-encoded byte streams */
#define	noDEBUG		/* do diagnostics printouts */


/*	Constants and macros
	==================== */

#ifdef	BIGTREE
#define MT	16
#define	MD	(4096)
#else
#define MT	8
#define	MD	(2048)
#endif

#define	ML	(254+MT)	/* 254 'cause 255 is EOF mark */

#ifdef	HASH
#define	MH		(1 << 3)
#define	Hash(ch)	((ch) & MH - 1)
#endif


#ifdef	DBGSTR
FILE	* len1Stream,
	* len2Stream,
	* dist1Stream,
	* dist2Stream,
	* charStream;
#endif


/*	Statistical variables
	===================== */

#ifdef	STATS

int	ProgressInd = 1;

struct	{
long	Reads,
	Chars,
	Refs,
	LenBits,
	DistBits,
	LenBytes,
	DistBytes,
	BitsOut,
	BytesOut;
}	Total;

long	RefLen  [ML];
long	RefDist [MD / 256];

#endif


/*	File i/o functions
	================== */

/* they are copies of parameters passed to SquoPack() or SquoUnpack () */

ReadFunc	* p_reader;
WriteFunc	* p_writer;


/*	BitBuf variables
	================ */

#define	BITS	16

struct  {
	UWORD	bits;
	UBYTE	bytes [BITS];	/* bits in field 'bits' */

	UBYTE	freeBits,
		dptr freeBytePtr;
}	BitBuf;


/*	Tree variables
	============== */

typedef	struct	{
	UBYTE	codeLen, codeVal;
	}	treeEl;

treeEl	LenTree [MT] = {
#ifdef	BIGTREE
		/* experimental tree-16 for lengths
			01,	10,	11,	0000,
			00100,	00101,	00110,	001110,
			001111,	000111,	0001000,0001001,
			0001010,0001011,0001100,0001101
		*/
			{2, 2},	{2, 1},	{2, 3},	{4, 0},
			{5, 4},	{5,20},	{5,12},	{6,28},
			{6,60},	{6,56},	{7, 8},	{7,72},
			{7,40},{7,104},	{7,24},	{7,88}
#else
		/* self-computed tree-8; !!! no codes */
			{1}, {3}, {3}, {4},
			{4}, {4}, {5}, {5}
#endif
	};

treeEl	DistTree [MT] = {
#ifdef	BIGTREE
		/* experimental tree-16 for distances
			11,	100,	101,	0000,
			0001,	0010,	00110,	00111,
			01000,	01001,	01010,	01011,
			01100,	01101,	01110,	01111

		*/
			{2, 3},	{3, 1},	{3, 5},	{4, 0},
			{4, 8},	{4, 4},	{5,12},	{5,28},
			{5, 2},	{5,18},	{5,10},	{5,26},
			{5, 6},	{5,22},	{5,14},	{5,30}
#else
		/* self-computed tree-8; !!! no codes */
			{1}, {3}, {3}, {4},
			{4}, {4}, {5}, {5}
#endif
	};

	/* 	pointers to corresponding Tree:
		*LenStack [x] is current Huffman code for 'x' */

treeEl	dptr LenStack [MT],
	dptr DistStack [MT];


/*	BitBuf functions
	================ */

/*
tree path:	1011		reversed in table
put code:	1101->CF	shr	al, 1
		CF->databyte	rcr	bx, 1
byte:		xxxx1101->CF	shr	bp, 1
get code:	yy<-CF		rcl	bl, 1
result:		1011		used as index
*/

void	_PutCode (treeEl dptr t);
void	PutCode (treeEl dptr t)	{

	#ifdef	STATS
	Total.BitsOut += t -> codeLen;
	#endif
	#ifdef	DEBUG
	printf ("	%sTree [%d] codeLen: %d codeVal: %d\n",
		t >= DistTree ? "Dist" : "Len",
		t >= DistTree ? t - DistTree : t - LenTree,
		t -> codeLen, t -> codeVal);
	#endif

	_PutCode (t);
}

void	PutByte (UBYTE b)	{

	#ifdef	STATS
	Total.BytesOut ++;
	#endif
	#ifdef	DEBUG
	printf ("	byte: %d [%c]\n", b, b);
	#endif

	* (BitBuf.freeBytePtr ++) = b;
}

void	InitBitBuf (void)	{
	BitBuf.bits = 0;
	BitBuf.freeBits = BITS;
	BitBuf.freeBytePtr = & (BitBuf.bytes [0]);
}

void	FlushBitBuf (void)	{
	p_writer (& BitBuf.bits, sizeof (BitBuf.bits));
	p_writer (& BitBuf.bytes, BitBuf.freeBytePtr - BitBuf.bytes);
	InitBitBuf ();
}

void	DoneBitBuf (void)	{
	BitBuf.bits >>= BitBuf.freeBits;
	FlushBitBuf ();
}


/*	Tree functions
	============== */

void	InitTrees (void)	{
	UWORD	i;

	for (i = 0; i < MT; i ++)	{
		LenStack [i] = & (LenTree [i]);
		DistStack [i] = & (DistTree [i]);
	}
}

void	PutLen (UWORD len)	{
	UWORD	l;

	#ifdef	STATS
		RefLen [len - 1] ++;
	#endif

	l = ( (len >= MT) ? MT : len) - 1;

	PutCode (LenStack [l]);
	#ifdef	STATS
		Total.LenBits += LenStack [l] -> codeLen;
	#endif
	#ifdef	DBGSTR
		fwrite (&l, 1, 1, len1Stream);
	#endif

	if (len >= MT)	{
		PutByte (len - MT);
		#ifdef	STATS
			Total.LenBytes ++;
		#endif
		#ifdef	DBGSTR
			{
				UBYTE	b = len - MT;
				fwrite (&b, 1, 1, len2Stream);
			}
		#endif
	}

	#ifndef	STATICTREE
	{
	UWORD	i;

	for (i = 0; i < MT; i ++)	{
		if (LenStack [i] < LenStack [l]
		#ifdef	PARTSH
		    && LenStack [i] + SHLEN >= LenStack [l]
		#endif
		)
			LenStack [i] ++;
	}
	#ifndef	PARTSH
	LenStack [l] = & (LenTree [0]);
	#else
	if (LenStack [l] - LenTree >= SHLEN)
		LenStack [l] -= SHLEN;
	else
		LenStack [l] = LenTree;
	#endif
	}
	#endif
}

void	PutDist (UWORD dist)	{
	UWORD	d;

	#ifdef	STATS
		RefDist [dist / 256] ++;
	#endif

	d = dist >> 8;

	PutCode (DistStack [d]);
	#ifdef	DBGSTR
		fwrite (&d, 1, 1, dist1Stream);
	#endif

	PutByte (dist & 0xFF);
	#ifdef	STATS
		Total.DistBits += DistStack [d] -> codeLen;
		Total.DistBytes ++;
	#endif
	#ifdef	DBGSTR
		{
			UBYTE	b = dist & 0xFF;
			fwrite (&b, 1, 1, dist2Stream);
		}
	#endif

	#ifndef	STATICTREE
	{
	UWORD	i;

	for (i = 0; i < MT; i ++)	{
		if (DistStack [i] < DistStack [d]
		#ifdef	PARTSH
		    && DistStack [i] + SHLEN >= DistStack [d]
		#endif
		)
			DistStack [i] ++;
	}
	#ifndef	PARTSH
	DistStack [d] = & (DistTree [0]);
	#else
	if (DistStack [d] - DistTree >= SHLEN)
		DistStack [d] -= SHLEN;
	else
		DistStack [d] = DistTree;
	#endif
	}
	#endif
}

void	DoneTrees (void)	{
	/* nothing there */
}


/*	Buffer variables
	================ */

typedef	struct	bufferEl {
	char			c;

	#ifndef	NEWHASH
	struct	bufferEl	dptr next;
	#ifdef	HASH
	struct	bufferEl	dptr next2;
	#endif

	#else
	struct	bufferEl	dptr next_2,
				dptr next_3,
				dptr next_4;
	#endif
} bufferEl;

#ifndef	NEWHASH
typedef	struct	{
	bufferEl	dptr first, dptr last;
	#ifdef	HASH
	struct	hashList	{
		bufferEl	dptr first2, dptr last2;
	}	list2 [MH];
	#endif
} cacheEl;

#define		CacheSize	256
cacheEl		Cache [CacheSize];

#else

typedef	struct	{
	bufferEl	dptr first, dptr last;
}	hashList;


hashList	Hash_2 [512],
		Hash_3 [1024],
		Hash_4 [2048];
#endif

#define	BufferSize	(MD + ML)
bufferEl	Buffer [BufferSize];

bufferEl	dptr BufStart,	/* start of dictionary */
		dptr BufPtr;	/* end of dictionary, start of match */

UWORD		InBuffer;	/* size of dictionary */
UWORD		CharsPastEof;	/* count of garbage chars in Buffer */


/*	Buffer functions
	================ */

#define	Next(p)	( (++p >= & Buffer [BufferSize]) ? (p = Buffer) : p)

#ifndef	NEWHASH
#define	FirstChar	(BufPtr -> c)
#define	SecondChar	(BufPtr < (Buffer + BufferSize - 1) ?	\
			(BufPtr + 1) -> c :			\
			Buffer -> c)
#endif


char	ReadChar (void)	{
	char	ch;

	int	status = p_reader (&ch, 1);

	if (status == 0)	{
		CharsPastEof ++;
                ch = 0;
	}

	#ifdef	STATS
	if (status != 0)	{
		Total.Reads ++;
		if (ProgressInd && (Total.Reads % 1024 == 0))	{
			fprintf (stderr, "@");
		}
	}
	#endif

	return	ch;
}


void	InitBuffer (void)	{
	UWORD	i;
	#ifdef	HASH
	UWORD	j;
	#endif

	#ifndef	NEWHASH
	for (i = 0; i < CacheSize; i ++)	{
		Cache [i].first = Cache [i].last = NULL;

		#ifdef	HASH
		for (j = 0; j < MH; j ++)	{
			Cache [i].list2 [j].first2 =
			Cache [i].list2 [j].last2 = NULL;
		}
		#endif
	}

	#else
	for (i = 0; i < arraySize (Hash_2); i ++)	{
		Hash_2 [i].first = Hash_2 [i].last = NULL;
	}
	for (i = 0; i < arraySize (Hash_3); i ++)	{
		Hash_3 [i].first = Hash_3 [i].last = NULL;
	}
	for (i = 0; i < arraySize (Hash_4); i ++)	{
		Hash_4 [i].first = Hash_4 [i].last = NULL;
	}
	#endif

	CharsPastEof = 0;
	for (i = 0; i < ML; i ++)	{
		Buffer [i].c = ReadChar ();
	}

	BufStart = BufPtr = Buffer;
	InBuffer = 0;
}

void	DoneBuffer (void)	{
	/* write EOF mark */
	PutLen (ML + 1);
}


#ifdef	NEWHASH
typedef	UWORD	HashValue;

#define	UpdateHash(hashVal, ch)	( ((HashValue) (hashVal) << 1) ^ (ch) )
#endif

void	MoveBuf (UWORD len)	{
	for ( ; len > 0; len --)	{
		if (InBuffer >= MD)	{
			/* delete first char from dictionary */

			#ifndef	NEWHASH
			register cacheEl	dptr cp;

			cp = & Cache [BufStart -> c];
			if ( (cp -> first = BufStart -> next) == NULL)
				cp -> last = NULL;

			Next (BufStart);

			#ifdef	HASH
			{
			register struct hashList	dptr lp;

			lp = & ( cp -> list2 [Hash (BufStart -> c)] );
			if ( (lp -> first2 = BufStart -> next2) == NULL)
				lp -> last2 = NULL;
			}
			#endif

			#else
			HashValue	hashVal = 0;
			bufferEl	dptr bp = BufStart;
			hashList	dptr hp;

			hashVal = UpdateHash (hashVal, bp -> c);
			Next (bp);

			hashVal = UpdateHash (hashVal, bp -> c);
			Next (bp);
			hp = & Hash_2 [hashVal];
			if ( (hp -> first = BufStart -> next_2) == NULL)
				hp -> last = NULL;

			hashVal = UpdateHash (hashVal, bp -> c);
			Next (bp);
			hp = & Hash_3 [hashVal];
			if ( (hp -> first = BufStart -> next_3) == NULL)
				hp -> last = NULL;

			hashVal = UpdateHash (hashVal, bp -> c);
			/* extra Next (bp); */
			hp = & Hash_4 [hashVal];
			if ( (hp -> first = BufStart -> next_4) == NULL)
				hp -> last = NULL;

			Next (BufStart);

			#endif
		} else {
			InBuffer ++;
		}

		{
			/* add one new char to dictionary */

			#ifndef	NEWHASH
			register cacheEl	dptr cp;

			cp = & Cache [BufPtr -> c];
			if (cp -> last == NULL)	{
				cp -> first = cp -> last = BufPtr;
			} else {
				cp -> last = cp -> last -> next = BufPtr;
			}
			BufPtr -> next = NULL;

			#else

			bufferEl        dptr bp = BufPtr;
			HashValue	hashVal = 0;
			hashList	dptr hp;

			hashVal = UpdateHash (hashVal, bp -> c);
			Next (bp);

			hashVal = UpdateHash (hashVal, bp -> c);
			Next (bp);
			hp = & Hash_2 [hashVal];
			if (hp -> last == NULL)	{
				hp -> first = hp -> last = BufPtr;
			} else {
				hp -> last = hp -> last -> next_2 = BufPtr;
			}
			BufPtr -> next_2 = NULL;

			hashVal = UpdateHash (hashVal, bp -> c);
			Next (bp);
			hp = & Hash_3 [hashVal];
			if (hp -> last == NULL)	{
				hp -> first = hp -> last = BufPtr;
			} else {
				hp -> last = hp -> last -> next_3 = BufPtr;
			}
			BufPtr -> next_3 = NULL;

			hashVal = UpdateHash (hashVal, bp -> c);
			/* extra Next (bp); */
			hp = & Hash_4 [hashVal];
			if (hp -> last == NULL)	{
				hp -> first = hp -> last = BufPtr;
			} else {
				hp -> last = hp -> last -> next_4 = BufPtr;
			}
			BufPtr -> next_4 = NULL;

			#endif

			/* read next char into buffer's gap */
			{
				bufferEl	dptr bp;

				bp = BufPtr + ML;
				if (bp >= Buffer + BufferSize)	{
					bp -= BufferSize;
				}
				bp -> c = ReadChar ();
			}

			Next (BufPtr);

			#ifndef	NEWHASH
			#ifdef	HASH
			{
			register struct hashList	dptr lp;

			lp = & ( cp -> list2 [Hash (BufPtr -> c)] );
			if (lp -> last2 == NULL)	{
				lp -> first2 = lp -> last2 = BufPtr;
			} else {
				lp -> last2 = lp -> last2 -> next2 = BufPtr;
			}
			BufPtr -> next2 = NULL;
			}
			#endif
			#endif
		}
	}	/* for (len) */
}


#ifdef	STATS
void	PrintWeightedAvg (char * text, long * data, size_t size)	{
	size_t	i;
	long	total;		/* weighted sum of data [size] */
	long	weight;		/* simple sum of -"-*/

	for (total = 0, weight = 0, i = 0; i < size; i ++)	{
		total += i * data [i];
		weight += data [i];
	}
	printf ("%s%ld.%02ld", text,
		total / weight, (total % weight) * 100 / weight);
}

void	PrintStats (void)	{
	UWORD	i;

	printf ("\nTotal:\n"
		"	reads: %07ld"
		"	chars: %07ld"
		"	refs:  %07ld\n"
		"	len: bits: %07ld, bytes: %07ld\n"
		"	dist: bits: %07ld, bytes: %07ld\n"
		"	total: bits: %07ld, bytes: %07ld == %07ld bytes"
			"; %d%% bits left\n",
		Total.Reads,
		Total.Chars,
		Total.Refs,
		Total.LenBits, Total.LenBytes,
		Total.DistBits, Total.DistBytes,
		Total.BitsOut, Total.BytesOut,
		(Total.BitsOut >> 3) + Total.BytesOut,
		100 * (Total.BitsOut + (Total.BytesOut << 3))
		    / (Total.Reads << 3)
		);

	PrintWeightedAvg ("Mean (Dist) = ", RefDist, arraySize (RefDist));
	PrintWeightedAvg ("\tMean (Len - 1) = ", RefLen, arraySize (RefLen));
	printf ("\nRef distances: \n");
	for (i = 0; i < MD / 256; i ++)
		printf (" %05ld%s", RefDist [i], (i + 1) % 8 ? "" : "\n");
	printf ("\nRef lengths: \n");
	for (i = 0; i < ML / 4; i ++)	{
		/* only first quarter -- last are nearly all 0's */
		printf (" %04ld%s", RefLen [i], (i + 1) % 10 ? "" : "\n");
	}
	printf ("\n");
}
#endif


/*	The Packer
	========== */

int	SquoPack (ReadFunc *reader, WriteFunc *writer)	{
	UWORD		len, bestLen;
	bufferEl	dptr start,  dptr bestStart;
	register        bufferEl	dptr p,  dptr bestP;
	#ifdef	HASH
	cacheEl		dptr cp;
	#endif

	#ifdef	DBGSTR
        len1Stream  = fopen ("_l1.lz", "wb");
        len2Stream  = fopen ("_l2.lz", "wb");
        dist1Stream = fopen ("_d1.lz", "wb");
        dist2Stream = fopen ("_d2.lz", "wb");
	charStream  = fopen ("_c.lz", "wb");
	#endif

	p_reader = reader;
	p_writer = writer;

	InitBitBuf ();
	InitTrees ();
	InitBuffer ();

	while (CharsPastEof < ML)	{
		/* the Buffer always contains ML chars in the gap */

		bestLen = 0;
		bestStart = BufStart;	/* the value doesn't matter actually,
					but I want to have it initialized */

		#ifndef	NEWHASH
		#ifndef	HASH
		if ( (start = Cache [FirstChar].first) != NULL)	{
		#else
		if ( (cp = Cache + FirstChar) -> first != NULL
		 && (start = cp -> list2 [Hash (SecondChar)].first2) != NULL) {
		#endif
			do	{

				p = start;
				#ifndef	HASH
				Next (p);
				#endif

				bestP = BufPtr;
				Next (bestP);

				for (len = 1; (++ len) <= ML; )	{
					if (p -> c != bestP -> c)
						break;
					Next (p); Next (bestP);
				}
				len --;
				if (len >= bestLen)	{
					bestLen = len;
					bestStart = start;
				}

			#ifndef	HASH
			} while ( (start = start -> next) != NULL);
			#else
			} while ( (start = start -> next2) != NULL);
			#endif
		}

		#else
		{
		HashValue	hv_2, hv_3, hv_4;

		hv_2 = 0;				p = BufPtr;
		hv_2 = UpdateHash (hv_2, p -> c);	Next (p);
		hv_2 = UpdateHash (hv_2, p -> c);	Next (p);
		hv_3 = hv_2;
		hv_3 = UpdateHash (hv_3, p -> c);	Next (p);
		hv_4 = hv_3;
		hv_4 = UpdateHash (hv_4, p -> c);	/* extra Next (p); */

		if ( (start = Hash_4 [hv_4].first) != NULL)	{
			do	{

				#ifdef	FASTPACK
				/* kludge: skip over repeating series */
				{
				int	step = start - bestStart;

				if (step < 0)
					step += BufferSize;

				if (step < bestLen)
					continue;
				}
				#endif

				p = start;
				bestP = BufPtr;

				for (len = 0; (++ len) <= ML; )	{
					if (p -> c != bestP -> c)
						break;
					Next (p); Next (bestP);
				}
				len --;
				if (len >= bestLen)	{
					bestLen = len;
					bestStart = start;
				}

			} while ( (start = start -> next_4) != NULL);

			if (bestLen < 4)
				bestLen = 0;
		}

		if (bestLen == 0)	{
			if ( (start = Hash_3 [hv_3].first) != NULL)	{
				do	{
					p = start;
					bestP = BufPtr;

					if (p -> c != bestP -> c)
						continue;
					Next (p); Next (bestP);
					if (p -> c != bestP -> c)
						continue;

					bestLen = 3;
					bestStart = start;
				} while ( (start = start -> next_3) != NULL);
			}
		}

		if (bestLen == 0)	{
			if ( (start = Hash_2 [hv_2].first) != NULL)	{
				do	{
					p = start;
					bestP = BufPtr;

					if (p -> c != bestP -> c)
						continue;

					bestLen = 2;
					bestStart = start;
				} while ( (start = start -> next_2) != NULL);
			}
		}

		}
		#endif

		if (bestLen > ML - CharsPastEof)	{
			bestLen = ML - CharsPastEof;
		}

		if (bestLen <= 1)	{
			bestLen = 1;

			#ifdef	DEBUG
				fprintf (stdout, "char %c [%x]\n",
				BufPtr -> c, BufPtr -> c);
			#endif

			PutLen (1);
			PutByte (BufPtr -> c);
			#ifdef	DBGSTR
				{
				char	ch = BufPtr -> c;
				fwrite (&ch, 1, 1, charStream);
				}
			#endif

			#ifdef	STATS
			Total.Chars ++;
			#endif
		} else {
			WORD	dist;

			dist = BufPtr - bestStart;
			if (dist < 0)  dist += BufferSize;
			#ifndef	HASH
			dist --;
			#endif

			#ifdef	DEBUG
				fprintf (stdout, "ref (%d) <-%d\n",
				bestLen, dist + 1);
			#endif

			PutLen	(bestLen);
			PutDist (dist);

			#ifdef	STATS
			Total.Refs ++;
			#endif
                }
		MoveBuf (bestLen);
	} /* while (! eof ()) */

	DoneBuffer ();
	DoneTrees ();
	DoneBitBuf ();

	#ifdef	DBGSTR
        fclose (len1Stream);
        fclose (len2Stream);
        fclose (dist1Stream);
        fclose (dist2Stream);
	fclose (charStream);
	#endif

	#ifdef	STATS
	PrintStats ();
	#endif

	return	0;
}


/*	The Unpacker
	============ */

extern	void	_SquoUnpack (void);

int	SquoUnpack (ReadFunc *reader, WriteFunc *writer)	{

#ifndef	UNPACKER
	printf ("SquoUnpack() not included.\n");
	return	1;
#else
	p_reader = reader;
	p_writer = writer;
	_SquoUnpack ();
	return	0;
#endif
}

