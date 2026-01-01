#include "window.h"

#define toupp(c) ((((c)>='a')&&((c)<='z'))?(c)-32:(c))


/***************************************************************
** Make a point-and-shoot type menu, general purpose is for   **
** pull-down menus. Uses raw menu engine.                     **
***************************************************************/
int far makemenu(int x1,int y1,VMENU far *flags,char far *menu,
	int far (*scan)(int curnt))
{
int total=0,i,l=0,j,maxl=0,choice;
char far *s;
MEITEM far *mi;
	s=menu;
	while (1) {
		if (!*s) {
			if (s!=menu)
				total++;
			if (!(*(++s)))
				break;
			if (maxl<l)
				maxl=l;
			l=0;
		}
		else {
			s++;
			l++;
		}
	}
	if (!total)
		return 0;
	mi=_mymalloc(total*sizeof(MEITEM));
	if (mi==NULL)
		return 0;
	s=menu;
	for (i=0;i<total;i++) {
		mi[i].x=x1+1;
		mi[i].y=y1+i+1;
		mi[i].xlen=maxl+(flags->reserved<<1);
		mi[i].text=s;
		mi[i].normcolor=flags->normcolor;
		mi[i].invcolor=flags->invcolor;
		mi[i].hicolor=flags->hicolor;
		l=0;
		while (s[l])
			l++;
		mi[i].highoff=l-1;
		mi[i].textoff=flags->reserved+((flags->center)?((maxl-l)/2):0);
		for (choice=0;choice<l;choice++) {
			for (j=0;j<i;j++) {
				if (toupp(mi[j].text[mi[j].highoff])==toupp(s[choice]))
					break;
			}
			if (j==i)
				break;
		}
		if (choice!=l)
			mi[i].highoff=choice;
		while (*s++);
	}
	maxl+=flags->reserved<<1;
	if (flags->makenew)
		makewnd(x1,y1,x1+maxl+1,y1+total+1,
			flags->frame,flags->wndcolor,160);
	else
		clearwnd((flags->wndcolor<<8)|flags->frame[4]);
	l=rawmenu(total,flags->defchoice,mi,1,scan);
	if (!flags->leavemenu)
		closewnd();
	return l;
}
