//╔═════════════════════════════════════════════════════════════════════════╗
//║                                                                         ║
//║	    Module name	: 	tok_x.c                                     ║
//║   	    Date	: 	5 July 1991                                 ║
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

int tok_x( void )
{
//_______________________________________________

    extern char tmp_str[ 255 ];
//_______________________________________________

    int x;
//_______________________________________________

    strcpy( tmp_str, strtok( NULL, "\xff"));
    if( tmp_str[ 0 ])
    {
	x = atoi( tmp_str );
	if( x < 1 || x > 80 )
	{
	    put_error("Значение X( Xn ) должно лежать периоде от 1 до 80");
	}
	else
	{
	    return x;
	}
    }
    else
    {
	put_error("Команда должна содержать значение X( Xn )");
    }
    return -1;
//_______________________________________________
}