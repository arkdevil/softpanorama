#include "window.h"

/*******************************************************************
** Validate/set video mode. Return mode number or -1 if display   **
** in unsupported mode and newmode was -1. Else force display to  **
** newmode (which must be valid video mode) and return mode.      **
*******************************************************************/
int far vidmode(int newmode)
{
	if (newmode==-1) {
validmode:
		_AH=0x0f;
		__int__(0x10);
		if (_AL<4 || _AL==7)
			return (int)_AL;
		else
			return -1;
	}
	_AX=newmode;
	__int__(0x10);
	goto validmode;
}
