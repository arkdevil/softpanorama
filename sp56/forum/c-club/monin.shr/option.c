/*  OPTION.C   Copyright (C)   DUL-Soft    14/04/93

    Обработка опций командной строки.
*/


#include <option.h>


#define  SIGN   '-'      /*  Признак начала опций.  */


int option ( OPTION * opt, char * p )
{
   OPTION * cur ;

   if ( ! opt  ||   ! p )    return  -2 ;
   if ( * p != SIGN )        return  -1 ;

   for ( p ++ ; * p ; p ++ )
   {
      if ( * p == SIGN )     continue ;

      for ( cur = opt ; cur -> flag ; cur ++ )
      {
	 if ( cur -> symbol == * p )
	    * cur -> flag = cur -> value ;
      }
   }

   return  0 ;
}
