//╔═════════════════════════════════════════════════════════════════════════╗
//║                                                                         ║
//║	    Module name	: 	manager.c                                   ║
//║   	    Date	: 	5 July 1991                                 ║
//║    	    Environment	: 	Turbo C++ 1.0                               ║
//║    	    Language    :       Turbo C                                     ║
//║    	    Author	: 	Melnik Oleg                                 ║
//║    	    Notice	:                                                   ║
//║                                                                         ║
//╚═════════════════════════════════════════════════════════════════════════╝

#ifndef		_STDLIB_H
#include	<stdlib.h>
#endif

#ifndef		_STDIO_H
#include	<stdio.h>
#endif

#ifndef		_CONIO_H
#include	<conio.h>
#endif

#ifndef		_CTYPE_H
#include	<ctype.h>
#endif

#include	"mbe.h"
//_______________________________________________

void show_cursor( void );
void hide_cursor( void );
void check_nu( void );
//_______________________________________________

int nu;
int old_nu;
char old_scr[ 200 ];
char new_scr[ 200 ];
int attrib;
int x[ 100 ];
int y[ 100 ];
int length[ 100 ];
int i;
int ur;
//_______________________________________________

void manager( int d[ 420 ])
{
//_______________________________________________

     int k;
     int foreg;
     int back;
     int key;
     int move;
     char hot_keys[ 100 ];
     int done;
//_______________________________________________

     ur = d[ 0 ];
     for( i = 1, k = 1; i <= ur; i++ )
     {
	  x[ i ] = d[ k++ ];
	  y[ i ] = d[ k++ ];
	  length[ i ] = d[ k++ ];
	  hot_keys[ i ] = d[ k++ ];
     }
     hot_keys[ i ] = 0;
     foreg = d[ k++ ];
     back  = d[ k++ ];
     nu    = d[ k++ ];
     move  = d[ k ];
//_______________________________________________

     attrib = back * 16 + foreg;
     old_nu = nu;
     gettext( x[ nu ], y[ nu ], x[ nu ]+ length[ nu ]- 1, y[ nu ], old_scr );
     show_cursor();
     done = -1;
     strlwrr( hot_keys );
//_______________________________________________

     while( done == -1 )
     {
	    key = get_key();
	    if( key == 0 )
	    {
		key = getch();
		switch( key )
		{
			case RIGHT : if( move == 1 )
				     {
					 break;    
				     }
				     do
				     { 
					     nu++;
					     check_nu();
				     }while( length[ nu ] == 0 );
				     show_cursor();
				     break;

			case DOWN  : if( move == 0 )
				     {
					 break;    
				     }
				     do
				     { 
					     nu++;
					     check_nu();
				     }while( length[ nu ] == 0 );
				     show_cursor();
				     break;

			case LEFT  : if( move == 1 )
				     {
					 break;    
				     } 
				     do
				     { 
					     nu--;
					     check_nu();
				     }while( length[ nu ] == 0 );
				     show_cursor();
				     break;

			case UP    : if( move == 0 )
				     {
					 break;    
				     } 
				     do
				     { 
					     nu--;
					     check_nu();
				     }while( length[ nu ] == 0 );
				     show_cursor();
				     break;

			case HOME  : for( nu =1; length[ nu ]==0 && nu <=ur;
					  nu++);
				     show_cursor();
				     break;

			case END   : for( nu =ur; length[ nu ]==0 && nu >=1;
					  nu--);
				     show_cursor();
				     break;
		}
	    }
	    else
	    {
		switch( key )        
		{
			case ESC   : done = 0;
				     hide_cursor();
				     break;

			case SPACE :
			case ENTER : done = nu;
				     hide_cursor();
				     break;
    
			default    : key = tolowerr( key );
				     for( i = 1; i <= ur; i++ )
				     {
					  if( key == hot_keys[ i ]
					      && length[ i ] != 0 )
					  {
					      nu = i;
					      show_cursor();
					      done = nu;
					      hide_cursor();
					      break;
					  }
				     }
				     break;
		}
	    }
     }
     exit( done );
//_______________________________________________
}

void show_cursor( void )
{
     hide_cursor();
     gettext( x[ nu ], y[ nu ], x[ nu ]+ length[ nu ]- 1, y[ nu ], old_scr );
     old_nu = nu;
     for( i = 0; i < length[ nu ]; i++ )	
     {                               
       new_scr[ i * 2 ]     = old_scr[ i * 2 ];
       new_scr[ i * 2 + 1 ] = attrib;
     }
     puttext( x[ nu ], y[ nu ], x[ nu ]+ length[ nu ]- 1, y[ nu ], new_scr );
}

void hide_cursor( void )
{
     puttext( x[ old_nu ], y[ old_nu ],
	      x[ old_nu ]+ length[ old_nu ]- 1, y[ old_nu ], old_scr );
}

void check_nu( void )
{
     if( nu < 1 )
     {
	 nu = ur;
     }
     else 
     {
	 if( nu > ur )
	 {
	     nu = 1;
	 }
     }
}