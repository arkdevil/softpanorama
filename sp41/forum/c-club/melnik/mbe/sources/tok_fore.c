//╔═════════════════════════════════════════════════════════════════════════╗
//║                                                                         ║
//║	    Module name	: 	tok_foreground.c                            ║
//║   	    Date	: 	5 July 1991                                 ║
//║    	    Environment	: 	Turbo C++ 1.0                               ║
//║    	    Language    :       Turbo C                                     ║
//║    	    Author	: 	Melnik Oleg                                 ║
//║    	    Notice	:                                                   ║
//║                                                                         ║
//╚═════════════════════════════════════════════════════════════════════════╝

#ifndef		_STDIO_H
#include	<stdio.h>
#endif

#ifndef		_STRING_H
#include	<string.h>
#endif

#ifndef		_STDLIB_H
#include	<stdlib.h>
#endif

#include	"mbe.h"
//_______________________________________________

int tok_foreground( void )
{
//_______________________________________________

    extern char tmp_str[ 255 ];
//_______________________________________________

    int foreground;
//_______________________________________________

    strcpy( tmp_str, strtok( NULL, "\xff"));
    if( tmp_str[ 0 ])
    {
	foreground = atoi( tmp_str );
	if( foreground < 0  || foreground > 143 ||
	  ( foreground > 15 && foreground < 128 ))
	{
put_error("Значение цвета переднего плана должно лежать в периоде от 0 до 15 ( для мерцания - от 128 до 143 )");
	}
	else
	{
	    return foreground;
	}
    }
    else
    {
	put_error("Команда должна содержать значение цвета переднего плана");
    }
    return -1;
//_______________________________________________
}