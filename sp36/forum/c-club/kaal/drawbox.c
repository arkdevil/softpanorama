#include "window.h"

/***************************************************************
** Draw box with upper left corner in X1,Y1;                  **
**               down right corner in X2,Y2;                  **
**               using characters from FRAME string;          **
**               fill attribute in 8 LSB bits of COLOR;       **
**               frame attribute in 8 MSB bits of COLOR.      **
***************************************************************/
void far _drawbox(int x1,int y1,int x2,int y2,char far *frame,
	unsigned int color,int infill)
{
unsigned int l,i;
	l=x2-x1-1;								/* this is length of mid line */
	if (l>0x7fff)
		l=0;								/* just for stupid ones... */
	i=(color*256)|frame[4];					/* to make things faster */
	color&=0xff00;							/* strip off the wrong part */
	_vputc(x1,y1,color|frame[0]);			/* up-left corner */
	_vlwrite(x1+1,y1,color|frame[1],l);		/* upper mid line */
	_vputc(x2,y1,color|frame[2]);			/* up-right corner */
	for (y1++;y1<y2;y1++) {					/* now the lines till bottom */
		_vputc(x1,y1,color|frame[3]);		/* left border */
		if (infill)							/* if we're filling */
			_vlwrite(x1+1,y1,i,l);			/* inside */
		_vputc(x2,y1,color|frame[5]);		/* right border */
	}
	if (y1==y2) {							/* if more  than one line */
		_vputc(x1,y2,color|frame[6]);		/* bottom-left */
		_vlwrite(x1+1,y2,color|frame[7],l);	/* bottom mid line */
		_vputc(x2,y2,color|frame[8]);		/* bottom right */
	}
}
