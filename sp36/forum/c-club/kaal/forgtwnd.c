#include "window.h"

/***************************************************************
** "Forget" window to screen, acts like closewnd, but doesn't **
** restore screen contents. Returns 0 if no window exists.    **
***************************************************************/
int far forgetwnd(void)
{
WINDOW far *wx;
	if (_curntwnd==NULL)					/* if we don't have any */
		return 0;							/* windows... */
	wx=_curntwnd;
	_curntwnd=wx->last;						/* else strip it off */
	_curntwnd->next=NULL;					/* the linked list */
	_myfree(wx);							/* and free it's space */
	return 1;
}
