/*   DIST.C      Copyright (C)    DUL-Soft        01/05/93

     Комерческий продукт                       Версия 1.00

     Программа удаления дублирующих записей в базе данных.
    Записи просто помечаются, как удаленные, но можно ука-
    зать, чтобы база одновременно паковалась. Возможна об-
    работка как отдельных баз, так и каталогов.

    All right reserved.
*/


#include <io.h>
#include <string.h>
#include <bios.h>

#include <d4base.h>
#include <u4error.h>
#include <g4char.h>

#include <twindow.h>
#include <hard_err.h>
#include <user_err.h>
#include <dir_.h>
#include <option.h>
#include <distinct.h>


#define  NULL   0L


static int process_file ( DIRECTORY_FILE * ) ;

static DIRECTORY_MODE dir =
{
   0,
   0,
   "*.dbf",
   process_file
} ;

static int pack ;     /*  Режим пакования.  */

static OPTION opt [] =
{
   {   & pack,     'P',  ON   },
   {   & pack,     'p',  ON   },
   {   & dir.root, 'R',  ON   },
   {   & dir.root, 'r',  ON   }
} ;

static int  stop             ( DISTINCT * ) ;
static void first_statistics ( DISTINCT * ) ;
static void cur_statistics   ( DISTINCT * ) ;
static void last_statistics  ( DISTINCT * ) ;

static DISTINCT_FUNCTIONS df =
{
   stop,
   {
      first_statistics,
      cur_statistics,
      last_statistics
   }
} ;

static WINDOW * error_wnd ;    /*  Окно ошибок.              */
static WINDOW * stop_wnd ;     /*  Окно останова обработки.  */
static WINDOW * result_wnd ;   /*  Окно результатов.         */
static WINDOW * process_wnd ;  /*  Окно обработки.           */

static char current_dir [ MAX_FILE_NAME_LEN ] ;
static char work_directory [ MAX_FILE_NAME_LEN ] ;
static int  error ;       /*  Номер ошибки.  */
static int  stop_flag ;   /*  Признак завершения программы.  */


typedef struct
{
   int    number ;
   char * data   ;
}  ERROR_DATA ;

/* Где :
   number - номер ошибки.
   data   - смысл ошибки.
*/

static ERROR_DATA error_data [] =
{
   {  E_OPEN,         "Открытие файла"                  },
   {  E_READ,         "Чтение из файла"                 },
   {  E_WRITE,        "Запись в файл"                   },
   {  E_CLOSE,        "Закрытие файла"                  },
   {  E_BAD_DBF,      "Файл не является базой данных"   },
   {  E_REC_LENGTH,   "Файл не является базой данных"   },
   {  E_CHANGE_SIZE,  "Изменение размера базы данных"   },
   {  E_LOCK,         "Блокирование файла"              },
   {  E_UNLOCK,       "Разблокирование файла"           },
   {  E_MEMORY,       "Недостаточно памяти"             },
   {  E_ALLOCATE,     "Внутренняя ошибка"               },
   {  E_INTERNAL,     "Внутренняя ошибка"               },

   {  E_DIR_NAME,     "Файл ( каталог ) не существует"  }
} ;

static char * title_message = "Удаление дублирующих записей." ;
static char * copyright_message =
       "Copyright (C)   Монин Максим Анатольевич" ;
static char * pack_message = "Режим пакования" ;
static char * help_message = "Режим помощи" ;

static char * key          = "Esc - останов                   " ;
static char * stop_key     = "Используйте клавиши  \033, \032, Enter" ;
static char * continue_key = "Нажмите любую клавишу ...       " ;

static char * error_title   = " Ошибка " ;
static char * stop_title    = " Обработка остановлена " ;
static char * result_title  = " Окно результатов " ;
static char * process_title = " Обработка " ;
static char * help_title    = " Помощь " ;

static char * stop_message  = "Ваши действия :" ;
static char * stop_menu []  =
{
   "Продолжить", "Пропустить", "Завершить", NULL
} ;

static char * result_message =
       "  База данных      Исходное      Дубль   Конечное" ;
static char * break_message = "Обработка прервана" ;
static char * end_message   = "Обработка завершена." ;

static char * process_message =
       "\n  База данных : %-12s\n"
       "  Число обработаных записей : %10ld\n"
       "  Число дублирующих записей : %10ld"   ;

static char * help1_message =
       "      Формат командной строки :\n"
       "  DISTINCT  [ Опции ]  Элементы обработки.\n\n"
       "      Опции :\n"
       " -p - при  обработке  база  одновременно  пакуется. По умолча-\n"
       "      нию записи просто помечаются, как удаленные.\n"
       " -r - обработка  каталога  со всеми  своими  подкаталогами.\n\n" ;
static char * help2_message =
       "Элементы обработки  -  список файлов  или каталогов, разделен-\n"
       "ных пробелами.   Если  имя  файла задано без расширения, то по\n"
       "умолчанию считается .dbf.\n\n" ;
static char * help3_message =
       "      Пример.\n"
       "  DISTINCT -pr  D:\\  C:\\SYS.DBF\n"
       "Будут обработаны все базы на диске D, а также база C:\\SYS.DBF.\n"
       "После удаления  дублирующих записей  все базы будут спакованы.\n"
       "                                        т. (044) 432-2792 (д)." ;

static int    process ( char * line ) ;
static void   color ( WINDOW * wnd, char * title ) ;
static void   writexy ( int x, int y, char * string ) ;
static void   white ( int line ) ;
static char * error_ptr ( int error_num ) ;
static void   help () ;


static int stop ( DISTINCT * d )
{
   int rc ;

   if ( bioskey ( 1 ) )     /*  Нажата клавиша.  */
   {
      rc = get_char () ;
      if ( rc == ESC )
      {
         writexy ( 2, 24, stop_key ) ;
         display_window ( stop_wnd ) ;

         wcursor ( stop_wnd, 0, 2 ) ;
         rc = hmenu ( stop_wnd, 1, stop_menu, NULL ) ;

         hide_window ( stop_wnd ) ;
         writexy ( 2, 24, key ) ;

	 if ( rc >= 2 )     /*  Прервать обработку текущей базы.  */
         {
            stop_flag = rc ;
            return  -1 ;
         }
      }
   }

   return  1 ;
}


static void first_statistics ( DISTINCT * d )
{
   int  i ;
   char base_name [13] ;

   error = 0 ;         /*  Сбросить флаг ошибок.  */

   process_wnd = establish_window ( 17, 2, 10, 44, 1 ) ;
   color ( process_wnd, process_title ) ;
   u4name_part ( base_name, d -> base_name, 0, 1 ) ;
   wprintf ( process_wnd, process_message, base_name,
             d -> count, d -> not_unique               ) ;
   wcursor ( process_wnd, 20, 5 ) ;
   wprintf ( process_wnd, "0\%" ) ;
   wcursor ( process_wnd, 1, 6 ) ;
   for ( i = 0 ; i < 40 ; i ++ )
      wprintf ( process_wnd, "█" ) ;

   display_window ( process_wnd ) ;
}


static void cur_statistics ( DISTINCT * d )
{
   int i ;
   int per_cent, end ;

   if ( ! process_wnd )          return ;
   if ( d -> cur_record % 50 )   return ;

   per_cent = d -> count * 100 / d -> reccount ;
   end      = d -> count *  40 / d -> reccount ;

   wcursor ( process_wnd, 30, 2 ) ;
   wprintf ( process_wnd, "%10ld", d -> count ) ;
   wcursor ( process_wnd, 30, 3 ) ;
   wprintf ( process_wnd, "%10ld", d -> not_unique ) ;
   wcursor ( process_wnd, 18, 5 ) ;
   wprintf ( process_wnd, "%3d", per_cent ) ;
   wcursor ( process_wnd, 1, 6 ) ;

   reverse_video ( process_wnd ) ;
   for ( i = 0 ; i < end ; i ++ )
      wprintf ( process_wnd, "░" ) ;
   normal_video ( process_wnd ) ;
}


static void last_statistics ( DISTINCT * d )
{
   char   base_name [13] ;

   u4name_part ( base_name, d -> base_name, 0, 1 ) ;
   d1_name ( d -> base_name, d -> base_name ) ;
   if ( strcmp ( d -> base_name, current_dir ) )
   {
      strncpy ( current_dir, d -> base_name, MAX_FILE_NAME_LEN - 1 ) ;
      wprintf ( result_wnd, "\n%s", current_dir ) ;
   }

   if ( error  ||  stop_flag )
   {
      if ( error )
      {
	 wprintf ( result_wnd, "\n  %-15s   Ошибка : %s",
		   base_name, error_ptr ( error )           ) ;
      }
      else
      {
	 wprintf ( result_wnd, "\n  %-15s   %s",
		   base_name, break_message       ) ;
	 stop_flag -= 2 ;     /*  Сбросить флаг, если было задано     */
			      /*  пропустить обработку текущей базы.  */
      }
   }
   else
   {
      wprintf ( result_wnd, "\n  %-15s%10ld %10ld %10ld", base_name,
                d -> reccount, d -> not_unique, d -> write_record  ) ;
   }

   delete_window ( process_wnd ) ;
}


static void writexy ( int x, int y, char * string )
{
   wr_str_screen ( x, y, string, strlen ( string ),
                   clr ( WHITE, BLACK, DIM )        ) ;
}


static void color ( WINDOW * wnd, char * title )
{
   set_colors ( wnd, NORMAL, WHITE, BLACK, DIM ) ;
   set_colors ( wnd, ACCENT, BLUE, YELLOW, BRIGHT ) ;
   set_colors ( wnd, TITLE,  WHITE, RED, DIM ) ;
   set_colors ( wnd, BORDER, WHITE, BLUE, DIM ) ;
   set_border ( wnd, 1 ) ;
   set_title  ( wnd, title ) ;
}


static void white ( int line )
{
   int i ;

   for ( i = 0 ; i < 80 ; i ++ )
      write_screen ( i, line, ' ', clr ( WHITE, BLACK, DIM ) ) ;
}


static char * error_ptr ( int error_num )
{
   int i ;

   for ( i = 0 ; i < sizeof ( error_data ) / sizeof ( ERROR_DATA ) ; i ++ )
      if ( error_data [i]. number == error_num )
         return  error_data [i]. data ;

   return  " " ;   /*  Неверный номер ошибки.  */
}


int u4error ( int error_num, char * message )
{
   error = error_num ;    /*  Установить флаг ошибки.  */

   clear_window ( error_wnd ) ;
   wcentre ( error_wnd, 1, error_ptr ( error_num ) ) ;
   if ( message )     wcentre ( error_wnd, 2, message ) ;

   writexy ( 2, 24, continue_key ) ;
   display_window ( error_wnd ) ;
   get_char () ;
   hide_window ( error_wnd ) ;
   writexy ( 2, 24, key ) ;
}


static int process_file ( DIRECTORY_FILE * d )
{
   distinct_base ( d -> name, pack, & df ) ;

   return  - stop_flag ;
}


static int process ( char * line )
{
   char name [90] ;

   strupr ( line ) ;
   u4name_full ( name, line, ".DBF" ) ;

   if ( chdir ( line ) == 0 )
      d1_process ( & dir, line ) ;
   else
   {
      if ( access ( line, 0 )  &&  access ( name, 0 ) )
         u4error ( E_DIR_NAME, line ) ;
      else
         distinct_base ( line, pack, & df ) ;
   }

   chdir ( work_directory ) ;
   return  - stop_flag ;
}


static void help ()
{
   WINDOW * wnd ;

   wnd = establish_window ( 7, 2, 19, 64, 1 ) ;
   color ( wnd, help_title ) ;
   wprintf ( wnd, help1_message ) ;
   wprintf ( wnd, help2_message ) ;
   wprintf ( wnd, help3_message ) ;
   display_window ( wnd ) ;
   writexy ( 2, 24, continue_key ) ;
   writexy ( 65, 24, help_message ) ;
   get_char () ;
   delete_window ( wnd ) ;
}


main ( int argc, char * argv [] )
{
   int i ;
   int cursor_type ;

   init_window () ;
   d4init_memory ( 1, 0, 0, 0 ) ;
   set_hard_error_handler ( 5, 2 ) ;
   cursor_type = get_cursor_type () ;
   set_cursor_type ( 0x2020 ) ;
   getcwd ( work_directory , MAX_FILE_NAME_LEN ) ;

   clear_screen ( 0x30 ) ;
   white ( 0 ) ;
   white ( 24 ) ;
   writexy ( 2, 0, title_message ) ;
   writexy ( 39, 0, copyright_message ) ;

   for ( i = 1 ; i < argc ; i ++ )
      if ( option ( opt, argv [i] ) < 0 )
         break ;

   if ( i == argc )      help () ;
   else
   {
      error_wnd = establish_window ( 19, 5, 6, 40, 2 ) ;
      set_colors ( error_wnd, ALL, RED, WHITE, BRIGHT ) ;
      set_title ( error_wnd, error_title ) ;

      stop_wnd = establish_window ( 19, 4, 6, 40, 2 ) ;
      color ( stop_wnd, stop_title ) ;
      wcentre ( stop_wnd, 1, stop_message ) ;

      result_wnd = establish_window ( 13, 13, 9, 52, 1 ) ;
      color ( result_wnd, result_title ) ;
      wprintf ( result_wnd, result_message ) ;
      display_window ( result_wnd ) ;
      if ( result_wnd )           /*  Предотвратить скролиг  */
      {                           /*  первой строки окна.    */
         result_wnd -> _wy ++ ;
         result_wnd -> _wh -- ;
      }

      if ( pack )     writexy ( 63, 24, pack_message ) ;
      writexy ( 2, 24, key ) ;

      while ( i < argc )     /*  Обработка.  */
	 if ( process ( argv [ i++ ] ) < 0 )
            break ;

      wprintf ( result_wnd, "\n  %s", end_message ) ;
      writexy ( 2, 24, continue_key ) ;
      get_char () ;

      if ( result_wnd )
      {
         result_wnd -> _wy -- ;
         result_wnd -> _wh ++ ;
      }
      delete_window ( result_wnd ) ;
      delete_window ( stop_wnd ) ;
      delete_window ( error_wnd ) ;
   }

   chdir ( work_directory ) ;
   set_cursor_type ( cursor_type ) ;
   restore_hard_error_handler () ;
   close_window () ;
   clear_screen ( 0x0F ) ;
}
