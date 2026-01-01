/*  BINARY_TREE.C    Copyright (C)  DUL-Soft     23/03/93

    Модуль работы с двоичным деревом
     элементы которого упорядочены.
*/


#include <stdlib.h>
#include <string.h>

#include <b_tree.h>


#define LOOK    0
#define INSERT  1
#define MODIFY  2


static  BINARY_TREE * current ;    /*  Текущее обрабатываемое
		дерево - вводится для уменьшения затрат стека.    */

static  void b_clear   ( B_TREE * b ) ;
static  int  b_main    ( BINARY_TREE * bt, int mode,
			 void * key, void * data      ) ;
static  int  b_process ( B_TREE * b ) ;


void bt1_init ( BINARY_TREE * bt,
		B_TREE_FUNCTIONS * function,
		int unique, unsigned max_number  )
{
   memset ( bt, 0, sizeof ( BINARY_TREE ) ) ;
   bt -> function = function ;
   bt -> unique = unique ;
   bt -> max_number = max_number ;
}


void bt1_clear ( BINARY_TREE * bt )
{
   b_clear ( bt -> root ) ;
   bt -> root = NULL ;
   bt -> cur_number = 0 ;
}


static void b_clear ( B_TREE * b )
{
   if ( b )
   {
      b_clear ( b -> left ) ;
      b_clear ( b -> right ) ;
      free ( b -> key ) ;
      free ( b -> data ) ;
      free ( b ) ;
   }
}


int bt1_look ( BINARY_TREE * bt, void * key )
{
   return b_main ( bt, LOOK, key, NULL ) ;
}

int bt1_insert ( BINARY_TREE * bt, void * key, void * data )
{
   return b_main ( bt, INSERT, key, data ) ;
}

int bt1_modify ( BINARY_TREE * bt, void * key, void * data )
{
   return b_main ( bt, MODIFY, key, data ) ;
}


static int b_main ( BINARY_TREE * bt, int mode,
		    void * key, void * data       )
{
   B_TREE  * p ;
   B_TREE ** q ;   /*  Используется при присоединении
		       нового узла к дереву.             */

   B_TREE_FUNCTIONS * function ;
   unsigned  key_len, data_len ;

#ifndef NO_VERIFY_ERROR

   if ( ! bt -> function )     /*  Не определены функции,  */
      return  -2 ;             /*  работающие с деревом.   */

#endif

   function = bt -> function ;

#ifndef NO_VERIFY_ERROR

   if ( ! function -> compare_key   ||
	! function -> key_len       ||
	! function -> data_len           )
   {
      return  -2 ;
   }

#endif

   /*   Поиск ключа в дереве.  */

   p = bt -> root ;
   q = ( B_TREE ** ) & bt -> root ;

   while ( p )
   {
      int rc = ( * function -> compare_key ) ( key, p -> key ) ;

      if ( ! rc )
      {
	 switch ( mode )
	 {
	    case LOOK   :  return  1 ;
	    case INSERT :
	       if ( bt -> unique )  return  1 ;

	       q = ( B_TREE ** ) & p -> right ;
	       p = p -> right ;
	       continue ;

	    case MODIFY :

#ifndef NO_VERIFY_ERROR

	       if ( ! function -> modify_data )   return  -2 ;

#endif

	       ( * function -> modify_data ) ( data, p -> data ) ;
	       return  1 ;
	 }
      }

      if ( rc < 0 )
      {
	 q = ( B_TREE ** ) & p -> left ;
	 p = p -> left ;
      }
      else
      {
	 q = ( B_TREE ** ) & p -> right ;
	 p = p ->right ;
      }
   }

   if ( mode == LOOK )   return  0 ;
   if ( bt -> max_number == bt -> cur_number )   return  -1 ;

   /*  Добавление нового элемента в дерево.  */

   p = calloc ( 1, sizeof ( B_TREE ) ) ;
   if ( ! p )   return  -1 ;

   if ( key )   key_len = ( * function -> key_len ) ( key ) ;
   else         key_len = 0 ;
   if ( data )  data_len = ( * function -> data_len ) ( data ) ;
   else         data_len = 0 ;

   if ( key_len )
   {
      p -> key = malloc ( key_len ) ;
      if ( ! p -> key )
      {
	 b_clear ( p ) ;
	 return  -1 ;
      }

      if ( function -> move_key )
	 ( * function -> move_key ) ( p -> key, key ) ;
      else
	 memcpy ( p -> key, key, key_len ) ;
   }

   if ( data_len )
   {
      p -> data = malloc ( data_len ) ;
      if ( ! p -> data )
      {
	 b_clear ( p ) ;
	 return  -1 ;
      }

      if ( function -> move_data )
	 ( * function -> move_data ) ( p -> data, data ) ;
      else
	 memcpy ( p -> data, data, data_len ) ;
   }

   *q = p ;
   bt -> cur_number ++ ;

   return  0 ;
}


/*  Эта функция нереентерабельна.  */

int bt1_process ( BINARY_TREE * bt )
{

#ifndef NO_VERIFY_ERROR

   if ( ! bt -> function  ||  ! bt -> function -> process )
      return  -2 ;

#endif

   current = bt ;
   return b_process ( bt -> root ) ;
}


static int b_process ( B_TREE * b )
{
   if ( b )
   {
      int rc ;

      rc = b_process ( b -> left ) ;
      if ( rc < 0 )  return  rc ;

      rc = ( * current -> function -> process ) ( b ) ;
      if ( rc < 0 )  return  rc ;

      return b_process ( b -> right ) ;
   }

   return  0 ;
}
