//╔═════════════════════════════════════════════════════════════════════════╗
//║                                                                         ║
//║	    Module name	: 	tok_y.c                                     ║
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

#ifndef		_STDLIB_H
#include	<stdlib.h>
#endif

#include	"mbe.h"
//_______________________________________________

int tok_y( void )
{
//_______________________________________________

    extern char tmp_str[ 255 ];
//_______________________________________________

    int y;
//_______________________________________________

    strcpy( tmp_str, strtok( NULL, "\xff"));
    if( tmp_str[ 0 ])
    {
	y = atoi( tmp_str );
	if( y < 1 || y > 25 )
	{
	    put_error("Значение Y( Yn ) должно лежать периоде от 1 до 25");
	}
	else
	{
	    return y;
	}
    }
    else
    {
	put_error("Команда должна содержать значение Y( Yn )");
    }
    return  -1;
//_______________________________________________
}