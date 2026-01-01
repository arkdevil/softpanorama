#include "window.h"

/***************************************************************
** Scroll contents of window down one line                    **
***************************************************************/
int far scrolldn(unsigned int charattr)
{
int y1,y2,x1,l,cols,far *t;
	if (_curntwnd==NULL)
		return 0;
	y1=_curntwnd->vy1;
	y2=_curntwnd->vy2;
	x1=_curntwnd->vx1;
	l=_curntwnd->vx2-x1+1;
	if (l>0) {
		DVbeginc();				/* critical section, do not task switch */
		t=_scrbase();
		_AH=0x0f;
		__int__(0x10);
		cols=_AX>>8;
		t+=y2*cols+x1;
		while (y2>y1) {
			_fromvid(x1,y2-1,t,l);
			t-=cols;			/* pointer arithmetic! */
			y2--;
		}
		if (y1==y2)
			_vlwrite(x1,y1,charattr,l);
		DVendc();				/* DV rolling again */
	}
	return 1;
}
