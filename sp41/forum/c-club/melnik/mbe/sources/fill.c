//╔═════════════════════════════════════════════════════════════════════════╗
//║                                                                         ║
//║	    Module name	: 	fill.c                                      ║
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

#include	"mbe.h"
//_______________________________________________

void fill( int ch, int x, int y, int xn, int yn, int foreg, int back )
{
//_______________________________________________

     int f;
     int z;
     char *out_array;
     int i;
     int attrib;
//_______________________________________________

     if(( xn * yn * 2 ) < 1 )
     {
	  return;
     }
     if(( out_array = ( char* )malloc( xn * yn * 2 )) == NULL )
     {
	  put_error("Недостаточно памяти для заполнения части экрана");
     }
//_______________________________________________

     f = x + xn - 1;
     z = y + yn - 1;
     attrib = back * 16 + foreg;
//_______________________________________________

     i = 0;
     while( i < ( xn * yn * 2 ))
     {
	  out_array[ i++ ] = ch;
	  out_array[ i++ ] = attrib;
     }
//_______________________________________________

     puttext( x, y, f, z, out_array );
//_______________________________________________

     free( out_array );
//_______________________________________________
}