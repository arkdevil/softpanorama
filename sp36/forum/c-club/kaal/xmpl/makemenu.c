#include "window.h"
#include <dos.h>
#include <bios.h>

char far *menu=
	"First choice\0"
	"Second choice\0"
	"Third choice\0"
	"4th choice\0"
	"Yet another choice\0"
	"The\0"
	"The\0"
	"The\0"
	"23094dfjw efwemf\0"
	"aklsjh aslfjasld kfjasdf laksdjf lsakdjf lkj lkj\0"
	"ABC\0"
	"\0"
;

int far scan(int item)
{
	prtwnd(2,-1,"┤ Use '+' and '-' to move, CR of ESC to leave ├",0x0a);
	item=bioskey(0)&255;
	return item;
}

VMENU flags;

main()
{
	makewnd(0,0,79,24,"░░░░░░░░░",0x0101,80);
	flags.frame=SINGLEFRAME;
	flags.makenew=1;
	flags.center=1;
	flags.wndcolor=0x0a07;
	flags.normcolor=0x07;
	flags.invcolor=0x70;
	flags.hicolor=0x0a;
	flags.leavemenu=1;
	flags.reserved=4;
	flags.defchoice=3;
	flags.defchoice=makemenu(20,6,&flags,menu,&scan);
	flags.defchoice=makemenu(14,5,&flags,menu,&scan);
	flags.defchoice=makemenu(7,2,&flags,menu,&scan);
	flags.center=0;
	flags.defchoice=makemenu(10,12,&flags,menu,&scan);
	flags.defchoice=makemenu(5,3,&flags,menu,&scan);
	bioskey(0);
	while (closewnd())
		;
}
