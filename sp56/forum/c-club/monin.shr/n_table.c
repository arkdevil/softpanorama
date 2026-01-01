/*  NAMES_TABLE.C    Copyright (C)  DUL-Soft      14/03/93

    Модуль работы с таблицей имен.
*/


#include <stdlib.h>
#include <n_table.h>


static int hashing ( NAMES_TABLE * nt, void * key ) ;
static int default_hashing ( char * key ) ;
       /*  Стандартная функция хеширования.
	   Она удобна для ключей, имеющих формат строки.  */


int nt1_init ( NAMES_TABLE * nt, int unique, unsigned max_number )
{
   int i ;

   if ( ! nt -> tree )
   {
      nt -> tree = calloc ( nt -> number, sizeof ( BINARY_TREE ) ) ;
      if ( ! nt -> tree )  return  0 ;

      for ( i = 0 ; i < nt -> number ; i ++ )
      {
	 bt1_init ( nt -> tree + i, & nt -> function,
		    unique, max_number                 ) ;
      }
   }

   return  1 ;
}


void nt1_close ( NAMES_TABLE * nt )
{
   nt1_clear ( nt ) ;
   free ( nt -> tree ) ;
   nt -> tree = NULL ;
}


void nt1_clear ( NAMES_TABLE * nt )
{
   if ( nt -> tree )
   {
      int i ;

      for ( i = 0 ; i < nt -> number ; i ++ )
	 bt1_clear ( nt -> tree + i ) ;
   }
}


int nt1_look ( NAMES_TABLE * nt, void * key )
{
   int i = hashing ( nt, key ) ;

   if ( i < 0 )   return  -1 ;
   return  bt1_look ( nt -> tree + i, key ) ;
}


int nt1_insert ( NAMES_TABLE * nt, void * key, void * data )
{
   int i = hashing ( nt, key ) ;

   if ( i < 0 )   return  -1 ;
   return  bt1_insert ( nt -> tree + i, key, data ) ;
}


int nt1_modify ( NAMES_TABLE * nt, void * key, void * data )
{
   int i = hashing ( nt, key ) ;

   if ( i < 0 )   return  -1 ;
   return  bt1_modify ( nt -> tree + i, key, data ) ;
}


/*       Функция хеширования имеет свойство :
    одинаковые ключи дают один и тот же hash код.
    Иначе говоря, если hash коды не совпадают,то
    ключи различны.
*/

static int hashing ( NAMES_TABLE * nt, void * key )
{
   int i ;

   if ( ! nt -> tree  ||  ! nt -> number )   return  -1 ;

   if ( nt -> hashing )
      i = ( * nt -> hashing ) ( key ) ;
   else
      i = default_hashing ( key ) ;

   if ( i < 0 )   i = - i ;
   i %= nt -> number ;

   return i ;
}


static int default_hashing ( char * p )
{
   int i = 0 ;

   if ( ! p )   return  0 ;

   while ( * p )
      i = i << 1  ^  * p ++ ;

   return i ;
}


int nt1_process ( NAMES_TABLE * nt )
{
   if ( nt -> tree )
   {
      int i, rc ;

      for ( i = 0 ; i < nt -> number ; i ++ )
      {
	 rc = bt1_process ( nt -> tree + i ) ;
	 if ( rc < 0 )   return  rc ;
      }

      return  0 ;
   }

   return  -1 ;
}
