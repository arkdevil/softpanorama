/******************************************************************/
/*                                                                */
/*       Directory Size - calculate the total size and number     */
/*     of files ( and separately for hidden, system and other     */
/*     files ) in the specified directory tree ( current by       */
/*     default ).                                                 */
/*                                                                */
/*   Main file : DIRSIZE.C                                        */
/*                                                                */
/*		       Copyright (c) MSH  1991  Samara.           */
/*                                                                */
/******************************************************************/

#define VERSION "3.5"

#include <stdio.h>
#include <conio.h>
#include <stdlib.h>
#include <dir.h>
#include <dos.h>
#include <string.h>
#include <ctype.h>

#define	PLUR	"ies"
#define	SING	"y"

unsigned
    dirnum = 0,
    hidnum = 0,
    sysnum = 0,
    nornum = 0,
    totnum = 0,
    clunum = 0,

    total_files = 0,
    total_clusters = 0;

int bytes_per_cluster;

unsigned long
    hidsize = 0,
    syssize = 0,
    norsize = 0,
    totsize = 0,
    clusize = 0,

    total_size = 0,
    total_clusize = 0;

char *mask = "*.*";  /*  Mask for search  */

int ALL = 0;          /* 1, if need info about all files*/
int BRIEF = 0;	      /* 1, if brief info required 	*/
int NO_PATH = 1;      /* 1, if no path specified        */

int screenline;


/*	---------    	     Prototypes	          -----------      */

/*        Main function that computes and prints all information   */
/*        Returns 0 if error occured, 1 otherwise.                 */

	int proceed_dir( char *drive, char *dir, char* name );

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

	char* c( unsigned long val );

/*	Print help information.					   */

	void help( void );

/*      ----------------------------------------------------       */

void main( int argc, char* argv[] ) {

char curdir[MAXDIR];
unsigned curdisk;
int i, n;


  printf(
  "\nDirectory Size V%s   Type DS /? for help.       Copyright (c)MSH 1991,92\n"
  , VERSION );
  puts(
  "--------------------------------------------------------------------------"
  );

  for( i=1; i<argc; i++ ) {

    if( *argv[i] == '-' || *argv[i] == '/' ) {

      switch( toupper( argv[i][1] ) ) {
	case 'A':
	  ALL = 1;
	  break;
	case 'B':
	  BRIEF = 1;
	  break;
	case 'F':
	  mask = &argv[i][3];
	  printf( "Files matching %s only :\n", mask );
	  break;
	case 'H':
	case '?':
	  help();
	  return;
      }
    }
    else NO_PATH = 0;
  }

  curdisk = getdisk();
  getcwd( curdir, 127 );
  if( NO_PATH ) {
    argc = 2;
    argv[1] = curdir;
  }

  for( n=0,i=1; i<argc; i++ ) {

    int flags;
    char drive[MAXDRIVE], dir[MAXDIR], name[MAXFILE+MAXEXT],
	 ext[MAXEXT];

    if( *argv[i] == '-' || *argv[i] == '/' ) continue;

    flags = fnsplit( strupr( argv[i] ), drive, dir, name, ext );

    if( flags & DRIVE ) {
      if( setdisk( *drive - 'A' )-1 < *drive - 'A' ) {
	printf( "Error : Invalid drive %s\n", drive );
	continue;
      }
    }

    if( flags & DIRECTORY ) {
      int len = strlen( dir );
      if( dir[len-1] == '\\' && len > 1 ) dir[len-1] = 0;
      if( chdir( dir ) == -1 ) {
	printf( "Error : Invalid directory %s\n", dir );
	setdisk( curdisk );
	continue;
      }
    }

    strcat( name, ext );
    if( flags & WILDCARDS ) {
      struct ffblk ffblk;
      if( findfirst( name, &ffblk, FA_DIREC ) == -1 ) {
	printf( "Error : No directories matches %s\n", argv[i] );
	continue;
      }
      do {
	if( ffblk.ff_attrib & FA_DIREC && right( &ffblk ) &&
	    proceed_dir( drive, dir, ffblk.ff_name ) ) n++;
      } while( findnext( &ffblk ) != -1 );
    }
    else {
      if( flags & FILENAME ) {
	if( proceed_dir( drive, dir, name ) ) n++;
      } else {
	if( proceed_dir( drive, dir, "" ) ) n++;
      }
    }
  }

  setdisk( curdisk );
  chdir( curdir );

  if( n > 1 ) {
    puts("--------------------------------------------------------------------------");
    printf( "Total :\n%11s ", c(total_size) );
    printf( "(%11s) bytes in %4i file(s) (%4i cluster(s)).\n",
	    c(total_clusize), total_files, total_clusters );
  }
}

int proceed_dir( char *drive, char *dir, char* name ) {

struct fatinfo fatinfo;
struct text_info info;

  if( *name && chdir( name ) == -1 ) {
    printf( "\nError : Invalid directory %s%s", drive, dir );
    if( *name ) {
      if( dir[strlen(dir)-1] != '\\' ) putchar( '\\' );
      printf( "%s", name );
    }
    putchar( '\n' );
    return 0;
  }

  dirnum = hidnum = sysnum = nornum = totnum = 0;
  hidsize = syssize = norsize = totsize = clusize = 0;
  clunum = 0;

  getfatd( &fatinfo );
  bytes_per_cluster = fatinfo.fi_sclus * fatinfo.fi_bysec;

  gettextinfo( &info );
  if( ( screenline = wherey() ) == info.screenheight )
    screenline = info.screenheight-1;

  getsize();

  clusize = (long) clunum * bytes_per_cluster;
  total_files += totnum; total_size += totsize;
  total_clusters += clunum; total_clusize += clusize;

  printf( "%s%s", drive, dir );
  if( *name ) {
    if( dir[strlen(dir)-1] != '\\' ) putchar( '\\' );
    printf( "%s", name );
  }
  if( dirnum ) {
    printf( " ( %d sub-director%s ) :" , dirnum,
					     dirnum > 1 ? PLUR : SING );
  }
  else {
    printf( " (no sub-directories) :" );
  }
  clreol();
  if( !BRIEF ) {
    printf( "\nOccupied disk space :\n", mask );
    if( ALL ) {
      printf( " Hidden : %11s  bytes  in %4i file(s)\n", c(hidsize), hidnum );
      printf( " System : %11s  bytes  in %4i file(s)\n", c(syssize), sysnum );
      printf( " Other  : %11s  bytes  in %4i file(s)\n", c(norsize), nornum );
    }
    printf( " Size   : %11s  bytes  in %4i file(s)\n", c(totsize), totnum );
    printf( " Space  : %11s  bytes  in %4i cluster(s)\n\n", c(clusize), clunum );
  }
  else {
    printf( "\n%11s ", c(totsize) );
    printf( "(%11s) bytes in %4i file(s) (%4i cluster(s)).\n",
            c(clusize), totnum, clunum );
  }
  if( *name ) chdir( ".." );
  return 1;
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
	right( &ffblk ) ) {

      totsize += ffblk.ff_fsize;

      clunum += (int) ( ( ffblk.ff_fsize + bytes_per_cluster - 1 )
		       / bytes_per_cluster );
      totnum++;

      if( ALL ) {
	if( FA_HIDDEN & ffblk.ff_attrib ) {
	  hidnum++;
	  hidsize += ffblk.ff_fsize;
	}
	if( FA_SYSTEM & ffblk.ff_attrib ) {
	  sysnum++;
	  syssize += ffblk.ff_fsize;
	}
      }
      if( !( (FA_SYSTEM | FA_HIDDEN) & ffblk.ff_attrib ) ) {
	nornum++;
	norsize += ffblk.ff_fsize;
      }
    }
    done = findnext(&ffblk);
  }
  clunum += (unsigned)( ( ((unsigned long)totnum << 4)
	    + bytes_per_cluster - 1 ) / bytes_per_cluster );
}

int right( struct ffblk* ffblk ) { return  *(ffblk->ff_name) != '.'; }

char* c( unsigned long val ) {

char str[20];
static char res[20] = "                   ";
char* ptr;
int i, len;

  ultoa( val, str, 10 );
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
 "\n Usage : DS [<where>]... [{/|-}<switch>]...\n\n"
 "\t<where> ::= [<disk>] [<path>]\n"
 "\t<path>   : Path to directory ( default \".\" ). Wildcards are allowed.\n"
 "\t<switch> : A - Display information about hidden and system files.\n"
 "\t           B - Brief output format.\n"
 "\t           H or ? - This screen.\n"
 "\t           F:<mask> - count files matching <mask> only.\n\n"
 "Example : DS C:\A*.* D:F* /b /f:*.exe\n"
 "Meaning : Compute total size of all EXE files in directories\n"
 "          matching C:\A*.* and D:F*\n"
 "--------------------------------------------------------------------------"
 );
 printf(
 "Version %s  %s  Samara Aviation Institute \"MSH\" p.(846)66-32-84",
 VERSION, __DATE__ );
}