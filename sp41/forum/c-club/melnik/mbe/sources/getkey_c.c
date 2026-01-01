//╔═════════════════════════════════════════════════════════════════════════╗
//║                                                                         ║
//║	    Module name	: 	getkey_c.c                                  ║
//║   	    Date	: 	4 July 1991                                 ║
//║    	    Environment	: 	Turbo C++ 1.0                               ║
//║    	    Language    :       Turbo C                                     ║
//║    	    Author	: 	Melnik Oleg                                 ║
//║    	    Notice	:                                                   ║
//║                                                                         ║
//╚═════════════════════════════════════════════════════════════════════════╝

#ifndef		_STDLIB_H
#include	<stdlib.h>
#endif

#ifndef		_CONIO_H
#include	<conio.h>
#endif

#include	"mbe.h"
//_______________________________________________


void getkey_c( void )
{
//_______________________________________________

     int key;
//_______________________________________________

     key = get_key();
     if( key == 0 )
     {
	 key = getch();
     }
     exit( key );
//_______________________________________________
}