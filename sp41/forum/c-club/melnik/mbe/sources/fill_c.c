//╔═════════════════════════════════════════════════════════════════════════╗
//║                                                                         ║
//║	    Module name	: 	fill_c.c                                    ║
//║   	    Date	: 	3 July 1991                                 ║
//║    	    Environment	: 	Turbo C++ 1.0                               ║
//║    	    Language    :       Turbo C                                     ║
//║    	    Author	: 	Melnik Oleg                                 ║
//║    	    Notice	:                                                   ║
//║                                                                         ║
//╚═════════════════════════════════════════════════════════════════════════╝

#include	"mbe.h"
//_______________________________________________

void fill_c( void )
{
//_______________________________________________

     int ch;
     int x;
     int y;
     int xn;
     int yn;
     int foreground;
     int background;
//_______________________________________________

     ch = tok_char();
     x  = tok_x();
     y  = tok_y();
     xn = tok_x();
     yn = tok_y();
     foreground = tok_foreground();
     background = tok_background();
     check_x_range( x, xn );
     check_y_range( y, yn );
     fill( ch, x, y, xn, yn, foreground, background );
//_______________________________________________
}