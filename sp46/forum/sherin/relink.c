/*[]--------------------------------------------------------------[]*/
/*| имя файла - relink.c                                           |*/
/*|                                                                |*/
/*|     функция  Relink                                            |*/
/*|                                                                |*/
/*[]--------------------------------------------------------------[]*/


/*[]--------------------------------------------------------------[]*/
/*|                                                                |*/
/*|      Design Plus Utilities Library   -   Version 1.0           |*/
/*|                                                                |*/
/*|                                                                |*/
/*|      Copyright (c) 1992 by Acta, Ltd.                          |*/
/*|      All rights reserved.                                      |*/
/*|                                                                |*/
/*[]--------------------------------------------------------------[]*/


// Interface Dependecies ---------------------------------------------

#ifndef   RELINKH
#include "relink.h"
#endif

#ifndef  _FCNTL_H
#include <fcntl.h>
#endif

#ifndef  _DIR_H
#include <dir.h>
#endif

// End Interface Dependecies -----------------------------------------

// Implementation Dependecies ----------------------------------------

#ifndef  _IO_H
#include <io.h>
#endif

#ifndef  _STRING_H
#include <string.h>
#endif

#ifndef  _ALLOC_H
#include <alloc.h>
#endif

#ifndef  _STDIO_H
#include <stdio.h>
#endif

// End Implementation Dependecies ------------------------------------

// Implementation Constants ------------------------------------------

#define LOOKUPID  0x4003
#define OFFSETIND 46

// End Implementation Constants --------------------------------------


// Function Relink //

int Relink( char *ReportName, char *OldTable, char *NewTable, int Mode )
{
 char          *Buffer = NULL;
 long           Size;
 int            Count, Flag, Error = ALL_RIGHT_MAMA, RHandle = -1,
		FullName = FALSE, Empty = TRUE, EndWork = FALSE;
 unsigned char  OldNameSize, NewNameSize;
 char           tblPath[MAXPATH], tblDrive[MAXDRIVE], tblDir[MAXDIR],
		tblName[MAXFILE], tblExt[MAXEXT];

 if( OldTable )
    {
     Flag = fnsplit( OldTable, tblDrive, tblDir, tblName, tblExt );
     if( Flag & DRIVE || Flag & DIRECTORY )
	{
	 strcpy( tblPath, tblDrive );
	 strcpy( tblPath + strlen( tblDrive ), tblDir );
	 strcpy( tblPath + strlen( tblDrive ) + strlen( tblDir ), tblName );
	 FullName = TRUE;
	}
     else
	 strcpy( tblPath, tblName );
     OldNameSize = strlen( tblPath ) + 1;
    }
 if( NewTable )
     NewNameSize = strlen( NewTable ) + 1;
 if( !ReportName || ( Mode != LOOKUPLIST && ( !OldTable || !NewTable ) ) )
     Error = INVALID_PARM;
 else
 if( access( ReportName, 0 ) )
     Error = WHERE_IS_FILE;
 else
 if( ( RHandle = open( ReportName, O_RDWR | O_BINARY ) ) == -1 )
     Error = ERROR_READ;
 else
 if( ( Size = filelength( RHandle ) ) == -1 )
     Error = ERROR_READ;
 else
 if( ( Buffer = malloc( ( unsigned )Size ) ) == NULL )
     Error = MEMORY_LIMIT;
 else
 if( ( Count = read( RHandle, Buffer, ( unsigned )Size ) ) == -1 )
     Error = ERROR_READ;
 else
 if( ( lseek( RHandle, 0L, SEEK_SET ) ) == -1 )
     Error = ERROR_READ;
 else
    {
     Count = *( int * )( Buffer + OFFSETIND );
     if( ( long )Count >= Size )
	 Count = ( int )Size - 1;
     for( ; ( long )Count < Size; Count++ )
	 {
	  if( *( ( int * )( Buffer + Count ) ) != LOOKUPID )
	      continue;
	  switch( Mode )
		 {
		  case LOOKUPLIST : Count += 4;
				    printf( "\n\r%s", strupr( Buffer + Count ) );
				    Count += strlen( Buffer + Count );
				    Empty = FALSE;
				    break;
		  case REPLACEALL : Count += 2;
				    if( FullName )
					Flag = stricmp( Buffer + Count + 2, tblPath );
				    else
				       {
					fnsplit( Buffer + Count + 2, tblDrive, tblDir, tblName, tblExt );
					Flag = stricmp( tblPath, tblName );
				       }
				    if( Flag )
					break;
				    strcpy( tblPath, NewTable );
				    OldNameSize = Buffer[Count];
				    Buffer[Count] = NewNameSize;
				    Count += 2;
				    EndWork = TRUE;
				    break;
		  case PATHONLY   : Count += 2;
				    if( FullName )
					Flag = stricmp( Buffer + Count + 2, tblPath );
				    else
				       {
					fnsplit( Buffer + Count + 2, tblDrive, tblDir, tblName, tblExt );
					Flag = stricmp( tblPath, tblName );
				       }
				    if( Flag )
					break;
				    strcpy( tblPath, NewTable );
				    if( tblPath[ NewNameSize - 2 ] != '\\' )
					tblPath[ NewNameSize - 1 ] = '\\';
				    else
					NewNameSize--;
				    strcpy( tblPath + NewNameSize, tblName );
				    NewNameSize = strlen( tblPath ) + 1;
				    OldNameSize = Buffer[Count];
				    Buffer[Count] = NewNameSize;
				    Count += 2;
				    EndWork = TRUE;
				    break;
		  case NAMEONLY   : Count += 2;
				    if( FullName )
					Flag = stricmp( Buffer + Count + 2, tblPath );
				    else
				       {
					fnsplit( Buffer + Count + 2, tblDrive, tblDir, tblName, tblExt );
					Flag = stricmp( tblPath, tblName );
				       }
				    if( Flag )
					break;
				    strcpy( tblPath, tblDrive );
				    strcpy( tblPath + strlen( tblPath ), tblDir );
				    fnsplit( NewTable, tblDrive, tblDir, tblName, tblExt );
				    strcpy( tblPath + strlen( tblPath ), tblName );
				    NewNameSize = strlen( tblPath ) + 1;
				    OldNameSize = Buffer[Count];
				    Buffer[Count] = NewNameSize;
				    Count += 2;
				    EndWork = TRUE;
				    break;
		 }
	  if( EndWork )
	      break;
	 }
     if( Mode == LOOKUPLIST )
	 if( Empty )
	     Error = LOOKUP_EMPTY;
	 else
	     printf( "\n\r" );
     else
     if( ( long )Count == Size )
	 Error = LOOKUP_ABSENT;
     else
     if( ( write( RHandle, Buffer, Count ) ) == -1 )
	 Error = ERROR_WRITE;
     else
     if( ( write( RHandle, tblPath, NewNameSize ) ) == -1 )
	 Error = ERROR_WRITE;
     else
     if( ( write( RHandle, Buffer + Count + OldNameSize, ( unsigned )Size - Count - OldNameSize ) ) == -1 )
	 Error = ERROR_WRITE;
     else
     if( ( chsize( RHandle, Size - OldNameSize + NewNameSize ) ) == -1 )
	 Error = ERROR_WRITE;
    }
 if( RHandle != -1 && close( RHandle ) )
     Error = ERROR_WRITE;
 if( Buffer )
     free( Buffer );
 return( Error );
}
// End Function Relink //
