/******************************************************************/
/*                                                                */
/*       Directory Size - calculate the total size and number     */ 
/*     of files ( and separately for hidden, system and other     */
/*     files ) in the specified directory tree ( current by       */
/*     default ).                                                 */
/*                                                                */
/*   Main file : DIRSIZE.C                                        */
/*                                                                */
/*		       CopyRight (c) 1991 by MSH.  Samara.        */
/*                                                                */
/******************************************************************/

#include <stdio.h>
#include <conio.h>
#include <stdlib.h>
#include <dir.h>
#include <dos.h>
#include <string.h>
#include <ctype.h>

#define	PLUR	"ies"
#define	SING	"y"

int dirnum = 0,
    hidnum = 0,
    sysnum = 0,
    nornum = 0,
    totnum = 0,
    clunum = 1; /* 'Cause directory occupied 1 ( usually ) cluster itself */

int bytes_per_cluster;

long hidsize = 0,
     syssize = 0,
     norsize = 0,
     totsize = 0,
     clusize = 0;

char mask[] = "*.*";  /*  Mask for search  */

int FULL = 0;	      /* 1, if full info required 	*/
int CURRENT = 0;      /* 1, if no path specified        */

int screenline;


/*	---------    	     Prototypes	          -----------      */


/*        Recursive function computing size & number of            */
/*      files in the specified directory tree.                     */

	void getsize( void );

/*        Function computing size & number of files separately     */
/*      for hidden, system and other files in the current          */
/*      directory.			                           */

	void getcursize( void );

/*        Function checking 'ffblk.ff_name' for not equality       */
/*      with "." & ".." .     					   */

	int right( struct ffblk* ffblk );

/*      Function that separate each three characters with a comma. */

	char* c( long val );

/*	Print help information.					   */

	void help( void );

/*      ----------------------------------------------------       */

void main( int argc, char* argv[] ) {

char curdir[MAXDIR];
char _path[128];
char* path = _path;
unsigned disk, curdisk;
int path_place = 1;	/* Path	  - the 1st argument in command line */
int switch_place = 2;	/* Switch - the 2nd argument in command line */
struct fatinfo fatinfo;
struct text_info info;


  puts(
  "\nDirectory Size V3.3  Type DS /? for help.               (c) 1991 by MSH."
  );
  puts(
  "--------------------------------------------------------------------------"
  );

  if( *argv[1] == '-' || *argv[1] == '/' ) {
    switch_place = 1;
    path_place = 2;
  }

  if( argc < 2 || ( argc < 3 && switch_place == 1 ) ) {
    strcpy( path, "." );
    CURRENT = 1;
  }
  else {
    strcpy( path, argv[path_place] );
    strupr( path );
  }

  if( argc > switch_place ) {
    switch( toupper( argv[switch_place][1] ) ) {
      case 'F':
	FULL = 1;
      break;
      case 'H':
      case '?':
	help();
	return;
    }
  }

  curdisk = getdisk();
  getcwd( curdir, 127 );

  if( path[1] == ':' ) {
    disk = path[0] - 'A';
    if( setdisk( disk )-1 < disk ) {
      path[2] = 0;
      printf( "\nInvalid drive '%s'.\n", path );
      return;
    }
    path += 2;

    if( !*path ) {
      path = ".";
    }
  }

  if( chdir( path ) == -1 ) {
    printf( "\nInvalid directory '%s'.\n", _path );
    setdisk( curdisk );
    return;
  }

  getfatd( &fatinfo );
  bytes_per_cluster = fatinfo.fi_sclus * fatinfo.fi_bysec;

  gettextinfo( &info );
  if( ( screenline = wherey() ) == info.screenheight )
    screenline = info.screenheight-1;

  getsize();

  clusize = (long) clunum * bytes_per_cluster;

  setdisk( curdisk );
  chdir( curdir );

  if( CURRENT )
    printf( "Current directory" );
  else
    printf( "Directory %s", _path );
  if( dirnum ) {
    printf( " contains %d sub-director%s." , dirnum,
					     dirnum > 1 ? PLUR : SING );
  }
  else {
    printf( " doesn't contain sub-directories." );
  }
  clreol();
  printf( "\n\nOccupied disk space :\n" );
  if( FULL ) {
    printf( " --------------------------------------------\n" );
    printf( " Hidden : %11s  bytes  in %4i file(s)\n", c(hidsize), hidnum );
    printf( " System : %11s  bytes  in %4i file(s)\n", c(syssize), sysnum );
    printf( " Other  : %11s  bytes  in %4i file(s)\n", c(norsize), nornum );
  }
  printf( " --------------------------------------------\n" );
  printf( " Total  : %11s  bytes  in %4i file(s).\n", c(totsize), totnum );
  printf( " Space  : %11s  bytes  in %4i cluster(s).\n", c(clusize), clunum );
}

void getsize() {

static char path[ MAXDIR ];
struct ffblk ffblk;
int done;

  getcursize();

  done = findfirst( mask, &ffblk, FA_DIREC );

  while ( !done )
  {
    if( right( &ffblk ) && ffblk.ff_attrib & FA_DIREC )
    {
      dirnum++;
      clunum += 1;
      chdir( ffblk.ff_name );
      printf( "%s", getcwd( path, MAXDIR ) );
      clreol();
      putchar( '\n' );
      gotoxy( 1, screenline );
      getsize();
      chdir( ".." );
    }

    done = findnext(&ffblk);
  }
}

void getcursize( void ) {

struct ffblk ffblk;
int done;

  done = findfirst( mask, &ffblk,
		    FA_HIDDEN | FA_SYSTEM | FA_ARCH | FA_RDONLY );

  while ( !done ) {

    if( !( (FA_LABEL | FA_DIREC) & ffblk.ff_attrib ) &&
	right( &ffblk ) )
    {
      totsize += ffblk.ff_fsize;

      clunum += (int) ( ( ffblk.ff_fsize + bytes_per_cluster - 1 )
		       / bytes_per_cluster );
      totnum++;

      if( FA_HIDDEN & ffblk.ff_attrib )
      {
	hidnum++;
	hidsize += ffblk.ff_fsize;
      }
      if( FA_SYSTEM & ffblk.ff_attrib )
      {
	sysnum++;
	syssize += ffblk.ff_fsize;
      }
      if( !( (FA_SYSTEM | FA_HIDDEN) & ffblk.ff_attrib ) )
      {
        nornum++;
        norsize += ffblk.ff_fsize;
      }
    }
    done = findnext(&ffblk);
  }
}

int right( struct ffblk* ffblk ) { return  *(ffblk->ff_name) != '.'; }

char* c( long val ) {

char str[20];
static char res[20] = "                   ";
char* ptr;
int i, len;

  ltoa( val, str, 10 );
  len = strlen( str );
  res[19] = 0;
  ptr = res + 19;
  for( i=len-1; i>=0; i-- ) {
    *(--ptr) = str[i];
    if( !( (len-i)%3 ) && i ) *(--ptr) = ',';
  }

  return ptr;
}

void help( void ) {
 puts(
 "Compute total size of the specified directory tree ( current by default )."
  ); puts(
 "\n Usage : DS [<where>] [{/|-}<switch>]\n" );
 puts(
 "\t<where> ::= [<disk>] [<path>]\n" );
 puts(
 "\t<path>   : Path to directory ( default \".\" )." );
 puts(
 "\t<switch> : F - Display information about hidden and system files." );
 puts(
 "\t           H or ? - This screen.\n" );
 puts(
 "--------------------------------------------------------------------------"
 );
 puts(
 "Version 3.3  June 20, 1991  Samara Aviation Institute \"MSH\" t.(846)66-32-84"
 );
}