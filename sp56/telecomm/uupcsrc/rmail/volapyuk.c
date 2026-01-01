
#define isyo(c) ((c) == 0243 || (c) == 0263)
#define iscyrill(c) (((c)&0300) == 0300 || isyo(c))

static unsigned char outtab1[] =
"uabcdefghiiklmnoparstujvxyzsehcxUABCDEFGHIIKLMNOPARSTUJVXYZSEHCX";
static unsigned char outtab2[] =
"`         `      `         ``````         `      `         `````";
/* ATTENTION: [Yy]' already occupied for [Yy]o */

static	 curreg;	/* 0 - LAT; 1 - RUS */

void
init_volapyuk(void)
{
    curreg = 0;
}

void
xt_volapyuk(unsigned char *s, unsigned char *t, int ended)
{
	register int c;
	unsigned ncnt;
	int      regc;

	for(;;) {
		c = *s++;
skip:
		if (c < ' ' && c != '\t' && ended && curreg == 1) {
		    *t++ = '<';
		    *t++ = 'l';
		    *t++ = '>';
		    curreg = 0;
		}
		if( c == '\0' ) {
			*t = '\0';
			return;
		}
		if( c == '<' ) {
			ncnt = 0;
			while( (c = *s++) == '#' )
				ncnt++;
			if( c == 'r'        || c == 'l' ||
			    c == ('r'^0240) || c == ('l'^0240) ) {
				regc = c;
				if( (c = *s++) == '>' )
					ncnt++;
				s--;
				c = regc;
			}
			*t++ = '<';
			while( ncnt-- )
				*t++ = '#';
			goto skip;
		}
		/* Ordinary character */
		if( iscyrill(c) && curreg == 0 ) {
			*t++ = '<';
			*t++ = 'r';
			*t++ = '>';
			curreg = 1;
		} else
		if( (('A' <= c && c <= 'Z') ||
		     ('`' <= c && c <= 'z') )  && curreg == 1 ) {
			*t++ = '<';
			*t++ = 'l';
			*t++ = '>';
			curreg = 0;
		}
		if( iscyrill(c) ) {
			if (isyo(c)) {
				if (c & 020)
					*t++ = 'Y';
				else
					*t++ = 'y';
				*t++ = '`';
			}
			else {
				*t++ = outtab1[c & 077];
				c = outtab2[c & 077];
				if( c != ' ' )
					*t++ = c;
			}
		} else
			*t++ = c;
	}
}

static
struct {
	unsigned char unmod;
	unsigned char mod;
} intab[26] = {
/* a */ 0301, 0321,
/* b */ 0302,    0,
/* c */ 0303, 0336,
/* d */ 0304,    0,
/* e */ 0305, 0334,
/* f */ 0306,    0,
/* g */ 0307,    0,
/* h */ 0310, 0335,
/* i */ 0311, 0312,
/* j */ 0326,    0,
/* k */ 0313,    0,
/* l */ 0314,    0,
/* m */ 0315,    0,
/* n */ 0316,    0,
/* o */ 0317,    0,
/* p */ 0320,    0,
/* q */ 0313,    0,
/* r */ 0322,    0,
/* s */ 0323, 0333,
/* t */ 0324,    0,
/* u */ 0325, 0300,
/* v */ 0327,    0,
/* w */ 0327,    0,
/* x */ 0330, 0337,
/* y */ 0331, 0243,     /* Big Yo is 0263 */
/* z */ 0332,    0,
};

void
xf_volapyuk(unsigned char *s, unsigned char *t)
{
	register int c;
	int  state;
	int peekc, regc, xregc;
	int modc, unmodc;

	state = 0;
	modc = unmodc = 0;
	peekc = -1;
	for(;;) {
		c = (peekc != -1) ? peekc : *s++;
		peekc = -1;
		if( c != '<' ) {
			if( curreg && c == '`' && modc ) {
				c = modc;
				modc = unmodc = 0;
				goto chargot;
			}
			if( unmodc ) {
				s--;
				c = unmodc;
				modc = unmodc = 0;
				goto chargot;
			}
			if( !curreg )
				goto chargot;
			if(        'a' <= c && c <= 'z' ) {
				modc   = intab[c - 'a'].mod;
				unmodc = intab[c - 'a'].unmod;
			} else if( 'A' <= c && c <= 'Z' ) {
				modc   = intab[c - 'A'].mod;
				if( modc ) {
					if (modc == 0243)
						modc |= 020;
					else
						modc |= 040;
				}
				unmodc = intab[c - 'A'].unmod | 040;
			} else
				goto chargot;
			if( modc == 0 ) {
				c = unmodc;
				unmodc = 0;
				goto chargot;
			}
			continue;
		}
		if( unmodc ) {
			s--;
			c = unmodc;
			modc = unmodc = 0;
			goto chargot;
		}
		c = *s++;
		if( c != 'r' && c != 'l' ) {
			s--;
			c = '<';
			goto chargot;
		}
		xregc = c;
		c = *s++;
		if( c == '>' ) {
			curreg = (xregc == 'r');
			continue;
		}
		peekc = xregc;
		s--;
		c = '<';
chargot:
		if( c == '\0' ) {
			*t = '\0';
			return;
		}
		switch( state ) {
		    case 0:
			*t++ = c;
			if( c == '<' )
				state = 1;
			break;

		    case 1:
			if( c == '#' )
				state = 2;
			else {
				*t++ = c;
				state = 0;
			}
			break;

		    case 2:
			if( c == '#' )
				*t++ = c;
			else if( c == 'r'        || c == 'l' ||
				 c == ('r'^0240) || c == ('l'^0240) ) {
				regc = c;
				state = 3;
			} else {
				*t++ = '#';
				*t++ = c;
				state = 0;
			}
			break;

		    case 3:
			if( c != '>' )
				*t++ = '#';
			*t++ = regc;
			*t++ = c;
			state = 0;
		}
	}
}

