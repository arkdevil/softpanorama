#include "window.h"

/***************************************************************
** Clear current window. Returns 0 if no window exist, else   **
** returns 1.                                                 **
***************************************************************/
int far clearwnd(unsigned int charattr)
{
int i,l,x;
	if (_curntwnd==NULL)					/* if we don't have any */
		return 0;							/* open windows then leave */
	x=_curntwnd->vx1;						/* else go into frame */
	l=_curntwnd->vx2-x+1;					/* calculate width */
	if (l>0)								/* if anything at all */
		for (i=_curntwnd->vy1;i<=_curntwnd->vy2;i++)
			_vlwrite(x,i,charattr,l);		/* then fill the window */
	return 1;
}
