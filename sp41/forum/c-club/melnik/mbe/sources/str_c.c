//╔═════════════════════════════════════════════════════════════════════════╗
//║                                                                         ║
//║	    Module name	: 	str_c.c                                     ║
//║   	    Date	: 	3 July 1991                                 ║
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

void str_c( void )
{
//_______________________________________________

     extern char tmp_str[ 255 ];
//_______________________________________________

     char string[ 255 ];
     int x;
     int y;
     int foreground;
     int background;
//_______________________________________________

     tok_str();
     strcpy( string, tmp_str );
     x = tok_x();
     y = tok_y();
     foreground = tok_foreground();
     background = tok_background();
     check_x_range( x, strlen( string ));
     sprint( string, x, y, foreground, background );
//_______________________________________________
}