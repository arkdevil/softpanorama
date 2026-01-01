//╔═════════════════════════════════════════════════════════════════════════╗
//║                                                                         ║
//║	    Module name	: 	mbe.h                                       ║
//║   	    Date	: 	9 July 1991                                 ║
//║    	    Environment	: 	Turbo C++ 1.0                               ║
//║    	    Language    :       Turbo C                                     ║
//║    	    Author	: 	Melnik Oleg                                 ║
//║    	    Notice	:                                                   ║
//║                                                                         ║
//╚═════════════════════════════════════════════════════════════════════════╝

void screen_help( void );
void del_space( void );
void put_error( char* );

void tok_str( void );
int tok_x( void );
int tok_y( void );
int tok_foreground( void );
int tok_background( void );
int tok_char( void );
int tok_int( void );
int tok_onoff( void );

void check_x_range( int, int );
void check_y_range( int, int );

void str_c( void );
void fill_c( void );
void window_c( void );
void manager_c( void );
void command_c( void );
void anykey_c( void );
void ifesc_c( void );
void getkey_c( void );
void password_c( void );
void keylist_c( void );
void yesno_c( void );
void strprn_c( void );
void cursorpos_c( void );
void cursortype_c( void );
void sound_c( void );
void cls_c( void );
void setclock_c( void );
void setdate_c( void );
void stardelay_c( void );
void setstar_c( void );
void star_sky( void );

void sprint( char*, int, int, int, int );
void fill( int, int, int, int, int, int, int );
void windows( int[], char* );
int  tolowerr( int );
void strlwrr( char* );
int  stricmpr( char*, char* );
int  get_key( void );
void manager( int[] );
void cprint( char, int, int, int, int );
//_______________________________________________

#define	UP	  	72					
#define	DOWN    	80
#define	LEFT   		75
#define	RIGHT   	77
#define	HOME    	71
#define	END     	79
#define	SPACE   	32
#define	ENTER   	13
#define	ESC     	27
//_______________________________________________