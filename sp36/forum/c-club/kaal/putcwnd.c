#include "window.h"

/***************************************************************
** TTY-like character output, uses current window colour.     **
** Returns 0 if no window exist, else returns 1.              **
** Not that this is sslooowww compared to another functions!  **
***************************************************************/
int far putcwnd(int c)
{
register int x,y;
int ww,wh,color,i;
	if (_curntwnd==NULL)
		return 0;
	c&=255;
	x=_curntwnd->cursor&255;
	y=_curntwnd->cursor>>8;
	color=(_curntwnd->color<<8);
	ww=_curntwnd->vx2-_curntwnd->vx1;
	wh=_curntwnd->vy2-_curntwnd->vy1;
	switch (c) {
		case 13:
			x=0;
			break;
		case 10:
			y++;
			if (y>wh) {
				scrollup(color+32);
				y=wh;
			}
			break;
		case 8:
			if (x>0)
				x--;
			break;
		case 7:
			__emit__(0x55);		/* push BP */
			_AX=0x0e07;
			__int__(0x10);
			__emit__(0x5d);		/* pop BP */
			break;
		case 9:
			i=8-(x%8);
			while (i) {
				putcwnd(' ');
				i--;
			}
			return 1;
		default:
			if (x<0)
				x=0;
			if (x>ww) {
				x=0;
				y++;
			}
			if (y<0)
				y=0;
			if (y>wh) {
				scrollup(color+32);
				y=wh;
			}
			_vputc(_curntwnd->vx1+x,_curntwnd->vy1+y,color+c);
			x++;
			break;
	}
	_curntwnd->cursor=(y<<8)+(x&255);
	if (x>ww)
		x=ww;
	x+=_curntwnd->vx1;
	y+=_curntwnd->vy1;
	_DX=(y<<8)+(x&255);
	_BH=0;
	_AH=2;
	__int__(0x10);
	return 1;
}
