/******************************************************************* DEBUG.CC
 *									    *
 *  Debugging Aids							    *
 *									    *
 ****************************************************************************/

#define INCL_BASE
#define INCL_WIN
#include <os2.h>

#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>

#include "debug.h"

extern HFILE Timer = 0 ;
extern BOOL Trace = FALSE ;


/****************************************************************************
 *									    *
 *			 Display Debug Message				    *
 *									    *
 ****************************************************************************/

extern VOID Debug ( HWND hwnd, char *Message, ... )
{
 /***************************************************************************
  * Local Declarations							    *
  ***************************************************************************/

  va_list Marker ;
  char Text [500] ;

 /***************************************************************************
  * Format the debug message.						    *
  ***************************************************************************/

  va_start ( Marker, Message ) ;
  vsprintf ( Text, Message, Marker ) ;
  va_end ( Marker ) ;

 /***************************************************************************
  * Display the log message and wait for the user to press ENTER.	    *
  ***************************************************************************/

  WinMessageBox ( HWND_DESKTOP, hwnd, (PSZ)Text, (PSZ)"Debug", 0, MB_ENTER ) ;
}

/****************************************************************************
 *									    *
 *			   Log Debug Message				    *
 *									    *
 ****************************************************************************/

extern VOID Log ( char *Message, ... )
{
 /***************************************************************************
  * Try to open the log file.  If unsuccessful, just return.		    *
  ***************************************************************************/

  ULONG Action ;
  HFILE Handle ;

  if ( DosOpen ( (PSZ)"LOG", &Handle, &Action, 0,
    FILE_NORMAL, FILE_CREATE | FILE_OPEN,
    OPEN_ACCESS_WRITEONLY | OPEN_SHARE_DENYWRITE | OPEN_FLAGS_FAIL_ON_ERROR | 
    OPEN_FLAGS_WRITE_THROUGH | OPEN_FLAGS_SEQUENTIAL, 0 ) )
  {
    return ;
  }

 /***************************************************************************
  * Position to the end of the file.                                        *
  ***************************************************************************/

  ULONG Position ;
  DosChgFilePtr ( Handle, 0, FILE_END, &Position ) ;

 /***************************************************************************
  * Format the message for the log file.                                    *
  ***************************************************************************/

  char Buffer [512] ;
  va_list Marker ;

  va_start ( Marker, Message ) ;
  vsprintf ( Buffer, Message, Marker ) ;
  va_end ( Marker ) ;

 /***************************************************************************
  * Write the message to the log file.                                      *
  ***************************************************************************/

  ULONG Written ;

  DosWrite ( Handle, Buffer, strlen(Buffer), &Written ) ;

 /***************************************************************************
  * Close the log file and return.					    *
  ***************************************************************************/

  DosClose ( Handle ) ;
}

/****************************************************************************
 *									    *
 *			    Open Timer for Use				    *
 *									    *
 ****************************************************************************/

extern BOOL OpenTimer ( VOID )
{
  ULONG Action ;

  if ( Timer )
    DosClose ( Timer ) ;

  if ( DosOpen ( (PSZ)"TIMER$", &Timer, &Action, 0, FILE_NORMAL, FILE_OPEN, OPEN_SHARE_DENYNONE, 0 ) )
  {
    return ( FALSE ) ;
  }

  return ( TRUE ) ;
}

/****************************************************************************
 *									    *
 *				Close Timer				    *
 *									    *
 ****************************************************************************/

extern VOID CloseTimer ( VOID )
{
  DosClose ( Timer ) ;
}

/****************************************************************************
 *									    *
 *			 Read Time from HRTIMER.SYS			    *
 *									    *
 ****************************************************************************/

extern BOOL GetTime ( PTIMESTAMP pts )
{
  ULONG ByteCount ;

  if ( DosRead ( Timer, pts, sizeof(*pts), &ByteCount ) )
    return ( FALSE ) ;

  return ( TRUE ) ;
}

/****************************************************************************
 *									    *
 *			   Calculate Elapsed Time			    *
 *									    *
 ****************************************************************************/

extern ULONG ElapsedTime ( PTIMESTAMP ptsStart, PTIMESTAMP ptsStop, PULONG pulNs )
{
  ULONG ulMsecs, ulNsecs;
  TIMESTAMP tsStart, tsStop ;

  tsStart = *ptsStart ; 		      // De-reference timestamp
					      //     structures for speed
  tsStop  = *ptsStop ;

  ulMsecs = tsStop.ulMs - tsStart.ulMs ;      // Elapsed milliseconds

  if( tsStart.ulNs > tsStop.ulNs )	      // If nanosecond overflow ...
  {
    ulNsecs = (1000000 + tsStop.ulNs) - tsStart.ulNs; // Adjust nanoseconds
    ulMsecs--;					      // Adjust milliseconds
  }
  else
    ulNsecs = tsStop.ulNs - tsStart.ulNs ;    // No overflow..Elapsed nanos

  *pulNs = ulNsecs ;

  return ( ulMsecs ) ;
}

/****************************************************************************
 *									    *
 *  Allocate Memory							    *
 *									    *
 ****************************************************************************/

//#define ALLOCATE_THROUGH_DOS

extern PVOID AllocateMemory ( ULONG ByteCount )
{
  #ifdef ALLOCATE_THROUGH_DOS
  {
    PVOID Memory ;
    DosAllocMem ( &Memory, ByteCount, PAG_READ | PAG_WRITE | PAG_COMMIT ) ;
    return ( Memory ) ;
  }
  #else
  {
    return ( malloc ( ByteCount ) ) ;
  }
  #endif
}

/****************************************************************************
 *									    *
 *  Free Memory 							    *
 *									    *
 ****************************************************************************/

extern VOID FreeMemory ( PVOID Memory )
{
  #ifdef ALLOCATE_THROUGH_DOS
  {
    DosFreeMem ( Memory ) ;
  }
  #else
  {
    free ( Memory ) ;
  }
  #endif
}

