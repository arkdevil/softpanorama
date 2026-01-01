/************************************
 * демонстрация возможностей look.c *
 * по умолчанию просмотр look.c     *
 * параметр - имя файла             *
 ***********************************/
#include <stdlib.h>
#include <dos.h>
#include <fcntl.h>
#include <sys\types.h>
#include <sys\stat.h>
#include <io.h>
#include <share.h>
#include "look.c"
main ( int argc , char * argv[] )
{
   int fh,l;
   struct stat st;
   char *buf;
   char fname[15];

   if ( argc == 1 )
      strcpy ( fname , "look.c" );

   else
      strcpy ( fname , argv[1] );

   if( fh=sopen(fname,O_RDONLY|SH_DENYWR,S_IREAD) )
   {
      fstat(fh,&st);

     if ( buf = malloc ( st.st_size ) )
     {
        if ( (l = read(fh,buf,st.st_size)) )
           look ( buf , l );
        else
           printf( "Ошибка при чтении файла" );
     }
     else
        printf ( "Не хватает памяти" );

     close(fh);
  }
  else
     printf ( "Ошибка при открытии файла" );
  exit(0);
}