//╔═════════════════════════════════════════════════════════════════════════╗
//║                                                                         ║
//║	    Module name	: 	tok_int.c                                   ║
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

int tok_int( void )
{
//_______________________________________________

    extern char tmp_str[ 255 ];
//_______________________________________________

    int integer;
//_______________________________________________

    strcpy( tmp_str, strtok( NULL, "\xff"));
    if( tmp_str[ 0 ])
    {
	integer = atoi( tmp_str );
	if( integer < 0 )
	{
	    put_error("Целое число не может быть меньше нуля");
	}
	else
	{
	    return integer;
	}
    }
    else
    {
	put_error("Команда должна содержать целое число");
    }
    return -1;
//_______________________________________________
}