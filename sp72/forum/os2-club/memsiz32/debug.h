/******************************************************************** DEBUG.H
 *									    *
 *  Debugging Aids							    *
 *									    *
 ****************************************************************************/

#ifndef DEBUG_H
#define DEBUG_H

#include "hrtimer.h"

extern HFILE Timer ;
extern BOOL Trace ;

extern VOID Debug ( HWND hwnd, char *Message, ... ) ;
extern VOID Log ( char *Message, ... ) ;

extern BOOL OpenTimer ( VOID ) ;
extern VOID CloseTimer ( VOID ) ;
extern BOOL GetTime ( PTIMESTAMP pts ) ;
extern ULONG ElapsedTime ( PTIMESTAMP ptsStart, PTIMESTAMP ptsStop, PULONG pulNs ) ;

extern PVOID AllocateMemory ( ULONG ByteCount ) ;
extern VOID FreeMemory ( PVOID Memory ) ;

#endif
