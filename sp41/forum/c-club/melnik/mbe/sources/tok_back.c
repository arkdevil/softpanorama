//╔═════════════════════════════════════════════════════════════════════════╗
//║                                                                         ║
//║	    Module name	: 	tok_background.c                            ║
//║   	    Date	: 	3 July 1991                                 ║
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

int tok_background( void )
{
//_______________________________________________

    extern char tmp_str[ 255 ];
//_______________________________________________

    int background;
//_______________________________________________

    strcpy( tmp_str, strtok( NULL, "\xff"));
    if( tmp_str[ 0 ])
    {
	background = atoi( tmp_str );
	if( background < 0  || background > 7 )
	{
put_error("Значение цвета фона должно лежать периоде от 0 до 7");
	}
	else
	{
	    return background;
	}
    }
    else
    {
	put_error("Команда должна содержать значение цвета фона");
    }
    return -1;
//_______________________________________________
}