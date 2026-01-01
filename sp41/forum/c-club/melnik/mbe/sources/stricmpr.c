//╔═════════════════════════════════════════════════════════════════════════╗
//║                                                                         ║
//║	    Module name	: 	stricmpr.c                                  ║
//║   	    Date	: 	4 July 1991                                 ║
//║    	    Environment	: 	Turbo C++ 1.0                               ║
//║    	    Language    :       Turbo C                                     ║
//║    	    Author	: 	Melnik Oleg                                 ║
//║    	    Notice	:                                                   ║
//║                                                                         ║
//╚═════════════════════════════════════════════════════════════════════════╝

#ifndef		_STRING_H
#include	<string.h>
#endif

#include	"mbe.h"
//_______________________________________________


int stricmpr( char str1[ 255 ], char str2[ 255 ])
{
//_______________________________________________

    strlwrr( str1 );
    strlwrr( str2 );
    return strcmp( str1, str2 );
//_______________________________________________
}