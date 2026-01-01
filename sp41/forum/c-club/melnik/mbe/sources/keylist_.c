//╔═════════════════════════════════════════════════════════════════════════╗
//║                                                                         ║
//║	    Module name	: 	keylist_c.c                                 ║
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

#ifndef		_STRING_H
#include	<string.h>
#endif

#ifndef		_CONIO_H
#include	<conio.h>
#endif

#ifndef		_CTYPE_H
#include	<ctype.h>
#endif

#include	"mbe.h"
//_______________________________________________


void keylist_c( void )
{
//_______________________________________________

     extern char tmp_str[ 255 ];
//_______________________________________________

     int key;
     int num;
     int length;
//_______________________________________________

     tok_str();
     strlwrr( tmp_str );
     length = strlen( tmp_str );
     for( key = 256; key != 300;)
     {	  
	  key = get_key();
	  key = tolowerr( key );
	  if( key == 0 )
	  {
	      getch();
	  }
	  else
	  {
	      for( num = 0; key != 300 && num < length; num++ )
	      {
		   if( tmp_str[ num ] == key )
		   {
		       key = 300;
		   }
	      }
	  }
     }
     exit( num );
//_______________________________________________
}