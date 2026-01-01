//╔═════════════════════════════════════════════════════════════════════════╗
//║                                                                         ║
//║	    Module name	: 	del_space.c                                 ║
//║   	    Date	: 	3 July 1991                                 ║
//║    	    Environment	: 	Turbo C++ 1.0                               ║
//║    	    Language    :       Turbo C                                     ║
//║    	    Author	: 	Melnik Oleg                                 ║
//║    	    Notice	:                                                   ║
//║                                                                         ║
//╚═════════════════════════════════════════════════════════════════════════╝

#ifndef		_STDIO_H_
#include	<stdio.h>
#endif

#ifndef		_STRING_H_
#include	<string.h>
#endif

#include	"mbe.h"
//_______________________________________________

void del_space( void )
{
//_______________________________________________

     extern char source_str[ 255 ];
     extern char work_str[ 255 ];
//_______________________________________________

     int source_pos;
     int target_pos;
     int length;
     int tmp_fl;
//_______________________________________________

     source_pos = 0;
     target_pos = 0;
     tmp_fl = 0;
//_______________________________________________

     length = strlen( source_str );
     while( source_pos < length )
     {
	    if( source_str[ source_pos ] == ' '  ||
		source_str[ source_pos ] == '\t' ||
		source_str[ source_pos ] == '\r' ||
		source_str[ source_pos ] == '\n'  )
	    {
		if( tmp_fl == 0 && target_pos > 0 )
		{
		    tmp_fl = 1;
		    if( work_str[ target_pos - 1 ] != ( char )255 )
		    {
			work_str[ target_pos++ ] = 255;
		    }
		}
		do
		{
			 source_pos++;
		}while(( source_str[ source_pos ] == ' '  ||
			 source_str[ source_pos ] == '\t' ||
			 source_str[ source_pos ] == '\r' ||
			 source_str[ source_pos ] == '\n' )
			 && source_pos < length );
	    }
	    else if( source_str[ source_pos ] == '"' )
	    {
		if( work_str[ target_pos - 1 ] != ( char )255 )
		{
		    work_str[ target_pos++ ] = 255;
		}
		source_pos++;
		do
		{
			if( source_str[ source_pos ] == '\\')
			{
			    source_pos ++;
			}
			work_str[ target_pos++ ] = source_str[ source_pos++ ];
		}while( source_str[ source_pos ] != '"'
			&& source_pos < length );
		if( source_pos >= length )
		{
		    put_error("Кавычка открыта, но не закрыта");
		}
		else
		{
		    source_pos++;
		    if( work_str[ target_pos - 1 ] != ( char )255 )
		    {
			work_str[ target_pos++ ] = 255;
		    }
		}
	    }
	    else if( source_str[ source_pos ] == ',')
	    {
		     source_pos++;
		     if( work_str[ target_pos - 1 ] != ( char )255 )
		     {
			 work_str[ target_pos++ ] = 255;
		     }
	    }
	    else
	    {
		work_str[ target_pos++ ] = source_str[ source_pos++ ];
	    }
     }
     work_str[ target_pos ] = 0;
//_______________________________________________
}