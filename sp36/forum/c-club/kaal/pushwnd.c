#include "window.h"

/***************************************************************
** Push window pointer back to previous window.               **
** Returns 0 if no window exist or it's the first window, else**
** returns 1.                                                 **
***************************************************************/
int far pushwnd(void)
{
int i;
	if (_curntwnd==NULL || _curntwnd->last==NULL)
		return 0;
	_BH=0;
	_AH=3;
	__int__(0x10);
	i=_DX;
	_curntwnd->pushcursor=_DX;
	_curntwnd=_curntwnd->last;
	i=_curntwnd->cursor;
	_DX=(((i>>8)+_curntwnd->vy1)<<8)+((i&255)+_curntwnd->vx1);
	_BH=0;
	_AH=2;
	__int__(0x10);
	return 1;
}
