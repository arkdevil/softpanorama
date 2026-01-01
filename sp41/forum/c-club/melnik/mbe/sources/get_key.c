//╔═════════════════════════════════════════════════════════════════════════╗
//║                                                                         ║
//║	    Module name	: 	get_key.c                                   ║
//║   	    Date	: 	8 July 1991                                 ║
//║    	    Environment	: 	Turbo C++ 1.0                               ║
//║    	    Language    :       Turbo C                                     ║
//║    	    Author	: 	Melnik Oleg                                 ║
//║    	    Notice	:                                                   ║
//║                                                                         ║
//╚═════════════════════════════════════════════════════════════════════════╝

#include	<string.h>
#include	<stdlib.h>
#include	<stdio.h>
#include	<conio.h>
#include	<dos.h>
#include	"mbe.h"
//_______________________________________________


int get_key( void )
{
//_______________________________________________

    extern char tmp_str[ 255 ];
    extern int  star_fl;
    extern int  star_delay;

    extern int  date_fl;
    extern int  date_x;
    extern int  date_y;
    extern int  date_foreground;
    extern int  date_background;
    extern char date_str[ 255 ];
    extern int  date_str_x;
    extern int  date_str_y;
    extern int  date_str_foreground;
    extern int  date_str_background;

    extern int  clock_fl;
    extern int  clock_x;
    extern int  clock_y;
    extern int  clock_foreground;
    extern int  clock_background;
    extern char clock_str[ 255 ];
    extern int  clock_str_x;
    extern int  clock_str_y;
    extern int  clock_str_foreground;
    extern int  clock_str_background;
//_______________________________________________

    struct COUNTRY ci;
    struct time t;
    struct date d;
    int dest_hour;
    int dest_min;
    int dest_sec;
    char datep[ 25 ];
    char timep[ 25 ];
    char tmsep[ 3 ];
//_______________________________________________

    gettime( &t );
    dest_sec = t.ti_sec;
    dest_min = t.ti_min + star_delay;
    if( dest_min >= 60 )
    {
	dest_hour = ( t.ti_hour + dest_min/60 )%24;
	dest_min %= 60;
    }
    else
    {
	dest_hour = t.ti_hour;
    }
    country( 0, &ci );
    while( !kbhit())
    {
	   if( date_fl == 1 )
	   {
	       getdate( &d );
	       d.da_year %= 100;
	       switch( ci.co_date )
	       {
		       case  0:  sprintf( datep, "%2d%s%02d%s%02d",
					  d.da_mon, ci.co_dtsep,
					  d.da_day, ci.co_dtsep,
					  d.da_year );
				 break;

		       case  1:  sprintf( datep, "%2d%s%02d%s%02d",
					  d.da_day, ci.co_dtsep,
					  d.da_mon, ci.co_dtsep,
					  d.da_year );
				 break;

		       case  2:  sprintf( datep, "%2d%s%02d%s%02d",
					  d.da_year, ci.co_dtsep,
					  d.da_mon,  ci.co_dtsep,
					  d.da_day );
				 break;

		       default:  strcpy( datep, "*Error!*");
	       }
	       sprint( date_str, date_str_x, date_str_y, 
		       date_str_foreground, date_str_background );
	       sprint( datep, min( date_x, 81 - strlen( datep )), date_y, 
		       date_foreground, date_background );
	   }
	   gettime( &t );
	   strcpy( tmsep,( t.ti_sec & 1 ) == 0 ? ci.co_tmsep : " ");
	   if( clock_fl == 1 )
	   {
	       switch( ci.co_time & 1 )
	       {
		       case  0:  sprintf( timep, "%2d%s%02d%s", 
				 t.ti_hour % 12 != 0 ? t.ti_hour % 12 : 12, 
				 tmsep, t.ti_min, 
				 t.ti_hour > 12 ? "p" : "a" );
				 break;

		       case  1:  sprintf( timep, "%2d%s%02d", 
				 t.ti_hour, tmsep, t.ti_min, t.ti_hour );
				 break;
	       }
	       sprint( clock_str, clock_str_x, clock_str_y, 
		       clock_str_foreground, clock_str_background );
	       sprint( timep, min( clock_x, 81 - strlen( timep )), clock_y, 
		       clock_foreground, clock_background );
	   }
	   if( dest_hour == t.ti_hour && dest_min == t.ti_min 
	       && dest_sec == t.ti_sec && star_fl == 1 )
	   {
	       star_sky();
	       gettime( &t );
	       dest_sec = t.ti_sec;
	       dest_min = t.ti_min + star_delay;
	       if( dest_min >= 60 )
	       {
		   dest_hour = ( t.ti_hour + dest_min/60 )%24;
		   dest_min %= 60;
	       }
	       else
	       {
		   dest_hour = t.ti_hour;
	       }
	   }
    }
//_______________________________________________

    return getch();
//_______________________________________________
}