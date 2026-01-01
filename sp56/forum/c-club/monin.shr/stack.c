/*   STACK.C   Copyright  (C)   DUL-Soft  1992  год.

	 В этом модуле содержится реализация
	 функций по управлению стеком.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <stack.h>

#define  MAX_STACK_LEN  0xFFE0    /*  Максимальный размер стека.  */
	 /*     Эта константа может быть и меньше, но не больше.  */

#define  FIRST_SIZE  this -> first_size
#define  SIZE        this -> size
#define  ADD         this -> add
#define  TOP         this -> top
#define  BUFFER      this -> s
#define  HANDLER     this -> handler

static   int  stack_full ( STACK * ) ;

char * error_stack []  =
       {   "\nПамять исчерпана."               ,
	   "\nПереполнение стека."             ,
	   "\nНеверное использование стека."
       } ;


  /*  Инициализировать стек.  */

void  s1init ( STACK * this, unsigned size, unsigned add, PFI handler )
{
   HANDLER = handler ;

   if ( size > MAX_STACK_LEN )   size = MAX_STACK_LEN ;

   if ( ( BUFFER = malloc ( size ) ) == NULL )
   {
      if ( HANDLER )   ( * HANDLER ) ( OUT_OF_MEMORY ) ;
      s1delete ( this ) ;
   }
   else
   {
	  TOP = SIZE = FIRST_SIZE = size ;
	  ADD = add ;
   }
}


   /*  Удалить стек.  */

void  s1delete ( STACK * this )
{
   free ( BUFFER ) ;
   memset ( this, 0, sizeof ( STACK ) - sizeof ( PFI ) ) ;
}


/* Очистить стек.

   Параметр type должен принимать следующие значения :
   RESTORE - при очистке стека восстановливается его
	     предыдущий размер.
   SAVE    - размер стека н изменяется.
*/

void s1clear ( STACK * this, int type )
{
   if ( type  &&  SIZE != FIRST_SIZE )
   {
      free ( BUFFER ) ;
      s1init ( this, FIRST_SIZE, ADD, HANDLER ) ;
   }
   else  TOP = SIZE ;
}


/*  Проверить пуст ли стек.  */

int s1empty ( STACK * this )
{
   return  TOP == SIZE ;
}



/* Получить адрес данного в стеке.

     Параметр offset должен быть равен числу,
   возращаемому функцией push_stack.

		   Предупреждение !
     Используйте эту функцию только перед непосредственным
   использованием данного, иначе дейстительный адрес может
   изменится.
*/

void * s1get ( STACK * this, unsigned offset )
{
   return BUFFER + SIZE - offset ;
}


static int stack_full ( STACK * this )
{
   if ( HANDLER )  ( * HANDLER ) ( STACK_FULL ) ;

   return  -1 ;
}


/* Поместить данные в стек.

   Возвращается вершина стека.
   Если стек переполнен возращается  -1.
*/

unsigned s1push ( STACK * this, void * data, unsigned len )
{
   if ( len > TOP )     /*  Обработка переполнения стека.  */
   {
      long   add, new_size ;
      char * p ;

      if ( ADD == 0 )  return stack_full ( this ) ;

      add = ( ( unsigned ) ( ( len - TOP ) / ADD + 1 ) ) * ADD ;
      new_size = add + SIZE ;

      if ( new_size > MAX_STACK_LEN )  return stack_full ( this ) ;

      if ( ( p = malloc ( new_size ) ) == NULL )
	 return stack_full ( this ) ;

      memcpy ( p + add + TOP, BUFFER + TOP, SIZE - TOP ) ;

      free ( BUFFER ) ;

      BUFFER = p ;
      SIZE = new_size ;
      TOP += add ;
   }

   TOP -= len ;
   memcpy ( BUFFER + TOP, data, len ) ;

   return SIZE - TOP ;
}

   /*  Поместить строку в стек.  */

unsigned s1pushs ( STACK * this, char * s )
{
   return s1push ( this, s, strlen ( s ) + 1 ) ;
}


   /*  Извлечь данные из стека.  */

void s1pop ( STACK * this, void * data, unsigned len )
{
   if ( ( long ) ( TOP + len ) > SIZE )
   {
      if ( HANDLER )  ( * HANDLER ) ( ERROR_USE_STACK ) ;
   }
   else
   {
      memcpy ( data, BUFFER + TOP, len ) ;
      TOP += len ;
   }
}


   /*  Извлечь строку из стека.  */

void s1pops ( STACK * this, char * s )
{
   s1pop ( this, s, strlen ( BUFFER + TOP ) + 1 ) ;
}


   /*  Стандартный обработчик ошибок.  */

void s1default_handler ( int number )
{
   puts ( error_stack [ number ] ) ;
   exit ( 1 ) ;
}

