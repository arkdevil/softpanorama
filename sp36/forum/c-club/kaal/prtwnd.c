#include "window.h"

/***************************************************************
** Print string to window. Part which goes over right border  **
** is stripped off. Coordinates are relative to active window **
** and 0,0 is on borders. Returns 0 when no open window exist **
** or X1 is out of window righ border.                        **
***************************************************************/
int far prtwnd(int x1,int y1,char far *s,int color)
{
char t[160];
int i;
	if (_curntwnd==NULL || (x1+_curntwnd->vx1)>_curntwnd->vx2)
		return 0;
	for (i=0;i<160;i++) {
		t[i]=s[i];
		if (!t[i])
			break;
	}
	if (i==160)
		t[159]='\000';
	t[(_curntwnd->vx2-_curntwnd->vx1+1)-x1]='\000';
	_vputs(x1+_curntwnd->vx1,y1+_curntwnd->vy1,(char far *)t,color);
	return 1;
}
