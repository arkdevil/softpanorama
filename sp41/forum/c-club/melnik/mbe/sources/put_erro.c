//╔═════════════════════════════════════════════════════════════════════════╗
//║                                                                         ║
//║	    Module name	: 	put_error.c                                 ║
//║   	    Date	: 	3 July 1991                                 ║
//║    	    Environment	: 	Turbo C++ 1.0                               ║
//║    	    Language    :       Turbo C                                     ║
//║    	    Author	: 	Melnik Oleg                                 ║
//║    	    Notice	:                                                   ║
//║                                                                         ║
//╚═════════════════════════════════════════════════════════════════════════╝

#ifndef		_DIR_H_
#include	<dir.h>
#endif

#ifndef		_STDIO_H_
#include	<stdio.h>
#endif

#ifndef		_STDLIB_H_
#include	<stdlib.h>
#endif

#ifndef		_STRING_H_
#include	<string.h>
#endif
//_______________________________________________

void put_error( char *string )
{
//_______________________________________________

     extern char file_name[ MAXPATH ];
     extern char source_str[ 255 ];
     extern int  line_num;
//_______________________________________________

     int length;
//_______________________________________________

     length = strlen( source_str );
     if( source_str[ length - 1 ] == '\n')
     {
	 source_str[ length - 1 ] = 0;
     }
//_______________________________________________

     printf("\n%s\n", source_str );
     printf("**Error** %s(%d) %s\a\n", file_name, line_num, string );
     exit( 255 );
//_______________________________________________
}