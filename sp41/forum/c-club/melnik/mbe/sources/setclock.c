//╔═════════════════════════════════════════════════════════════════════════╗
//║                                                                         ║
//║	    Module name	: 	setclock_c.c                                ║
//║   	    Date	: 	8 July 1991                                 ║
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

void setclock_c( void )
{
//_______________________________________________

     extern char tmp_str[ 255 ];
     extern int  clock_fl;
     extern int  clock_x;
     extern int  clock_y;
     extern int  clock_foreground;
     extern int  clock_background;
     extern char clock_str[ 255 ];
     extern int  clock_str_x;
     extern int  clock_str_y;
     extern int  clock_str_foreground;
     extern int  clock_str_background;
//_______________________________________________

     tok_str();
     strcpy( clock_str, tmp_str );
     clock_str_x = tok_x();
     check_x_range( clock_str_x, strlen( clock_str ));
     clock_str_y = tok_y();
     clock_str_foreground = tok_foreground();
     clock_str_background = tok_background();
     clock_x = tok_x();
     clock_y = tok_y();
     clock_foreground = tok_foreground();
     clock_background = tok_background();
//_______________________________________________
}