/*   DIRECTORY.C    Copyright (C)   DUL-Soft       02/05/93

     Обработка файлов каталога.
*/

/*   Если вы не хотите выводить сообщения об ошибках на
     экран, то снимите следующий комментарий :           */

/*   #define   NO_DISPLAY_ERROR                          */


#include <stdlib.h>
#include <string.h>

#ifndef  NO_DISPLAY_ERROR

   #include <d4base.h>
   #include <u4error.h>

   #include <user_err.h>

#endif

#include <stack.h>
#include <dir_.h>


#define  MAX_DIR_NAME_LEN   MAX_FILE_NAME_LEN - 15


#ifndef  NO_DISPLAY_ERROR

static void stack_handler ( int error ) ;


/*  Обработка ошибок при работе со стеком.  */

static void stack_handler ( int error )
{
   if ( error == STACK_FULL )
      u4error ( E_MEMORY, NULL ) ;
}

#endif


int d1_process ( DIRECTORY_MODE * d, char * name )
{
   int rc ;
   int len ;
   char cur_dir [ MAX_DIR_NAME_LEN ] ;
   DIRECTORY_FILE df ;
   STACK stack ;

   if ( ! d  ||  ! d -> function )    return  -3 ;

   rc = 0 ;
   getcwd ( cur_dir, MAX_DIR_NAME_LEN ) ;
   if ( name )
   {
      if ( chdir ( name ) )
      {

#ifndef  NO_DISPLAY_ERROR

	 u4error ( E_DIR_NAME, name ) ;

#endif

	 return  -3 ;
      }
      strncpy ( df.name, name, MAX_DIR_NAME_LEN ) ;
      df.name [ MAX_DIR_NAME_LEN ] = '\0' ;
   }
   else
      if ( ! getcwd ( df.name, MAX_DIR_NAME_LEN ) )    return  0 ;

   len = strlen ( df.name ) ;
   if ( df.name [ len - 1 ] != '\\' )
      strcat ( df.name, "\\" ) ;

#ifdef NO_DISPLAY_ERROR

   s1init ( & stack, MAX_FILE_NAME_LEN, 1000, NULL ) ;

#else

   s1init ( & stack, MAX_FILE_NAME_LEN, 1000, stack_handler ) ;

#endif

   if ( s1pushs ( & stack, df.name ) == -1 )
      rc = -2 ;
   else
   {
      while ( ! s1empty ( & stack ) )
      {
	 s1pops ( & stack, df.name ) ;    /*  Проверить длину имени  */
	 len = strlen ( df.name ) ;       /*  каталога.              */
	 if ( len > MAX_DIR_NAME_LEN )    continue ;
	 s1pushs ( & stack, df.name ) ;

	 if ( d -> mask )
	    strncat ( df.name, d -> mask, 12 ) ;
	 else
	    strcat ( df.name, DEFAULT_MASK ) ;

	 /*  Обработать файлы текущего каталога.  */

	 for ( rc = findfirst ( df.name, & df.file, d -> attrib ) ;
	       rc == 0 ;  rc = findnext ( & df.file )                )
	 {
	    s1pops ( & stack, df.name ) ;
	    s1pushs ( & stack, df.name ) ;
	    strcat ( df.name, df.file.ff_name ) ;

	    rc = ( * d -> function ) ( & df ) ;
	    if ( rc < 0 )
	    {
	       s1delete ( & stack ) ;
	       chdir ( cur_dir ) ;
	       return  rc ;
	    }
	 }

	 s1pops ( & stack, df.name ) ;

	 if ( d -> root )      /*  Обработка с подкаталогами.  */
	 {
	    strcat ( df.name, "*.*" ) ;

	    for ( rc = findfirst ( df.name, & df.file, 0x10 ) ;
		  rc == 0 ;  rc = findnext ( & df.file )        )
	    {
	       if ( df.file.ff_attrib  &  0x10 )
	       {
		  if ( ! strcmp ( df.file.ff_name, "." ) )   continue ;
		  if ( ! strcmp ( df.file.ff_name, ".." ) )  continue ;

		  d1_name ( df.name, df.name ) ;
		  strcat ( df.name, "\\" ) ;
		  strcat ( df.name, df.file.ff_name ) ;
		  strcat ( df.name, "\\" ) ;

		  /*  Добавить в стек имена подкаталогов.  */

		  if ( s1pushs ( & stack, df.name ) == -1 )
		  {
		     rc = -2 ;
		     break ;
		  }

		  d1_name ( df.name, df.name ) ;

	       }
	    }
	 }

	 if ( rc == -2 )   break ;
      }
   }

   if ( rc >= -1 )  rc = 0 ;
   s1delete ( & stack ) ;
   chdir ( cur_dir ) ;
   return  rc ;
}


void d1_name ( char * dir, char * file_name )
{
   int len ;

   if ( ! dir )   return ;

   if ( ! file_name )    len = 0 ;
   else                  len = strlen ( file_name ) ;

   while ( len -- )
   {
      if ( file_name [ len ] == '\\' )
      {
	 len -- ;
	 break ;
      }
      if ( file_name [ len ] == ':' )   break ;
   }

   len ++ ;
   if ( len > 0 )   memmove ( dir, file_name, len ) ;
   dir [ len ] = '\0' ;
}
