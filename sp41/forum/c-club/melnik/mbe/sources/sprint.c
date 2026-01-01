//╔═════════════════════════════════════════════════════════════════════════╗
//║                                                                         ║
//║	    Module name	: 	sprint.c                                    ║
//║   	    Date	: 	3 July 1991                                 ║
//║    	    Environment	: 	Turbo C++ 1.0                               ║
//║    	    Language    :       Turbo C                                     ║
//║    	    Author	: 	Melnik Oleg                                 ║
//║    	    Notice	:                                                   ║
//║                                                                         ║
//╚═════════════════════════════════════════════════════════════════════════╝

#ifndef		_CONIO_H
#include	<conio.h>
#endif

#ifndef		_STDLIB_H
#include	<stdlib.h>
#endif

#ifndef		_STRING_H
#include	<string.h>
#endif

#include	"mbe.h"
//_______________________________________________


void sprint( char *string, int x, int y, int foreground, int background )
{
//_______________________________________________

     int attrib;
     char *out_array;
     int i;
     int length;
//_______________________________________________

     attrib = background * 16 + foreground;
//_______________________________________________

     length = strlen( string );
     if( length < 1 )
     {
	 return;
     }
     if(( out_array = ( char* )malloc( length * 2 )) == NULL )
     {
	  put_error("Недостаточно памяти для вывода строки");
     }
//_______________________________________________

     for( i = 0; i < length; i++ )	
     {
	  out_array[ i * 2 ] = string[ i ];
	  out_array[ i * 2 + 1 ] = attrib;
     }
//_______________________________________________

     length--;
     puttext( x, y, x + length, y, out_array );
//_______________________________________________

     free( out_array );
//_______________________________________________
}