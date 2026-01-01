#include "window.h"

/***************************************************************
** Pop window pointer back to next level. Return 0 if there is**
** no window, or this is last window, else returns 1.         **
***************************************************************/
int far popwnd(void)
{
	if (_curntwnd==NULL || _curntwnd->next==NULL)
		return 0;
	_curntwnd=_curntwnd->next;
	_DX=_curntwnd->pushcursor;
	_BH=0;
	_AH=2;
	__int__(0x10);
	return 1;
}
