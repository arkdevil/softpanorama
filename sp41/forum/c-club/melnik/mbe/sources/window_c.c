//╔═════════════════════════════════════════════════════════════════════════╗
//║                                                                         ║
//║	    Module name	: 	window_c.c                                  ║
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

void window_c( void )
{
//_______________________________________________

     extern char tmp_str[ 255 ];
//_______________________________________________

     int x;
     int y;
     int xn;
     int yn;
     int foreground;
     int background;
     int type;
     int box_ch;
     char type_cod[ 8 ];
     int shadow;
     int fill_ch;
     int foreground_ch;
     int background_ch;
     int d[ 15 ];
     int end_pos;
     int i;
//_______________________________________________

     x  = tok_x();
     y  = tok_y();
     xn = tok_x();
     yn = tok_y();
     foreground = tok_foreground();
     background = tok_background();
     type = tok_int();
     if( type < 0 || type > 99 )
     {
	 put_error("Значение типа окна должно лежать в периоде от 0 до 99");
     }
     switch( type )
     {
	     case  0:  box_ch = tok_char();
		       break;

	     case 99:  tok_str();
		       end_pos = strlen( tmp_str );
		       for( i = end_pos - 1; end_pos < 4; end_pos++ )
		       {
			    tmp_str[ end_pos ] = tmp_str[ i-- ];
			    if( i < 0 )
			    {
				i = 0;
			    }
		       }
		       tmp_str[ 4 ] = 0;
		       strlwr( tmp_str );
		       for( i = 0; i < 4; i++ )
		       {
			    if( tmp_str[ i ] != 's' && tmp_str[ i ] != 'd')
			    {
	      put_error("Код типа окна может содержать только буквы s и d");
			    }
		       }
		       strcpy( type_cod, tmp_str );
		       break;
     }
     shadow = tok_int();
     if( shadow < 0 || shadow > 1 )
     {
	 put_error("Значение тени должно лежать в периоде от 0 до 1");
     }
     check_x_range( x, ( xn + ( shadow * 2 )));
     check_y_range( y, ( yn + shadow ));
     tok_str();
     if( stricmp( tmp_str, "tr") != 0 )
     {
	 fill_ch = tmp_str[ 0 ];
	 foreground_ch = tok_foreground();
	 background_ch = tok_background();
     }
     else
     {
	 fill_ch = 256;
     }
//_______________________________________________

     d[  0 ] = x;
     d[  1 ] = y;
     d[  2 ] = xn;
     d[  3 ] = yn;
     d[  4 ] = foreground;
     d[  5 ] = background;
     d[  6 ] = type;
     d[  7 ] = box_ch;
     d[  8 ] = shadow;
     d[  9 ] = fill_ch;
     d[ 10 ] = foreground_ch;
     d[ 11 ] = background_ch;
     windows( d, type_cod );
//_______________________________________________
}