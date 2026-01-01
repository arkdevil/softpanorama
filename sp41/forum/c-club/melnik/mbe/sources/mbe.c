//╔═════════════════════════════════════════════════════════════════════════╗
//║                                                                         ║
//║	    Module name	: 	mbe.c                                       ║
//║   	    Date	: 	9 July 1991                                 ║
//║    	    Environment	: 	Turbo C++ 1.0                               ║
//║    	    Language    :       Turbo C                                     ║
//║    	    Author	: 	Melnik Oleg                                 ║
//║    	    Notice	:       Melnik Batch Enchanced 2.00                 ║
//║                                                                         ║
//╚═════════════════════════════════════════════════════════════════════════╝

#include	<dir.h>
#include	<stdio.h>
#include 	<stdlib.h>
#include 	<string.h>
#include	"mbe.h"
//_______________________________________________

char source_str[ 255 ];
char work_str[ 255 ];
char tmp_str[ 255 ];
int  line_num;
char file_name[ MAXPATH ];

int  star_fl;
int  star_delay;
int  ext_star_fl = 0;
char star_command[ 255 ];

int  clock_fl;
int  clock_x;
int  clock_y;
int  clock_foreground;
int  clock_background;
char clock_str[ 255 ];
int  clock_str_x;
int  clock_str_y;
int  clock_str_foreground;
int  clock_str_background;

int  date_fl;
int  date_x;
int  date_y;
int  date_foreground;
int  date_background;
char date_str[ 255 ];
int  date_str_x;
int  date_str_y;
int  date_str_foreground;
int  date_str_background;
//_______________________________________________

int main( int argc, char **argv )
{
//_______________________________________________

    FILE *stream;

    char drive[ MAXDRIVE ];
    char dir[ MAXDIR ];
    char file[ MAXFILE ];
    char ext[ MAXEXT ];
    int  num_command;
    char *p;
//_______________________________________________

    char *commands[] = {
			 "str", "fill", "window", "manager",
			 "command", "fool",
			 "anykey", "ifesc", "getkey", "password",
			 "keylist", "yesno", "strprn",
			 "cursorpos", "cursortype",
			 "sound", "cls",
			 "clock", "setclock", "date", "setdate",
			 "stardelay", "setstar", "star", "extstar"
		       };
//_______________________________________________

    line_num = 0;

    star_fl = 1;
    star_delay = 1;
    ext_star_fl = 0;
    star_command[ 0 ] = 0;

    clock_fl = 1;
    clock_x = 80;
    clock_y = 1;
    clock_foreground = 0;
    clock_background = 7;
    clock_str[ 0 ] = 0;
    clock_str_x = 1;
    clock_str_y = 1; 
    clock_str_foreground = 4;
    clock_str_background = 7;

    date_fl = 0;
    date_x = 73;
    date_y = 2;
    date_foreground = 0;
    date_background = 7;
    date_str[ 0 ] = 0;
    date_str_x = 1;
    date_str_y = 1;
    date_str_foreground = 4;
    date_str_background = 7;
//_______________________________________________

    if( argc < 2 )
    {
	puts("");
	printf("**Error** ????????(1) Нe задано имя входного файла\a\n");
	exit( 255 );
    }
//_______________________________________________

    if( strcmp( argv[ 1 ], "?") == 0 || strcmp( argv[ 1 ], "/?") == 0 )
    {
	screen_help();
	exit( 0 );
    }
//_______________________________________________

    fnsplit( argv[ 1 ], drive, dir, file, ext );
    strcpy( ext,".mbe");
    fnmerge( file_name, drive, dir, file, ext );
    p = searchpath( file_name );
    if( p )
    {
	strcpy( file_name, p );
    }
//_______________________________________________

    stream = fopen( file_name, "r");
    if( stream == 0 )
    {
	puts("");
	printf("**Error** ????????(1) Не могу открыть файл %s\a\n",
		file_name );
	exit( 255 );
    }
//_______________________________________________

    do
    {
	    line_num++;
	    source_str[ 0 ] = 0;
	    fgets( source_str, 251, stream );
    }while( !feof( stream ) &&
	  ( strlen( source_str ) == 0 || source_str[ 0 ] == '\n'));
//_______________________________________________

    for( ; !feof( stream ) || strlen( source_str ) != 0; )
    {
	 del_space();
//_______________________________________________

	 if( strlen( work_str ) > 0 && work_str[ 0 ] != '#')
	 {
	     strcpy( tmp_str, strtok( work_str, "\xff"));
	     if( tmp_str[ 0 ])
	     {
		 strlwr( tmp_str );
		 for( num_command = 0;
		      strcmp( commands[ num_command ], tmp_str ) != 0
		      && num_command < 25;
		      num_command++ );
		 if( num_command > 24 )
		 {
		     put_error("Неизвестная команда");
		 }
		 switch( num_command )
		 {
			 case  0: str_c();
				  break; //str

			 case  1: fill_c();
				  break; //fill

			 case  2: window_c();
				  break; //window

			 case  3: manager_c();
				  break; //manager

			 case  4: command_c();
				  break; //command

			 case  5: 
				  break; //run

			 case  6: anykey_c();
				  break; //anykey

			 case  7: ifesc_c();
				  break; //ifesc

			 case  8: getkey_c();
				  break; //getkey

			 case  9: password_c();
				  break; //password

			 case 10: keylist_c();
				  break; //keylist

			 case 11: yesno_c();
				  break; //yesno

			 case 12: strprn_c();
				  break; //strprn

			 case 13: cursorpos_c();
				  break; //cursorpos

			 case 14: cursortype_c();
				  break; //cursortype

			 case 15: sound_c();
				  break; //sound

			 case 16: cls_c();
				  break; //cls

			 case 17: clock_fl = tok_onoff();
				  break; //clock

			 case 18: setclock_c();
				  break; //setclock

			 case 19: date_fl = tok_onoff();
				  break; //date

			 case 20: setdate_c();
				  break; //setdate

			 case 21: stardelay_c();
				  break; //stardelay

			 case 22: tok_str();
				  strcpy( star_command, tmp_str );
				  break; //setstar

			 case 23: star_fl = tok_onoff();
				  break; //star

			 case 24: ext_star_fl = tok_onoff();
				  break; //extstar
		 }
	     }
	 }
//_______________________________________________

	 do
	 {
		 line_num++;
		 source_str[ 0 ] = 0;
		 fgets( source_str, 251, stream );
	 }while( !feof( stream ) &&
	       ( strlen( source_str ) == 0 || source_str[ 0 ] == '\n'));
    }
//_______________________________________________

    fclose( stream );
    return 0;
//_______________________________________________
}