//╔═════════════════════════════════════════════════════════════════════════╗
//║                                                                         ║
//║	    Module name	: 	cursortype_c.c                              ║
//║   	    Date	: 	5 July 1991                                 ║
//║    	    Environment	: 	Turbo C++ 1.0                               ║
//║    	    Language    :       Turbo C                                     ║
//║    	    Author	: 	Melnik Oleg                                 ║
//║    	    Notice	:                                                   ║
//║                                                                         ║
//╚═════════════════════════════════════════════════════════════════════════╝

#ifndef		_DOS_H_
#include	<dos.h>
#endif

#ifndef		_STRING_H_
#include	<string.h>
#endif

#ifndef		_STDLIB_H_
#include	<stdlib.h>
#endif

#include	"mbe.h"
//_______________________________________________

void cursortype_c( void )
{
//_______________________________________________

     extern char tmp_str[ 255 ];
//_______________________________________________

     union REGS regs;
     int begin;
     int end;
//_______________________________________________

     tok_str();
     strlwr( tmp_str );
     if( strcmp( tmp_str, "off") == 0 )
     {
	 begin = 32;
	 end = 0;
     }
     else if( strcmp( tmp_str, "normal") == 0 )
     {
	 begin = 6;
	 end = 7;
     }
     else if( strcmp( tmp_str, "solid") == 0 )
     {
	 begin = 0;
	 end = 8;
     }
     else
     {
	 begin = atoi( tmp_str );
	 if( begin < 0 || begin > 32 )
	 {
	     put_error("Значение начальной строки курсора должно быть в промежутке от 0 до 32");
	 }
	 end = tok_int();
	 if( end < 0 || end > 31 )
	 {
	     put_error("Значение конечной строки курсора должно быть в промежутке от 0 до 31");
	 }
     }
     regs.h.ah = 1;
     regs.h.ch = begin;
     regs.h.cl = end;
     int86( 0x10, &regs, &regs );
//_______________________________________________
}