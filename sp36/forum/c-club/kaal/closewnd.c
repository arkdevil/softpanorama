#include "window.h"

/***************************************************************
** Close window. Returns 1 if OK, 0 if no window to close.    **
***************************************************************/
int far closewnd(void)
{
WINDOW far *wx;
int room,i,y;
int far *s;
	if (_curntwnd==NULL)					/* if we don't have window */
		return 0;							/* then return */
	s=_curntwnd->space;						/* pointer to pure data */
	y=_curntwnd->y2;						/* this is where we must stop */
	room=_curntwnd->x2-_curntwnd->x1+1;		/* this is words per line */
	for(i=_curntwnd->y1;i<=y;i++) {			/* now put the data out */
		_tovid(_curntwnd->x1,i,s,room);		/* line by line */
		s+=room;							/* and adjust pointer */
	}
	_DX=_curntwnd->curpos;					/* get cursor position */
	_BH=0;
	_AH=2;
	__int__(0x10);							/* and put it back where it was */
	_CX=_curntwnd->cursize;
	_AH=1;
	__int__(0x10);							/* same goes to size */
	wx=_curntwnd;
	_curntwnd=wx->last;						/* strip the window off the */
	_curntwnd->next=NULL;					/* list */
	_myfree(wx);							/* and free the memory */
	return 1;
}
