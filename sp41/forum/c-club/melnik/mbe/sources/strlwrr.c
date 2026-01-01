//╔═════════════════════════════════════════════════════════════════════════╗
//║                                                                         ║
//║	    Module name	: 	strlwrr.c                                   ║
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


void strlwrr( char *string )
{
//_______________________________________________

     int length;
     int count;
//_______________________________________________

     length = strlen( string );
     for( count = 0; count < length; count++ )
     {
	  string[ count ] = tolowerr( string[ count ]);
     }
//_______________________________________________
}