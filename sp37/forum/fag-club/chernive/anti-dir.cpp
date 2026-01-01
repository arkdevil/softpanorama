/***************************************************************************\
   ШАГ I   - поиск и удаление вируса из памяти. Далее выполнябтся шаги
             II-V для каждого проверяемого диска.

   ШАГ II  - поиск вируса в последних кластерах диска (просто читаются
             подряд кластеры с конца диска до удачного чтения). Если на
             этом этапе найден вирус (vircluster), шаг III не делается.

   ШАГ III - вирус не найден на диске. Ищем поврежденные файлы. Те, которые
	     ссылаются на один кластер и имеют ненулевое поле crypt.

   ШАГ IV  - найдены поврежденные файлы (но вируса на диске нет или, быть
	     может неправильно определено его присутствие, хотя он находится
	     в правильном файле, или, быть может это новая хитрая
	     модификация). Проверяем, для всех ли файлов номер кластера
	     преобразуется в допустимый. Возвращает % вероятности
	     правильности определения vircluster (от 0 до 100). -1 нет
	     ссылающихся файлов вообще.

   ШАГ V   - исправляем поврежденные файлы.

Замечания:

   1.      - crypt_code зависит от vircluster и числа секторов в кластере.
             Иногда вирус ошибочно определяет тип дискетты (как 360К 2S2D),
             для этого стоит:  Если vircluster == 355, то tCL = 2.

   2.      - crypt_code (если есть большое число зараженных файлов) можно
             определить, исключая из множества возможных кодов, те, которые
             приводят к образованию недопустимого номера кластера для данного
             файла. Здесь это не делается.

\***************************************************************************/


#include <alloc.h>
#include <ctype.h>
#include <conio.h>
#include <dir.h>
#include <dos.h>
#include <mem.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


#define RUSSIAN

#ifdef RUSSIAN
const char* text0 = " Нажмите любую клавишу ...";
const char* text1 = "Сейчас система будет перезагружена.";
const char* text2 = "Сбой системы -- не восстанавливается. Перезагрузитесь и попробуйте еще раз.";
const char* text3 = "Вирус DIR в памяти не обнаружен.";
const char* text4 = "Вирус DIR обнаружен в памяти -- удален.";
const char* text5 = "Вирус DIR не обнаружен на диске.";
const char* text6 = "Вирус DIR обнаружен на диске.";
const char* text7 = "\nПроверка диска %c:\n";
const char* text8 = "Поиск поврежденных файлов.";
const char* text9 = "\n(!) Возможно это новая модификация вируса DIR.\n\
Не могу вылечить.\n\
Скопируйте цепочку с кластера %u (%xh) на дискету и передайте нам.\n";
const char*  text10 ="Лечение файлов.";
const char*  text10a="Зараженные файлы:";
const char*  text11 ="Найдены испорченные файлы. Они могут быть исправлены с вероятностью %d%%.\n\
Они могут быть полностью испорчены с вероятностью %d%%. Рискнете ? ";
const char*  text12 ="Не найдено повреждений от вируса DIR. Поиск вируса в файлах ...";
const char*  text13 ="%-*s - исправлен.\n";
const char*  text14 ="%-*s - экземпляр вируса -- УДАЛЕН.\n";
const char*  text13a="%-*s - поврежден.\n";
const char*  text14a="%-*s - экземпляр вируса.\n";
const char*  text15 ="Вирус DIR удален с диска.";
const char*  text16 ="\nНет диска %c:\n";
const char*  text17 ="\nПроверка ВСЕХ файлов\n";
const char*  text18 ="\nИзвините, мало памяти ...";
const char*  text19 ="\nОтсутствует опция /f. ИСПРАВЛЕНИЯ НЕ БУДУТ СОХРАНЕНЫ ...\n";
const char*  text20 ="\nВведите:\n\
   ANTI-DIR [диск] [/F] [/G]\n\
	     |       |    |\n\
	     |       |    +------ исправлять все файлы (иначе только COM и EXE)\n\
	     |       +----------- сохранять исправления на диске (лечить)\n\
	     +------------------- проверяемый диск\n\
   ANTI-DIR *      проверить ВСЕ диски винчестера\n\
   ANTI-DIR A:     проверить (например) только диск A:\n";
const char*  text21 ="ANTI-DIR Версия 0.3\n\
(C) CopyRight 1991 Научный Центр СП \"Диалог\". Тел. (095) 137-01-50.\n";
const char* text22 = "\nНЕ МОГУ ЗАПИСАТЬ НА ДИСК %c:\n";
const char* text23 = "%-*s - не может быть исправлен!\n";
#endif


#ifdef ENGLISH
const char* text0  "Press any key ...";
const char* text1  "Now the system is to be re-booted.";
const char* text2  "System crashed -- cannot recover. Re-boot and try again.";
const char* text3  "No DIR virus has been found in memory.";
const char* text4  "DIR virus has been found in memory -- removed.";
const char* text5  "No DIR virus has been found on the disk.";
const char* text6  "DIR virus has been found on the disk.";
const char* text7  "\nChecking disk %c:\n";
const char* text8  "Searching disk for damaged files.";
const char* text9  "\n(!) In seems to be a new modification of the DIR virus.\n\
Cannot cure.\n\
Copy the chain starting at %u (%xh) cluster to diskette and send it to us.\n";
const char* text10 "Curing files.";
const char*  text10a="Infected files:";
const char* text11 "Bad files have been found. They can be cured with %d%% probability.\n\
They may be completly destroyed with %d%% probability. Continue ? ";
const char* text12 "No DIR virus damages has been found on the drive. Searching for DIR in files";
const char* text13 "%-*s - Cured.\n";
const char* text14 "%-*s - Contained virus -- DELETED.\n";
const char* text13a="%-*s - Damaged.\n";
const char* text14a="%-*s - Contains DIR virus.\n";
const char* text15 "DIR virus removed from disk.";
const char* text16 "\nDisk %c is absent\n";
const char* text17 "\nChecking ALL files\n";
const char* text18 "\nSorry, not enough memory ...";
const char* text19 "\nNo /f option. CHANGES WILL NOT BE WRITTEN ...\n";
const char* text20 "\nType:\n\
   ANTI-DIR [drive] [/F] [/G]\n\
	       |      |    |\n\
	       |      |    +------ to check all files (default COM and EXE)\n\
	       |      +----------- to write changes to disk (cure)\n\
	       +------------------ drive to check\n\
   ANTI-DIR *      to scan ALL hard drives\n\
   ANTI-DIR A:     to scan only A: (for example) drive\n";
const char* text21 "ANTI-DIR Version 0.3\n\
(C) CopyRight 1991 Scientific Center of JV \"Dialogue\". Tel. (095) 137-0150.\n";
const char* text22 = "\nDISK %c: IS WRITE-PROTECTED\n";
const char* text23 = "%-*s - Cannot cure!\n";
#endif


typedef unsigned char BYTE;
typedef unsigned int  WORD;

typedef struct _DPB
{
   BYTE drive;
   BYTE unit;
   WORD sector_size;
   BYTE cluster_size_dec;
   BYTE cluster_size_log;
   WORD boot_sectors;
   BYTE fat_number;
   WORD root_size;
   WORD first_data_sector;
   WORD max_cluster;

   BYTE             fat_size;                   /* Для v.4.xx WORD */
   WORD             first_root_sector;
   void far*        driver;
   BYTE             media;
   BYTE             rebuild;
   struct _DPB far* next;
} DPB;

typedef DPB far* LPDPB;

typedef struct
{
   char name[8];
   char ext[3];
   BYTE atr;
   BYTE reserved[8];
   WORD crypt;          /* Зашифрованный кластер */
   WORD time;
   WORD date;
   WORD cluster;
   long size;
} DIRENTRY;





static void abort_write( void );        /* Запрещена запись - выход */
static void abort_memo( void );         /* Мало памяти - выход */
static int is_virus( void far* );	/* Есть ли вирус по этому адресу */
static int valid_entry( DIRENTRY* );    /* Правильный вход каталога */
static void print_name( void );         /* Вывод пути файла */
static void add_name( DIRENTRY* );      /* Добавление имени к пути */
static void del_name( void );           /* Удаление имени из пути */

static long sector( WORD );             /* Сектор из кластекра */
static WORD next_cluster( WORD );       /* Следующий кластер по FAT */
static int mem_remove( void );          /* Удаление DIR из памяти (1-был,0-нет,-1-есть и нельзя удалить) */
static int is_on_disk( void );          /* В последних секторах есть вирус ? */
static int infect( DIRENTRY*, int );    /* Зараженный вход ? */
                                        /*    0 - чистый
					      1 - может быть заражен (для определения совпадающих кластеров)
                                              2 - заражен, но crypt == 0
                                              3 - заражен
                                        */
static void clear_cluster( WORD );	/* Затирает кластер на диске */
static WORD crypt( void );              /* Формирует код для расшифровки */
static int getBPB( void );              /* Чтение DPB для disk (0-нет диска */


int   check_all_files=0;/* Проверять все файлы (не только COM и EXE) */
int   writeok=0;        /* Записывать изменения на диск - лечить */
long  virsector;        /* Сектор вируса */
WORD  vircluster;       /* Кластер вируса */
LPDPB dpb, dpb4;        /* Первая и вторая половины DPB с учетом вер. DOS */
WORD  crypt_code;       /* Код для расшифровки */
int   disk;             /* Рабочий диск  (A == 1) */



static void abort_memo( void )
{
   puts( text18 );
   exit( 1 );
}


static void clear_cluster( WORD cluster )
{
   char buf[512];
   long sec = sector( cluster );

   setmem( buf, 512, 0 );
   for(  int i = 0;  i <= dpb->cluster_size_dec;  ++i, ++sec  )
      if( writeok )
	 if(  0 != abswrite(  disk-1, 1, sec, buf  )  )
            abort_write ();
}


static void far* peekDW( unsigned seg, unsigned off )
{
   return * (void far* far*) MK_FP(seg,off);
}

/***************************************************************************\
   ШАГ I   - поиск и удаление вируса из памяти. Далее выполняются шаги
             II-V для каждого проверяемого диска.
\***************************************************************************/
/* Устранение вируса из памяти, 1 - был вирус, -1 - нельзя устранить */
static int mem_remove( void )
{
   LPDPB ptr;
   int res = 0;

   /* List of lists */
   _AH = 0x52;
   geninterrupt( 0x21 );

   /* Drive parameter block */
   ptr =  (LPDPB) peekDW(_ES,_BX);

   do
   {
      if( _osmajor >= 4 )  ++FP_OFF(ptr);       /* Учитываем версию Dos */

      /* Вирус есть, если смещение 0x4e9 и по 0x179 лежит известная цепочка */
      if(  FP_OFF(ptr->driver) == 0x4e9  &&
	   is_virus( MK_FP( FP_SEG(ptr->driver), 0x100 ) )
	)
      {
	 /* Ищем заголовок драйвера */
	 char far* tmp  =  (char far*) MK_FP( 0x70, 0 );
	 char adr[4]    =
	 {
	    *(char far*)MK_FP(FP_SEG(ptr->driver),0x4b2), *(char far*)MK_FP(FP_SEG(ptr->driver),0x4b3),
	    *(char far*)MK_FP(FP_SEG(ptr->driver),0x4b7), *(char far*)MK_FP(FP_SEG(ptr->driver),0x4b8)
	 };

	 while(
	    tmp[0] != adr[0]  ||  tmp[1] != adr[1]  ||
            tmp[2] != adr[2]  ||  tmp[3] != adr[3]
         )
	    if( ++FP_OFF(tmp) > 0xF000 )  return -1;

	 ptr->driver = tmp-6;         /* Устанавливаем старый адрес драйвера */
	 ptr->rebuild = 0xFF;         /* Заново построить BPB */
	 res = 1;
      }
      ptr = ptr->next;                /* Следующий драйвер */
   }
   while( FP_OFF(ptr) != 0xFFFF );

   return res;
}


static const char vir_pattern[] = "\x2e\xa3\xb2\x04\x2e\x8c\x06\xb7\x04\xfc";
static const int  vir_pattern_size = 10;
static const int  vir_pattern_off  = 0x79;

static int is_virus( void far* mem )
{
   return  0 == _fstrncmp(
     ((char far*)mem) + vir_pattern_off, vir_pattern, vir_pattern_size
   );
}


/* Эта функция - аналог той же в вирусе, которая определяет надо ли
   заражать данный вход каталога - только не проверется атрибут SYSTEM
   (его могли уже поменять). */

static int infect( DIRENTRY* dir, int detect )
{
   if(  ! check_all_files  &&
	strncmp( dir->ext, "EXE", 3 ) != 0  &&
	strncmp( dir->ext, "COM", 3 ) != 0
   )  return 0;

   if(  (dir->size & 0xFFC00000l) != 0  ||
	(dir->size & 0x003FF800l) == 0  ||
	(dir->atr  & (FA_LABEL|FA_DIREC)) != 0
   )  return 0;

   /* detect - при определении кластера вируса */
   if(  detect  ||  dir->cluster  ==  vircluster  )
   {
      if(  dir->crypt != 0  )
	 return 3;              /* Наверняка заражен */
      else
	 return 2;              /* Возможно (но маловероятно) заражен */
   }

   return 1;                    /* Может быть заражен (но пока вроде цел) */
}


static WORD crypt( void )             /* Формирует код для расшифровки */
{
   WORD crypt_code;
   BYTE tCL;

   if( vircluster == 355 )
     tCL = 2;
   else
     tCL = dpb->cluster_size_dec+1;

   _AX = vircluster;
   if( _AX >= 0xFF0 )
   {
      _CX = 2;
      asm  mul  cx
   }
   else
   {
      _CX = 3;
      asm  mul  cx
      asm  shr  ax, 1
   }
   _CX = 0x200;
   asm  div  cx
   asm  inc  ax

   asm  sub  dh, tCL
   asm  adc  dx, ax

   crypt_code = _DX;

   if(  vircluster < 0xFF0  &&  tCL < 2  )   crypt_code ^= 0x0300;
   return crypt_code;
}


static WORD next_cluster( WORD cluster )
{
   WORD offset, sector;
   int mask;
   char buf[512];

   if( dpb->max_cluster >= 0xFF0 )
   {
       /* 16 FAT */
      _AX = cluster;
      _CX = 2;
      asm  mul  cx
      mask = 0;
   }
   else
   {
      _AX = cluster;
      _CX = 3;
      asm  mul  cx
      asm  shr  ax, 1
      mask = 1;
      asm  jnc  m1
      mask = -1;
      m1:;
   }
   _CX = 0x200;
   asm  div  cx

   sector = _AX;
   offset = _DX;
   if(  0 != absread( disk-1, 1, sector+dpb->boot_sectors, buf )  )
      return 0xFFFF;
   cluster = *(WORD*)(buf+offset);

   switch( mask )
   {
      case  0:  break;
      case  1:  cluster &= 0x0FFF;  break;
      case -1:  cluster >>= 4;  break;
   }

   return cluster;
}

static int getBPB( void )
{
   BYTE res;
   _DL = disk;
   _AH = 0x32;          /* запрос DPB */
   asm  push ds
   asm  int  0x21
   asm  mov  cx, ds
   asm  pop  ds

   res = _AL;
   dpb4 =  dpb =  (LPDPB) MK_FP( _CX, _BX );
   if( _osmajor >= 4 )  ++FP_OFF(dpb4);       /* Учитываем версию Dos */

   return res != 0xFF;
}


static long sector( WORD cluster )
{
   long tmp;
   tmp  =  cluster-2;
   tmp *=  dpb->cluster_size_dec+1;
   tmp +=  dpb->first_data_sector;
   return tmp;
}


/***************************************************************************\
   ШАГ II  - поиск вируса в последних кластерах диска (просто читаются
	     подряд кластеры с конца диска до удачного чтения.
\***************************************************************************/
static int is_on_disk( void )
{
   char buf[512];

   vircluster =  dpb->max_cluster;

   /* Читаем для гарантии не 2, а 10 секторов с диска */
   while(  vircluster >= 2  )
   {
      virsector  =  sector( vircluster );
      if(  0 == absread( disk-1, 1, virsector, &buf )  &&  is_virus( buf )  )
	 return 1;
      --vircluster;
      if( dpb->max_cluster-vircluster > 10  )  return 0;
   }
   return 0;
}



static char  path_with_drive[130];
static char* current_path = path_with_drive+2;
static int   last_path_lenght;

static void add_name( DIRENTRY* de )
{
   char* s  =  &current_path[ strlen(current_path) ];

   *(s++) = '\\';
   strncpy( s, de->name, 8 );
   for(  *(s += 8) = 0;  s > current_path  &&  s[-1] == ' ';  --s  )  s[-1] = 0;
   *(s++) = '.';
   strncpy( s, de->ext, 3 );
   for(  *(s += 3) = 0;  s[-1] == ' ';  --s  )  s[-1] = 0;
   if( s[-1] == '.' )  *(--s) = 0;
}

static void del_name( void )
{
   strrchr( current_path, '\\' ) [0] = 0;
}

static void print_name( void )
{
   fprintf( stderr, "%-*s\r", last_path_lenght, path_with_drive );
   last_path_lenght  =  strlen( path_with_drive );
}


/* Не удаленный и не '.', '..' */
static int valid_entry( DIRENTRY* de )
{
   if(  de->name[0] < ' '  ||  de->name[0] > 127  )  return 0;
   if(  (de->atr & FA_DIREC) != 0  &&
        (strncmp( de->name, "..         ", 11 ) == 0  ||  strncmp( de->name, ".          ", 11 ) == 0)
   )  return 0;
   return 1;
}





static int (*action)(DIRENTRY*de); /* 1 - было изменение - обновить на диске */



static void req0( WORD cluster )
{
   DIRENTRY de[ 512/sizeof(DIRENTRY) ];
   WORD my_crypt_code = crypt_code;
   WORD saved_crypt_code = crypt_code;

   while( cluster < dpb->max_cluster )
   {
      for(  int rels = 0;  rels <= dpb->cluster_size_dec;  ++rels  )
      {
	 int changes = 0;
	 if( 0 != absread( disk-1, 1, sector(cluster)+rels, de ) )  continue;
	 for(  int j = 0;  j < 512/sizeof(DIRENTRY);  ++j  )
	 {
	    if(  valid_entry( &de[j] )  )
	    {
	       add_name( &de[j] );
	       if(  de[j].atr & FA_DIREC  )
		  req0( de[j].cluster );
	       else
	       {
		  print_name ();
		  crypt_code = my_crypt_code;
		  if(  action( &de[j] )  )   changes = 1;
		  crypt_code = saved_crypt_code;
	       }
	       del_name ();
	    }
	    asm  rol  my_crypt_code, 1
	 }
	 if( changes && writeok )
	    if(  0  !=  abswrite( disk-1, 1, sector(cluster)+rels, de )  )
	       abort_write ();

      }
      cluster = next_cluster( cluster );
   }
}

static int req( void )
{
   WORD my_crypt_code = crypt_code;
   WORD saved_crypt_code = crypt_code;
   DIRENTRY de[ 512 / sizeof(DIRENTRY) ];
   long rootsector = dpb4->first_root_sector;
   int changes;
   int rootsize = dpb->root_size;

   if( de == NULL ) abort_memo ();

   path_with_drive[0] = disk+'A'-1;
   path_with_drive[1] = ':';
   path_with_drive[2] = 0;
   last_path_lenght = 0;

   for(  int i = 0;  i < rootsize;  ++i  )
   {
      int ii = i % (512/sizeof(DIRENTRY));
      if(  ii ==  0  )
      {
	 changes = 0;
	 if( 0 != absread( disk-1, 1, rootsector++, de )  )  return 0;
      }

      if(  valid_entry( &de[ii] )  )
      {
	 add_name( &de[ii] );
	 if(  de[ii].atr & FA_DIREC  )
	    req0( de[ii].cluster );
	 else
	 {
	    print_name ();
	    crypt_code = my_crypt_code;
	    if(  action( &de[ii] )  )   changes = 1;
	    crypt_code = saved_crypt_code;
	 }
	 del_name ();
      }
      else if( de[ii].name[0] == 0 )
      {
	 /* Пустой вход корневого каталога - выход */
	 rootsize = i;
	 ii = 512/sizeof(DIRENTRY)-1;
      }
      asm  rol  my_crypt_code, 1

      if( ii ==  512/sizeof(DIRENTRY)-1 )
	 if( changes && writeok )
	    if(  0 != abswrite( disk-1, 1, rootsector-1, de )  )
	       abort_write ();

   }

   path_with_drive[0] = 0;	/* Стирание последнего имени */
   print_name ();

   return 1;
}



/***************************************************************************\
   ШАГ V   - исправляем поврежденные файлы.
\***************************************************************************/

static int action_cure( DIRENTRY* de )
{
   char buf[1024];
   int res = 0;

   if( infect(de,0) >= 2 )
   {
      printf( writeok ? text13 : text13a, last_path_lenght, path_with_drive );
      res = 1;
      de->cluster  =  de->crypt ^ crypt_code;
      de->crypt = 0;
   }

   if(  0 == absread( disk-1, 2, sector(de->cluster), buf )  &&
	is_virus( buf )
     )
   {
      printf( writeok ? text14 : text14a, last_path_lenght, path_with_drive );
      res = 1;
      clear_cluster( de->cluster );
      /*
	 chmod( path_with_drive, S_IWRITE );
	 unlink( path_with_drive );
      */
      de->name[0] = 0xe5;
   }
   return res;
}


static void cure_files( void )
{
   action = action_cure;
   req ();
   return;
}

/***************************************************************************\
   ШАГ III - вирус не найден на диске. Ищем поврежденные файлы. Те, которые
	     ссылаются на один кластер и имеют ненулевое поле crypt.
\***************************************************************************/

static BYTE* bitmap;
static int multiple_clust; /* Больше одного такого кластера (выбран max) */

static int action_search( DIRENTRY* de )
{
   if(  infect( de, 1 ) == 3  )   /* Определить - наверняка зараженный */
   {
      WORD cl = de->cluster;
      int  of = cl/8;
      int  ma = 1 << (cl%8);

      if( bitmap[of] & ma )     /* Уже был один такой файл */
      {
         if(  vircluster != 0  &&  vircluster != de->cluster  )
            multiple_clust = 1;
         if( vircluster < de->cluster )  vircluster = de->cluster;
      }
      bitmap[ of ]  |=  ma;
   }
   return 0;
}

static int is_damaged_disk( void ) /* 1 - есть, 0 - нет, -1 - много */
{
   vircluster = 0;
   multiple_clust = 0;
   action = action_search;

   bitmap  =  (BYTE*) malloc( 8*1024 );
   if( bitmap == NULL )  abort_memo ();
   setmem( bitmap, 8*1024, 0 );
   req ();
   free( bitmap );

   if( multiple_clust )  return -1;
   if( vircluster != 0 )  return 1;
   return 0;
}





/***************************************************************************\
   ШАГ IV  - найдены поврежденные файлы (но вируса на диске нет или, быть
	     может неправильно определено его присутствие, хотя он находится
	     в правильном файле, или, быть может это новая хитрая
	     модификация). Проверяем, для всех ли файлов номер кластера
	     преобразуется в допустимый. Возвращает % вероятности
	     правильности определения vircluster (от 0 до 100). -1 нет
	     ссылающихся файлов вообще.
\***************************************************************************/

static int bad_cluster;
static int files_checked;

static int action_check( DIRENTRY* de )
{
   if(  infect( de, 0 ) >= 2  )
   {
      if(  (de->crypt ^ crypt_code) > dpb->max_cluster  )
      {
         bad_cluster = 1;
         printf( text23, last_path_lenght, path_with_drive );
      }
      ++files_checked;
   }
   return 0;
}

static int is_vircluster_OK( void )
{
   bad_cluster = 0;
   files_checked = 0;

   action = action_check;
   req ();

   if( bad_cluster )  return 0;
   if( files_checked > 0 )
   {
      float res = 1;
      float tmp = dpb->max_cluster;
      tmp /= 0x10000l;
      while( files_checked-- )  res *= tmp;
      return (int)((1.-res)*100);
   }

   return -1;
}




int YesNo( void )
{
   fprintf( stderr, "[Y/N] " );
   for(;;) switch( toupper(getch()) )
   {
      case 'Y':  fprintf( stderr, "Yes\n" );  return 1;
      case 'N':  fprintf( stderr, "No\n"  );  return 0;
   }
}

void pause( void )
{
   fprintf( stderr, text0 );  getch();
}

void reboot( void )
{
   fputs( text1, stderr );
   pause ();
   flushall ();		/* Выпихиваем протокол на диск */
   (*  (void (far*)(void)) MK_FP(0xFFFF,0)  )  ();
}


int cure_disk( void )
{
   int prob;
   if( !getBPB() )  return 0;

   printf( text7, disk+'A'-1 );

   if(  is_on_disk ()  )
   {
      puts( text6 );  puts( text8 );
      crypt_code = crypt ();
      switch( prob = is_vircluster_OK () )
      {
	 case 0:
	    fprintf( stderr, text9, vircluster, vircluster );
	    if( writeok )
	    {
	       fprintf( stderr, text11, prob, 100-prob );
	       if( YesNo () )
		  {  puts( writeok ? text10 : text10a );  cure_files ();  break;  }
	    }
	    pause ();
	    return 1;
	 case -1:	/* Нет файлов, но есть вирус */
	    puts( text12 );
	    break;
	 default:
	    puts( writeok ? text10 : text10a );  cure_files ();  break;
      }
      if( writeok )
      {
	 puts( text15 );
	 clear_cluster( vircluster );
      }
   }
   else
   {
      puts( text5 );  puts( text8 );
      if(  0 != is_damaged_disk ()  )
      {
	 crypt_code = crypt ();
	 prob  =  is_vircluster_OK ();
	 if( writeok )
	 {
	    fprintf( stderr, text11, prob, 100-prob );
	    if( YesNo () )
	       {  puts( writeok ? text10 : text10a );  cure_files ();  }
	 }
	 else
	    {  puts( writeok ? text10 : text10a );  cure_files ();  }
      }
      else
      {
	 puts( text12 );
	 cure_files ();
      }
   }
   return 1;
}



int main( int argc, char** argv )
{
   int rbt = 0;
   char disk_to_cure = 0;

   fputs( text21, stderr );

   switch( mem_remove () )
   {
      case -1: fputs( text2, stderr ); reboot ();
      case  0: puts( text3 ); break;
      case  1: puts( text4 ); rbt = 1; break;
   }

   /* Обработка параметров */
   if( argc <= 1 )
   {
      fputs( text20, stderr );
      return 0;
   }
   for(  int cnt = 1;  cnt < argc;  ++cnt  )
   {
      switch( argv[cnt][0] )
      {
         case '/':  case '-':           /* Опции */
            switch( toupper(argv[cnt][1]) )
            {
               case 'F':  writeok = 1;  break;
               case 'G':  check_all_files = 1;  break;
               default :  fputs( text20, stderr );  return 0;
            }
            break;

         default:                       /* Дисковод */
            disk_to_cure = toupper(argv[cnt][0]);
            break;
      }
   }

   if( check_all_files )  puts( text17 );
   if( !writeok )  fputs( text19, stderr );


   if( disk_to_cure != '*' )
   {
      disk = disk_to_cure-'A'+1;
      if(  ! cure_disk ()  )   printf( text16, disk+'A'-1 );
   }
   else
   {
      disk = 3;
      while(  cure_disk ()  )  ++disk;
   }
   if( rbt && writeok ) reboot ();
   return 0;
}

static void abort_write( void )
{
   fprintf( stderr, text22, disk+'A'-1 );
   exit( 1 );
}
