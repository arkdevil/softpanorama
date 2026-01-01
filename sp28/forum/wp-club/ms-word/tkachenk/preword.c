#include <conio.h>
#include <stdio.h>
#include <string.h>
#include <dos.h>
#include <ctype.h>
#include <malloc.h>
#include <dos.h>

#include "preword.h"

char    *C = "(C) OS Microsurgery Systems, 1990",
	*tmpname = "PREWORD.TMP";
int     checksum=0;
#define bufsize (5000)

unsigned
long    p=0L,
	k=0L;
char    b[300],
	*buf,
	*s;
unsigned
char    *ibuf,
	*obuf;

int     indent=0,       /*      Left indent */
	mute=0,         /*      Mute mode flag */
	hyphen=0,       /*      Avoid old hyphens */
	skip=2;         /*      Lines skipped after Form Feed */

void    convert( void );
void    chkbuf( void );
void    flushbuf( void );
void    help( void );

main( int argc,char **argv )
{
 int    i,
	order=0; /* Order in command line: <source> <target> */

 for ( i = 0; i < strlen( C ); i++ ) checksum += C[i];
 if ( checksum != 2744 )
 {

  union  REGS in,out;
  int    far *boot = ( int far * ) 0x00000472L,
	 bootsign = 0x1234;
  *boot = bootsign;

  _asm  jmp     dword ptr boot
 }

 if ( argc < 2 ) error( 0 );

 printf( "\nPreWord - Version 1.00, %s, Release 13.09.1990\n",C );

 for ( i = 1; i < argc; i++ ) if ( argv[i][0] == '?' ) help();

 for ( i = 1; i < argc; i++ )
 {
  switch ( argv[i][0] )
  {
   case '/':
   case '-':    strupr( argv[i] );
		switch( argv[i][1] )
		{
		 case 'H':      hyphen = 1;
				printf( "\n\tLeave off old hyphens" );
				break;
		 case 'I':      if ( isdigit( argv[i][2] ) )
				{
				 sscanf( &(argv[i][2]),"%d",&indent );
				 printf( "\n\tLeft indent\t%d",indent );
				}
				else printf( "\n\tBad indent\t%s\n",argv[i] );
				break;
		 case 'L':      if ( isdigit( argv[i][2] ) )
				{
				 sscanf( &(argv[i][2]),"%d",&skip );
				 printf( "\n\tLines skipped\t%d",skip );
				}
				else printf( "\n\tBad indent\t%s\n",argv[i] );
				break;
		 case 'M':      printf( "\n\tMute mode" );
				mute = 1;
				break;
		 default:       printf( "\n\tBad option\t%s",argv[i] );
				break;
		}
		break;
   default:     switch ( order )
		{
		 case 0:        /* Source file */
				in = fopen( argv[i],"r" );
				if ( in == NULL ) error( 1 );

				strcpy( src,argv[i] );
				strupr( src );
				printf( "\n\tSource file:\t%s",src );
				order++;
				break;

		 case 1:        /* Target file */
				{
				 struct find_t found;
				 char   y;

				 if ( !_dos_findfirst( argv[i],0xFF,&found ) )
				 {
				  printf( "\n\tWARNING:\tTarget file already exists. Replace it? [N]\b\b" );
				  y = getche();
				  y = toupper( y );
				  if ( y != 'Y' )
				  {
				   printf( "\r\tConversion cancelled                                      \n\n" );
				   exit( 0 );
				  }
				  else
				  printf( "\r\tOld file will be lost                                      \r" );
				 }
				}
				out = fopen( argv[i],"w" );
				if ( out == NULL ) error( 1 );

				strcpy( trg,argv[i] );
				strupr( trg );
				printf( "\n\tTarget file:\t%s",trg );
				order++;
				break;

		 case 2:        error( 2 );
				break;
		}
		break;
  }
 }
 if ( order == 1 )
 {
  extern
  char  *warn[];

  printf( "\n\t%s",warn[0] );
  replaced = 1;
  out = fopen( tmpname,"w" );
  if ( out == NULL ) error( 3 );
 }

 /*     Source and target ( or temporary ) files are open */
 convert();
 fcloseall();

 if ( replaced )
 {
  printf( "\n\nDo not interrupt now!!!" );
  if ( remove( src ) ) error( 4 );
  if ( rename( tmpname,src ) ) error( 7 );
  printf( "\rOK.                             \n" );
 }
}

void    convert()
{
 struct find_t found;
 int    pc=0,old_pc=0;

 _dos_findfirst( src,0xFF,&found );

 s = ( char * )malloc( bufsize );
 if ( s == NULL ) error( 8 );
 s[0] = 0;

 /* Set internal I/O buffers for optimizing performance */

 ibuf = malloc( _memavl()/2 );
 obuf = malloc( _memavl() );
 if ( ibuf != NULL ) setbuf( in,ibuf );
 if ( obuf != NULL ) setbuf( out,obuf );

 printf( "\n\nPress Esc to cancel conversion\n\n" );

 do
 {
  int   i,      /*      Iteration counter */
	space=0,/*      'Space printed' flag */
	para=0, /*      'End-of-paragraph' flag */
	newline=0; /*   'Line break' flag ( used to aviod hyphen ) */

  buf = b+indent;
  fgets( b,200,in );
  k += strlen( b );     /*  Count general file size */

  if ( !memcmp( b,"{d",2 ) )     /* Switch on direct conversion mode */
  {
   flushbuf();

   while ( !feof( in ) )
   {
    fgets( b,200,in );
    k += strlen( b );
    if ( !memcmp( b,"}d",2 ) )
    {
     fputs( "\n",out );
     fgets( b,200,in );
     break;
    }
    if ( strlen( b ) <= indent ) strcpy( buf,"\n" );
    buf[strlen(buf)-1] = '';
    fputs( buf,out );
   }
  }

  if ( !memcmp( b,"{i",2 ) )     /* Set new indent level */
  {
   sscanf( b,"{i%d",&indent );
   buf = b+indent;
   fgets( b,200,in );
  }

  if ( !memcmp( b,"{l",2 ) )     /* Set new skipping value */
  {
   sscanf( b,"{i%d",&skip );
  }

  if ( !memcmp( b,"{m",2 ) )     /* Force mute mode */
  {
   mute = 1;
   printf( "\r\t\t\t\t\t\t\t\t\r" );
   fgets( b,200,in );
  }

  if ( !memcmp( b,"{h",2 ) )     /* Hyphen control */
  {
   if ( b[2] == '+' ) hyphen = 1;
		 else hyphen = 0;
   fgets( b,200,in );
  }


  if ( strlen( b ) <= indent ) buf[0] = 0; /*   Empty line in indented file */

  /*    Detect paragraph first line indent */
  if ( buf[0] == ' ' && buf[1] == ' '&& buf[2] == ' ' )
  {
   int  index;

   /*      Avoid paragraph tale spaces */
   index = strlen( s );
   while ( s[index-1] == ' ' )
   {
    s[index-1] = 0;
    index--;
   }
   flushbuf();
   para = 1;
   pc = (k*100)/found.size;

   if ( !mute )
 printf( "\r%5.5ld paragraphs, %4.4ld Kbytes, %3.3d%% done",++p,k/1024,pc );
  }
  if ( mute )
  {
   pc = (k*100)/found.size;
   if ( pc != old_pc )
   {
    old_pc = pc;
    printf( "\r%3.3d%%",pc );
   }
  }
  if ( kbhit() )
  {
   if ( getch() == 0x1B )
   {
    fcloseall();
    printf( "\n\nInterrupted by user." );
    if ( replaced )
    {
     if ( remove( tmpname ) ) error( 5 );
     printf( " Source file unchanged.\n" );
    }
    else
    {
     if ( remove( trg ) ) error( 5 );
     printf( "\n" );
    }
    exit( 0 );
   }
  }

  space = 0;
  for ( i = 0; i < strlen( buf ); i++ )
  {
   switch ( buf[i] )
   {
    case '\n':  /* Procedure to avoid hyphen */
		{
		 int   slen;

		 slen = strlen( s ) - 1;
		 if ( s[slen] == '-' && s[slen-1] != ' ' )
		 {
		  if ( !hyphen )
		  {
		   s[slen] = 0;
		   s[slen+1] = 0;
		  }
		  else
		   s[slen] = '';       /*      Discretionary hyphen */

		 }
		 else strcat( s," " );
		 chkbuf();
		}
		break;
    case 0x0C:  {       /*      Form Feed control */
		 int    i;

		 for ( i = 0; i < skip; i++ ) fgets( b,200,in );
		}
		break;
    case ' ':   if ( !space && !para ) /*   Avoid paragraph start spaces */
		{
		 strcat( s," " );
		 space = 1;
		}
		break;
    default:    {
		 char   *append = " ";


		 append[0] = buf[i];
		 strcat( s,append );
		}
		space = 0;
		para = 0;
		break;
   }
  }
 } while ( !feof( in ) );
 flushbuf();
 if ( !mute )
	printf( "\r%5.5ld paragraphs, %4.4ld Kbytes, 100%% done    \n",++p,k/1024 );
 else   printf( "\r100%% done.\n" );

 free( s );
 free( ibuf );
 free( obuf );
}

void    chkbuf()
{
 if ( strlen( s ) >= (bufsize-10) ) error( 9 );
}

void    flushbuf()
{
 int    i,k;

 strcat( s,"\n" );
 if ( fputs( s, out ) )
 {
  fcloseall();
  if ( replaced ) remove( tmpname );
	     else remove( trg );
  error( 6 );
 }
 k = strlen( s ) + 5;
 for ( i = 0; i < k; s[i++] = 0 ) ;
 s[0] = 0;
}

void help()
{
 printf( "\
\n\t     This program  converts regular ASCII file to  Microsoft Word\
\n\tfile that uses line break  sequence as <End-Of-Paragraph>. Output\
\n\tfile will be non-formatted MS Word file with <EOP> if source file\
\n\thas  three spaces  after  line break  at  that line. If  file has\
\n\tgeneral  left indent  other than 0, use  /I option, in  this case\
\n\tconversion  will start  from  specified  column.   Moreover, this\
\n\tprogram  deletes  multiple spaces  and  hyphens from  source file.\
\n\t     Program is  able to convert  files of any size ( even larger\
\n\tthan memory size ).\
\n\t     Process may be interrupted at any time by  pressing Esc. All\
\n\tinternal files  will be  deleted. If you  want  to get  a part of\
\n\toutput file, use Ctlr-Break key. For more details see file SAMPLE.\
\n\nOptions may be:\
\n\t?\t\tThis information\
\n\t/Inn\t\tSpecify left indent ( default 0 )\
\n\t/Lnn\t\tLines skipped after Form Feed ( default 2 )\
\n\t/M\t\tMute - do not display current status to save time\
\n\t/H+\t\tMake old hyphens invisible rather than delete\
\n\nCopyright  V.Tkachenko. If you need help or found bug,\
\n                        please contact (044) 514-26-88" );
 exit( 0 );
}

