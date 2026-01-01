//╔═════════════════════════════════════════════════════════════════════════╗
//║                                                                         ║
//║	    Module name	: 	tok_onoff.c                                 ║
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

int tok_onoff( void )
{
//_______________________________________________

    extern char tmp_str[ 255 ];
//_______________________________________________

    strcpy( tmp_str, strtok( NULL, "\xff"));
    if( tmp_str[ 0 ])
    {
	strlwr( tmp_str );
	if( strcmp( tmp_str, "off") == 0 )
	{
	    return 0;
	}
	else if( strcmp( tmp_str, "on") == 0 )
	{
	    return 1;
	}
	else
	{
	    put_error("Вместо On или Off вставлена непонятная строка");
	}
    }
    put_error("Команда должна содержать слово On или Off");
    return -1;
//_______________________________________________
}