#include "window.h"

/***************************************************************
** Get string with window. Creates window large enough for    **
** prompt and string. Uses getwinp to read actual data        **
***************************************************************/
int getswnd(int x1,int y1,char far *prompt,char far *dest,
		char far *frame,unsigned int pattr,int len,
		unsigned int ipad,int far (*scan)(void))
{
int j=0,l;
	while (prompt[j++])						/* count chars in prompt */
		;
	if (len>0) {							/* check for idiots... */
		makewnd(x1,y1,x1+len+j+2,y1+2,frame,pattr,160);
		prtwnd(1,0,prompt,_curntwnd->color); /* show the prompt */
		l=getwinp(j,0,ipad,dest,len,scan); 	/* and make general input */
		closewnd();							/* remove window */
	}
	return l;								/* and return character count */
}
