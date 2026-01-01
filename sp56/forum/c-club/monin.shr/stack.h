/*   STACK.H   Copyright  (C)  DUL-Soft  1992 год.

	В этой программе описаны
     функции по управлению стеком.
*/

typedef  void  ( *PFI ) ( int ) ;

typedef  struct
{
   unsigned first_size ;  /*  Начальный размер стека.  */
   unsigned size ;        /*  Текущий размер стека.    */
   unsigned add ;         /*  Используется при увеличении размера стека.  */
   unsigned top ;         /*  Указатель на вершину стека.  */
   char *   s ;           /*  Указатель на буфер стека.    */
   PFI      handler ;     /*  Функция обработки ошибок.    */
}  STACK ;

/*  Константы, используемые при вызове
    функции  clear_stack.
*/

#define  RESTORE  1
#define  SAVE     0


  /*  Функции модуля STACK.C.  */

void     s1init   ( STACK *, unsigned, unsigned, PFI ) ; /*  Инициализировать стек.  */
void     s1delete ( STACK * ) ;                          /*  Удалить стек.   */
void     s1clear  ( STACK *, int ) ;                     /*  Очистить стек.  */
int      s1empty  ( STACK * ) ;                          /*  Пуст ли стек.  */
void *   s1get    ( STACK *, unsigned ) ;                /*  Получить адрес данного в стеке.  */
unsigned s1push   ( STACK *, void *, unsigned ) ;        /*  Поместить данные в стек.  */
unsigned s1pushs  ( STACK *, char * ) ;                  /*  Поместить строку в стек.  */
void     s1pop    ( STACK *, void *, unsigned ) ;        /*  Извлечь данные из стека.  */
void     s1pops   ( STACK *, char * ) ;                  /*  Извлечь строку из стека.  */


  /*  Обработка ошибок при работе со стеком.  */

#define OUT_OF_MEMORY     0
#define STACK_FULL        1
#define ERROR_USE_STACK   2


extern char * error_stack [] ;

void   s1default_handler ( int ) ; /*  Стандартная процедура обработки ошибок.  */
