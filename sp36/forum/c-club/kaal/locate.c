#include "window.h"

/***************************************************************
** Position cursor to window-relative position. Always return **
** nonzero.                                                   **
***************************************************************/
int far locate(x1,y1) {
	_DL=x1+_curntwnd->vx1;					/* make position */
	_DH=y1+_curntwnd->vy1;					/* window relative */
	_BH=0;
	_AH=2;
	__int__(0x10);						/* and let BIOS do the job */
	return 1;								/* always OK */
}
