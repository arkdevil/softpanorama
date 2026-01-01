//╔═════════════════════════════════════════════════════════════════════════╗
//║                                                                         ║
//║	    Module name	: 	setstar_c.c                                 ║
//║   	    Date	: 	5 July 1991                                 ║
//║    	    Environment	: 	Turbo C++ 1.0                               ║
//║    	    Language    :       Turbo C                                     ║
//║    	    Author	: 	Melnik Oleg                                 ║
//║    	    Notice	:                                                   ║
//║                                                                         ║
//╚═════════════════════════════════════════════════════════════════════════╝

#ifndef		_STRING_H_
#include	<string.h>
#endif

#include	"mbe.h"
//_______________________________________________

void setstar_c( void )
{
//_______________________________________________

     extern char tmp_str[ 255 ];
     extern char star_command[ 255 ];
//_______________________________________________

     tok_str();
     strcpy( star_command, tmp_str );
//_______________________________________________
}