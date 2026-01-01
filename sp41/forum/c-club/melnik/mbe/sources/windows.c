//╔═════════════════════════════════════════════════════════════════════════╗
//║                                                                         ║
//║	    Module name	: 	windows.c                                   ║
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

#ifndef		_STRING_H
#include	<string.h>
#endif

#ifndef		_CONIO_H
#include	<conio.h>             
#endif

#include	"mbe.h"
//_______________________________________________


void windows( int d[ 15 ], char type_cod[ 8 ])
{
//_______________________________________________

     int f;
     int z;
     char *out_array;
     int i;
     int attrib;
     int t;
     int k;
     int size;
     int attrib_f;
//_______________________________________________

     char up_mid;
     char up_left;
     char left_mid;
     char down_left;
     char up_right;
     char right_mid;
     char down_right;
     char down_mid;
//_______________________________________________

     size = ( d[ 2 ] + ( d[ 8 ] * 2 )) * ( d[ 3 ] + ( d[ 8 ] * 1 )) * 2;
     if( size < 1 )
     {
	 return;
     }
     if(( out_array = ( char* )malloc( size )) == NULL )
     {
	  put_error("Недостаточно памяти для вывода окна");
     }
//_______________________________________________

     f = d[ 0 ] + d[ 2 ] - 1 + d[ 8 ] * 2;
     z = d[ 1 ] + d[ 3 ] - 1 + d[ 8 ] * 1;
     gettext( d[ 0 ], d[ 1 ], f, z, out_array );
//_______________________________________________

     switch( d[ 6 ] )
     {
	     case  1:  strcpy( type_cod, "ssss");
		       d[ 6 ] = 99;
		       break;

	     case  2:  strcpy( type_cod, "dddd");
		       d[ 6 ] = 99;
		       break;

	     case  3:  strcpy( type_cod, "ssdd");
		       d[ 6 ] = 99;
		       break;

	     case  4:  strcpy( type_cod, "sdsd");
		       d[ 6 ] = 99;
		       break;

	     case  5:  strcpy( type_cod, "dsds");
		       d[ 6 ] = 99;
		       break;

	     case  6:  strcpy( type_cod, "ddss");
		       d[ 6 ] = 99;
		       break;

	     case  7:  strcpy( type_cod, "dssd");
		       d[ 6 ] = 99;
		       break;

	     case  8:  strcpy( type_cod, "sdds");
		       d[ 6 ] = 99;
		       break;

	     case  9:  strcpy( type_cod, "ddds");
		       d[ 6 ] = 99;
		       break;

	     case 10:  strcpy( type_cod, "sddd");
		       d[ 6 ] = 99;
		       break;

	     case 11:  strcpy( type_cod, "dsdd");
		       d[ 6 ] = 99;
		       break;

	     case 12:  strcpy( type_cod, "ddsd");
		       d[ 6 ] = 99;
		       break;

	     case 13:  strcpy( type_cod, "sssd");
		       d[ 6 ] = 99;
		       break;

	     case 14:  strcpy( type_cod, "dsss");
		       d[ 6 ] = 99;
		       break;

	     case 15:  strcpy( type_cod, "sdss");
		       d[ 6 ] = 99;
		       break;

	     case 16:  strcpy( type_cod, "ssds");
		       d[ 6 ] = 99;
		       break;
     }
     switch( d[ 6 ] )
     {
	     case  0:
				up_right     = d[ 7 ];
				up_mid       = d[ 7 ];
				up_left      = d[ 7 ];
				left_mid     = d[ 7 ];
				down_left    = d[ 7 ];
				down_mid     = d[ 7 ];
				down_right   = d[ 7 ];
				right_mid    = d[ 7 ];
				break;
	     case 99:
		       if( type_cod[ 0 ] == 's')
		       {
			   up_mid       ='─';
		       }
		       else if( type_cod[ 0 ] == 'd')
		       {
			   up_mid       ='═';
		       }
		       else
		       {
			   up_mid       ='E';
		       }
		       if( type_cod[ 1 ] == 's')
		       {
			   left_mid       ='│';
		       }
		       else if( type_cod[ 1 ] == 'd')
		       {
			   left_mid       ='║';
		       }
		       else
		       {
			   left_mid       ='E';
		       }
		       if( type_cod[ 2 ] == 's')
		       {
			   right_mid       ='│';
		       }
		       else if( type_cod[ 2 ] == 'd')
		       {
			   right_mid       ='║';
		       }
		       else
		       {
			   right_mid       ='E';
		       }
		       if( type_cod[ 3 ] == 's')
		       {
			   down_mid       ='─';
		       }
		       else if( type_cod[ 3 ] == 'd')
		       {
			   down_mid       ='═';
		       }
		       else
		       {
			   down_mid       ='E';
		       }
		       if( type_cod[ 0 ] == 's' && type_cod[ 1 ] == 's')
		       {
			   up_left = '┌';
		       }
		       else if( type_cod[ 0 ] == 's' && type_cod[ 1 ] == 'd')
		       {
			   up_left = '╓';
		       }
		       else if( type_cod[ 0 ] == 'd' && type_cod[ 1 ] == 's')
		       {
			   up_left = '╒';
		       }
		       else if( type_cod[ 0 ] == 'd' && type_cod[ 1 ] == 'd')
		       {
			   up_left = '╔';
		       }
		       else
		       {
			   up_left = 'E';
		       }
		       if( type_cod[ 0 ] == 's' && type_cod[ 2 ] == 's')
		       {
			   up_right = '┐';
		       }
		       else if( type_cod[ 0 ] == 's' && type_cod[ 2 ] == 'd')
		       {
			   up_right = '╖';
		       }
		       else if( type_cod[ 0 ] == 'd' && type_cod[ 2 ] == 's')
		       {
			   up_right = '╕';
		       }
		       else if( type_cod[ 0 ] == 'd' && type_cod[ 2 ] == 'd')
		       {
			   up_right = '╗';
		       }
		       else
		       {
			   up_right = 'E';
		       }
		       if( type_cod[ 3 ] == 's' && type_cod[ 1 ] == 's')
		       {
			   down_left = '└';
		       }
		       else if( type_cod[ 3 ] == 's' && type_cod[ 1 ] == 'd')
		       {
			   down_left = '╙';
		       }
		       else if( type_cod[ 3 ] == 'd' && type_cod[ 1 ] == 's')
		       {
			   down_left = '╘';
		       }
		       else if( type_cod[ 3 ] == 'd' && type_cod[ 1 ] == 'd')
		       {
			   down_left = '╚';
		       }
		       else
		       {
			   down_left = 'E';
		       }
		       if( type_cod[ 3 ] == 's' && type_cod[ 2 ] == 's')
		       {
			   down_right = '┘';
		       }
		       else if( type_cod[ 3 ] == 's' && type_cod[ 2 ] == 'd')
		       {
			   down_right = '╜';
		       }
		       else if( type_cod[ 3 ] == 'd' && type_cod[ 2 ] == 's')
		       {
			   down_right = '╛';
		       }
		       else if( type_cod[ 3 ] == 'd' && type_cod[ 2 ] == 'd')
		       {
			   down_right = '╝';
		       }
		       else
		       {
			   down_right = 'E';
		       }
		       break;

	     case 17:
				up_mid       ='▀';
				up_left      ='▐';
				left_mid     ='▐'; 
				down_left    ='▐';
				up_right     ='▌';
				right_mid    ='▌';
				down_right   ='▌';
				down_mid     ='▄';
				break;
	     case 18:
				up_mid       ='▀';
				up_left      ='█';
				left_mid     ='█'; 
				down_left    ='█';
				up_right     ='█';
				right_mid    ='█';
				down_right   ='█';
				down_mid     ='▄';
	     case 19:
				up_mid       ='█';
				up_left      ='█';
				left_mid     ='█'; 
				down_left    ='█';
				up_right     ='█';
				right_mid    ='█';
				down_right   ='█';
				down_mid     ='█';
				break;
	     case 20:
				up_mid       ='░';
				up_left      ='░';
				left_mid     ='░'; 
				down_left    ='░';
				up_right     ='░';
				right_mid    ='░';
				down_right   ='░';
				down_mid     ='░';
				break;
	     case 21:
				up_mid       ='▒';
				up_left      ='▒';
				left_mid     ='▒'; 
				down_left    ='▒';
				up_right     ='▒';
				right_mid    ='▒';
				down_right   ='▒';
				down_mid     ='▒';
				break;
	     case 22:
				up_mid       ='▓';
				up_left      ='▓';
				left_mid     ='▓'; 
				down_left    ='▓';
				up_right     ='▓';
				right_mid    ='▓';
				down_right   ='▓';
				down_mid     ='▓';
				break;
	     case 23:
				up_mid       ='█';
				up_left      ='';
				left_mid     ='█'; 
				down_left    ='';
				up_right     ='';
				right_mid    ='█';
				down_right   ='';
				down_mid     ='█';
				break;
	     case 24:
				up_mid       ='█';
				up_left      ='';
				left_mid     ='█'; 
				down_left    ='';
				up_right     ='';
				right_mid    ='█';
				down_right   ='';
				down_mid     ='█';
				break;
	     case 25:
				up_mid       ='█';
				up_left      ='';
				left_mid     ='█'; 
				down_left    ='█';
				up_right     ='█';
				right_mid    ='█';
				down_right   ='█';
				down_mid     ='█';
				break;
	     case 26:
				up_mid       ='█';
				up_left      ='';
				left_mid     ='█'; 
				down_left    ='█';
				up_right     ='█';
				right_mid    ='█';
				down_right   ='█';
				down_mid     ='█';
				break;
	     case 27:
				up_mid       ='█';
				up_left      ='';
				left_mid     ='█'; 
				down_left    ='';
				up_right     ='█';
				right_mid    ='█';
				down_right   ='█';
				down_mid     ='█';
				break;
	     case 28:
				up_mid       ='█';
				up_left      ='';
				left_mid     ='█'; 
				down_left    ='';
				up_right     ='█';
				right_mid    ='█';
				down_right   ='█';
				down_mid     ='█';
				break;
	     case 29:
				up_mid       ='█';
				up_left      ='';
				left_mid     ='█'; 
				down_left    ='█';
				up_right     = 26;
				right_mid    ='█';
				down_right   ='█';
				down_mid     ='█';
				break;
	     case 30:
				up_mid       ='█';
				up_left      ='';
				left_mid     ='█'; 
				down_left    ='';
				up_right     = 26;
				right_mid    ='█';
				down_right   ='';
				down_mid     ='█';
				break;
	     case 31:
				up_mid       ='█';
				up_left      ='';
				left_mid     ='█'; 
				down_left    ='';
				up_right     ='█';
				right_mid    ='█';
				down_right   ='█';
				down_mid     ='█';
				break;
	     case 32:
				up_mid       ='█';
				up_left      ='';
				left_mid     ='█'; 
				down_left    ='█';
				up_right     ='';
				right_mid    ='█';
				down_right   ='█';
				down_mid     ='█';
				break;
	     case 33:
				up_mid       ='█';
				up_left      ='';
				left_mid     ='█'; 
				down_left    ='';
				up_right     ='';
				right_mid    ='█';
				down_right   ='';
				down_mid     ='█';
				break;
     }                                         
//_______________________________________________

     attrib = d[ 5 ] * 16 + d[ 4 ];
     if( d[ 9 ] != 256 )
     {
	 attrib_f = d[ 11 ] * 16 + d[ 10 ];
     }
//_______________________________________________

     i = 0;
     out_array[ i++ ] = up_left;
     out_array[ i++ ] = attrib;
     for( t = 0; t < d[ 2 ] - 2; t++ )
     {
	  out_array[ i++ ] = up_mid;
	  out_array[ i++ ] = attrib;
     }
     out_array[ i++ ] = up_right;
     out_array[ i++ ] = attrib;
     if( d[ 8 ] == 1 )
     {
	 i += 4;
     }
     for( k = 0; k < d[ 3 ] - 2; k++ )
     {
	  out_array[ i++ ] = left_mid;
	  out_array[ i++ ] = attrib;
	  for( t = 0; t < d[ 2 ] - 2 ; t++ )
	  {
	       if( d[ 9 ] != 256 )
	       {
		   out_array[ i ] = d[ 9 ];
		   out_array[ i + 1 ] = attrib_f;
	       }
	       i += 2;
	  }
	  out_array[ i++ ] = right_mid;
	  out_array[ i++ ] = attrib;
//_______________________________________________

	  if( d[ 8 ] == 1 )
	  {
	      i++;
	      out_array[ i ] = out_array[ i ] & 135;
	      i += 2;
	      out_array[ i ] = out_array[ i ] & 135;
	      i++;
	  }
     }
//_______________________________________________

     out_array[ i++ ] = down_left;
     out_array[ i++ ] = attrib;
     for( t = 0; t < d[ 2 ] - 2; t++ )
     {
	  out_array[ i++ ] = down_mid;
	  out_array[ i++ ] = attrib;
     }
     out_array[ i++ ] = down_right;
     out_array[ i++ ] = attrib;
//_______________________________________________

     if( d[ 8 ] == 1 )
     {
	 i++;
	 out_array[ i ] = out_array[ i ] & 135;
	 i += 2;
	 out_array[ i ] = out_array[ i ] & 135;
	 for( i += 6; i < size; i += 2 )
	 {
		out_array[ i ] = out_array[ i ] & 135;
	 }
     }
//_______________________________________________

     puttext( d[ 0 ], d[ 1 ], f, z, out_array );
//_______________________________________________

     free( out_array );
//_______________________________________________
}