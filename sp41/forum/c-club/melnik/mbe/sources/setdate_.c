//╔═════════════════════════════════════════════════════════════════════════╗
//║                                                                         ║
//║	    Module name	: 	setdate_c.c                                ║
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

void setdate_c( void )
{
//_______________________________________________

     extern char tmp_str[ 255 ];
     extern int  date_fl;
     extern int  date_x;
     extern int  date_y;
     extern int  date_foreground;
     extern int  date_background;
     extern char date_str[ 255 ];
     extern int  date_str_x;
     extern int  date_str_y;
     extern int  date_str_foreground;
     extern int  date_str_background;
//_______________________________________________

     tok_str();
     strcpy( date_str, tmp_str );
     date_str_x = tok_x();
     check_x_range( date_str_x, strlen( date_str ));
     date_str_y = tok_y();
     date_str_foreground = tok_foreground();
     date_str_background = tok_background();
     date_x = tok_x();
     check_x_range( date_x, 8 );
     date_y = tok_y();
     date_foreground = tok_foreground();
     date_background = tok_background();
//_______________________________________________
}