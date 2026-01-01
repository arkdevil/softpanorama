#include "window.h"

/***************************************************************
** General purpose string input. Returns number of characters **
** got.                                                       **
***************************************************************/
int far getwinp(int x1,int y1,unsigned int pad,char far *dest,
	int len,int far (*scan)(void))
{
int l,def=1,c,wx,wy;
	l=0;
	if (len>0) {							/* for idiots... */
		while (dest[l])
			l++;							/* count chars in default */
		if (l>len) {						/* if longer than legal */
			l=len;							/* then strip off */
			dest[l]='\000';					/* the extra characters */
		}
		wx=_curntwnd->vx1+x1;				/* make it window relative */
		wy=_curntwnd->vy1+y1;
		_vlwrite(wx,wy,pad,len);			/* put out pad chars */
		prtwnd(x1,y1,dest,pad>>8);			/* and then default string */
		do {
			locate(l+x1,y1);				/* position cursor */
			c=(*scan)();					/* scan for character */
			if (c==13)						/* done if CR */
				break;
			if (def || c==27) {				/* if it was ESC or we still */
				l=def=0;					/* had default string */
				*dest='\000';				/* then clear destination space */
				_vlwrite(wx,wy,pad,len);	/* and clean up screen */
			}
			if (c==8) {						/* if BS */
				if (--l<0)					/* then try to decrease count */
					++l;					/* bump it back if fails */
				dest[l]='\000';				/* put line end there */
				_vputc(wx+l,wy,pad);		/* and remove one char */
			}
			else {
				if (c>=' ' && c!='\177' && l<len) {
					dest[l]=c;				/* if character and any space */
					_vputc(wx+l,wy,c|(pad&0xff00));
					l++;					/* then add it to string */
					dest[l]='\000';			/* set new end */
				}							/* and keep going */
			}
		} while (1);
		return l;							/* return character count */
	}
	return 0;								/* or 0 if len was 0 */
}
