//╔═════════════════════════════════════════════════════════════════════════╗
//║                                                                         ║
//║	    Module name	: 	cls_c.c                                     ║
//║   	    Date	: 	3 July 1991                                 ║
//║    	    Environment	: 	Turbo C++ 1.0                               ║
//║    	    Language    :       Turbo C                                     ║
//║    	    Author	: 	Melnik Oleg                                 ║
//║    	    Notice	:                                                   ║
//║                                                                         ║
//╚═════════════════════════════════════════════════════════════════════════╝

#ifndef		_CONIO_H_
#include	<conio.h>
#endif

#include	"mbe.h"
//_______________________________________________

void cls_c( void )
{
//_______________________________________________

     textcolor( tok_foreground());
     textbackground( tok_background());
     clrscr();
//_______________________________________________
}