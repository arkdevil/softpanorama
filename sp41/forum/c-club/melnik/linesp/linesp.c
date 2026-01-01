//╔═════════════════════════════════════════════════════════════════════════╗
//║                                                                         ║
//║	    Module name	: 	linesp.c                                    ║
//║   	    Date	: 	14 June 1991                                ║
//║    	    Environment	: 	Turbo C++ 1.0                               ║
//║    	    Language    :       Turbo C                                     ║
//║    	    Author	: 	Melnik Oleg                                 ║
//║    	    Notice	:       This is a formating programm for text files ║
//║                                                                         ║
//╚═════════════════════════════════════════════════════════════════════════╝

#include	<stdio.h>
#include	<conio.h>
#include	<stdlib.h>
#include	<string.h>
//_______________________________________________

#define	MESSAGE "Linesp  Written by Melnik Oleg  14 June 1991  Free Ware"
#define ERROR   "Неизвестная опция: "
#define CAN_NOT_OPEN "Не могу открыть файл-"
//_______________________________________________

void main( int argc, char **argv )
{
//_______________________________________________

     FILE *source;
     FILE *target;
     int i;
     int k;
     int length;
     char tmp_str[ 255 ];
     char str_dest[ 255 ];
     char str_src[ 255 ];
     char page_num_str[ 255 ];
     int set_eof;

     char source_name[ 155 ];
     char target_name[ 155 ];
     char comment[ 255 ];
     int comment_f;
     int lines;
     int save_f;
     int delete_f;
     int no_f;
     int end_f;
     int page_num;
     int page_num_f;
     int center;
     int space;
     int line_mark;
//_______________________________________________

     if( argc < 3 )
     {
 printf("\n %s\n", MESSAGE );
 puts("┌──────────────────────────────────────────────────────────────────┐");
 puts("│Linesp  source  target  [ options ]\t\t\t\t   │");
 puts("│source  - файл-источник\t\t\t\t\t   │");
 puts("│target  - файл-приемник\t\t\t\t\t   │");
 puts("│Options:\t\t\t\t\t\t\t   │");
 puts("│lines\t - количество строк на странице ( по умолчанию - 63 )\t   │");
 puts("│/s\t - сохранить старые разделители\t\t\t\t   │");
 puts("│/d\t - удалить источник после работы\t\t\t   │");
 puts("│/n\t - не ставить новых разделителей\t\t\t   │");
 puts("│/e\t - не ставить разделитель в конце файла-приемника\t   │");
 puts("│/p[num] - включить нумерацию страниц, начиная с num\t\t   │");
 puts("│/l[pos] - центрировать номер страницы и колонтитул по позиции\t   │");
 puts("│\t   pos ( по умолчанию - 33 )\t\t\t\t   │");
 puts("│/c[str] - задать строку колонтитула str\t\t\t   │");
 puts("│/a[spc] - задать количество пустых строк между номером\t\t   │");
 puts("│\t   страницы ( колонтитулом ) и текстом ( по умолчанию - 1 )│");
 puts("└──────────────────────────────────────────────────────────────────┘");
     exit( 1 );
     }
//_______________________________________________

     printf("\n%s\n", MESSAGE );
//_______________________________________________

     lines = 63;
     save_f = 0;
     delete_f = 0;
     no_f = 0;
     end_f = 1;
     page_num_f = 0;
     center = 33;
     space = 1;
     comment_f = 0;
     set_eof = 0;
//_______________________________________________

     strcpy( source_name, argv[ 1 ]);
     strcpy( target_name, argv[ 2 ]);
     if( stricmp( source_name, target_name ) == 0 )
     {
	 puts("Имя файла-приемника идентично имени файла-источника\7");
         exit( 1 );
     }
     source = fopen( source_name, "r");
     if( source == NULL )
     {
	 printf("%sисточник > %s\7\n", CAN_NOT_OPEN, source_name );
	 exit( 1 );
     }
     target = fopen( target_name, "r");
     if( target != NULL )
     {
	 printf("Файл %s уже существует. Переписать (Y/N)?\a ", target_name );
	 for( i = getch(); i != 'y' && i != 'n' && i != 'N' && i != 'Y';
	      i = getch());
	 if( i == 'y' || i == 'Y')
	 {
	     puts("Y");
	 }
	 else
	 {
	     puts("N");
	     exit( 1 );
	 }
     }
     target = fopen( target_name, "w");
     if( target == NULL )
     {
	 printf("%sприемник > %s\7\n", CAN_NOT_OPEN, target_name );
	 fclose( source );
	 exit( 1 );
     }
//_______________________________________________

     for( i = 3; i < argc; i++ )
     {
	  if( argv[ i ][ 0 ] == '/')
	  {
	      switch( argv[ i ][ 1 ])
	      {
		      case 's': save_f = 1;
				break;
		      case 'd': delete_f = 1;
				break;
		      case 'n': no_f = 1;
				break;
		      case 'e': end_f = 0;
				break;
		      case 'p':
		      case 'l':
		      case 'a': length = strlen( argv[ i ]);
				for( k = 2; k < length && k < 252; k++ )
				{
				     tmp_str[ k -2 ] = argv[ i ][ k ];
				}
				tmp_str[ k -2 ] = 0;
				k = atoi( tmp_str );
				switch( argv[ i ][ 1 ])
				{
					case 'p': if( k != 0 )
						  {
						      page_num_f = 1;
						      page_num = k;
						  }
						  else
						  {
						      page_num_f = 1;
						      page_num = 1;
						  }
						  break;
					case 'l': center = k;
						  break;
					case 'a': space = k;
						  break;
				}
				break;
		      case 'c': length = strlen( argv[ i ]);
				for( k = 2; k < length && k < 252; k++ )
				{
				     comment[ k -2 ] = argv[ i ][ k ];
				}
				comment[ k -2 ] = 0;
				comment_f = 1;
				break;
		      default : printf("%s%s\7\n", ERROR, argv[ i ]);
				exit( 1 );
	      }
	  }
	  else if( atoi( argv[ i ]) != 0 )
	  {
	      lines = atoi( argv[ i ]);
	  }
	  else
	  {
	      printf("%s%s\7\n", ERROR, argv[ i ]);
	      exit( 1 );
	  }
     }
//_______________________________________________

     if( comment_f == 1 )
     {
	 length = strlen( comment );
	 if(( center - length /2 ) > 0 )
	 {
	      strcpy( tmp_str, comment );
	      memset( comment, ' ', 252 );
	      if(( center + length /2 ) < 250 )
	      {
		  for( i = center-length/2-1, k = 0; k < length; i++, k++ )
		  {
		       comment[ i ] = tmp_str[ k ];
		  }
		  comment[ i ] = 0;
	      }
	      else
	      {
		  for( i = 249, k = length -1; k >= 0; i--, k-- )
		  {
		       comment[ i ] = tmp_str[ k ];
		  }
		  comment[ 250 ] = 0;
	      }
	 }
     }
//_______________________________________________

     lines -= page_num_f + comment_f + space;
     if( lines < 1 )
     {
	 puts("Размер страницы получается меньше одной строки\7");
	 puts("Дальнейшая работа невозможна");
	 exit( 1 );
     }
     str_src[ 0 ] = 0;
     fgets( str_src, 250, source );
     if( feof( source ) && strlen( str_src ) == 0 )
     {
	 set_eof = 1;
     }
     for( line_mark = 0; set_eof == 0; line_mark++ )
     {
	  if( line_mark >= lines || line_mark == 0 )
	  {
	      if( line_mark != 0 && no_f != 1 )
	      {
		  fputs("", target );
	      }
	      if( page_num_f == 1 )
	      {
		  itoa( page_num, page_num_str, 10 );
		  length = strlen( page_num_str );
		  if(( center - length /2 ) > 0 )
		  {
		       strcpy( tmp_str, page_num_str );
		       memset( page_num_str, ' ', 252 );
		       if(( center + ( length +2 ) /2 ) < 250 )
		       {
			    i = center - length/2 -2;
			    page_num_str[ i++ ] = '-';
			    for( k = 0; k < length; )
			    {
				 page_num_str[ i++ ] = tmp_str[ k++ ];
			    }
			    page_num_str[ i++ ] = '-';
			    page_num_str[ i ] = 0;
		       }
		       else
		       {
			    for( i = 249, k = length -1; k >= 0; i--, k-- )
			    {
				 page_num_str[ i ] = tmp_str[ k ];
			    }
			    page_num_str[ 250 ] = 0;
		       }
		  }
		  fputs( page_num_str, target );
		  fputs("\n", target );
		  page_num++;
	      }
	      if( comment_f == 1 )
	      {
		  fputs( comment, target );
		  fputs("\n", target );
	      }
	      for( i = 0; i < space; i++ )
	      {
		   fputs("\n", target );
	      }
	      line_mark = 0;
	  }
	  if( save_f == 0 )
	  {
	      for( i = 0, k = 0; i < strlen( str_src ); i++ )
	      {
		   if( str_src[ i ] != '')
		   {
		       str_dest[ k++ ] = str_src[ i ];
		   }
	      }
	      str_dest[ k ] = 0;
	      fputs( str_dest, target );
	  }
	  else
	  {
	      fputs( str_src, target );
	  }
	  str_src[ 0 ] = 0;
	  fgets( str_src, 250, source );
	  if( feof( source ) && strlen( str_src ) == 0 )
	  {
	      set_eof = 1;
	  }
     }
//_______________________________________________

     if( end_f == 1 )
     {
	 fputs("", target );
     }
//_______________________________________________

     fclose( source );
     fclose( target );
//_______________________________________________

     if( delete_f == 1 )
     {
	 i = unlink( source_name );
	 if( i == -1 )
	 {
	     printf("Не могу удалить файл-источник > %s\7\n", source_name );
	 }
     }
//_______________________________________________
}