//╔═════════════════════════════════════════════════════════════════════════╗
//║                                                                         ║
//║	    Module name	: 	command_c.c                                 ║
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

#ifndef		_STDLIB_H
#include	<stdlib.h>
#endif

#include	"mbe.h"
//_______________________________________________

void command_c( void )
{
//_______________________________________________

     extern char tmp_str[ 255 ];
//_______________________________________________

     tok_str();
     if( system( tmp_str ) == -1 )
     {
	 perror("\nMBE: Не могу выполнить команду\nОшибка\a");
	 exit( 255 );
     }
//_______________________________________________
}