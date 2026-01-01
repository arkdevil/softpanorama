/******************************************************************/
/*                                                                */
/*       Run Tree - run specified command in each sub-directory   */
/*     of current directory.					  */
/*                                                                */
/*   Main file : RUNTREE.C                                        */
/*                                                                */
/*		       CopyRight (c) 1991 by MSH.  Samara.        */
/*                                                                */
/******************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <dir.h>
#include <dos.h>
#include <string.h>

char startdir[MAXDIR];
char command[256] = { ' ' };
char mask[] = "*.*";  /*  Mask for search  */
int CtrlBreak = 0;    /* 1, if Ctrl-Break was pressed */
void far interrupt (*Old9)(); /* Old 9th interrupt handler */


/*	---------    	     Prototypes	          -----------      */


/*      Running thru the tree recursive function.                  */

	void thrutree( void );

/*      Function checking 'name' for not equality with "." & ".."  */

	int right( char name[] );

/*	Print help information.					   */

	void help( void );

/*	Ctrl-Break handler.					  */

	void ctrlbrk_handler( void );

/*	New 9th interrupt handler.				  */

	void interrupt New9( void );

/*	Set new 9th interrupt handler.				  */

	void setctrlbrk( void );

/*      ----------------------------------------------------       */

/*
void ctrlbrk_handler( void ) {

  puts( "Ctrl-Break was pressed - program aborted." );
  chdir( startdir );
  setvect( 0x9, Old9 );
  exit(0);
}
*/
void main( int argc, char* argv[] ) {

int i;

  puts(
  "\nRunTree V1.0  Type RT ? for help.               (c) 1991 by MSH."
  );
  puts(
  "-------------------------------------------------------------------------"
  );

  if( *argv[1] == '?' ) {
    help();
    return;
  }

  for( i=1; i<argc; i++ ) {
    strcat( command, argv[i] );
    strcat( command, " " );
  }

  getcwd( startdir, 127 );
/*  setctrlbrk(); */
  thrutree();
  chdir( startdir );
/*  setvect( 0x9, Old9 ); */
}

void thrutree( void ) {

int done;
char curdir[ MAXDIR ];
struct ffblk ffblk;

/*  if( CtrlBreak ) ctrlbrk_handler(); */

  printf( "\n%s %s\n\n", ( getcwd( curdir, MAXDIR ), curdir ), command );
  system( command );
  clreol();

  done = findfirst( mask, &ffblk, FA_DIREC );

  while ( !done )
  {
    if( right( ffblk.ff_name ) && ffblk.ff_attrib & FA_DIREC )
    {
      chdir( ffblk.ff_name );
      thrutree();
      chdir( ".." );
    }

    done = findnext(&ffblk);
  }
}

int right( char name[] ) { return  *name != '.'; }

void help( void ) {
 puts(
 "Run specified command in each sub-directory of current directory."
  ); puts(
 "\n Usage : RT [<command>]\n" );
 puts(
 "--------------------------------------------------------------------------"
 );
 puts(
 "Version 1.0  May 3, 1991  Samara Aviation Institute \"MSH\" t.(846)66-32-84"
 );
}

/*
void setctrlbrk( void ) {

  setvect( 0x60, Old9 = getvect( 0x9 ) );
  setvect( 0x9, New9 );
}
*/