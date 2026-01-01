#include "window.h"
#define toupp(c) ((((c)>='a')&&((c)<='z'))?(c)-32:(c))

/***************************************************************
** Raw menu engine. Expects the array of MEITEM structures    **
** passed with address of first element. Caller has responsi- **
** bility to preserve screen contents if neccesary.           **
** Returns item selected if CR is pressed, negative item      **
** number if ESC is pressed and 0 on error ( illegal input    **
** parameters, no memory ).                                   **
***************************************************************/
int far rawmenu(int items,int def,MEITEM far menu[],int leavebar,
					int far (*scan)(int curnt))
{
int i,j=0,k;
int far *s;
char far *t;
MEITEM *mi;
	if (items<1)							/* must be something */
		return 0;							/* to select */
	for (i=0;i<items;i++)					/* check out all items */
		if (menu[i].xlen>j)					/* to see how many */
			j=menu[i].xlen;					/* space we need for longest */
	if (def<1)
		def=1;
	if (def>items)
		def=items;
	s=_mymalloc((j+1)*sizeof(int));			/* try to get some memory */
	if (s==NULL)							/* got it? */
		return 0;							/* nope, fail */
	for (i=0;i<items;i++) {
		t=(char *)s;						/* temp pointers */
		mi=&menu[i];
		if (mi->textoff>mi->xlen) {			/* if text offset */
			_myfree(s);						/* exceeds field length */
			return 0;						/* we fail */
		}
		for (j=0;j<mi->textoff;j++)
			*t++=' ';						/* fill with blanks */
		for (j=0;j<mi->xlen-mi->textoff;j++) {
			if (!mi->text[j])
				break;
			*t++=mi->text[j];				/* copy string */
		}
		for (j=j+mi->textoff;j<mi->xlen;j++)
			*t++=' ';						/* clear remaining space */
		*t='\0';							/* terminate sting */
		_vputs(mi->x,mi->y,(char *)s,mi->normcolor);
		_vputc(mi->x+mi->textoff+mi->highoff,mi->y,
				mi->text[mi->highoff]+(mi->hicolor<<8));
	}
	k=0;									/* initialize check */
	do {
		if (k!=def) {
			if (k!=0)						/* if not first time put back */
				_tovid(mi->x,mi->y,s,mi->xlen);
			mi=&menu[def-1];				/* working with new item */
			_fromvid(mi->x,mi->y,s,mi->xlen);
			_recolor(mi->x,mi->y,mi->xlen,mi->invcolor);
			k=def;							/* and save checker */
		}
		j=(*scan)(def)&255;					/* keep only meaningful stuff */
		j=toupp(j);							/* in upper case */
		i=def-1;							/* set up for CR or ESC */
		switch (j) {
			case '+':
				if (++def>items)			/* bump to next */
					def=1;					/* and skip over end */
				break;
			case '-':
				if (--def<1)				/* bump to previous */
					def=items;				/* and skip over end */
				break;
			case 0x0d:
				goto getout;				/* k==def, so just get out */
			case 0x1b:
				k=-def;						/* negative value on ESC */
				goto getout;
		}
		for (i=0;i<items;i++) {
			if (j==toupp(menu[i].text[menu[i].highoff])) {
				k=i+1;						/* match, set up return value */
getout:			_tovid(mi->x,mi->y,s,mi->xlen);
				_myfree(s);					/* give up space */
				if (leavebar) {
					mi=&menu[i];			/* if leaving bar, redraw it */
					_recolor(mi->x,mi->y,mi->xlen,mi->invcolor);
				}
				return k;					/* and go back */
			}
		}
	} while (1);							/* endless loop ... */
}
