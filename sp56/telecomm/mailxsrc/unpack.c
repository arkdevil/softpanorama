/*
 * Mail -- a mail program
 *
 * Uncompress batches
 *
 * $Log:	unpack.c,v $
 * Revision 1.2  93/01/04  02:24:35  ache
 * I decide to put all changes into RCS now
 * 
 * Revision 1.1  92/08/24  02:23:07  ache
 * Initial revision
 * 
 */

#include "rcv.h"
#include <stdio.h>

/*NOXSTR*/
static char rcsid[] = "$Header: unpack.c,v 1.2 93/01/04 02:24:35 ache Exp $";
/*YESXSTR*/

#ifdef  UNPACK_MAILBOX
long SaveSeek = 0L;
long SaveOld = 0L;
static char line[LINESIZE];
static int InHeader = 0;
static int len;
static int uuerror = 0;
static int fperror = 0;
static int EofFlag = 0;
static int nm = 0;
static error(), uuDecodeLine(), outdec(), CTuuDecodeLine(), pack(), fpbstart(), fpbread();

static unsigned char koi8alt[] = {
	0xb0, 0xb1, 0xb2, 0xb3, 0xb4, 0xb5, 0xb6, 0xb7,
	0xb8, 0xb9, 0xba, 0xbb, 0xbc, 0xbd, 0xbe, 0xbf,
	0xc0, 0xc1, 0xc2, 0xc3, 0xc4, 0xc5, 0xc6, 0xc7,
	0xc8, 0xc9, 0xca, 0xff, 0xcc, 0xcd, 0xce, 0xcf,
	0xd0, 0xd1, 0xd2, 0xf1, 0xd4, 0xd5, 0xd6, 0xd7,
	0xd8, 0xd9, 0xda, 0xdb, 0xdc, 0xdd, 0xde, 0xdf,
	0xd3, 0xf3, 0xf2, 0xf0, 0xf4, 0xf5, 0xf6, 0xf7,
	0xf8, 0xf9, 0xfa, 0xfb, 0xfc, 0xfd, 0xfe, 0xcb,
	0xee, 0xa0, 0xa1, 0xe6, 0xa4, 0xa5, 0xe4, 0xa3,
	0xe5, 0xa8, 0xa9, 0xaa, 0xab, 0xac, 0xad, 0xae,
	0xaf, 0xef, 0xe0, 0xe1, 0xe2, 0xe3, 0xa6, 0xa2,
	0xec, 0xeb, 0xa7, 0xe8, 0xed, 0xe9, 0xe7, 0xea,
	0x9e, 0x80, 0x81, 0x96, 0x84, 0x85, 0x94, 0x83,
	0x95, 0x88, 0x89, 0x8a, 0x8b, 0x8c, 0x8d, 0x8e,
	0x8f, 0x9f, 0x90, 0x91, 0x92, 0x93, 0x86, 0x82,
	0x9c, 0x9b, 0x87, 0x98, 0x9d, 0x99, 0x97, 0x9a,
};

#define ESC '~'

static char dectab [93] = {
	0,	1,	2,	3,	4,	5,	6,	7,
	8,	9,	10,	11,	12,	13,	14,	15,
	16,	17,	18,	19,	20,	21,	22,	23,
	24,	25,	26,	27,	28,	29,	30,	31,
	32,	33,	34,	35,	36,	37,	38,	39,
	40,	41,	42,	43,	44,	45,	46,	47,
	48,	49,	50,	51,	52,	53,	54,	55,
	56,	57,	58,	0,	59,	60,	61,	0,
	62,	63,	64,	65,	66,	67,	68,	69,
	70,	71,	72,	73,	74,	75,	76,	77,
	78,	79,	80,	81,	82,	83,	84,	85,
	86,	87,	88,	89,	90,
};

static int uuget (), CTuuget ();
/* single character decode */
#define DEC(c)	(((c) - ' ') & 077)
static unsigned char uubuf[256];
static int uuptr = -1;
static int max_uuptr;
static int uuEOF = 0;

static uuget (f)
FILE *f;
{
	if (uuEOF)
		return EOF;

	if (uuptr >= 0 && uuptr < max_uuptr) {
		return uubuf[uuptr++];
	} else {
		if (GetMailboxLine (line, f) < 0) {
			uuerror = 1;
			uuptr = -1;
			uuEOF = 1;
			return EOF;
		}
		if ((max_uuptr = uuDecodeLine (uubuf, f)) < 0) {
			uuptr = -1;
			uuEOF = 1;
			return EOF;
		}
	}
	uuptr = 0;
	return uubuf[uuptr++];
}

SetUncompress (in)
FILE *in;
{
	uuptr = -1;
	uuEOF = 0;
	uuerror = 0;
	fperror = 0;

	for (;;) {
		if (GetMailboxLine(line, in) < 0) {
			error (ediag("No 'begin' line in message",
				     "В письме нет строки 'begin'"));
			uuerror = 1;
			return -1;
		}

		if (ishead(line)) {
			error (ediag("No 'begin' or 'start' line in message",
				     "В письме нет ни строки 'begin', ни строки 'start'"));
			return -1;
		}
		if (strncmp(line, "begin", 5) == 0) {
			if (fpbstart (uuget, in) < 0)
				return -1;
			return 0;
		}

		if (strncmp(line, "start", 5) == 0) {
			if (fpbstart (CTuuget, in) < 0)
				return -1;
			return 0;
		}
	}
}

UncompressError ()
{
	if (uuerror || fperror)
		return 1;
	return 0;
}

GetUncompressLine (s)
char s[];
{
	int sz, i, ch;
	unsigned char buf;

	for (i = 0 ; i < LINESIZE-1 ; i++) {
		if (fpbread(&buf, 1, 1) != 1) {
			ch = EOF;
		} else {
			ch = buf;
#ifdef MSDOS
			if (ch & 0x80)
				ch = koi8alt[ch & 0x7f];
#endif
		}
		if (ch == '\n') {
			s[i] = ch;
			s[i+1] = 0;
			return i+1;
		} else if (ch == EOF) {
			return -1;
		} else
			s[i] = ch;
	}

	error(ediag("Line in mailbox is too long",
		    "Слишком длинная строка в почтовом ящике"));
	s[i] = 0;
	return i;
}

static int uuDecodeLine(out, f)
char *out;
FILE *f;
{
	char *p;
	char *bp;
	int m, n;

	/* for each input line */
	if (!strcmp(line, "end")) {
		error(ediag("Short message", "Письмо короче, чем ожидалось"));
		uuerror = 1;
		uuEOF = 1;
		return -1;
	}
	m = n = DEC(line[0]);
	if (n <= 0) {
		if (GetMailboxLine (line, f) < 0 || strncmp(line, "end", 3)) {
			uuerror = 1;
			error (ediag("No 'end' line in message",
				     "В письме нет строки 'end'"));
		}
		return -1;
	}

	bp = &line[1];

	while (n > 0) {
		outdec(bp, out, n);
		bp += 4;
		out += 3;
		n -= 3;
	}

	return m;
}

/*
 * output a group of 3 bytes (4 input characters).
 * the input chars are pointed to by p, they are to
 * be output to file f.  n is used to tell us not to
 * output all of them at the end of the file.
 */

static outdec(p, buf, n)
char *p;
char *buf;
{
	int c1, c2, c3;

	c1 = DEC(*p) << 2 | DEC(p[1]) >> 4;
	c2 = DEC(p[1]) << 4 | DEC(p[2]) >> 2;
	c3 = DEC(p[2]) << 6 | DEC(p[3]);
	if (n >= 1)
		*(buf++) = c1;
	if (n >= 2)
		*(buf++) = c2;
	if (n >= 3)
		*(buf++) = c3;
}

static CTuuget (f)
FILE *f;
{
	if (uuEOF)
		return EOF;

	if (uuptr >= 0 && uuptr < max_uuptr) {
		return uubuf[uuptr++];
	} else {
		if (GetMailboxLine (line, f) < 0) {
			uuerror = 1;
			uuptr = -1;
			uuEOF = 1;
			return EOF;
		}
		if ((max_uuptr = CTuuDecodeLine (uubuf)) < 0) {
			uuptr = -1;
			uuEOF = 1;
			return EOF;
		}
	}
	uuptr = 0;
	return uubuf[uuptr++];
}

static int CTuuDecodeLine(out)
char *out;
{
	char *p, *np;
	int m, n, len;

	np = out;

	for (len = strlen(line) ; len > 0 && line[len-1] == ' ' ; len--);

	if (len == 0 || ishead(line)) {
		uuerror = 1;
		error (ediag("No 'end' line in message",
			     "В письме нет строки 'end'"));
		return -1;
	}

	if (len == 4 && !strncmp(line, "end\n", 4)) {
		uuEOF = 1;
		return -1;
	}

	for (p = line; len > 3; len -= 16, p += 16) {

		if (*p == ESC) {
			m = *++p - 'A';
			if (m <= 0 || m > 12) {
				error (ediag("Invalid record in message",
					     "В письме неверная последовательность"));
				return -1;
			}
			++p;
			len -= 2 + (m*8 + 12) / 13 * 2;
		} else
			m = 13;

		pack (p, np);
		np += m;
	}

	return np-out;
}

static pack (p, s)
char *p;
register char *s;
{
	int w [8];
	char b [16];
	register i, c;

	for (i=0; i<16; ++i) {
		c = *p++;
		if (c<'!' || c>'}')
			b[i] = 0;
		else
			b[i] = dectab [c - '!'];
	}
	for (i=0, p=b; i<8; ++i, p+=2)
		w[i] = p[0] * 91 + p[1];
	*s++ = w[0] >> 5;
	*s++ = w[0] << 3 | w[1] >> 10 & 07;
	*s++ = w[1] >> 2;
	*s++ = w[1] << 6 | w[2] >> 7 & 077;
	*s++ = w[2] << 1 | w[3] >> 12 & 01;
	*s++ = w[3] >> 4;
	*s++ = w[3] << 4 | w[4] >> 9 & 017;
	*s++ = w[4] >> 1;
	*s++ = w[4] << 7 | w[5] >> 6 & 0177;
	*s++ = w[5] << 2 | w[6] >> 11 & 03;
	*s++ = w[6] >> 3;
	*s++ = w[6] << 5 | w[7] >> 8 & 037;
	*s = w[7];
}

static error (s)
char *s;
{
	fputs(s, stderr);
	putc('\n', stderr);
}

GetMailboxLine (s, f)
char *s;
FILE *f;
{
	int i, ch;
#ifdef	MSDOS
	int savret = 0;
#endif

	for (i = 0 ; i < LINESIZE-1; ) {
		ch = getc(f);
#ifdef	MSDOS
		if (ch == '\r') {
			if (!savret)
				savret = 1;
			else
				s[i++] = '\r';
		}
		else
#endif
		if (ch == '\n') {
			s[i++] = ch;
			s[i] = '\0';
			return i;
		} else if (   ch == EOF
#ifdef	MSDOS
			   || ch == CTRL_Z
#endif
			  ) {
#ifdef	MSDOS
			if (savret)
				s[i++] = '\r';
#endif
			s[i] = '\0';
			return -1;
		} else {
#ifdef	MSDOS
			if (savret) {
				s[i++] = '\r';
				savret = 0;
			}
#endif
			s[i++] = ch;
		}
	}
	error(ediag("Line in mailbox is too long",
			"Слишком длинная строка в почтовом ящике"));
	ungetc(ch, f);
	s[i] = '\0';
	return i;
}

# define BITS 	12	/* max bits/code for 16-bit machine */
# undef USERMEM


# define HSIZE	5003		/* 79% occupancy */

static unsigned char magic_header[] = { "\037\235" };   /* 1F 9D */

/* Defines for third byte of header */
#define BIT_MASK	0x1f
#define BLOCK_MASK	0x80
/* Masks 0x40 and 0x20 are free.  I think 0x20 should mean that there is
   a fourth header byte (for expansion).
*/
#define INIT_BITS 9			   /* initial number of bits/code */

static int n_bits;				        /* number of bits/code */
static int maxbits = BITS;		    	/* user settable max # bits/code */
static int maxcode;			        /* maximum code, given n_bits */
static int maxmaxcode = 1 << BITS;	    /* should NEVER generate this code */

# define MAXCODE(n_bits)	((1 << (n_bits)) - 1)

# define MAXSTACK    4000		/* size of output stack */

static unsigned short *codetab /*[HSIZE]*/;

#define tab_prefix	codetab		        /* prefix code for this entry */

static unsigned char *tab_suffix; /* [1<<BITS]; */    /* last char in this entry */

static int free_ent = 0;			    /* first unused entry */

static int getcode();

/*
 * block compression parameters -- after all codes are used up,
 * and compression rate changes, start over.
 */
static int block_compress = BLOCK_MASK;
static int clear_flg = 0;

#define FIRST	257	/* first free entry */
#define	CLEAR	256	/* table clear output code */

static char buf[BITS];

static unsigned char rmask[9] = {0x00, 0x01, 0x03, 0x07, 0x0f, 0x1f, 0x3f, 0x7f, 0xff};

static char *stack /*[MAXSTACK]*/;

static int code, oldcode;
static int finchar;
static int stack_top = MAXSTACK;
static int fromfin = 1;     /* read from finchar */
static int incode;
static int need_continue;
static int offset = 0;
static int size = 0;
static int fpb_init = 0;

static int (* get_proc)();
static FILE * fpb_file;

# define GETC (* get_proc)

static fpbstart (get, f)
int (* get)();
FILE *f;
{
	fperror = 0;
	get_proc = get;
	fpb_file = f;

	if (!fpb_init) {
		stack = calloc(1, MAXSTACK);
		codetab = (unsigned short *)calloc(sizeof(unsigned short), HSIZE);
		tab_suffix = (unsigned char *)calloc(1, 1<<BITS);

		if (stack == NULL || codetab == NULL || tab_suffix == NULL) {
			error(ediag("Cannot allocate memory for uncompress",
				    "Не могу выделить память для распаковки"));
			fperror = 1;
			return -1;
		}

		fpb_init = 1;
	}

	if(maxbits < INIT_BITS) maxbits = INIT_BITS;
	if (maxbits > BITS) maxbits = BITS;
	maxmaxcode = 1 << maxbits;

	if ((GETC(fpb_file) != magic_header[0])
		 || (GETC(fpb_file) != magic_header[1])) {
		fperror = 2;
		error(ediag("Message not in compressed format",
			    "Письмо не в упакованном формате"));
		return -1;
	}
	maxbits = GETC(fpb_file);	/* set -b from file */
	block_compress = maxbits & BLOCK_MASK;
	maxbits &= BIT_MASK;
	maxmaxcode = 1 << maxbits;
	if(maxbits > BITS) {
		fperror = 3;
		error(ediag("Message uncompressed bits overflow",
			    "Переполнились биты для распаковки письма"));
		return -1;
	}

	/*
	 * As above, initialize the first 256 entries in the table.
	 */
	maxcode = MAXCODE(n_bits = INIT_BITS);
	for ( code = 255; code >= 0; code-- ) {
		    tab_prefix[code] = 0;
		    tab_suffix[code] = code;
	}
	free_ent = ((block_compress) ? FIRST : 256 );

	offset = size = 0;

	finchar = oldcode = getcode();
	fromfin = 1;
	stack_top = MAXSTACK;
	need_continue = 0;

	return 0;
}

static fpbget ()
{
	char buf[1];

	if (fpbread (buf, 1, 1) != 1)
		return EOF;
	return buf[0] & 0x7f;
}

static fpbread(buf,size,n)
char * buf;
unsigned size, n;
{
	unsigned cnt = 0;
	unsigned max_cnt = size*n;

	if ( max_cnt == 0 )
		return 0;

	if ( need_continue || stack_top < MAXSTACK ) {
		for ( ; stack_top < MAXSTACK; ) {
			/* printf ("c=%d stack_top=%d cnt=%d\n",stack[stack_top],stack_top,cnt); */
			buf[cnt++] = stack[stack_top++];
			if (cnt >= max_cnt)
				return cnt/size;
		}

		 if ( (code=free_ent) < maxmaxcode ) {
			tab_prefix[code] = (unsigned short)oldcode;
			tab_suffix[code] = finchar;
			free_ent = code+1;
			/* printf (" code=%d oldcode=%d\n",code,oldcode); */
		}

		oldcode = incode;
	}

	if (fromfin)
		buf[cnt++] = finchar;             /* first code must be 8 bits = char */

	fromfin = 0;

	if (cnt >= max_cnt)
		return cnt/size;

	while ( (code = getcode()) != -1 ) {

		/* printf ("code=%d free_ent=%d\n", code,free_ent); */

		if ( (code == CLEAR) && block_compress ) {
			for ( code = 255; code > 0; code -= 4 ) {
				tab_prefix [code-3] = 0;
				tab_prefix [code-2] = 0;
				tab_prefix [code-1] = 0;
				tab_prefix [code] = 0;
			}
			clear_flg = 1;
			free_ent = FIRST - 1;
			if ( (code = getcode ()) == -1 )	/* O, untimely death! */
				return cnt/size;
		}
		incode = code;
		/*
		 * Special case for KwKwK string.
		 */
		if ( code >= free_ent ) {
			stack[--stack_top] = finchar;
			code = oldcode;
		}

		/*
		 * Generate output characters in reverse order
		 */
		while ( code >= 256 ) {
			stack[--stack_top] = tab_suffix[code];
			code = tab_prefix[code];
			/* printf ("code=%d top=%d\n",code,stack_top); */
		}
		stack[--stack_top] = finchar = tab_suffix[code];

		/*
		 * And put them out in forward order
		 */
		for ( ; stack_top < MAXSTACK; ) {
			/* printf ("c=%d top=%d cnt=%d width=%d\n",stack[stack_top],stack_top,cnt,width); */
			buf[cnt++] = stack[stack_top++];
			if (cnt >= max_cnt) {
				need_continue = 1;
				return cnt/size;
			}
		}
		stack_top = MAXSTACK;
		need_continue = 0;

		/*
		 * Generate the new entry.
		 */
		 if ( (code=free_ent) < maxmaxcode ) {
			tab_prefix[code] = (unsigned short)oldcode;
			tab_suffix[code] = finchar;
			free_ent = code+1;
			/* printf ("code=%d oldcode=%d\n",code,oldcode); */
		}
		/*
		 * Remember previous code.
		 */
		oldcode = incode;

		if (cnt >= max_cnt)
			return cnt/size;
    }
	return cnt/size;
}

static int getcode()
{
	register int code;
	static unsigned char buf[BITS];
	register int r_off, bits;
	register unsigned char *bp = buf;
	int ch;

	/* printf ("getcode ()\n"); */
	if ( clear_flg > 0 || offset >= size || free_ent > maxcode ) {
		/*
		 * If the next entry will be too big for the current code
		 * size, then we must increase the size.  This implies reading
		 * a new buffer full, too.
		 */
		if ( free_ent > maxcode ) {
			n_bits++;
			if ( n_bits == maxbits )
				maxcode = maxmaxcode;	/* won't get any bigger now */
			else
				maxcode = MAXCODE(n_bits);
		}
		if ( clear_flg > 0) {
			maxcode = MAXCODE (n_bits = INIT_BITS);
			clear_flg = 0;
		}
		/*
		size = fread( buf, 1, n_bits, fp );
		*/
		for (size = 0 ; size < n_bits ; size++) {
			if ((ch = GETC(fpb_file)) == EOF)
				break;
			buf[size] = ch;
		}

		if ( size <= 0 )
			return -1;			/* end of file */
		offset = 0;
		/* Round size down to integral number of codes */
		size = (size << 3) - (n_bits - 1);
	}
	r_off = offset;
	bits = n_bits;
	/*
	 * Get to the first byte.
	 */
	bp += (r_off >> 3);
	r_off &= 7;
	/* Get first part (low order bits) */
	code = *bp++ >> r_off;
	bits -= (8 - r_off);
	r_off = 8 - r_off;		/* now, offset into code word */
	/* Get any 8 bit parts in the middle (<=1 for up to 16 bits). */
	if ( bits >= 8 ) {
	    code |= *bp++ << r_off;
	    r_off += 8;
	    bits -= 8;
	}
	/* high order bits. */
	code |= (*bp & rmask[bits]) << r_off;
    offset += n_bits;

    return code;
}
#endif  /* UNPACK_MAILBOX */
