#include <ctype.h>
#include <stdio.h>
#include <string.h>

work()
{
#include "teco.h"

	int iter;				/* Iteration  < > count */
	int prefix;				/* Non-zero if prefix   */
	int sign;				/* Sign  of number      */
	int tmp;				/* Scratch variable     */
	int value;				/* Value of number      */
	int wrk;				/* Another scratch var. */

	append();				/* Read in first buffer */

	bufptx=0;				/* Start at head of bfr */
loop:	cancel=0;				/* Show output  allowed */
	comand();				/* Get the comand strng */
	getptx=0;				/* Start of command buf */
	iter=0;					/* Not any <> iteration */
next:	if (++getptx > getptr) {		/* Any more commands?   */
		if (iter) fprintf(stderr,"?UTC, Unterminated command\n\7");
		goto loop;			/*  ..yes then go again */
	}
	if (getbuf[getptx] == 27) goto next;	/* Punt Delimiter */
	prefix=0;				/* No numeric arg */
	sign=1; 				/* Default  sign  */
	value=1;				/* Default  value */
	if (getbuf[getptx] == '+') {
		sign=1;				/* Positive sign  */
		getptx++;
	} else {
		if (getbuf[getptx] == '-') {
			sign=-1;		/* Negative sign  */
			getptx++;
		}
	}
	tmp=getptx;				/* Start  parse   */
	if (isdigit(getbuf[tmp])) {		/*  ...is number  */
		prefix=1;			/*  ...not deflt  */
		value=0;			/*  ...initialize */
		while (isdigit(getbuf[tmp])) {
			value=value*10+(getbuf[tmp++]-'0');
			}
	} else {
		if (getbuf[tmp] == '.'){	/* Dot means THIS */
			prefix=1;		/*  ....not deflt */
			value=bufptx;		/* Value is  THIS */
			tmp++;			/* Accept it      */
		}
		if (toupper(getbuf[tmp]) == 'B'){
			prefix=1;		/*  ....not deflt */
			value=0;		/* Always is zero */
			tmp++;			/* Accept it      */
		}
		if (toupper(getbuf[tmp]) == 'Z'){
			prefix=1;		/*  ....not deflt */
			value=bufptr;		/* Value is   END */
			tmp++;			/* Accept it      */
		}
	}
	number=sign*value;			/* Specific value */
	getptx=tmp;				/* getptx --> Cmd */

	verb=toupper(getbuf[getptx]);		/* VERB is action */
	if (verb == 27 ) goto next;		/* Missing  verb  */
	if (verb == '=') {			/* Show our globl */
		if (prefix) {
			fprintf(stderr,"%d\n",number);
		} else {
			fprintf(stderr,"?NAE, No arg before =\n\7");
		}
		goto next;			/* punt, all done */
	} else {
	      adverb=toupper(getbuf[getptx+1]);	/* verb qualifier */
	}					/*   ...is adverb */

	if (verb == '>') {			/* End iteration */
		if (!iter)  {			/*  ..must exist */
			fprintf(stderr,"?BNI, Not in iteration\n\7");
			goto loop;		/*  ...flush buf */
		}
		if (--iter) {			/*  ..find start */
			while (getbuf[--getptx] != '<');
		}				/*  ..must exist */
		goto next;			/*  ...continue  */
	}
	if (verb == '<') {			/* Iteration mode */
		if (iter)  {			/*  ...norecursiv */
			fprintf(stderr,"?PDO, Push-down list overflow\n\7");
			goto loop;
		}
		if (!prefix) {			/*  ...no limits  */
			iter=32766;		/*  ...big enuff  */
		} else {			/*  ...use his v  */
			iter=value;		/*  ...supplied   */
		}				/*  ...finished   */
		goto next;			/*  ...have more  */
	}
	if (verb == 'A') {			/* Append a  page */
		while (0 < number--) append();	/*  ...with call  */
		goto next;			/*  ...punt this  */
	}

	if (verb == 'C') {			/* Advance char   */
		bufptx=bufptx+number;		/*  on  request   */
		if (bufptx<0) {			/* Insane request */
			fprintf(stderr,"?POP, pointer off page\n\7");
			bufptx=0;		/* Minimum place  */
			goto loop;		/*  ...abort this */
			}
		if (bufptx>bufptr) {		/* More  insanity */
			fprintf(stderr,"?POP, pointer off page\n\7");
			bufptx=bufptr;		/* Maximum place  */
			goto loop;		/*  ...abort this */
		}
		goto next;			/* Eat some more  */
	}

	if (verb == 'D') {			/* Delete char    */
		if (number == 0) goto next;	/* Must exist     */
		if (number <  0) {		/* Delete backwds */
			bufptx=bufptx+number;	/*  ...back up    */
			number=abs(number);	/*  ...magnitude  */
		}				/*  ...delete for */
		if (bufptx < 0) {		/* Sanity chk #1  */
			fprintf(stderr,"?DTB, Delete too big\n\7");
			goto loop;		/*  ...flush all  */
		}				/*  ...of buffer  */
		if (bufptx+number > bufptr) {	/* Sanity chk #2  */
			fprintf(stderr,"?DTB, Delete too big\n\7");
			goto loop;		/*  ...flush all  */
		}				/*  ...of buffer  */
		memcpy(&buffer[bufptx+1],&buffer[bufptx+number+1],bufptr-bufptx);
		bufptr=bufptr-number;		/* Show deleted.. */
		if (bufptr < bufptx) {		/*  ..not past nd */
			bufptx=bufptr;		/* Impose  sanity */
		}				/*  ..stop  this  */
		goto next;			/*  ...punt this  */
	}
	if (verb == 'E' ) {			/* Buffer  exits  */
		getptx++;			/* Advance pointr */
		if (adverb == 'F') return;	/* Terminate file */
		if (adverb == 'X') {		/* Orderly   exit */
			while (bufptr) page();	/* Write out page */
			return;			/*  ...and leave  */
		}
	      fprintf(stderr,"?IEC, Illegal character '%c' after E\n\7",adverb);	
		goto loop;			/* Punt commands  */
	}
	if (verb == 'F' ) {			/* Replaqe string */
		getptx++;			/* Advance pointr */
		if (adverb=='S' | adverb=='N') {/* ...replace cmd */
			if (1 > number) {
				fprintf(stderr,"?ISA, Illegal search arg\n\7");
				goto loop;
			}
			if (getbuf[++getptx] == 27) goto next;

			while (number--) {	/* Scan from here */
				if (adverb == 'S'){/* Local in scope */
					search();
				} else {	/* Global replace */
					next();
				}
				if (!bufptx) {	/*  ...not  found */
				      tmp=getptx;
				      while (getbuf[++getptx] != 27);
				      getbuf[getptx]='\0';
				      fprintf(stderr,"?SRH, Search failure ");
				      fprintf(stderr,"'%s'\n\7",&getbuf[tmp]);
				      goto loop;
				}
		     tmp=0;
		     while (getbuf[getptx + ++tmp] != 27);
		     memcpy(&buffer[bufptx],&buffer[bufptx+tmp],bufptr-bufptx);
		     bufptr=bufptr-tmp;

		     wrk=0;
		     while (getbuf[getptx + tmp + ++wrk] != 27);
		     wrk--;
		     bufptr++;
		     if (bufptr+wrk > bufsiz) {
			fprintf(stderr,"?MEM, Memory overflow\n\7");
			goto loop;
		     }
		     if (bufptr > bufptx) {
		      memcpy(&buffer[bufptx+wrk],&buffer[bufptx],bufptr-bufptx);
		     }
		     if (wrk > 0) {
			memcpy(&buffer[bufptx],&getbuf[getptx+tmp+1],wrk);
		     }
		     bufptx--;
		     bufptr--;
		     bufptr=bufptr+wrk;
		     bufptx=bufptx+wrk;
		     }
		     while (getbuf[++getptx] != 27);
		     while (getbuf[++getptx] != 27);
		     goto next;
		}
	fprintf(stderr,"?ILL, Illegal command '%c%c'\n\7",verb,adverb);
	goto loop;
	}
	if (verb == 'H' ) {			/* Hole   thingy  */
		getptx++;			/* Advance pointr */
		if (adverb == 'T') {		/* Type the buffr */
			tmp=0;			/* Start at begin */
			while (++tmp<=bufptr ){	/*  ...start list */
				echo(buffer[tmp]);
			}			/*  ...all done   */
			goto next;		/*  ...fetch next */
		}
		if (adverb == 'K') {		/* Kill the bufer */
			bufptr=0;		/* Nothing in it  */
			bufptx=0;		/* Force at end   */
			goto next;		/* Fetch next com */
		}
		fprintf(stderr,"?ILL, Illegal command '%c%c'\n\7",verb,adverb);
		goto loop;			/* Punt the error */
	}

	if (verb == 'I' | verb == 9) {		/* Insert    text */
		if (verb == 'I') ++getptx;	/* Skip 'I'  only */
		tmp=getptx;			/* Grab a pointer */
		if (prefix) {			/* Character inst */
			if (getbuf[tmp] != 27) {
				fprintf(stderr,"?IIA, Illegal insert arg\n\7");
				goto loop;
			}
			bufptr++;
			bufptx++;
			if (bufptr > bufsiz) {
				fprintf(stderr,"?MEM, Memory overflow\n\7");
				goto loop;
			}
			if (bufptr > bufptx) {	/* Sanity  check  */
			memcpy(&buffer[bufptx+1],&buffer[bufptx],bufptr-bufptx);
			}			/* ..only if sane */
			buffer[bufptx]=toascii(number);
			goto next;		/* Eat some  more */
		}
		while (getbuf[++tmp] != 27);	/* Find string nd */
		bufptr++;
		bufptx++;
		if (bufptr+tmp > bufsiz) {
			fprintf(stderr,"?MEM, Memory overflow\n\7");
			goto loop;
		}
		if (bufptr > bufptx) {		/* Sanity  check  */
		memcpy(&buffer[bufptx+tmp-getptx],&buffer[bufptx],bufptr-bufptx);
		}				/* ..only if sane */
		memcpy(&buffer[bufptx],&getbuf[getptx],tmp-getptx);
		bufptx--;			/* Undo the fudge */
		bufptr--;			/*  ...also fudge */
		bufptr=bufptr+tmp-getptx;	/* New buffer siz */
		bufptx=bufptx+tmp-getptx;	/* Position AFTER */
		getptx=tmp;			/* Skip insertion */
		goto next;			/*  ...fetch next */
		}

	if (verb == 'J') {			/* Jump  defaults */
		bufptx=0;			/* ...to zero !!! */
		if (prefix) {			/* Explicit  jump */
			if (number < 0) {	/* Sanity chk  #1 */
				fprintf(stderr,"?POP, Pointer off page\n\7");
				goto loop;	/*  ..insane, abt */
			}
			if (number > bufptr) {	/* Sanity chk  #2 */
				fprintf(stderr,"?POP, Pointer off page\n\7");
				bufptx=bufptr-1;/* Maximum place  */
				goto loop;	/*  ...abort  cmd */
			}
			bufptx=number;		/* Jump  location */
		}
		goto next;			/* punt, all done */
	}
	if (verb == 'K' ) {			/* delete lines   */
		kill();				/*  ...as desired */
		goto next;			/* Eat some more */
	}
	if (verb == 'L') {			/* Line  position */
		line();				/*   ...go for it */
		goto next;			/*   ...work more */
	}
	if (verb == 'N') {			/* Global  search */
		if (1 > number) {
			fprintf(stderr,"?ISA, Illegal search arg\n\7");
			goto loop;
		}
		if (getbuf[++getptx] == 27) {	/* Scan from here */
			goto next;		/*  ..null search */
		}
		while (number--) {		/* Search  counts */
			next();			/* Execute search */
			if (!bufptx) {		/*  ...not found  */
				tmp=getptx;
				while (getbuf[++getptx] != 27);
				getbuf[getptx]='\0';
				fprintf(stderr,"?SRH, Search failure ");
				fprintf(stderr,"'%s'\n\7",&getbuf[tmp]);
				goto loop;
			}
		}
		while (getbuf[++getptx] != 27) {
			bufptx++;
		}
		goto next;
	}
	if (verb == 'P') {			/* Page in buffer */
		if (number < 1) {		/* Illegal  count */
			fprintf(stderr,"?NPA, Negative page argument\n\7");
			goto loop;		/*  ...abort this */
		}
		while(number-- && bufptr)page();/*  ...do   pages */
		goto next;			/* Eat some more  */
	}
	if (verb == 'R') {			/* Backspace char */
		bufptx=bufptx-number;		/*  on  request   */
		if (bufptx<0) {			/* Insane request */
			fprintf(stderr,"?POP, pointer off page\n\7");
			bufptx=0;		/* Minimum place  */
			goto loop;		/*  ...abort this */
		}
		if (bufptx>bufptr) {		/* More insanity  */
			fprintf(stderr,"?POP, Pointer off page\n\7");
			bufptx=bufptr;		/* Maximum place  */
			goto loop;		/*  ...abort this */
		}
		goto next;			/* Eat some more  */
	}
	if (verb == 'S') {			/* Local   search */
		if (1 > number) {
			fprintf(stderr,"?ISA, Illegal search arg\n\7");
			goto loop;
		}
		if (getbuf[++getptx] == 27) {	/* Scan from here */
			goto next;		/*  ..null search */
		}
		while (number--) {		/* Search  counts */
			search();		/* Execute search */
			if (!bufptx) {		/*  ...not found  */
				tmp=getptx;
				while (getbuf[++getptx] != 27);
				getbuf[getptx]='\0';
				fprintf(stderr,"?SRH, Search failure ");
				fprintf(stderr,"'%s'\n\7",&getbuf[tmp]);
				goto loop;
			}
		}
		while (getbuf[++getptx] != 27) {
			bufptx++;
		}
		goto next;
	}
	if (verb == 'T') {			/* Type out stuff */
		type();				/*  ...get typist */
		goto next;			/* Eat more stuff */
	}
	if (verb == 'V') {			/* Verify  lines  */
		verify();			/*  ..verify type */
		goto next;			/* Eat more stuff */
	}
	if (verb == '^' & adverb == 'C') {	/* Flush politely */
		abort();			/*  ..and go away */
	}
	fprintf(stderr,"?ILL, Illegal command '%c'\n\7",verb);
	goto loop;				/* Flush command  */

}
