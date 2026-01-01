// Class RESTRING: Encapsulates the load/discard
//   logic for a resource String Table entry.

#define INCL_BASE
#include <os2.h>

class ResourceString
{
  private:
    HMODULE SavedModule ;
    ULONG SavedId ;

    PVOID BlockPointer ;
    PSZ StringPointer ;

  public:
    ResourceString ( HMODULE Module, ULONG Id ) ;
//  ~ResourceString ( ) ;

    inline PSZ Ptr ( ) { return ( (PSZ)StringPointer ) ; }
    inline ULONG QueryModule ( ) { return ( SavedModule ) ; }
    inline ULONG QueryId ( ) { return ( SavedId ) ; }
} ;
