//╔═════════════════════════════════════════════════════════════════════════╗
//║                                                                         ║
//║	    Module name	: 	cprint.c                                    ║
//║   	    Date	: 	9 July 1991                                 ║
//║    	    Environment	: 	Turbo C++ 1.0                               ║
//║    	    Language    :       Turbo C                                     ║
//║    	    Author	: 	Melnik Oleg                                 ║
//║    	    Notice	:                                                   ║
//║                                                                         ║
//╚═════════════════════════════════════════════════════════════════════════╝

#include	<conio.h>
//_______________________________________________


void cprint( char symbol, int x, int y, int foreground, int background )
{
//_______________________________________________

     char out_array[ 2 ];
//_______________________________________________

     out_array[ 0 ] = symbol;
     out_array[ 1 ] = background * 16 + foreground;
//_______________________________________________

     puttext( x, y, x, y, out_array );
//_______________________________________________
}