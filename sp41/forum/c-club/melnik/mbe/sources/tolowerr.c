//╔═════════════════════════════════════════════════════════════════════════╗
//║                                                                         ║
//║	    Module name	: 	tolowerr.c                                  ║
//║   	    Date	: 	4 July 1991                                 ║
//║    	    Environment	: 	Turbo C++ 1.0                               ║
//║    	    Language    :       Turbo C                                     ║
//║    	    Author	: 	Melnik Oleg                                 ║
//║    	    Notice	:                                                   ║
//║                                                                         ║
//╚═════════════════════════════════════════════════════════════════════════╝

#ifndef		_CTYPE_H
#include	<ctype.h>
#endif

#include	"mbe.h"
//_______________________________________________


int tolowerr( int ch )
{
//_______________________________________________

    if( ch < 0x80 )
    {
	ch = tolower( ch );
    }
    else if( ch > 0x7f && ch < 0x90 )
    {
	ch += 0x20;
    }
    else if( ch > 0x8f && ch < 0xa0 )
    {
	ch += 0x50;
    }
    else if( ch == 0xf0 )
    {
	ch = 0xf1;
    }
    return ch;
//_______________________________________________
}