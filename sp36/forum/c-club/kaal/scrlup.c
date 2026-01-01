#include "window.h"

/***************************************************************
** Scroll contents of window up one line                      **
***************************************************************/
int far scrollup(unsigned int charattr)
{
int y1,y2,x1,l,cols,far *t;
	if (_curntwnd==NULL)
		return 0;
	y1=_curntwnd->vy1;
	y2=_curntwnd->vy2;
	x1=_curntwnd->vx1;
	l=_curntwnd->vx2-x1+1;
	if (l>0) {
		DVbeginc();
		t=_scrbase();
		_AH=0x0f;
		__int__(0x10);
		cols=_AX>>8;
		t+=y1*cols+x1;
		while (y1<y2) {
			_fromvid(x1,y1+1,t,l);
			y1++;
			t+=cols;
		}
		if (y1==y2)
			_vlwrite(x1,y2,charattr,l);
		DVendc();
	}
	return 1;
}
