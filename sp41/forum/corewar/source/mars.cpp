		//					//
		//		MARS.CPP		//
		//					//
//--------------------------------------------------------------------//



#include <stdio.h>
#include <conio.h>
#include <stdlib.h>
#include <time.h>
#include <io.h>
#include <fcntl.h>
#include <alloc.h>
#include <graphics.h>
#include <string.h>
#include "keys.h"

#pragma hdrstop

#define B 1
#define R 2
#define W 3

#define GRAPHICS_NEED

#include "mars.h"

TREE a, b;

void main( int argc, char *argv[] ) {

  if( argc < 3 ) {
    puts( " M A R S  -- Memory Array Redcode Simulator       (c)91 by MSH" );
    puts( "\n  Usage : MARS < file_name_1 > < file_name_2 > \n");
    return;
  }

int handle1,handle2;
char name1[100],
     name2[100];

  strupr( argv[1] );
  strcpy( name1, argv[1] );
  append_extention( name1, ".COM" );
  strupr( argv[2] );
  strcpy( name2, argv[2] );
  append_extention( name2, ".COM" );

  handle1 = openfile( name1 );
  handle2 = openfile( name2 );

  randomize();
  do {
    a.current->pc = random( MAX_SMALL );
    b.current->pc = random( MAX_SMALL );
  } while ( ( a.current->pc-b.current->pc ) < SMALL_INT(1000) );

SMALL_INT start_a, start_b;
  _read( handle1, &start_a, 2);
  _read( handle2, &start_b, 2);

#ifdef GRAPHICS_NEED
  init_graph();
#endif

  SMALL_INT i;

  for( i=0; !eof( handle1 ); i++ ) {
#ifdef GRAPHICS_NEED
    bar4( a.current->pc+i, B );
#endif
    _read( handle1, &COMMAND::array[(a.current->pc+i).data], sizeof( COMMAND ) );
  }

  for( i=0; !eof( handle2 ); i++ ) {
#ifdef GRAPHICS_NEED
    bar4( b.current->pc+i, R );
#endif
    _read( handle2, &COMMAND::array[(b.current->pc+i).data], sizeof( COMMAND ) );
  }

  getch();

  a.current->pc += start_a;
  b.current->pc += start_b;

  _close( handle1 );
  _close( handle2 );


SMALL_INT code;
char key;
int print_need = 1;
SMALL_INT pc;

  print_mem();

  for(;;) {

    while( kbhit() ) {

      key = getch();

      switch( key ) {
	case ESC:
	  message("Interrupted by user");
	  return;
	case CR:
#ifdef GRAPHICS_NEED	
	  if( print_need ) {
	    setfillstyle( SOLID_FILL, 0 );
	    bar( 0, 150, 319, 199 );
	  }
	  else {
	    print_mem();
	  }
#endif	  
	  print_need = !print_need;
	break;
      }
    }

    COMMAND::current_execute = &a.current->pc;
#ifndef GRAPHICS_NEED
    COMMAND::array[ a.current->pc.data ].print();
#else
    PROG_COLOR = B;
    pc = a.current->pc;
    bar4( pc, 0 );
#endif
    if( ( code = COMMAND::
	  array[ a.current->pc.data ].execute( a.current->pc ) ) == OOPS ) {
      if( a.remove() == -1 ) {
	win( argv[2] );
      }
      else {
	if( print_need ) print_mem();
      }
    }
    else {
      if( code == SPL ) {
	if( a.add( _SPL_PC ) == -1 ) {
	  message( "Not enough memory.");
	  return;
	}
	if( print_need ) print_mem();
      }
      else {
	a.next();
      }
    }
#ifdef GRAPHICS_NEED
  bar4( pc, PROG_COLOR );
#endif

    COMMAND::current_execute = &b.current->pc;
#ifndef GRAPHICS_NEED
    COMMAND::array[ b.current->pc.data ].print();
#else
    PROG_COLOR = R;
    pc = b.current->pc;
    bar4( pc, 0 );
#endif
    if( ( code = COMMAND::
	  array[ b.current->pc.data ].execute( b.current->pc ) ) == OOPS ) {
      if( b.remove() == -1 ) {
	win( argv[1] );
      }
      else {
	if( print_need ) print_mem();
      }
    }
    else {
      if( code == SPL ) {
	if( b.add( _SPL_PC ) == -1 ) {
	  message( "Not enough memory.");
	  return;
	}
	if( print_need ) print_mem();
      }
      else {
	b.next();
      }
    }
#ifdef GRAPHICS_NEED
  bar4( pc, PROG_COLOR );
#endif
  }
}

void win( char name[] ) {
  char str[50];

  sprintf( str, "Program '%s' won!", name );
  message( str );
}


void message( char *str ) {

#ifndef GRAPHICS_NEED
  puts( str );
  getch();
#else
  setfillstyle( SOLID_FILL, 0 );
  bar( 60, 80, 65+textwidth( str ), 98 );
  setfillstyle( SOLID_FILL, W );
  bar( 55, 75, 60+textwidth( str ), 93 );
  setcolor( 0 );
  outtextxy( 60, 80, str );
  getch();
  restorecrtmode();
#endif
  exit(0);
}

void init_graph( void )

{ int GraphDriver=CGA,GraphMode=CGAC1,ErrorCode;

//  registerbgidriver ( EGAVGA_driver );
  registerbgidriver ( CGA_driver );
  initgraph ( &GraphDriver,&GraphMode,"");
  if ( (ErrorCode = graphresult()) != grOk ) {
    closegraph();
    printf ("Graph Err : %s \n", grapherrormsg(ErrorCode));
    exit(1);
  }
}

void bar4( SMALL_INT adr, int color ) {

  putpixel( adr.data%160*2, adr.data/160*2, color );
  putpixel( adr.data%160*2+1, adr.data/160*2, color );
  putpixel( adr.data%160*2, adr.data/160*2+1, color );
  putpixel( adr.data%160*2+1, adr.data/160*2+1, color );
}

void print_mem( void ) {

static char str1[30],str2[10],str3[10];

  sprintf( str1, "Free memory : %lu",coreleft() );
  sprintf( str2, "A: %d", a.nodes );
  sprintf( str3, "B: %d", b.nodes );
#ifdef GRAPHICS_NEED
  setfillstyle( SOLID_FILL, 0 );
  bar( 100, 160, 320, 170 );
  setcolor( W );
  outtextxy( 0, 160, str1 );
  setcolor( B );
  outtextxy( 200, 160, str2 );
  setcolor( R );
  outtextxy( 260, 160, str3 );
#else
  printf("%s    %s  %s", str1, str2, str3);
#endif
}

void append_extention( char *name, char *ext ) {

  if( strrchr( name, '.' ) == NULL ) {
    strcat( name, ext );
  }
}

int openfile( char* name ) {

int handle;
char buf[63];

  if( (handle=_open( name, O_RDONLY )) == -1 ) {
    printf("\nCan't open file '%s'", name );
    exit(1);
  }
  _read( handle, buf, 63 );
  if( memcmp( buf, (void*)STUB, 63 ) ) {
    printf( "'%s' is not MARS executable file.\n", name );
    exit(1);
  }
  return handle;
}
