/*  DISTINCT.C   Copyright (C)   DUL-Soft      13/04/93

   Удаление дублирующих записей в базе данных.
*/


#include <d4base.h>
#include <u4error.h>
#include <string.h>

#include <n_table.h>
#include <distinct.h>


#define LOOK     0
#define INSERT   1
#define NULL     0L


static int compare_key   ( void * key, void * tree_key ) ;
static unsigned key_len  ( void * key ) ;
static unsigned data_len ( void * data ) ;
static int hashing       ( char * key ) ;


static NAMES_TABLE distinct =
{
   NULL,
   100,
   hashing,
   {
      compare_key,
      key_len,
      data_len,
      NULL,
      NULL,
      NULL,
      NULL
   }
} ;


static int compare_key ( void * key, void * tree_key )
{
   if ( tree_key )
      return memcmp ( key, tree_key, key_len ( key ) ) ;
   return  0 ;
}


static unsigned key_len ( void * key )
{
   return  d4ptr() -> buffer_len - 1 ;
}


static unsigned data_len ( void * data )
{
   return 0 ;
}


static int hashing ( char * key )   /*  Функция хеширования.  */
{
   int rc ;
   int len ;

   rc = 0 ;
   len = key_len ( key ) ;

   while ( len -- )
      rc += * key ++ ;

   return  rc ;
}


/*   Функция удаления дублирующих записей в базе данных.  */

int distinct_base ( char * base_name, int pack,
		    DISTINCT_FUNCTIONS * df      )
{
   int      rc ;
   int      mode ;
   int      no_record_in_memory ;
   void *   key ;     /*  Указатель на промежуточный буфер.  */
   DISTINCT d ;

   if ( ! base_name )   return -1 ;

   memset ( & d, 0, sizeof ( DISTINCT ) ) ;
   d.base_name = base_name ;
   d.pack      = pack ;

   if ( d4use ( base_name ) < 0 )   return  -1 ;
   d.reccount = d4reccount () ;
   if ( ! pack )   d.write_record = d.reccount ;

   if ( df  &&   df -> statistics.first )
      ( * df -> statistics.first ) ( & d ) ;

   rc  = 1 ;
   key = d4ptr() -> buffer + 1 ;
   nt1_init ( & distinct, 1, 200 ) ;

   while ( d.count < d.reccount )
   {
      nt1_clear ( & distinct ) ;
      no_record_in_memory = 1 ;
      mode = INSERT ;

      for ( d.cur_record = d.count + 1 ;
	    ! ( rc = d4go ( d.cur_record ) ) ;
	    d.cur_record ++                      )
      {
	 if ( df )
	 {
	    if ( df -> stop )    rc = ( * df -> stop ) ( & d ) ;
	    if ( rc < 0 )
	    {
	       rc = -3 ;
	       break ;
	    }

	    if ( df -> statistics.current )
	       ( * df -> statistics.current ) ( & d ) ;
	 }

	 if ( d4deleted() )
         {
	    if ( mode == INSERT )   d.count ++ ;
            continue ;
         }

         if ( mode == INSERT )
         {
            rc = nt1_insert ( & distinct, key, NULL ) ;
            if ( rc < 0 )
            {
               if ( no_record_in_memory )
	       {
		  u4error ( E_MEMORY, NULL ) ;
                  rc = -2 ;   /*  Нет памяти даже для       */
                  break ;     /*  размещения одной записи.  */
               }
               mode = LOOK ;
            }
            else
            {
               no_record_in_memory = 0 ;
	       d.count ++ ;
	       if ( ! rc  &&  pack )
	       {
		  d.write_record ++ ;
		  if ( d.cur_record != d.write_record )
		  {
		     rc = d4write ( d.write_record ) ;
		     if ( rc < 0 )   break ;
		  }
	       }
            }
         }
         else
            rc = nt1_look ( & distinct, key ) ;

         if ( rc == 1 )   /*  Запись дублируется.  */
	 {
	    d.not_unique ++ ;
	    if ( mode == LOOK    ||
		 mode == INSERT  &&  ! pack  )
	    {
	       rc = d4delete ( d.cur_record ) ;
	       if ( rc < 0 )   break ;
	    }
	 }
      }

      if ( rc < 0 )   break ;
   }

   if ( df  &&  df -> statistics.last )
      ( * df -> statistics.last ) ( & d ) ;

   if ( d.reccount == -1 )  rc = -1 ;
   if ( rc > 0  &&  pack )
      rc = d4adjust ( d4ptr (), d.write_record ) ;

   nt1_close ( & distinct ) ;
   if ( d4close () < 0 )   rc = -1 ;
   return  rc ;
}
