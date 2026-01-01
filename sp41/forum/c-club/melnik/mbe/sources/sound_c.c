//╔═════════════════════════════════════════════════════════════════════════╗
//║                                                                         ║
//║	    Module name	: 	sound_c.c                                   ║
//║   	    Date	: 	3 July 1991                                 ║
//║    	    Environment	: 	Turbo C++ 1.0                               ║
//║    	    Language    :       Turbo C                                     ║
//║    	    Author	: 	Melnik Oleg                                 ║
//║    	    Notice	:                                                   ║
//║                                                                         ║
//╚═════════════════════════════════════════════════════════════════════════╝

#ifndef		_DOS_H_
#include	<dos.h>
#endif

#include	"mbe.h"
//_______________________________________________

void sound_c( void )
{
//_______________________________________________

     int frequency;
     int detain;
     int pause;
     int num;
     int count;
//_______________________________________________

     frequency = tok_int();
     detain = tok_int();
     pause = tok_int();
     num = tok_int();
     for( count = 0; count < num; count++ )
     {
	  sound( frequency );
	  delay( detain );
	  nosound();
	  delay( pause );
     }
//_______________________________________________
}