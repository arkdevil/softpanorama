/*----------------------------------------------------------------------+
|                                                                       |
|                                        panorame's editor              |
|                                        version 2.02                   |
|          adventures of Captain Comic                                  |
|                                                                       |
+------------------------------------- (c) Insight corp., 1991 --------*/


#include <stdio.h>
#include <dos.h>
#include <graph.h>

/*
 *  программка реализует работу по редактированию панорамы игрушки
 *               "Капитан Комик"

 *   версия 2.00 программы
	 отличия:
		реализует работу программы с тремя панорамами одновременно;
		обеспечивает работу с прозрачными и непрозрачными кубиками;
		обеспечивает просмотр словаря кубиков.

 */

#define VISIBLE         0x00
#define INVISIBLE       !VISIBLE

#define MODE_OFF        0x00
#define MODE_ON         !MODE_OFF

#define NO              0x00
#define YES             !NO

#define F_key           0x100
#define F_esc           0x1b
#define F_enter         0x0d
#define F_space         0x20

#define F_tab           0x09
#define F_shft_tab      F_key + 0x0f

#define F_home          F_key + 71
#define F_end           F_key + 79

#define F_up            F_key + 0x48
#define F_down          F_key + 0x50
#define F_left          F_key + 0x4b
#define F_right         F_key + 0x4d

#define F_pgup          F_key + 0x49
#define F_pgdn          F_key + 0x51
#define F_ctrl_pgup     F_key + 0x84
#define F_ctrl_pgdn     F_key + 0x76

#define F_02            F_key + 60
#define F_03            F_key + 61
#define F_04            F_key + 62
#define F_05            F_key + 63
#define F_06            F_key + 64
#define F_07            F_key + 65
#define F_08            F_key + 66
#define F_09            F_key + 67

#define Ctrl_F_05       F_key + 98

#define C_black         0x00
#define C_blue          0x01
#define C_green         0x02
#define C_cyan          0x03
#define C_red           0x04
#define C_magenta       0x05
#define C_brown         0x06
#define C_white         0x07
#define C_gray          0x08
#define C_lightblue     0x09
#define C_lightgreen    0x0a
#define C_lightcyan     0x0b
#define C_lightred      0x0c
#define C_lightmagenta  0x0d
#define C_lightyellow   0x0e
#define C_brightwhite   0x0f

#define TT2_SIZE    0x4000
#define PT_MAP_SIZE 0x504

#define SCREEN_WDT  320 /* columns - X координата */
#define SCREEN_HGT  200 /* lines   - Y координата */

#define PAN_SIZE        0x80 /* общая длина панорамы в кубиках */
#define PAN_SCR_SIZE    16 /* длина отображаемой на экране части панорамы */
#define PAN_LEFT_LIM    PAN_SIZE - PAN_SCR_SIZE - 1


#define W_EDIT_X    3   /* строчка */
#define W_EDIT_Y    10  /* байт */

/*-----------------------------------------------------------------------*/

char tt2_name[ 15 ] = "forest.tt2";
FILE *tt2_file;
char tt2[ TT2_SIZE ];   /* буфер, в котором хранятся кубики панорамы */

/*-----------------------------------------------------------------------*/

char *pt_map; /* указатель на текущую редактируемую панораму */

char pt_map0_name[ 15 ] = "forest0.pt";
FILE *pt_map0_file;
char pt_map0[ PT_MAP_SIZE ];  /* буфер, в котором хранится карта панорамы 0*/

char pt_map1_name[ 15 ] = "forest1.pt";
FILE *pt_map1_file;
char pt_map1[ PT_MAP_SIZE ];  /* буфер, в котором хранится карта панорамы 1*/

char pt_map2_name[ 15 ] = "forest2.pt";
FILE *pt_map2_file;
char pt_map2[ PT_MAP_SIZE ];  /* буфер, в котором хранится карта панорамы 2*/

/*-----------------------------------------------------------------------*/

int visible_toggle = MODE_OFF;  /* переключатель режима прозрачности */
		/* структура для представления прозрачности кубиков */
struct cube {           /* строчка кубика */
	 short inv;         /* флажечек невидимости */
	 short nmb;         /* логический номер кубика (используется
						   при запоминании */
	 };
struct cube vc[ 0x7f ]; /* массив поддержки признаков словаря */

/*-----------------------------------------------------------------------*/

int qbk_crnt[ 16 ][ 16 ];  /* массив, в котором содержится точечное
					  представление кубика */

/*---------------------------------------------------------------------
		  системная функция символьного ввода   int getkey()
---------------------------------------------------------------------*/
int
getkey()
{
  int next_char;
  if( !(next_char = getch()) )
	  return( F_key + getch() );
  else
	  return( next_char );
}

/*---------------------------------------------------------------------
	  системная функция позиционирования курсора void goto_xy()
---------------------------------------------------------------------*/
void
goto_xy( column, line )
int column, line;
{
  _settextposition( (short) column, (short) line );
}

/*---------------------------------------------------------------------
			функция вводит файл
---------------------------------------------------------------------*/
get_file( file_ptr, file_name, file_buffer, file_size )
FILE *file_ptr;
char *file_name;
char *file_buffer;
int file_size;
{
  int file_len;

  if( (file_ptr = fopen( file_name, "rb" )) == NULL )
	  {
	  printf( "SystemError: не могу открыть файл %s\n", file_name );
	   exit( 1 );
	  }
  file_len = fread( file_buffer, 1, file_size, file_ptr );
  fclose( file_ptr );
  return( file_len );
}

/*---------------------------------------------------------------------
		   функция выводит файл
---------------------------------------------------------------------*/
put_file( file_ptr, file_name, file_buffer, file_size )
FILE *file_ptr;
char *file_name;
char *file_buffer;
int file_size;
{
 if( (file_ptr = fopen( file_name, "wb" )) == NULL )
	 {
	 printf( "SystemError: не могу открыть файл %s\n",
			  file_name );
	 exit( 1 );
	 }
  fwrite( file_buffer, 1, file_size, file_ptr );
  fclose( file_ptr );
}

/*---------------------------------------------------------------------
		функция возвращает номер кубика по координате
				 в файле панорамы
		номер колонки, номер строчки --> номер кубика
---------------------------------------------------------------------*/
int
cd_to_nm( column, line )
int column, line;
{
  return( pt_map[ 4+ ( 0x80*line ) + column ] );
}

/*---------------------------------------------------------------------
			  функция устанавливает номер кубика
			   в требуемые координаты файла tt2
---------------------------------------------------------------------*/
void
mn_to_cd( nmbr_qbk, column, line )
int nmbr_qbk, column, line;
{
  pt_map[ 4+ ( 0x80*line ) + column ] = (short)nmbr_qbk;
}



/*---------------------------------------------------------------------

	  следующие далее функции позволяют обрабатывать
	  прозрачные и непрозрачные для прохождения кубики:

	  после загрузки файла кубиков, происходит определение
	  общего количества кубиков и количества прозрачных кубиков
	  и непрозрачные кубики записываются в конец буфера

	  два счетчика поддерживают количества тех и других кубиков
	  при этом прозрачные кубики растут вниз, а непрозрачные -
	  вверх

	  в конце рабочего сеанса, при записи, непрозрачные кубики
	  дописываются в буфер до прозрачных и сбрасываются в файл


---------------------------------------------------------------------*/
load_stocks()
{
  int file_len = 0,
	  qbk_all_count;

  /* считываем в буфер tt2[] файл с кубиками */
  file_len = get_file( tt2_file, tt2_name, tt2, TT2_SIZE );

  /* определяем количество кубиков в файле */
  qbk_all_count = ( file_len - 4 ) / 80;

  /* перезаписываем непрозрачные кубики в конец буфера
  и устанавливаем счетчики */
/*  qbk_soft_count = (int) tt2[0];
  qbk_hard_count = qbk_all_count - qbk_soft_count; */
  /*
   for( i=
   */
}

/*---------------------------------------------------------------------
		  функция преобразует кубик под номером nmbr
				в точечное представление
					в массив qbk_crnt
---------------------------------------------------------------------*/
line_to_qbk( nmbr, ptr_to_qbk_crnt, n_line )
int nmbr;
int *ptr_to_qbk_crnt;
int n_line;
{
  unsigned int i;
  int rslt, ptr_to_qbk, i_crnt,
	  word[ 4 ];
  for( i=0; i<=3; i++)
	   {
	   ptr_to_qbk = 4 + 0x80 * nmbr + i * 0x20 + n_line * 2;
	   word[ i ] = (tt2[ ptr_to_qbk ] & 0x00ff)*0x100
				  + (tt2[ ptr_to_qbk + 1 ] & 0x00ff);
	   }
  i = 0x8000; i_crnt = 0;
  do{
	  rslt = 0;
	  rslt |= ( ( i & word[ 0 ] ) ? 0x1 : 0x0 );
	  rslt |= ( ( i & word[ 1 ] ) ? 0x2 : 0x0 );
	  rslt |= ( ( i & word[ 2 ] ) ? 0x4 : 0x0 );
	  rslt |= ( ( i & word[ 3 ] ) ? 0x8 : 0x0 );

	  ptr_to_qbk_crnt[ n_line*16+i_crnt ] = rslt;

	  i >>= 1; i_crnt++;
  }while( i != 0 );
}

convert_to_qbk( nmbr, ptr_to_qbk_crnt )
int nmbr;
int *ptr_to_qbk_crnt;
{
  int i;
  for( i=0; i<16; i++ )
	   line_to_qbk( nmbr, ptr_to_qbk_crnt, i );
}

/*---------------------------------------------------------------------
		   функция записывает кубик под номером nmbr
				 из точечного представления
					в массиве qbk_crnt
					  в файл кубиков
---------------------------------------------------------------------*/
convert_from_qbk( nmbr, ptr_to_qbk_crnt )
int nmbr;
int *ptr_to_qbk_crnt;
{
  unsigned int i;
  int image_x, image_y,
	  dstn;
  int word[ 4 ];

  for( image_y=0; image_y<16; image_y++ )
	   { /* цикл по строчкам образа */
	   i = 0x8000;
	   word[ 0 ] = 0;
	   word[ 1 ] = 0;
	   word[ 2 ] = 0;
	   word[ 3 ] = 0;
	   for( image_x=0; image_x<16; image_x++)
			{ /* цикл обработки следующего байта строки */
			dstn = ptr_to_qbk_crnt[ image_y*16 + image_x ];
			word[ 0 ] |= ( (dstn & 0x1 )? i : 0);
			word[ 1 ] |= ( (dstn & 0x2 )? i : 0);
			word[ 2 ] |= ( (dstn & 0x4 )? i : 0);
			word[ 3 ] |= ( (dstn & 0x8 )? i : 0);
			i >>= 1;
			}
	   /* запись отработанного слова в буфер */
	   for( i=0; i<4; i++ )
			{
			int ptr_to_tt2 = 4 + 0x80 * nmbr + i *0x20 + image_y * 2;
			tt2[ ptr_to_tt2 ] = (short)((word[ i ] >> 8) & 0x00ff);
			tt2[ ptr_to_tt2 + 1 ] = (short)(word[ i ] & 0x00ff);
			}
	   }
}



/*---------------------------------------------------------------------
				 функция рисует кубик ptr_to_qbk_crnt
				   в относительной координате x, y
---------------------------------------------------------------------*/
set_qbk( ptr_to_qbk_crnt, x, y )
int *ptr_to_qbk_crnt;
int x, y;
{
  int i, j;

  for( i=0; i<=15; i++ )
	   for( j=0; j<=15; j++ )
			{
			int i_x, i_y;
			i_x = W_EDIT_X + x*16 + i;
			i_y = W_EDIT_Y + y*16 + j;

			_setcolor( (short int) *(ptr_to_qbk_crnt + i*16+j ) );
			_setpixel( (short int) i_y,
					   (short int) i_x );
			}
}

/*------------------------------------------- фрагмент на ассемблере --
				  функция рисует кубик ptr_to_qbk_crnt
					в относительной координате x, y
---------------------------------------------------------------------*/
asm_set_qbk( qbk_nmbr, x, y )
int qbk_nmbr;
int x, y;
{
  int i;
  unsigned int segmnt_src, offset_src,
			   offset_tgt;
  char far *ptr_to_tt2 = tt2 + 4 + 0x80 * qbk_nmbr;

  segmnt_src = FP_SEG( ptr_to_tt2 );
  offset_src = FP_OFF( ptr_to_tt2 );

  /* вычислим target адрес в видеобуфере */
  /* по входным координатам x, y */

  offset_tgt = (W_EDIT_Y + y*0x10)*0x28 + W_EDIT_X + x*0x02;

  _asm{
				push    ax
				push    bx
				push    dx
				push    ds
				push    es
				push    di
				push    si

				; разместим source адрес
				mov     ax, segmnt_src
				mov     ds, ax
				mov     si, offset_src
				; разместим target адрес
				mov     ax, 0xa000
				mov     es, ax
				mov     di, offset_tgt

				mov     ah, 1

		   main_loop:
						mov     dx, 0x03c4
						mov     al, 2
						out     dx, al
						inc     dx
						mov     al, ah
						out     dx, al
						mov     bx, 0x10
						push    di
				l_loop:
						movsw           ; mov ds:[si] to es:[di]
										; причем с инкрементами si и di
						add     di, 0x026
						dec     bx
						jnz     l_loop
						pop     di
				add     ah, ah
				cmp     ah, 8
				jle     main_loop

				pop     si
				pop     di
				pop     es
				pop     ds
				pop     dx
				pop     bx
				pop     ax
	  }
}

/*---------------------------------------------------------------------
	   функция выдает текущий кусок панорамы относительно
			 смещений координат disp_x и disp_y
---------------------------------------------------------------------*/
drow_pan( displ )
int displ;
{
  int i, j;
  for( i=0; i<=9; i++ )
	   for( j=0; j<=PAN_SCR_SIZE; j++ )
			{
			int nmbr_qbk;
			nmbr_qbk = pt_map[ 4+ (0x80*i ) + ( displ + j ) ];

			asm_set_qbk( nmbr_qbk, j, i );
			/* фрагмент аккомпанирует в работе обработке режима
			   прозрачности: если режим отображения прозрачности
			   включен, то отметить непрозрачные кубики */
			if( visible_toggle == MODE_ON )
				if( vc[ nmbr_qbk ].inv == INVISIBLE )
					{ /* подать признак на экран */
					int offset_x, offset_y;

					offset_x = W_EDIT_X*0x8 + j*0x10;
					offset_y = W_EDIT_Y + i*0x10;

					_setcolor( C_lightred );
					_rectangle( _GBORDER,
								offset_x+1, offset_y+1,
								offset_x + 0x0f-1, offset_y + 0x0f-1 );
					}
			}
}

/*---------------------------------------------------------------------
			  функция засвечивает кубиk по заданным
				  координатам ( рамку рисует )
---------------------------------------------------------------------*/
turn_on_box( x, y )
int x, y;
{
  int offset_x, offset_y;

  offset_x = W_EDIT_X*0x8 + x*0x10;
  offset_y = W_EDIT_Y + y*0x10;

  _setcolor( C_lightyellow );
  _rectangle( _GBORDER,
			  offset_x, offset_y,
			  offset_x + 0x0f, offset_y + 0x0f );
}

/*---------------------------------------------------------------------
				функция перерисовывает кубик по заданным
					 координатам, чтобы убрать рамку
---------------------------------------------------------------------*/
turn_of_box( x, y )
int x, y;
{
  int offset_x, offset_y;

  asm_set_qbk( cd_to_nm( x, y ), x, y );

}


/*---------------------------------------------------------------------
				функция реализует переращет
				номеров кубиков для запоминания в
				файле словаря
---------------------------------------------------------------------*/
vc_recount()
{
  int sc_count,  /* переменная содержит количество мягких кубиков
					кличка "прозрачных"  */
	  qbk_soft,
	  i;
				 /* функция двухпроходная:
					на первом проходе сдвигаются ближе к началу
					все прозрачные (по кличке) кубики;
					на втором - дописываются непрозрачные
					в поле .nmb структуры vc
					посередине определяется количество прозрачных
					кубиков, каковое и записывается в начало файла
				 */
  sc_count = 0;
  for( i=0; i<0x80; i++ )
	   if( vc[ i ].inv == VISIBLE )
		   vc[ sc_count++ ].nmb = i;
  qbk_soft = sc_count - 1;
  for( i=0; i<0x80; i++ )
	   if( vc[ i ].inv == INVISIBLE )
		   vc[ sc_count++ ].nmb = i;
  tt2[ 0 ] = (short) qbk_soft;
}

/*---------------------------------------------------------------------
				функция записывает в файл словаря кубиков
				tt2 кубики в логическом порядке
				vc[   ].nmb
---------------------------------------------------------------------*/
vc_out_tt2()
{
 int i;

 if( (tt2_file = fopen( tt2_name, "wb" )) == NULL )
	 {
	 printf( "SystemError: не могу открыть файл (vc_out_tt2) %s\n",
			  tt2_name );
	 exit( 1 );
	 }
  fwrite( tt2, 1, 4, tt2_file );
  for( i=0; i<0x80; i++ )
	   fwrite( tt2+4+0x80*vc[i].nmb, 1, 0x80, tt2_file );

  fclose( tt2_file );
}

/*---------------------------------------------------------------------
				функция реализует
				конвертирование номеров кубиков в текущей карте
				согласно номерам в поле .nmb структуры vc
---------------------------------------------------------------------*/
vc_convert()
{
  int i, j;

  for( i=0+4; i< PT_MAP_SIZE; i++ )
	   {
	   /* по каждому кубику карты панорамы */
	   j = 0;
	   /*
		* методом поиска перебором ищем логический номер
		* кубика и заменяем его физическим номером
		*
		*/
	   while( vc[ j ].nmb != pt_map[ i ] )
			  {
			  if( j++ >= 0x80 )
				  {
				  printf( "SystemError: потерялся кубик с номером %d\n",
						  j );
				  exit( 0 );
				  }
			  }
	   pt_map[ i ] = (short) j;
	   }
}

/*===================================================================
			функции реализующие работу со словарем кубиков;
===================================================================*/

#define WND_VC_X 100
#define WND_VC_Y 100

/*---------------------------------------------------------------------
				функция работает со словарем кубиков:
				позволяет выбирать кубик из словаря,
				возвращает затем его номер

				функция возвращает -1 , если было выйдено по Esc
				в противном случае возвращается номер кубика
---------------------------------------------------------------------*/
int
voc_cube()
{

  /*
   | функция организует строчку из кубиков внизу экрана,
   | в которой позволяет циклически просматривать
   | словарь кубиков и выбирать нужный, который и
   | становится активным
   |
   | координаты словаря: 0, 10 длина строки: 8 кубиков
   +-------------------------------------------------------*/
   int i, next_instr;
   static int bx = 0, by = 0;
   int offsetby = 10;


   do{
	  for( i=0; i<0x10; i++ ) /* вывод строчки кубиков */
		   asm_set_qbk( by*0x10+i, 0+i, 10 );
	  turn_on_box( bx, 10 );

	  next_instr = getkey();

	  turn_of_box( bx, 10 );
		   switch( next_instr ) {
			   case F_esc:
	  _setcolor( C_black );
	  _rectangle( _GFILLINTERIOR, 24,  10-1 + 0x0a*0x10,
					24 + 0x10*0x10-1, 10-1 + 0x0a*0x10  + 0xf+1 );
					return( -1 );
			   case F_enter:
	  _setcolor( C_black );
	  _rectangle( _GFILLINTERIOR, 24,  10-1 + 0x0a*0x10,
					24 + 0x10*0x10-1, 10-1 + 0x0a*0x10  + 0xf+1 );
					return( by * 0x10 + bx ) ;
					break;
			   case F_home: /* к первому кубику */
					bx = 0;
					by = 0;
					break;
			   case F_end:  /* к последнему кубику */
					bx = 14;
					by = 7;
					break;
			   case F_up:   /* циклически на ряд вперед */
					if( --by < 0 ) by = 7;
					break;
			   case F_down: /* циклически на ряд назад */
					if( ++by > 7 ) by = 0;
					break;
			   case F_left: /* циклически влево на кубик */
					if( --bx < 0 ) bx = 0x0f;
					break;
			   case F_right: /* циклически вправо на кубик */
					if( ++bx > 0x0f ) bx = 0;
					break;
			   }
  }while( 1 );

}

/*===================================================================
			функции реализующие работу редактора кубика
===================================================================*/
/* размеры точки в окне редактирования */
#define DOT_WIDTH       3
#define DOT_HEIGHT      3

/* координаты экрана палитры цветов */
#define CLR_PLT_HOME_X  60
#define CLR_PLT_HOME_Y  60

/* координаты окна редактирования */
#define WND_HOME_X      100
#define WND_HOME_Y      70

/* размеры образа в байтах */
#define IMG_WIDTH       0x10    /* ширина образа в байтах */
#define IMG_HEIGHT      0x10    /* высота образа в байтах */


/* размеры окна редактирования (в точках) */
#define WND_WIDTH       0x10    /* количество точек по горизонтали */
#define WND_HEIGHT      0x10    /* количество точек по вертикали */

/* координаты окна образа */
#define WND_IMAGE_X      160
#define WND_IMAGE_Y      60

int image[ WND_WIDTH ][ WND_HEIGHT ];
int current_color;
int trg_path = NO;

cursor_goto( x, y)
int x, y;
{
 static int old_x = 0,    /* старые координаты курсора */
		old_y = 0;
 /* сотрем изображение предыдущего курсора */
 _setcolor( C_black );
 _rectangle(_GBORDER,   WND_HOME_X+old_x*DOT_WIDTH,
			WND_HOME_Y+old_y*DOT_HEIGHT,
			WND_HOME_X+old_x*DOT_WIDTH+DOT_WIDTH,
			WND_HOME_Y+old_y*DOT_HEIGHT+DOT_HEIGHT );
 /* функция визуализации графического курсора */
 _setcolor( C_lightyellow );
 _rectangle(_GBORDER,   WND_HOME_X+x*DOT_WIDTH,
			WND_HOME_Y+y*DOT_HEIGHT,
			WND_HOME_X+x*DOT_WIDTH+DOT_WIDTH,
			WND_HOME_Y+y*DOT_HEIGHT+DOT_HEIGHT );
 old_x = x;
 old_y = y;
}

color_palette()
{
 /* функция выдает на экран палитру цветов */
 int i;

 for( i=0; i<=15; i++ )
      {
      _setcolor( i );
      _rectangle( _GFILLINTERIOR, CLR_PLT_HOME_X,
				  CLR_PLT_HOME_Y+i*5,
				  CLR_PLT_HOME_X+12,
				  CLR_PLT_HOME_Y+i*5+3 );
      };
 current_color = 0;
}

color_cursor_goto( x )
int x;
{
 /* сотрем изображение предыдущего курсора */
 _setcolor( C_lightcyan );
 _rectangle(_GBORDER,   CLR_PLT_HOME_X-1,
			CLR_PLT_HOME_Y+current_color*5-1,
			CLR_PLT_HOME_X+12+1,
			CLR_PLT_HOME_Y+current_color*5+4 );
 /* функция визуализации графического курсора */
 _setcolor( C_lightyellow );
 _rectangle(_GBORDER,   CLR_PLT_HOME_X-1,
			CLR_PLT_HOME_Y+x*5-1,
			CLR_PLT_HOME_X+12+1,
			CLR_PLT_HOME_Y+x*5+4 );
 current_color = x;
}

paint_point( coord_x, coord_y, current_color )
int coord_x, coord_y;
int current_color;
{ /*
   * закрасим текущую координату в
   * текущий цвет
   */
   _setcolor( current_color );
   image[ coord_y ][ coord_x ] = current_color;
   _rectangle( _GFILLINTERIOR,
			   WND_HOME_X+coord_x*DOT_WIDTH+1,
			   WND_HOME_Y+coord_y*DOT_HEIGHT+1,
			   WND_HOME_X+coord_x*DOT_WIDTH+DOT_WIDTH-1,
			   WND_HOME_Y+coord_y*DOT_HEIGHT+DOT_HEIGHT-1 );

   /* закрасим данную точку в реальном размере */
   _setpixel(  WND_IMAGE_X+coord_x,
   WND_IMAGE_Y+coord_y );
}

/* функция редактирует образ в графическом окне */
image_editor()
{
 int next_instr;
 static int coord_x = 8,
		coord_y = 8;

do {

 cursor_goto( coord_x, coord_y); /* курсор на середину окошка */

 next_instr = getkey();




 /* переключатель цветов */
 switch( next_instr ) {
	 case 'a' : { color_cursor_goto( C_black ); break; }
	 case 'b' : { color_cursor_goto( C_blue ); break; }
	 case 'g' : { color_cursor_goto( C_green ); break; }
	 case 'c' : { color_cursor_goto( C_cyan ); break; }
	 case 'r' : { color_cursor_goto( C_red ); break; }
	 case 'm' : { color_cursor_goto( C_magenta ); break; }
	 case 'n' : { color_cursor_goto( C_brown ); break; }
	 case 'w' : { color_cursor_goto( C_white ); break; }
	 case 'A' : { color_cursor_goto( C_gray ); break; }
	 case 'B' : { color_cursor_goto( C_lightblue ); break; }
	 case 'G' : { color_cursor_goto( C_lightgreen ); break; }
	 case 'C' : { color_cursor_goto( C_lightcyan ); break; }
	 case 'R' : { color_cursor_goto( C_lightred ); break; }
	 case 'M' : { color_cursor_goto( C_lightmagenta ); break; }
	 case 'Y' : { color_cursor_goto( C_lightyellow ); break; }
	 case 'W' : { color_cursor_goto( C_brightwhite ); break; }

	}
 switch( next_instr ) {
	case ' ':
	     { /* закрасим текущую координату в
			* текущий цвет
			*/
		 paint_point( coord_x, coord_y, current_color );
	     break;
		 }

	case F_04: /* триггер переключателя режима закраски */
		 {
		 if( trg_path == NO )
			 {
			 _setcolor( C_lightyellow );
			 _rectangle( _GFILLINTERIOR, CLR_PLT_HOME_X,
						  CLR_PLT_HOME_Y+17*5,
						  CLR_PLT_HOME_X+130,
						  CLR_PLT_HOME_Y+17*5+3 );
			 trg_path = YES;
			 }
		 else
			 {
			 _setcolor( C_lightcyan );
			 _rectangle( _GFILLINTERIOR, CLR_PLT_HOME_X,
						  CLR_PLT_HOME_Y+17*5,
						  CLR_PLT_HOME_X+130,
						  CLR_PLT_HOME_Y+17*5+3 );
			 trg_path = NO;
			 }
		 break;
		 }
	case F_left:
		 {
		 if( trg_path == YES )
			 paint_point( coord_x, coord_y, current_color );

		 if( coord_x > 0 )
		 coord_x--;
	     break;
		 }
	case F_right:
		 {
		 if( trg_path == YES )
			 paint_point( coord_x, coord_y, current_color );

		 if( coord_x < WND_WIDTH-1 )
		 coord_x++;
	     break;
		 }
	case F_up:
		 {
		 if( trg_path == YES )
			 paint_point( coord_x, coord_y, current_color );

		 if( coord_y > 0 )
		 coord_y--;
	     break;
		 }
	case F_down:
		 {
		 if( trg_path == YES )
			 paint_point( coord_x, coord_y, current_color );

		 if( coord_y < WND_HEIGHT-1 )
		 coord_y++;
	     break;
		 }

	case F_05: /* закрасить весь кубик текущим цветом */
		 {
		 int i, j;
		 for( j=0; j<IMG_HEIGHT; j++ )
			  for( i=0; i<IMG_WIDTH; i++ )
			  {
			  paint_point( i, j, current_color );
			  }
		 break;
		 }
	case F_esc:
	     return;
    }; /* switch */

} while( 1 );



}

qbk_edit()
{
    int xi, xj;
	short x;

    /* вырисовывание экрана редактора */

	_setcolor( C_lightyellow );

	_rectangle( _GBORDER,       40, 40, 210, 160 );
	_setcolor( C_lightcyan );
	_rectangle( _GFILLINTERIOR, 50, 50, 200, 150 );

	_setcolor( C_black );
	_rectangle( _GFILLINTERIOR, WND_HOME_X,
				WND_HOME_Y,
				WND_HOME_X+(WND_WIDTH)*DOT_WIDTH,
				WND_HOME_Y+(WND_HEIGHT)*DOT_HEIGHT );

    color_palette();
	color_cursor_goto( C_black );

	/* выведем статус триггера следа */
	if( trg_path == YES )
		{
		_setcolor( C_lightyellow );
		_rectangle( _GFILLINTERIOR, CLR_PLT_HOME_X,
						  CLR_PLT_HOME_Y+17*5,
						  CLR_PLT_HOME_X+130,
						  CLR_PLT_HOME_Y+17*5+3 );
		}
	else
		{
		_setcolor( C_lightcyan );
		_rectangle( _GFILLINTERIOR, CLR_PLT_HOME_X,
					 CLR_PLT_HOME_Y+17*5,
					 CLR_PLT_HOME_X+130,
					 CLR_PLT_HOME_Y+17*5+3 );
		}

    /* вырисуем образ на экране */

	for( xj=0; xj<IMG_HEIGHT; xj++ )
	  for( xi=0; xi<IMG_WIDTH; xi++ )
	 {
	 _setcolor( image[ xj ][ xi ] );
	 _rectangle( _GFILLINTERIOR,
		     WND_HOME_X+xi*DOT_WIDTH+1,
		     WND_HOME_Y+xj*DOT_HEIGHT+1,
		     WND_HOME_X+xi*DOT_WIDTH+DOT_WIDTH-1,
		     WND_HOME_Y+xj*DOT_HEIGHT+DOT_HEIGHT-1 );
	 /* закрасим данную точку в реальном размере */
	 _setpixel(  WND_IMAGE_X+xi,
		     WND_IMAGE_Y+xj );


	 };

    image_editor();

    /*    _setpixel( x, y );*/

}



/*---------------------------------------------------------------------
		   функция отрабатывает основное меню системы
					   редактирования
---------------------------------------------------------------------*/
drow_menu()
{
  int next_instr;
  int offset_pan = 0; /* смещение панорамы на экране */
  int crnt_box_nmbr,  /* номер и                     */
	  box_x=0, box_y=0; /* координаты выделенного кубика */

  pt_map = pt_map0; /* инициилизируем указатель на текущую карту панорамы */

  do{
	  drow_pan( offset_pan );

	  turn_on_box( box_x, box_y );

	  next_instr = getkey();

	  turn_of_box( box_x, box_y );
		   switch( next_instr ) {
			   case F_esc:
					return;
					break;
			   case F_home: /* панораму к левому краю */
					offset_pan = 0;
					break;
			   case F_end: /* панораму к правому краю */
					offset_pan = PAN_LEFT_LIM;
					break;
			   case F_ctrl_pgdn: /* панораму вправо на кубик */
					offset_pan = ((offset_pan+=2)>=PAN_LEFT_LIM)
								 ? PAN_LEFT_LIM
								 : offset_pan;
					break;
			   case F_pgdn: /* панораму вправо на экран */
					offset_pan = ((offset_pan+=PAN_SCR_SIZE)>=PAN_LEFT_LIM)
								 ? PAN_LEFT_LIM
								 : offset_pan;
					break;
			   case F_ctrl_pgup: /* панораму влево на кубик */
					offset_pan = ( (offset_pan-=2) <= 0 )
								 ? 0
								 : offset_pan;
					break;
			   case F_pgup: /* панораму влево на экран */
					offset_pan = ( (offset_pan-=PAN_SCR_SIZE) <= 0 )
								 ? 0
								 : offset_pan;
					break;
			   case F_up: /* рамочку вверх на кубик */
					box_y = ( (box_y-=1) <= 0 )
							  ? 0
							  : box_y;
					break;
			   case F_down: /* рамочку вниз на кубик */
					box_y = ( (box_y+=1) >= 9 )
							  ? 9
							  : box_y;
					break;
			   case F_left: /* рамочку влево на кубик */
					box_x -= 1;
					if( box_x <= 0 )
						{
						if( offset_pan > 0 )
							offset_pan = ( (offset_pan-=2) <= 0 )
										   ? 0
										   : offset_pan;
						box_x = 0;
						}
          break;
         case F_right: /* рамочку вправо на кубик */
					box_x +=1;
					if( box_x >= PAN_SCR_SIZE )
						{
						if( offset_pan < PAN_LEFT_LIM )
							offset_pan = ((offset_pan+=2)>=PAN_LEFT_LIM)
										  ? PAN_LEFT_LIM
										  : offset_pan;
						box_x = PAN_SCR_SIZE;
            }
		  break;
			   case F_05: /* фиксирование кубика как текущего */
					crnt_box_nmbr = cd_to_nm( offset_pan + box_x, box_y );
					asm_set_qbk( crnt_box_nmbr, 17, 10 );
					break;
			   case F_06: /* занесение текущего кубика в
									   текущую позицию */
					mn_to_cd( crnt_box_nmbr, offset_pan + box_x, box_y );
					break;
			   case F_08: /* редактирование кубика под курсором */
					crnt_box_nmbr = cd_to_nm( offset_pan + box_x, box_y );
					convert_to_qbk( crnt_box_nmbr, image );
					qbk_edit();
					convert_from_qbk( crnt_box_nmbr, image );
					asm_set_qbk( crnt_box_nmbr, 17, 10 );
					break;
			   /* новыe команды версии 2.00: переключение текущей панорамы */
			   case F_02: /* сделать текущей карту 0 */
					pt_map = pt_map0;
					break;
			   /* новыe команды версии 2.00: переключение текущей панорамы */
			   case F_03: /* сделать текущей карту 1 */
					pt_map = pt_map1;
					break;
			   /* новыe команды версии 2.00: переключение текущей панорамы */
			   case F_04: /* сделать текущей карту 2 */
					pt_map = pt_map2;
					break;
			   case F_07: /* переключить признак кубика
							 прозрачный/непрозрачный */
					crnt_box_nmbr = cd_to_nm( offset_pan + box_x, box_y );
					if( vc[ crnt_box_nmbr ].inv == VISIBLE )
						vc[ crnt_box_nmbr ].inv = INVISIBLE;
					else
						vc[ crnt_box_nmbr ].inv = VISIBLE;
					break;
			   case F_09: /* переключатель режима прозрачности */
					if( visible_toggle == MODE_OFF )
						visible_toggle = MODE_ON;
					else
						visible_toggle = MODE_OFF;
					break;
			   case Ctrl_F_05: /* вызов словаря кубиков */
					/* функция voc_cube() возвращает номер выбранного
					   кубика */
					{ int cbn;
					cbn = voc_cube();
					if( cbn != -1 )
						{
						crnt_box_nmbr = cbn;
						asm_set_qbk( crnt_box_nmbr, 17, 10 );
						}
					}
					break;


		   }
  }while( 1 );
}


/*---------------------------------------------------------------------

---------------------------------------------------------------------*/

main()
{
  /* вводим имена для файлов */
  char pad_name[ 12 ] = "";
  char pad_nmbr[ 12 ] = "";

  printf( "Ридактар панарам {(c) Insight corp., 1991}\n" );
  printf( "                      version 2.02\n\n" );
  printf( "Та-а-а-к, введите имя панорамы (файла tt2 без расширения) : " );
  scanf ( "%s", pad_name );
  strcpy( pad_nmbr, pad_name );  /* в поле pad_nmbr - копия имени панорамы */
  strcat( pad_name, ".tt2" );
  strcpy( tt2_name, pad_name );

  get_file( tt2_file, tt2_name, tt2, TT2_SIZE );
  /* фрагмент инициализирует структуру vc на предмет
	 прозрачности кубиков: поле inv */
  {
  int i;
  int qbk_soft_count;

  qbk_soft_count = (int) tt2[0];
  for( i=0; i<0x80; i++)
	   {
	   if( i<= qbk_soft_count )
		   vc[i].inv = VISIBLE;
	   else
		   vc[i].inv = INVISIBLE;
		}
  }
						/* в версии 2.00 все три карты панорам
						   вводятся одновременно */

  strcpy( pad_name, pad_nmbr );
  strcat( pad_name, "0.pt" );
  strcpy( pt_map0_name, pad_name );
  get_file( pt_map0_file, pt_map0_name, pt_map0, PT_MAP_SIZE );

  strcpy( pad_name, pad_nmbr );
  strcat( pad_name, "1.pt" );
  strcpy( pt_map1_name, pad_name );
  get_file( pt_map1_file, pt_map1_name, pt_map1, PT_MAP_SIZE );

  strcpy( pad_name, pad_nmbr );
  strcat( pad_name, "2.pt" );
  strcpy( pt_map2_name, pad_name );
  get_file( pt_map2_file, pt_map2_name, pt_map2, PT_MAP_SIZE );


  _setvideomode( _MRES16COLOR );

  goto_xy(  8, 5 );
  printf( "   ридактар панарамный" );
  goto_xy( 10, 5 );
  printf( "для игрушки 'Кипитан Комик'" );
  goto_xy( 16, 5 );
  printf( " (c) Insight corp., 1991   v2.02" );
  goto_xy( 18, 5 );
  printf( "нажмите       чиво-нибудь," );
  goto_xy( 19, 5);
  printf( "    и мы паработаем...");

  getch();

  drow_menu();

  _setvideomode( _DEFAULTMODE );

  vc_recount();
  vc_out_tt2();

  pt_map = pt_map0;
  vc_convert();
  put_file( pt_map0_file, pt_map0_name, pt_map0, PT_MAP_SIZE );
  pt_map = pt_map1;
  vc_convert();
  put_file( pt_map1_file, pt_map1_name, pt_map1, PT_MAP_SIZE );
  pt_map = pt_map2;
  vc_convert();
  put_file( pt_map2_file, pt_map2_name, pt_map2, PT_MAP_SIZE );

}
