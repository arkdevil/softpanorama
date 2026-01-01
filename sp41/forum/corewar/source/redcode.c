	/*						*/
	/*		REDCODE.C			*/
	/*						*/
/* ---------------------------------------------------------------- */


#include <stdio.h>
#include <stdlib.h>
#include <io.h>
#include <string.h>
#include <alloc.h>
#include <fcntl.h>
#include <ctype.h>
#include <sys\stat.h>
#include <dos.h>
#pragma hdrstop
#include "redcode.h"


char text[ MAX_STR ][MAX_LEN];
LABEL label[ MAX_LABEL ];
int max_label;
int handle;
char *name;

int main( int argc, char *argv[] ) {

  FILE *file;
  char *(words[ MAX_STR ][ 4 ]);
  char *ptr,*str;
  int i,j;
  int max_str;
  int start;
  CODE code;
  int two_op;
  int const1, const2;
  int pr = 0;

  puts("\n RedCode -- CoreWar programm compiler for MARS -");
  puts("	    - Memory Array Redcode Simulator.    (c)91 by MSH\n");


  if( argc < 2 ) {
    puts("Usage : REDCODE <source_file>\n");
    return 2;
  }

  strupr( argv[1] );

  if( (file=fopen( argv[1],"rt" ))==NULL ) {
    printf("Can't open input file '%s'.", argv[1]);
    return 2;
  }

  name = malloc( strlen( argv[1] ) + 4 );
  strcpy( name, argv[1] );
  strupr( name );
  if( (ptr=strrchr( name, '.')) == NULL ) ptr = name + strlen( name );
  strcpy( ptr, ".COM" );

  if( (handle=_creat( name, FA_ARCH )) == -1 ) {
    printf("Can't open output file '%s'", name );
    free( name );
    return 2;
  }
  free( name );

  _write( handle, (void*)STUB, 63 );

  printf("Compiling from '%s' to '%s' :\n", argv[1], name );

  for(max_str=0; !feof( file ) && ( max_str<MAX_STR ); )  {
    fgets( text[max_str], 80, file );         /* Read the source text */
    if( strstr( strlwr(text[max_str]), END_LABEL ) ) goto NEXT_PASS;
    if( strchr( text[max_str], ';' ) == NULL ) {
      for(i=0; i<strlen(text[max_str]); i++) {
	if( right_char( text[max_str][i] ) ) {
	  pr = 1;
	  break;
	}
      }
    }
    if( pr ) {
      strlwr( text[max_str++] );
      pr = 0;
    }
  }
  puts( "\nError : Unexpected end of file." );
  remove( name );
  return 1;

NEXT_PASS:
  fclose( file );

  printf("\n Pass 1 ");

  for( i=0; i<max_str; i++ ) {                 /* Create array with     */
    str = text[i];			       /* elements pointed to   */
    if( (ptr=strchr( str, ':')) != NULL ) {    /* words of the source   */
      *ptr = ' ';			       /* text.		        */
      j = 0;                                   /* ( ...the first pass ) */
    }
    else {
      words[i][0] = 0;
      j = 1;
    }
    ptr = str;
    for( ; j<4; j++ ) {
      while( !right_char( *ptr ) ) ptr++;
      words[i][j] = ptr;
      while( right_char( *ptr ) ) ptr++;
      if( ptr >= str+MAX_LEN ) break;
      *ptr = 0;
    }
    printf(".");
  }

  printf("\n Pass 2 ");

  start = -1;
  for( i=0,max_label=0; i<max_str; i++ ) {      /* Create label array     */
    if( words[i][0] ) {			        /* ( ...the second pass ) */
      label[max_label].str = words[i][0];
      if( !strcmp( strlwr(label[max_label].str), START_LABEL ) ) start = i;
      label[max_label++].num = i;
    }
    printf(".");
  }
  if( start == -1 ) start = 0;
  write( handle, &start, sizeof( start ) );

  printf("\n Pass 3 ");

  for( i=0; i<max_str; i++ ) {     /* Compiling ( ...the third pass ) */

    if( (code.command=compile_command( words[i][1] ,
				      &two_op, &const1, &const2 )) == 255 ) {
      syntax_error( COMMAND_ERR, i );
    }
    if( (ptr = compile_operand( words[i][2], &code.adr1, &code.oper1, i ))
	!= NULL ) { syntax_error( ptr, i ); }

    if( (code.adr1 == 0) && ( !const1 ) ) syntax_error( INV_ADR_ERR, i );

    if( two_op ) {
      if ( (ptr = compile_operand( words[i][3], &code.adr2, &code.oper2, i ))
	!= NULL ) { syntax_error( ptr, i ); }

    if( (code.adr2 == 0) && ( !const2 ) ) syntax_error( INV_ADR_ERR, i );

    }
    else {
      code.adr2  = code.adr1;
      code.oper2 = code.oper1;
    }

    _write( handle, &code, sizeof( code ) );
    printf(".");
  }
  _close( handle );
  printf("\n\n  Done.\n");
  return 0;
}

BYTE compile_command( char *str, int *two_op , int *const1, int *const2 ) {

int i;

  for( i=0; i<MAX_COMMAND; i++ ) {
    if( !strcmp( str,command[i].text ) ) {
      *two_op = command[i].two_op;
      *const1 = command[i].const1;
      *const2 = command[i].const2;
      return command[i].code;
    }
  }
  return 255;
}

char *compile_operand( char *str, BYTE *adr, int *oper, int str_num) {

int i,j;

  if( strchr( POSSIBLE_ADR, *str ) == NULL ) {
    if( atoi( str ) !=0 || *str == '0' ) {
      *oper = ( atoi( str ) + 8000 ) % 8000;
      *adr = 1;
      return NULL;
    }
    else {
      for( j=0; j<max_label; j++ ) {
	if( !strcmp( str, label[j].str ) ) {
	  *adr = 1;
	  *oper = (( label[j].num - str_num )+8000)%8000;
	  return NULL;
	}
      }
      return UNDEF_LABEL_ERR;
    }
  }
  else {
    for( i=0; i<MAX_ADR; i++ ) {
      if( *str == adr_method[i].text ) {
	*adr = adr_method[i].code;
	if( atoi( str+1 ) !=0 || *(str+1)=='0' ) {
	  *oper = ( atoi( str+1 ) + 8000 ) % 8000;
	  return NULL;
	}
	else {
	  for( j=0; j<max_label; j++ ) {
	    if( !strcmp( str+1, label[j].str ) ) {
	      *oper = (( label[j].num - str_num )+8000)%8000;
	      return NULL;
	    }
	  }
	  return UNDEF_LABEL_ERR;
	}
      }
    }
    return OPERAND_ERR;
  }
}

int right_char( char c ) {

int i;

  if( isalnum( c ) || c == '-' || c == '+') return 1;
  for(i=0; i<MAX_ADR; i++ ) {
    if( c == adr_method[i].text ) return 1;
  }
  return 0;
}

void syntax_error( char *str, int n ) {
char comm[100];

  printf( "\nError : %s", str );
  if( n >= 0 ) printf(" in line %d.", n+1 );
  putchar('\n');
  _close(handle);
  sprintf( comm,"del %s",name );
  system( comm );
  exit(1);
}


