//╔═════════════════════════════════════════════════════════════════════════╗
//║                                                                         ║
//║	    Module name	: 	star_sky.c                                  ║
//║   	    Date	: 	9 July 1991                                 ║
//║    	    Environment	: 	Turbo C++ 1.0                               ║
//║    	    Language    :       Turbo C                                     ║
//║    	    Author	: 	Melnik Oleg                                 ║
//║    	    Notice	:                                                   ║
//║                                                                         ║
//╚═════════════════════════════════════════════════════════════════════════╝

#include	<stdlib.h>
#include	<stdio.h>
#include	<conio.h>
#include	<dos.h>
#include	"mbe.h"
//_______________________________________________


void star_sky( void )
{
//_______________________________________________

     extern int ext_star_fl;
     extern char star_command[ 255 ];
//_______________________________________________

     union REGS regs;
     char save_screen[ 4096 ];
     int  save_x;
     int  save_y;
     char stars[ 55 ];
     char stars_x[ 55 ];
     char stars_y[ 55 ];
     int i;
     int rnd;
//_______________________________________________

     save_x = wherex();
     save_y = wherey();
     gettext( 1, 1, 80, 25, save_screen );
     textattr( 7 );
     clrscr();
//_______________________________________________

     if( ext_star_fl == 1 )
     {
	 if( star_command[ 0 ] != 0 )
	 {
	     system( star_command );
	 }
	 else
	 {
puts("**Error** ????????(1) Внешняя программа тушения экрана не определена");
	     exit( 255 );
	 }
     }
     else
     {
	 regs.h.ah = 2;
	 regs.h.bh = 0;
	 regs.h.dh = 25;
	 regs.h.dl = 0;
	 int86( 0x10, &regs, &regs );
	 for( i = 0; i < 50; i++ )
	 {
	      stars[ i ] = 0;
	 }
	 for( i = 0; !kbhit(); i = ( ++i % 50 ), rnd = random( 100 ))
	 {
	      switch( stars[ i ])
	      {
		      case 250:  if( rnd < 4 )
				 {
				     if( rnd > 1 )
				     {
					 stars[ i ] = 249;
				     }
				     else
				     {
					 stars[ i ] = 0;
				     }
				 }
				 break;

		      case 249:  if( rnd < 25 )
				 {
				     stars[ i ] = 7;
				 }
				 else
				 {
				     stars[ i ] = 0;
				 }
				 break;

		      case   7:  stars[ i ] = 4;
				 break;

		      case   4:  stars[ i ] = 15;
				 break;

		      case  15:  stars[ i ] = 0;
				 break;

		      default :  if( rnd > 50 )
				 {
				     stars[ i ] = 250;
				 }
				 else
				 {
				     stars[ i ] = 0;
				 }
				 stars_x[ i ] = random( 80 ) + 1;
				 stars_y[ i ] = random( 25 ) + 1;
				 break;
	      } 
	      cprint( stars[ i ], stars_x[ i ], stars_y[ i ], 3, 0 );
	      delay( 5 );
	 }
	 while( kbhit())
	 {
		getch();
	 }
     }
//_______________________________________________

     gotoxy( save_x, save_y );
     puttext( 1, 1, 80, 25, save_screen );
//_______________________________________________
}