//╔═════════════════════════════════════════════════════════════════════════╗
//║                                                                         ║
//║	    Module name	: 	password_c.c                                ║
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

#ifndef		_DOS_H
#include	<dos.h>
#endif

#include	"mbe.h"
//_______________________________________________


void password_c( void )
{
//_______________________________________________

     extern char tmp_str[ 255 ];
//_______________________________________________

     char password[ 255 ];
     int num;
     int frequency;
     int dd;
     int count;
     int i;
     int key;
//_______________________________________________

     tok_str();
     strcpy( password, tmp_str );
     num = tok_int();
     frequency = tok_int();
     dd = tok_int();
     for( count = 0; count < num; count++ )
     {	  
	  key = get_key();
	  if( key == 0 )
	  {
	      key = getch();
	  }
	  for( i = 0; key != 13 && i < 251; i++ )
	  {
	       tmp_str[ i ] = key; 
	       key = get_key();
	       if( key == 0 )
	       {
		   key = getch();
	       }
	  }
	  tmp_str[ i ] = 0;
	  if( strcmp( tmp_str, password ) == 0 )
	  {
	      exit( 1 );
	  }
	  sound( frequency );
	  delay( dd );
	  nosound();
     }
     exit( 0 );
//_______________________________________________
}