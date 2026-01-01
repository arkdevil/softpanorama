#include "window.h"

/***************************************************************
** Print string to center of window line. Both ends are cut   **
** off if going over borders. Line number is relative to      **
** current window. Returns 0 if no open window exist.         **
***************************************************************/
int far prtcwnd(int y1,char far *s,int color)
{
char x[161],far *t;
int l,w;
	if (_curntwnd==NULL)
		return 0;
	t=x;
	for (l=0;l<160;l++)
		t[l]=s[l];
	t[160]='\000';
	w=_curntwnd->vx2-_curntwnd->vx1+1;
	if (w>0) {
		l=0;
		while(t[l])
			l++;
		t+=((l>w) ? (l/2-w/2) : 0);
		t[w]='\000';
		l=0;
		while(t[l])
			l++;
		_vputs((_curntwnd->vx1+w/2)-(l/2),_curntwnd->vy1+y1,t,color);
	}
	return 1;
}
