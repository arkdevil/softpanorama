// Class RESTRING: Encapsulates the load/discard
//   logic for a resource String Table entry.

#define INCL_BASE
#include <os2.h>

#include "debug.h"

#include "restring.h"


  // Constructor

ResourceString::ResourceString ( HMODULE Module, ULONG Id )
{
  SavedModule = Module ;
  SavedId = Id ;

  APIRET Status = DosGetResource ( Module, RT_STRING, Id/16+1, &BlockPointer ) ;
  if ( Status )
  {
//  Log (
//    "ERROR: Unable to get string resource."
//    "  Module %lu, id %lu, code %08lX.\r\n", SavedModule, SavedId, Status ) ;
    return ;
  }

  StringPointer = BlockPointer + sizeof(USHORT) ;

  USHORT Index = (USHORT) ( Id % 16 ) ;
  while ( Index-- )
  {
    StringPointer += *StringPointer ;
    StringPointer ++ ;
  }

  StringPointer ++ ;
}


  // Destructor

//ResourceString::~ResourceString ( )
//{
//  APIRET Status = DosFreeResource ( BlockPointer ) ;
//  if ( Status )
//  {
//    Log (
//	"ERROR: Unable to free string resource."
//	"  Module %lu, id %lu, ptr %p, code %08lX.\r\n", SavedModule, SavedId, BlockPointer, Status ) ;
//    return ;
//  }
//}
