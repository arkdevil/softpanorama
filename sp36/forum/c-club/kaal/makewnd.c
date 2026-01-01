#include "window.h"

/***************************************************************
** Make window, all parameters like for _drawbox.             **
** Returns 0 if out of memory, 1 if OK.                       **
***************************************************************/
int far makewnd(int x1,int y1,int x2,int y2,char far *frame,
	unsigned int color,int zoom)
{
WINDOW far *new;
int room,i,far *s,al,au,ar,ad;
unsigned int j,timecount=0;
char oldtick,far *ticker=(char far *)0x0000046cL;
	room=(y2-y1+1)*(x2-x1+1)*sizeof(int);	/* words for pure data */
	room=room-sizeof(int)+sizeof(WINDOW);   /* for data and info */
	if ((new=_mymalloc(room))==NULL)
		return 0;							/* we're out of memory... */
	new->x1=x1;
	new->y1=y1;								/* save coordinates */
	new->x2=x2;
	new->y2=y2;
	new->vx1=x1+1;							/* viewport coordinates */
	new->vy1=y1+1;
	new->vx2=x2-1;
	new->vy2=y2-1;
	new->color=color;						/* and colours */
	_BH=0;
	_AH=3;
	__int__(0x10);							/* get cursor pos. & loc. */
	new->curpos=_DX;
	new->cursize=_CX;						/* save cursor stuff */
	new->cursor=0;
	new->last=_curntwnd;
	new->next=NULL;							/* adjust pointers */
	_curntwnd->next=new;
	_curntwnd=new;
	s=new->space;							/* this is where we put data */
	room=x2-x1+1;
	for(i=y1;i<=y2;i++) {					/* make it row by row... */
		_fromvid(x1,i,s,room);				/* copy one row */
		s+=room;							/* and update pointer */
	}
	if (zoom>0) {							/* make sure we're growing */
		ar=al=x1+(x2-x1)/2;					/* then calculate where to start */
		au=ad=y1+(y2-y1)/2;
		if (zoom<(au-y1)) {					/* if we're zooming */
			oldtick=*ticker;				/* get the initial counter */
			while (oldtick==*ticker)		/* and wait for start of tick */
				;							/* to count size of full tick */
			oldtick=*ticker;				/* get counter again */
			while (oldtick==*ticker)		/* and wait tick to end */
				timecount++;				/* incr. counter by the way */
			timecount/=3;					/* and get N cycles in tick */
		}
		do {								/* now let's put it out */
			al-=zoom*3;						/* zoom one step */
			ar+=zoom*3;
			au-=zoom;
			ad+=zoom;
			if (al<x1) al=x1;				/* check limits */
			if (ar>x2) ar=x2;
			if (au<y1) au=y1;
			if (ad>y2) ad=y2;
			_drawbox(al,au,ar,ad,frame,color,1); /* draw one box */
			for (j=0;j<timecount;j++)		/* and then delay about 22 ms */
				;							/* 37 boxes in second... */
		} while ((al!=x1) || (ar!=x2) || (au!=y1) || (ad!=y2));
	}
	return 1;
}
