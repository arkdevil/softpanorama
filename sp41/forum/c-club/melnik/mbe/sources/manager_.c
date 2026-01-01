//╔═════════════════════════════════════════════════════════════════════════╗
//║                                                                         ║
//║	    Module name	: 	manager_c.c                                 ║
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

void manager_c( void )
{
//_______________________________________________

     extern char tmp_str[ 255 ];
//_______________________________________________

     int d[ 420 ];
     int count;
//_______________________________________________

     d[ 0 ] = tok_int();
     if( d[ 0 ] < 1 || d[ 0 ] > 100 )
     {
 put_error("Значение количества позиций должно лежать в периоде от 1 до 100");
     }
     for( count = 1; count < ( d[ 0 ] * 4 + 1 );)
     {
	  d[ count++ ] = tok_x();
	  d[ count++ ] = tok_y();
	  d[ count++ ] = tok_int();
	  check_x_range( d[ count - 3 ], d[ count - 1 ]);
	  d[ count++ ] = tok_char();
     }
     d[ count++ ] = tok_foreground();
     d[ count++ ] = tok_background();
     d[ count++ ] = tok_int();
     if( d[ count - 1 ] < 1 || d[ count - 1 ] > d[ 0 ])
     {
put_error("Номер начальной позиции не может быть меньше 0 и больше    количества позиций");
     }
     d[ count ] = tok_int();
     if( d[ count ] < 0 || d[ count ] > 2 )
     {
	 put_error("Значение типа меню должно лежать в периоде от 0 до 2");
     }
     manager( d );
//_______________________________________________
}