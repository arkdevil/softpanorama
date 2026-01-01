//╔═════════════════════════════════════════════════════════════════════════╗
//║                                                                         ║
//║	    Module name	: 	yesno_c.c                                   ║
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

#ifndef		_CTYPE_H
#include	<ctype.h>
#endif

#include	"mbe.h"
//_______________________________________________


void yesno_c( void )
{
//_______________________________________________

     int key;
//_______________________________________________

     for( key = 256;
	  key != 'y' && key != 'n';
	  key = get_key(), key = tolower( key ))
     {	  
	  if( key == 0 )
	  {
	      getch();
	  }
     }
     if( key == 'n')
     {
	 exit( 0 );
     }
     else
     {
	 exit( 1 );
     }
//_______________________________________________
}