#include "window.h"

/*
** Create a status window and leave it onto screen. **********************
*/
int statwnd(char far *s,char far *frame,unsigned int color)
{
int i=0,j=0;
	while (s[i])
		i++;
	j=(i&1)^1;
	if (i&1)
		i++;
	if (makewnd(38-i/2-j,10,42+i/2,14,frame,color,80)) {
		_AH=1;
		_CX=0x2000;
		__int__(0x10);
		prtcwnd(1,s,color);
		return 1;
	}
	return 0;
}
