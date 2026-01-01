#include "window.h"

/*************************************************************
** Shrink window ( zoom backwards ). Not fully tested, but  **
** works fine with step 1 at least. I took easy way out and **
** used closewnd to restore screen finally and release      **
** memory.                                                  **
*************************************************************/
int far shrnkwnd(int step)
{
char s[9],oldtick,far *ticker=(char far *)0x0000046cL;
int x1,y1,x2,y2,cx,cy,y11,y22,far *img,lx,ly,i,timecount=0;
	if (_curntwnd==NULL || step<1)
		return 0;
	img=_curntwnd->space;
	x1=_curntwnd->x1;		x2=_curntwnd->x2;
	y1=y11=_curntwnd->y1;	y2=y22=_curntwnd->y2;
	lx=x2-x1+1; ly=y2-y1;
	cx=x1+(((x2-x1)+1)/2);
	cy=y1+(((y2-y1)+1)/2);
	s[0]=_vgetc(x1,y1);   s[1]=_vgetc(x2-1,y1);  s[2]=_vgetc(x2,y1);
	s[3]=_vgetc(x1,y1+1); s[4]=_vgetc(x1,y1)>>8; s[5]=_vgetc(x2,y1+1);
	s[6]=_vgetc(x1,y2);   s[7]=_vgetc(x2-1,y2);  s[8]=_vgetc(x2,y2);
	oldtick=*ticker;				/* get the initial counter */
	while (oldtick==*ticker)		/* and wait for start of tick */
		;							/* to count size of full tick */
	oldtick=*ticker;				/* get counter again */
	while (oldtick==*ticker)		/* and wait tick to end */
		timecount++;				/* incr. counter by the way */
	timecount>>=1;					/* then divide it with 2 */
	do {
		x1+=step*3; x2-=step*3;
		y1+=step;   y2-=step;
		if (x1>cx-1) x1=cx-1;
		if (x2<cx+1) x2=cx+1;
		if (y1>cy-1) y1=cy-1;
		if (y2<cy+1) y2=cy+1;
		_drawbox(x1,y1,x2,y2,s,s[4]<<8,0);
		for (i=y1;i<=y2;i++) {
			_tovid(_curntwnd->x1,i,img+(i-_curntwnd->y1)*lx,
					x1-_curntwnd->x1);
			_tovid(x2+1,i,img+(i-_curntwnd->y1)*lx+(lx-(_curntwnd->x2-x2)),
					_curntwnd->x2-x2);
		}
		while (y1>y11) {
			_tovid(_curntwnd->x1,y11,img+(y11-_curntwnd->y1)*lx,lx);
			y11++;
		}
		while (y2<y22) {
			_tovid(_curntwnd->x1,y22,img+(ly-(_curntwnd->y2-y22))*lx,lx);
			y22--;
		}
		for (i=0;i<timecount;i++)		/* and then delay about 22 ms */
			;							/* 37 boxes in second... */
	} while (x1<cx-1 || x2>cx+1 || y1<cy-1 || y2>cy+1);
	return closewnd();
}
