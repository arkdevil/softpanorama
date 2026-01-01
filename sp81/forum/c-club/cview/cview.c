#include <stdio.h>
#include <conio.h>
#include <stdlib.h>
#include <string.h>
#include <alloc.h>
#include <dos.h>
#include <process.h>
#include <bios.h>
#include <ctype.h>
#include <time.h>

typedef  unsigned int uint;
typedef  unsigned int ushort;
typedef  unsigned long ulong;
typedef  unsigned char uchar;

// compile it in Compact model !

struct HDAT {            // заголовок файла данных
       uint filesig;     /* +0 file signature */
       uint sfatr;       /* +2 file attribute and status */
       uchar numbkeys;   /* +4 number of keys in file */
       ulong numrecs;    /* +5 number of records in file */
       ulong numdels;    /* +9 number of deleted records */
       uint numflds;     /* +13 number of fields */
       uint numpics;     /* +15 number of pictures */
       uint nummars;     /* +17 number of array descriptors */
       uint reclen;      /* +19 record length (including record header) */
       ulong offset;     /* +21 start of data area */
       ulong logeof;     /* +25 logical end of file */
       ulong logbof;     /* +29 logical beginning of file */
       ulong freerec;    /* +33 first usable deleted record */
       uchar recname[12];/* +37 record name without prefix */
       uchar memnam[12]; /* +49 memo name without prefix */
       uchar filpre[3];  /* +61 file name prefix */
       uchar recpre[3];  /* +64 record name prefix */
       uint memolen;     /* +67 size of memo */
       uint memowid;     /* +69 column width of memo */
       ulong reserved;   /* +71 reserved */
       ulong chgtime;    /* +75 time of last change */
       ulong chgdate;    /* +79 date of last change */
       uint reserved2;   /* +83 reserved as CRC */
} hdat;

struct FHEAD {           // заголовок поля (для каждого свой)
       uchar fldtype;    /* type of field */
       uchar fldname[16];/* name of field */
       uint foffset;         /* offset into record */
       uint length;          /* length of field */
       uchar decsig;     /* significance for decimals */
       uchar decdec;     /* number of decimal places */
       uint arrnum;          /* array number */
       uint picnum;          /* picture number */
} fh;

struct FHEAD *Fields;  // указатель на буфеp с описаниями полей

struct DHEAD {           // заголовок записи в файле данных
       uchar rhd;        /* record header type and status */
       ulong rptr;       /* pointer for next deleted record or memo if active */
} dh;

typedef struct  {  // описание каждой компоненты ключа, содеpжится в .dat
       uchar fldtype;    /* type of field */
       uint fldnum;          /* field number */
       uint elmoff;          /* record offset of this element */
       uchar elmlen;     /* length of element */
} KEYPART;

KEYPART kpart;

typedef struct {         // описание ключа, содеpжится в .dat
       uchar numcomps;   /* number of components for key */
       char keynams[16];         /* name of this key */
       uchar comptype;   /* type of composite */
       uchar complen;    /* length of composite */
       KEYPART * P;       /* адрес структур(ы) KEYPART */
} KEYSECT;

KEYSECT sect;

// from Solovjev'library
const uint     aFileLocked     = 1 << 0;
const uint     aFileOwned      = 1 << 1;
const uint     aFileEncrypted  = 1 << 2;
const uint     aMemoExists     = 1 << 3;
const uint     aFileCompressed = 1 << 4;
const uint     aReclaimDeleted = 1 << 5;
const uint     aReadOnly       = 1 << 6;
const uint     aFileCreate     = 1 << 7;

uint mask=0;   // XOR-маска, которой зашифрован файл
uint view_mask=0;   // XOR-маска, используется как признак во время вывода
                    // списка полей файла на экран


FILE *in, *out, *k, *mem, *mem2;     // потоки: .dat, ...
char *DATfileName;      // имя файла .dat
char * RecBuf;          // указатель на буфеp, содеpжащий одну запись
			// и несколько еще в режиме поиска

int memo=0;      // признак открытого memo
ulong   file_len,       // длина файла
        KEYsectBegin,   // смещение в файле .dat стpуктуpы KEYSECT
        recno;          // номеp записи
ulong KeyFileLen = 0;       // длина ключевого файла
const ulong LenKeyRec = 512L; // длина узла ключевого файла

uint *txt_equ; // указатель на длины полей в строковом эквиваленте
               // напр. int -> 6 знаков
uchar *types;  // массив типов полей (копия)
uint *col_width; // массив ширины столбцов (не меньше заголовка столбца)
uint *view_as;
char oStr[200];         // буфеp для вывода на экpан и в файл

uchar vX, vY;           // координаты вывода на экран одного поля
uint LeftFieldNum;      // номер 0.. поля, крайнего слева на экране
const uint Lscr = 2;    // крайний слева столбец на экране
const uint Rscr = 79;    // крайний справа столбец на экране

    // переменные для поиска
    long goto_record, n_search, d_search, t_search;
    uint last_search_fieldtype;

    uint records_per_buffer;
    char *search_buffer;

    char s_search[30];
    char dec_search[60];
    void *search_ptr;
    ulong old_record;
    // сколько записей можно прочесть сразу в буфер
    int records_to_read;

// keyboard variable
uint  key, shft, o_shft;

// colors
uchar colorNormal=0x70;
uchar colorWindow=0x30;
uchar colorError=0x1C;
uchar colorSelect1=0x1A;
uchar colorSelect2=0x0A;

// путь к каталогу, где лежит работающая в данный момент копия cview
// там хранится cview.ini
char *programm_name;

// расположение лифтов (используется при обработке нажатий мыши)
typedef struct {        // описание скролл-бара, заполняется (обновляется)
                        // при каждом вызове Percent()
       uchar mode;      // признак: 0-горизонтальный 1=вертикальный
       uint barMin, barMax; // концы скролл-бара
       uint barX, barY;  // позиция указателя (лифта)
} SCROLLBAR;

SCROLLBAR Vscrollbar;
SCROLLBAR Hscrollbar;

signed int batch=0; // признак работы в пакетном режиме (>0) или ESC (<0)
void clear_batch(void)
{
   if ( batch ) batch=-1;
}

// выдает коды клавиш со стрелками, если курсор мыши попал на участки
// скроллбара до или после лифта
uint scroll2key( uint mX, uint mY, SCROLLBAR *scroll );

// выдает 1 если указатель мыши находится в окне, иначе 0
uint InWindow( uint x, uint y, uint width, uint height, uint mX, uint mY )
{
     if (( mX<x ) || ( mY<y )) return 0;
     if (( mX>x+width ) || ( mY>y+height )) return 0;
     return 1;
}

void Selector( char x, char y, char color, char len );
void Say( char x, char y, char color, char *zstring );
void SayCR( char x, char y, char color, char *zstringCR );
void SayN( char x, char y, char color, uint len, char *string );
void SayNchar( char x, char y, char color, uint len, char c );
void fLine( uchar x, uchar y, uchar direction, uchar size,
            char color, uchar *shape );


void fseek0( FILE *f, ulong to ) { fseek( f, to, 0); }

ulong flen( FILE *f )   // возвpащает длину файла
{
    ulong len; fseek( f, 0, 2); len=ftell(f); fseek0( f, 0 ); return len;
}

void ChkName(char *name)  // пpовеpяет доступность входного файла
{
   char *ext;
   char mem_name[128];
   if ((in = fopen( name, "rb"))  == NULL)
   { printf( "Не откpыт входной файл %s\n", name); exit(1); }
   strcpy( mem_name, strupr(name) );
   if (( ext=strstr(mem_name, ".DAT") ) != NULL)
   {
      sprintf( ext, ".mem" );
      if ((mem = fopen( mem_name, "rb"))  != NULL) memo=1;
   }

}

////////////////////// процедуры шифрования ///////////////////////////
// находит контрольную сумму массива
uint CalcSum( int len, uchar *where)
{
  uint sum = 0;
  uint add = 0;
  while (len-- > 0)
  {
  add = ((uint) *where++); sum += add;
  };
  return sum;
}

// шифрует массив маской
void DoCrypt (uint len, char *where)
{
  len >>= 1 ;
  while (len--)
  {
    *((uint *)where) ^= mask; where += 2;
  };
}

// проверяет маску шифра файла, правильная ли она
int CheckMask (void)
{
  uint count;
  uint csum;
  DoCrypt (sizeof (hdat) - 4, &hdat.numbkeys);
  csum=hdat.reserved2;
  hdat.reserved2 = 0;
  count=CalcSum (sizeof (hdat) - sizeof ( hdat.reserved2), (char *)&hdat);
  hdat.reserved2=csum;
  DoCrypt (sizeof (hdat) - 4, &hdat.numbkeys);
  return ( count != csum ? 0 : 1);
};

// находит маску, которой зашифрован файл
void CalculateMask(void)
{
  _AX= *((uint *) &hdat.recname[10]);
  asm xor ax,2020h
  asm xchg al,ah
  mask= _AX;

  if  (CheckMask()) return;

  asm mov ax, word ptr hdat.offset+2
  asm xchg al,ah
  mask= _AX;

  if  (CheckMask()) return;

  asm mov ax, word ptr hdat.logbof+2
  asm xchg al,ah
  mask= _AX;

  if  (CheckMask()) return;

  asm mov ax, word ptr hdat.reserved+2
  asm xchg al,ah
  mask= _AX;

  if  (CheckMask()) return;

  mask = 0xFFFF;
  while (1)
  {
    if  (CheckMask()) break;
    if  (!mask) break;
    mask--;
  };
};

////////////////////////// чтение логических записей ///////////////////
ulong recno2offset( ulong num) // пpеобpаз. номеp записи (0..) в смещение в .dat файле
{
        return ((ulong) hdat.reclen ) * num + hdat.offset;
}

void GetRecHead( ulong recno ) // пpочитаем заголовок заданной записи (1..)
{
        fseek0( in, recno2offset( recno-1 )); // встанем на запись (0..)
        fread( &dh, 1, sizeof( dh ), in );
}


ulong *filterTABLE; // указатель на номера физических записей
uint filter=0; // маска фильтра, !=0 когда фильтр активен
ulong old_numrecs; // временно хранит количество записей в файле

void GetRecord( ulong recno ) // пpочитаем заданную запись (1..) и заголовок
{
	ulong old_recno=recno;

        // если имеется фильтр, то из таблицы берем номер физической записи
        if ( filter )
        {
            recno=filterTABLE[ recno-1 ];
        };
        fseek0( in, recno2offset( recno-1 )); // встанем на запись (0..)
        fread( RecBuf, 1, hdat.reclen, in );
        if ( mask )
        {
           DoCrypt ( hdat.reclen-5, RecBuf+5);
        };
        recno=old_recno;
}

// возвращает 1 если ошибка записи
int PutRecord( char *buffer ) // записывает одну запись
{
        int n;
        n=fwrite( buffer, 1, hdat.reclen, out );
        if ( n==hdat.reclen ) return 0; else return 1;
}



/*
rhd bit	0 - new record
    bit 1 - old record
    bit 2 - revised record
    bit 4 - deleted record
    bit 6 - record held    */


void box( char x, char y, char width, char height, char color );

void dialog_box( char x, char y, char color,
                 char *header, char *prompt, char *footer );

void search_dialog_box( char *prompt, char *footer )
{
     dialog_box( 20,6 ,colorWindow, " Поиск ", prompt, footer );
}

void wait_box(void)
{
     dialog_box( 30,8 ,colorWindow, " Ждите ", "Ищу", " Esc прервать ");
}

void error_window( char *message )
{
         dialog_box( 30,8,colorError, " Ошибка ", message, " Esc ");
         asm xor ax,ax
         asm int 16h
}

void errorNUM_window( void )
{
     error_window("Число записано неверно");
}

void errorFILE_window( void )
{
     error_window("Не Clarion-файл");
}

void errorARG_window( void )
{
     error_window("Неверный аргумент поиска");
}

void errorDATE_window( void )
{
     error_window("Дата записана неверно");
}

void errorTIME_window( void )
{
     error_window("Время записано неверно");
}

// преобразует строку в длинное целое, первые нецифры пропускаются
// возвращает указатель на следующий за цифрой символ
char error;
char *str2long( char *str, long *num )
{
        char minus=0;
        *num=0L;
        error=1;
        while (( *str !=0 ) && ( !isdigit( *str ))) str++;
	if ( *(str-1) == 0x2D ) minus=1;
        while ( isdigit( *str ) )
        {
           *num *= 10L;
           *num += *str++ -48;
           error=0;
        };
        if ( minus ) *num = -(*num);
        return str;
}

// преобразует строку в формат Decimal справа налево,
// последние нецифры пропускаются
// точка должна быть, но она игнорируется
char str2decimal( char *str, char *num, signed int len );

char *ClaTime( long abstime );

char *ClaDate( ulong absday );

long str2timeClar( char *from)
{
    long hour, minutes;
    uint seconds=0;
    uint hundr=0;
    ulong abstime;

    from=str2long( from, &hour );
    if ( error ) return -1;
    from=str2long( from, &minutes );
    if ( error ) return -1;

    if ( hour>23 ) return -1;
    if ( minutes>60 ) return -1;

    abstime= hour * 360000L;
    abstime += minutes*6000L;
    abstime += seconds*100;
    abstime += hundr;
    abstime++;
    return abstime;
}


extern char number_of_days[];
long str2dataClar( char *from)
{
    long day, month, year;
    ulong absday;

    from=str2long( from, &day );
    if ( error ) return -1;
    from=str2long( from, &month );
    if ( error ) return -1;
    from=str2long( from, &year );
    if ( error ) return -1;

    if ( year < 100 ) year += 1900;
    if ((( year % 4) == 0 ) && ( year != 1900 ))
    {
        number_of_days[1] = 29;
    }
    else
    {
        number_of_days[1] = 28;
    };
    absday = (year-1801L)*1461L;
    absday = absday / 4L + day + 3L;
    while ( month-1L >0 )
    {
        absday += (long)number_of_days[month-2];
        month--;
    }
    if ( year > 1900 ) absday--;
    return absday;
}

// рисует полоску и лифт; direction=2 для вертикали
// возвращает текущую абсолютную позицию лифта (от верха или слева экрана)
void Percent( char x, char y, uchar direction, char size,
              char color, ulong current, ulong max, SCROLLBAR *scroll);


// читает из заголовка .dat описания полей и копиpует их
// в массив Fields
void GetFieldHeader( void )
{
   uint j, i;
   for ( j=0; j < hdat.numflds; j++ )
   {
   fread( &fh, 1, sizeof( fh ), in );
   if ( mask )
   {
      DoCrypt (sizeof( fh ), (char *)&fh);
   }
   // сделаем ASCIIZ имена полей
   i=15;
   while ( i )
   {
      if ( fh.fldname[i] == 0x20 ) fh.fldname[i] = 0; else break;
      i--;
   };
   // ширина столбца данных зависит от типа
   i=2;
   switch ( fh.fldtype )
   {
      case 1:  // LONG
         i = 11; // десять цифр и знак
         break;
      case 2:  // REAL
         // i = 21; // 21 цифр и знак
         i = 8*2+1; // hex-представление 8 байт и пробел
         break;
      case 3:  // STRING
      case 4:  // STRING WITH PICTURE
      case 7:  // GROUP
         i = fh.length; // полная длина
         if ( fh.length > Rscr-Lscr-1 ) i = Rscr-Lscr-1;
         break;
      case 5:  // BYTE
         i = 4; // три цифры и знак
         break;
      case 6:  // SHORT
         i = 6; // пять цифр и знак
         break;
      case 8:  // DECIMAL
         i = fh.length*2; // две цифры в байте
         break;
   };
   txt_equ[j]=i;
   types[j] = fh.fldtype;
   col_width[j] = strlen( fh.fldname );
   if ( txt_equ[j] > col_width[j]) col_width[j] = txt_equ[j];
   memcpy( Fields+j, &fh, sizeof( fh ));
   fh.fldname[15] =0;
   if (( fh.fldtype ==1) && strstr( fh.fldname, "DATE" ))
      view_as[j] |= 0x0001;
   else if (( fh.fldtype ==1) && strstr( fh.fldname, "TIME" ))
      view_as[j] |= 0x0004;
   };
   KEYsectBegin = ftell(in);   // вслед за заголовками полей лежат
                                // стpуктуpы KEYSECT
}

    uchar *data; // указатель на поле записи
    uint len_data; // размер поля

char *convt( char field_number, char *from )
{
   int i, j;
   char sign;
   switch ( types[field_number] )
   {
     case 1:  // LONG
        if ( view_as[field_number] & 0x0001 )
        {
        sprintf( oStr, "%s ", ClaDate( *((ulong *)from) ));
        }
        else
        if ( view_as[field_number] & 0x0004 )
        {
        sprintf( oStr, "%s ", ClaTime( *((ulong *)from) ));
        }
        else
        {
        sprintf( oStr, "%11ld", *((ulong *)from) );  // десять цифр и знак
        };
        break;
     case 2:  // REAL
        // sprintf( oStr, "    *******   " );  // 21 цифр и знак
        sprintf( oStr, "%08lX%08lX ",
        *(((ulong *)from)+1), *((ulong *)from) );
        break;
     case 3:  // STRING
     case 4:  // STRING WITH PICTURE
     case 7:  // GROUP
        memcpy( oStr, from, txt_equ[field_number]); // полная длина
        break;
     case 5:  // BYTE
        sprintf( oStr, "%4d", *from ); // три цифры и знак
        break;
     case 6:  // SHORT
        sprintf( oStr, "%6d", *((ushort *)from) ); // пять цифр и знак
        break;
     case 8:  // DECIMAL
        i = txt_equ[field_number]; // суммарная длина поля на экране
        j=i;
        oStr[i]=0;               // ASCIIZ
        sign=0;
        // определим знак
        if ( *from & 0x80 )
        {
            *from ^= 0x80;
            sign =1;
        }

        // все цифры преобразуем в символы
        while ( i>0 )
        {
          oStr[i-1] = (from[i/2-1] & 0x0F) + 48;
          oStr[i-2] = ((from[i/2-1] >> 4) & 0x0F) + 48;

            i -= 2;
        }
        // заменим лидирующие пробелы
        for ( i=0; i<j; i++ )
        {
          if (oStr[i]==0x30)
          {
             if (oStr[i+1]!=0) oStr[i]=0x20;
          }
          else
          {
             if (sign) oStr[i-1]=0x2D;
             break;
          }
        }
        // вставим точку
        if ( oStr[0]==0x20 )
        for ( i=0; i< j-(Fields+field_number)->decdec-1 ; i++ )
        {
           oStr[i] = oStr[i+1];
           oStr[i+1]=0x2E;
        }
        else *((uint *)&oStr[0]) = 0x2A;
        break;
   }
   return oStr;
}


uint str_len; // длина строки глобального поиска
uint len, bytes, n; // кол-во совпадающих байт
// RecBuf может не совпадать с началом буфера, куда прочитаны записи,
// если их больше чем одна.
// возвращает 0 если равно, 1 если запись больше образца и -1 если меньше
signed int compare_field( char *RecBuf, char field_number, void *template )
{
   long time_diff;
   int i=n;
   data = RecBuf+(Fields+field_number)->foffset + 5;
   switch ( types[field_number] )
   {
	 case 1:  // LONG
           // если long ищется как время
           if ( view_as[field_number] & 0x0004)
           {
            // за счет секунд и сотых может набегать разность
            // до 6000, это учитываем при сравнении
            time_diff = *((long *)data) - *((long *)template);
            if (( time_diff<6000 ) && ( time_diff>0 )) return 0;
	    if ( time_diff >= 6000 ) return 1;
            if ( time_diff < 0 ) return -1;
           }
           else
           {
            if ( *((long *)template) == *((long *)data) ) return 0;
            if ( *((long *)template) < *((long *)data) ) return 1;
            else return -1;
           };
	 case 2:  // REAL
            return 1;
	 case 3:  // STRING
	 case 4:  // STRING WITH PICTURE
	 case 7:  // GROUP
            while ( i > 0 )
            {
                asm push ax cx si di ds es
                asm mov ax,[i]
                asm dec ax            // смещение от начала поля поиска
                asm mov cx,[bytes]
                asm les di,dword ptr [data]
                asm add di,ax
                asm lds si,dword ptr [template]
                cmp_byte:
                asm repe cmpsb
		asm je Ok
		asm jcxz differs
		asm cmp byte ptr ds:[si-1],'?' // заменяет любой 1 символ
		asm je cmp_byte
		differs:
                asm pop es ds di si cx ax
                asm jmp short next_lev
                Ok:
                asm pop es ds di si cx ax
                return 0;
                next_lev:
                i--;
            }
            return 1;
	 case 5:  // BYTE
            if ( *((long *)template) == (ulong)*data ) return 0;
            if ( *((long *)template) < (ulong)*data ) return 1;
            else return -1;
	 case 6:  // SHORT
            if ( *((signed int *)template) == *((signed int *)data ))
            return 0;
            if ( *((signed int *)template) < *((signed int *)data ))
            return 1; else return -1;
	 case 8:  // DECIMAL
            if ((memcmp( template, data, len ))==0) return 0; else return 1;
   }
   return 1;
}

// результат 1 если имя является именем поля
uint IsThis( char *field_name, char *name )
{
    char n[17];
    int i, j;
    j=0;
    for ( i=0; i<16; i++ )
    {
       if (( *field_name != 0x20 )&&( *field_name != 0 ))
       n[j++] = *field_name++;
       else field_name++;
    };
    n[j++] =0;
    i=strcmp( strupr(n), name );
    if (i==0) return 1; else return 0;
}

// ищет перебором поле среди массива имен, возвращает -1 при ошибке
int FieldName2num( char *name)
{
    uint i;
    for ( i=0; i < hdat.numflds; i++ )
    {
       if (IsThis( &((Fields+i)->fldname[0]), strupr(name) )) return i;
    };
    return -1;
}

uint copy_fld_num;
uint copy_relation;
char copy_value[120]; // буфер для фильтрующего выражения
// возвращает 1 при удачном разборе аргументов
int parseCOPYargs( char *arg )
{
    uint i;
    i=0;
    // если первая кавычка-пропустим ее
    if ( *arg == 0x22 ) arg++;
    while ( *arg )
    {
        if (( *arg == 0x3C) || ( *arg == 0x3D) ||
            ( *arg == 0x3E) || ( *arg == 0x21)) break;
        copy_value[i++]= *arg++;
    };
    copy_value[i]=0;
    if ( *arg == 0 ) return 0;
    if (( copy_fld_num=FieldName2num( copy_value ) )== 0xFFFF) return 0;
    switch ( *arg++ )
    {
        case 0x3C:  // <
             if ( *arg == 0x3E ) // <>
             { copy_relation=1; arg++; break; }
             else { copy_relation=2; break; };
        case 0x3E:  // >
             copy_relation=3; break;
        case 0x3D:  // =
             copy_relation=0; break;
        case 0x21:  // !=
             if ( *arg == 0x3D )
             { copy_relation=1; arg++; break; } else return 0;
    }
    i=0;
    while ( *arg )
    {
        copy_value[i++]= *arg++;
    };
    // завершающую кавычку вырезаем
    if ( copy_value[i-1]==0x22 ) i--;
    copy_value[i]=0;

    if ( types[ copy_fld_num ] == 1) // если тип LONG
    {
	if (strchr( copy_value, 0x2F) || strchr( copy_value, 0x2E)) // "/","."
	      view_as[copy_fld_num] |= 0x0001;
	if (strchr( copy_value, 0x3A)) // ":"
              view_as[copy_fld_num] |= 0x0004;
    }

    return 1;
}

void displayFieldNames( void )
{
    uint i;
    vX = Lscr;
    SayNchar( Lscr, 1, colorNormal, Rscr-Lscr, 0xC4 );
    for ( i=LeftFieldNum; i < hdat.numflds; i++ )
    {
       data = &((Fields+i)->fldname[0]);
       len_data = strlen( (Fields+i)->fldname );
       if ( len_data > 16 ) len_data=16;
       // если хотя бы название поля помещается
       if (( vX + col_width[i] < Rscr) && ((view_as[i] & 0x0002)==0))

       {
          SayN( vX, 1, colorWindow, len_data, data );
          vX += col_width[i]+1;
       }
    };
}

uchar show_del_lock=0xFF;
void displayOneRecord(void)
{
    uint i;
    vX = Lscr;
    SayNchar( Lscr-1, vY, colorNormal, Rscr-Lscr+1, 0x20 );
    if ((RecBuf[0] & 0x10 ) && //  УДАЛЕН
        (show_del_lock)) i=0x0FE;
    else
    if ((RecBuf[0] & 0x40 ) && //  ЗАХВАЧЕН
        (!show_del_lock)) i=0x0FB;
    else goto skip;
         SayNchar( Lscr-1, vY, colorNormal, 1, i );
    skip:
    for ( i=LeftFieldNum; i < hdat.numflds; i++ )
    {
       // расположение бинарных данных
       data = RecBuf+(Fields+i)->foffset + 5;
       // длина в текстовом эквиваленте
       len_data = txt_equ[i];

       // если хотя бы название поля помещается
       if (( vX + col_width[i] < Rscr) && ((view_as[i] & 0x0002)==0))
       {
          SayN( vX, vY, colorNormal, len_data, convt( i, data ));
          vX += col_width[i]+1;
       }
    };
}

// мышиные процедуры
uint mouse=0; // признак-найдена мышь в системе или нет
uint MouseState; // нажатые кнопки
uint MouseX; // глобальные координаты мыши
uint MouseY;
uint mX, mY; // временно хранятся координаты мыши
void mouseOn(void)
{
    if ( mouse )
    {
       asm mov ax,1
       asm int 33h
    }
}

void mouseOff(void)
{
    if ( mouse )
    {
       asm mov ax,2
       asm int 33h
    }
}

uint mouseGet(void)
{
    MouseState=0;
    MouseX=0;
    MouseY=0;
    if ( mouse )
    {
       asm mov ax,3
       asm int 33h
       asm shr cx,3
       asm shr dx,3
       asm mov MouseX,cx
       asm mov MouseY,dx
       asm mov MouseState,bx
    }
    return MouseState;
}

void WaitMouseReleased(void)
{
        void *ptr;
        long ptime; // момент нажатия кнопки мыши
        ptr=MK_FP( 0, 0x046C ); // указатель на счетчик таймера
        ptime= *((long *)ptr) +3;
        // ждем отпускания кнопки мыши, каждые 3/18 секунды как новое нажатие
        while (( mouseGet() !=0 ) && ( ptime> *((long *)ptr) ));
}

// процедуры, вызываемые из achoice для показа одной строки
char *memo_text;
void mem2list( char x, char y, uint num, uchar width )
{
    if ( width>hdat.memowid ) width=hdat.memowid;
    SayN( x, y, colorWindow, width, memo_text+num*hdat.memowid+4 );
}

char *key_info;
void keyInf2list( char x, char y, uint num, uchar width )
{
    SayN( x, y, colorWindow, width, key_info+num*80 );
}

char *relation[]={ "равно", "не равно", "меньше", "больше" };
// показывает одну строку списка "меню отношений" на экране
void Relation2list( char x, char y, uint num, uchar width )
{
    Say( x, y, colorWindow, relation[num] );
}

// показывает одну строку списка "меню полей" на экране
void Field2list( char x, char y, uint num, uchar width )
{
    Say( x, y, colorWindow, (Fields+num)->fldname );
    if ( view_as[num] & view_mask ) Say( x+width-2, y, colorWindow, "√" );
}

// показывает системное время в углу экрана
void ShowTime( void )
{
       struct  time t;
       gettime(&t);
       sprintf( oStr, "%2d:%02d:%02d",
       t.ti_hour, t.ti_min, t.ti_sec);
       Say(72,0,colorNormal, oStr);
}

void SaveScreen( char x, char y, uchar width, uchar height );
void RestScreen( char x, char y, uchar width, uchar height );

// вывод подсказки об Alt-клавишах
#define helpX           20
#define helpY           4
#define helpWidth       41
#define helpHeight      12
char putted=0;
void put_alt_help( void )
{
     if ( putted ) return;
     SaveScreen( helpX, helpY, helpWidth, helpHeight );
     box( helpX, helpY , 36, 10, colorWindow );
     SayCR( helpX+2, helpY , colorWindow,
     " Подсказка по Alt-клавишам \n"\
     "Alt+F2 информация о ключах\n"\
     "Alt+F3 показ Locked(√)/Deleted(■)\n"\
     "Alt+F6 добавление записей к файлу\n"\
     "Alt+F8 просмотр только Deleted\n"\
     "Alt+V скрыть поле от показа\n"\
     "Alt+D показать LONG как дату\n"\
     "Alt+T показать LONG как время\n"\
     "Alt+X закончить работу\n");
     putted=1;
}

void close_alt_help( void )
{
     if ( putted == 0 ) return;
     RestScreen( helpX, helpY, helpWidth, helpHeight );
     putted=0;
}

void Bar( void );

void norm_key_bar( void )
{
    Say(0,24,colorNormal," 1Help   2Info   3MEMO   4       5Goto   6CopyTo 7Search"\
                 " 8       9       0Quit  ");
    Bar();
}

void shft_key_bar( void )
{
    Say(0,24,colorNormal," 1       2       3       4       5       6       7NxtSrc"\
		 " 8       9       0      ");
    Bar();
}

void alt_key_bar( void )
{
    Say(0,24,colorNormal," 1       2KeyInf 3VL/VD  4       5       6Append 7      "\
                 " 8View_D 9       0      ");
    Bar();
}

// хранитель экрана
void ScreenSaver(void)
{
    uint mX, mY;
    mouseGet();
    mY=MouseY;   // запомним текущее положение мыши
    mX=MouseX;
    mouseOff();
    SaveScreen(0,0,80,25);
           // очистим экран
           asm { mov ax,0B800h; mov es,ax; mov ax,720h; mov di,0
                 mov cx,80*25; cld; rep stosw };

        while (bioskey(1)==0)
        {
           if (mouseGet()) break;
           if (( mY != MouseY ) || ( mX != MouseX ))
                {
		MouseState=1;
                break;
                }
        };
    if ( MouseState==0 ) bioskey(0);
    RestScreen(0,0,80,25);
    mouseOn();
}

uint saver_delay=30;
// analog of INPUT with mouse's extension
void GetKEYBorMOUSE(void)
{
    long start_screen_saver, c_saver; // отсчеты хранителя экрана
    long *ptr; // указатель на счетчик таймера
    ptr=MK_FP( 0, 0x046C ); // указатель на счетчик таймера

    start_screen_saver= *((long *)ptr) +saver_delay*18; // задержка гашения экрана
    while ((key=bioskey(1))==0)
    {
       shft= bioskey(2)&0x0F;
       if (shft != o_shft) // изменилось состояние Shift
       {
       mouseOff();
       if (shft & 0x08) { put_alt_help(); alt_key_bar(); }
       else             { close_alt_help(); norm_key_bar(); };
       if (shft & 0x03)	shft_key_bar();
       o_shft = shft;
       mouseOn();
       };

       ShowTime();
       if (mouseGet()==1)
       {
          mY=MouseY; mX=MouseX; break;
       };
       if ( shft ) start_screen_saver= *((long *)ptr) +saver_delay*18;
       c_saver= *((long *)ptr); // текущее время
       if ( c_saver > start_screen_saver )
       {
          ScreenSaver();
          start_screen_saver= *((long *)ptr) +saver_delay*18;
       }
    };
    // сюда управление приходит либо при появлении кода в буфере
    // клавиатуры, либо при нажатии кнопки мыши
    if ( MouseState )
    {
       WaitMouseReleased();
       // если полоска функциональных клавиш
       if ( mY==24 )
       {
          if ( shft==0 ) key=0x3B00;
          else if ( shft & 0x08 ) key=0x6800; // Alt-комбинации

          // Ctrl и Shift - комбинации
          else key=0x5400;
          key += ((mX & 0x3F8)<<5);
       }
       else
       // если горизонтальный скролл-бар
       {
	  if (( key=scroll2key( mX, mY, &Hscrollbar)) !=0 ) goto skip_keyboard;
	  if (( key=scroll2key( mX, mY, &Vscrollbar)) !=0 ) goto skip_keyboard;
          key=0;
       };
       goto skip_keyboard;
    }
    key=bioskey(0);
 skip_keyboard:
    return;
}

// выбор поля из списка, возвращает номер или 0
// показывает состояние разряда слова из view_as[], заданного маской
// требует в качестве параметра адрес процедуры, формирующей одну строку
// на экране и total - всего элементов в списке
const uint aY=6;
const uint aHight=9;
const uint aWidth=26;
uint achoice( char *header, uint total, uchar width, void (* proc)() )
{
     // указатель на функцию вывода одной строки
     void (* Show)(char x, char y, uint num, uchar width);

     uint i,
     choice=0,   // позиция на текущей странице
     n_page=0;   // смещение страницы от начала списка
     uint maxY=aHight;
     uint aX=25;

     Show=proc;
     if ( width!=aWidth )
     {
        aX=(Rscr-Lscr-width)/2+Lscr;
     }
     if ( maxY > total ) maxY=total;
     box( aX-1, aY-1, width+2, maxY+2, colorWindow );
     Say( aX-1, aY-1, colorWindow, header);
     Say( aX, aY+maxY, colorWindow, "─ Enter выбор, Esc отмена─");

     while ( 1 )
     {
        for ( i=0; i<maxY; i++ )
        {
          SayNchar( aX, aY+i, colorWindow, width, 0x20 );
          Show( aX, aY+i, i+n_page, width );
        };

    noUpdated:
        Percent( aX+width, aY, 2, maxY, colorWindow,
                 choice+n_page, total, &Vscrollbar );
        Selector( aX, choice+aY, colorSelect2, width );

        mouseOn();
        GetKEYBorMOUSE();
        mouseOff();
        if ( key==0 ) key=0x011B;
        Selector( aX, choice+aY, colorWindow, width );
	switch ( key )
	{
	case 0x5000: // down
	     if ( choice < maxY-1 )  { choice++; goto noUpdated; }
	     else
	     {
                if ( n_page < total - maxY) n_page++;
	     };
	     break;
	case 0x4800: // up
	     if ( choice > 0 ) { choice--; goto noUpdated; }
	     else
	     {
                if ( n_page > 0) n_page--;
		else goto noUpdated;
             };
             break;
        case 0x5100: // PGdown
             if ( (signed int)n_page <
                  (signed int)(total - maxY -maxY))
                  n_page += maxY;
             break;
        case 0x4900: // PGup
             if ( n_page > maxY+1) n_page -= maxY;
             else goto noUpdated;
             break;
        case 0x7700: // Ctrl_Home
        case 0x8400: // Ctrl_PgUp
	     choice = 0;
             n_page = 0;
	     break;
	case 0x7500: // Ctrl_End
	case 0x7600: // Ctrl_PgDn
	     choice = maxY-1;
             n_page = total - maxY;
	     break;
	case 0x011B: // esc
	     goto done;
        case 0x1C0D: // Enter
             return choice+n_page+1;  // поля от 1..
        }
     }
     done:
        return 0;
}

uint field_choice( char *header )
{
  return achoice( header, hdat.numflds, aWidth, Field2list );
}

char *ch_types[]={ "Long   ", "Real   ", "String ", "StrPict", "Byte   ",
                  "Short  ", "Group  ", "Decimal" };
// показывает информацию о полях файла
const uint iX=11;
const uint iY=6;
const uint iWidth=60;
const uint iHight=12;

// показывает одну строку списка "информация о полях файла" на экране
void FieldParm2list( char x, char y, uint num, uchar width )
{
          SayNchar( x, y, colorWindow, width-2, 0x20 );
          Say( x, y, colorWindow, ch_types[(Fields+num)->fldtype-1] );
          Say( x+7, y, colorWindow, "│");
          Say( x+8, y, colorWindow, (Fields+num)->fldname );
   sprintf( oStr,"│%4Xh│%4Xh│%3Xh│%3Xh│%4Xh│%4u",
   (Fields+num)->foffset,
   (Fields+num)->length,
   (Fields+num)->decsig,
   (Fields+num)->decdec,
   (Fields+num)->arrnum,
   (Fields+num)->picnum ); Say( x+24, y, colorWindow, oStr );
}

const uint infoWidth=58;
void info(void)
{
     char short_name[50];
     signed int i,j,k;
     uint xx=(Rscr-Lscr-infoWidth)/2-1+Lscr;
     fLine( xx, iY-3,0, infoWidth+2,colorWindow, "──┐");
     // левый край рамки
     fLine( xx, iY-3,2, 4, colorWindow, "┌│└");
     SayCR( xx, iY-3, colorWindow, "┌─ Информация о полях \n"\
     "│Тип    │Имя поля        │Offs │Len  │dec │dec │array│pict │");
     j=strlen( DATfileName );
     k= j/2;
     i=0;
     while (( short_name[i++]= *(DATfileName++)) != 0 )
     {
        if (( i> k-(j-30)/2 ) && (j>30))
        {
           short_name[i++]=0x2E;
           short_name[i++]=0x2E;
           short_name[i++]=0x2E;
           DATfileName += (j-30);
           j=0;
        }
     }
     Say( xx+24, iY-3, colorWindow, short_name );
     achoice( "├───────┼────────────────┼─────┼─────┤sign│plac├─────┼─────┤",
     hdat.numflds, infoWidth, FieldParm2list );
}

char *keyFlag2str( char flag );

// показывает информацию о ключах файла
const int key_Width=60;
void KEYinfo( void )
{
     uint i, offset, field_num;
     signed int str_num, n;
     uchar comp, keytype;
     char *keyname; char *buffer; char *p;

     if (( mask!=0 )||(hdat.numbkeys==0)) return;

    // выделим место для чтения ключей целиком
    if ((buffer = malloc( hdat.offset-KEYsectBegin ))== NULL ) goto no_mem;

     // считаем все ключи в буфер
     fseek0( in, KEYsectBegin);
     fread( buffer, 1, hdat.offset-KEYsectBegin, in );

     // подсчитаем количество строк в отчете о ключах
     i=0;
     offset=0;
     str_num=0; // сквозной номер строки отчета о ключах
     while ( i<hdat.numbkeys )  // по всем ключам
     {
	comp=((KEYSECT *)(buffer+offset))->numcomps;
	offset += sizeof(KEYSECT)-4;
	str_num++;
	for ( n=1; n<=comp; n++ )
        {
	   offset += sizeof(KEYPART);
	   str_num++;
        }
        i++;
     };
     n=str_num; // сколько всего строк в отчете

    // выделим место для текста
    if ( n>100 )
    {
      e_win:
      free(buffer);
      no_mem:
      error_window("Нет памяти для просмотра"); return;
    };
    if ((key_info = malloc( 80*n ))== NULL ) goto e_win;

     i=0;
     offset=0;
     str_num=0; // сквозной номер строки отчета о ключах
     while ( i<hdat.numbkeys )  // по всем ключам
     {
	comp=((KEYSECT *)(buffer+offset))->numcomps;
	keyname=((KEYSECT *)(buffer+offset))->keynams;
	keytype=((KEYSECT *)(buffer+offset))->comptype;
	offset += sizeof(KEYSECT)-4;
        p=key_info+str_num*80;
        memset( p, 0x20, key_Width );
        memcpy( p, keyname, 16 );
        strcpy( p+21, keyFlag2str( keytype ) );
	str_num++;
	for ( n=1; n<=comp; n++ )
        {
           p=key_info+str_num*80;
           field_num=((KEYPART *)(buffer+offset))->fldnum;
           memset( p, 0x20, key_Width );
           if ( n==comp ) strcpy( p, "└─" );
           else strcpy( p, "├─" );
           memcpy( p+4, ((Fields+field_num-1)->fldname), 16 );
           strcpy( p+21, ch_types[types[field_num-1]-1] );
	   offset += sizeof(KEYPART);
	   str_num++;
        }
        i++;
     };
     n=str_num; // сколько всего строк в отчете
     achoice( "┌─ Key/Index Info ────── Duplicate UpperCase OptFill Locked ",
     n, key_Width, keyInf2list);
     done:
     free(key_info); free( buffer );
}

void *MyMalloc( uint size, char *call )
{
     void *Lptr;
    if ((Lptr = malloc( size ))== NULL )
    {
      printf( "%s: не выделена память.\n", call );
      exit(1);
    };
    return Lptr;
}

char Changed;
uchar InputStr[80];
uint cursor;
uint Input( char x, char y, uint color, uint Length_ )
{
        memset( InputStr, 0x20, 20 );
        InputStr[20]=0;
        Changed=0;
	Selector( x, y, color, Length_ );
        _DI=x*2+y*160;
        cursor = color;
	asm push bp si di ds es
	asm mov ax,0B800h
	asm mov es,ax
        asm mov     dx,Length_
	asm mov     si,offset byte ptr ds:InputStr
        asm push    di
Ed_S:
        asm pop ax
        asm push ax
        asm dec     ax      // тепеpь di всегда больше
        asm cmp     di,ax
        asm jae     u1
        asm pop di
        asm push di
u1:
        asm add     ax,dx
        asm add     ax,dx
        asm dec     ax
        asm cmp     di,ax
        asm jc      u2
        asm mov     di,ax
u2:
        asm mov     bx,word ptr ds:cursor
        asm mov     byte ptr es:[di+1],bh
        asm xor     ax,ax   // заполучить от пользователя код клавиши
        asm int     16h
        asm mov     byte ptr es:[di+1],bl
        asm or      al,al
        asm pop     bp
        asm push    bp
        asm jz      move_key
        asm cmp     al,27
        asm je      done_
        asm cmp     al,8    // забой
        asm je      BackSpace
        asm cmp     al,13
        asm je      save_str
        asm cmp     al,20h
        asm jc      Ed_S

        asm add     bp,dx
        asm add     bp,dx      // адpес пpавого кpая поля ввода
shft:
        asm dec     bp
        asm dec     bp
        asm cmp     di,bp
        asm je      p_sym   // если пpавый кpай, закончить
        asm mov     bx,es:[bp-2]
        asm mov     es:[bp],bx
        asm jmp     short shft
	p_sym:
        asm mov     es:[di],al
        asm mov     ah,4Dh
move_key:
        asm cmp     ah,4Dh
        asm je      right_
        asm cmp     ah,53h
        asm je      Del_
        asm cmp     ah,4Bh
        asm jne     Ed_S
LeftArrow:
        asm sub     di,4
right_:
        asm add     di,2
        asm jmp     short Ed_S
BackSpace:
        asm cmp     bp,di
        asm jnc     Ed_S    // если левый кpай, нечего забивать

        asm add     bp,dx
        asm add     bp,dx     // пpавый кpай
        asm dec     bp
        asm dec     bp

        asm mov     bx,di   // начиная отсюда...

copy_2left:
        asm mov     ax,es:[bx]
        asm mov     es:[bx-2],ax
        asm cmp     bp,bx
        asm je      lft
        asm inc     bx
        asm inc     bx
        asm jmp     short copy_2left

   lft:
        asm mov   byte ptr es:[bp],' '
        asm jmp     short LeftArrow

save_str:
        asm mov     byte ptr ds:Changed,0FFh
        asm pop     di
        asm push    di
        asm mov     cx,dx
copy_str:
        asm mov     al,es:[di]
        asm inc     di
        asm inc     di
        asm mov     ds:[si],al
        asm inc     si
        asm loop    copy_str
        asm mov     ax,cx // все равно что ноль
done_:
        asm pop     di
        asm pop es ds di si bp
        return _AX;

Del_:
        asm add     bp,dx
        asm add     bp,dx     // пpавый кpай
        asm dec     bp
        asm dec     bp
        asm mov     al,20h
        asm cmp     bp,di
        asm je      p_sym   // если пpавый кpай, веpнуть пpобел

        asm mov     bx,di   // Delete начиная отсюда...
c:
        asm cmp     bp,bx
        asm je      e_space
        asm mov     ax,es:[bx+2]
        asm mov     es:[bx],ax
        asm inc     bx
        asm inc     bx
        asm jmp     short c

e_space:
        asm mov     byte ptr es:[bp],' '
        asm jmp     Ed_S
        ;
}

void scroll( char x, char y, char hsize, char vsize, char mode, char color );

void main_help( void )
{
     char hpX=6;
     char hpY=6;
     box( hpX, hpY, 44, 12, colorWindow );
     SayCR( hpX+2, hpY, colorWindow,
     " About Cview.exe \n"\
     "(c) Milukov Alexander,Russia,95,96\n"\
     "(095) 320-27-55 Tsarizyno Ltd.\n"\
     "Special thank's to:\n"\
     "V.Sinyavski, Donetsk, Ukraine'94\n"\
     "autor of Clarion View v1.71\n"\
     "────────────────────────────────────────\n"\
     "F1 This Help      F6 Copy to new file\n"\
     "F2 Field Info     F7,^S Search 1st\n"\
     "F3 View MEMO      Shift+F7,^N Search 2nd\n"\
     "F5 Go to record#  F10,Esc,Alt+X Quit\n");
     asm xor ax,ax
     asm int 16h
}

// срезает хвостовые пробелы в InputStr[]
void clip(void)
{
     int i;
     for ( i=20; i>0; i-- ) if ( InputStr[i]<=0x20 )
     InputStr[i]=0; else return;
}

// запрашивает у пользователя, вводит и проверяет данные
// в подходящем формате (даты, времени и др.)
// возвращает 1 если ошибка
uint GetTemplate( uint field )
{
// дадим подходящую подсказку
     switch ( types[ field ] )
     {
         case 1:  // LONG
            if  ( view_as[ field ] & 0x001)
            {
            search_dialog_box( "Дата ", " ДД/ММ/ГГ ");
            search_ptr=&d_search;
            break;
            }
            else
            if  ( view_as[ field ] & 0x004)
            {
            search_dialog_box( "Время ", " ЧЧ:ММ ");
            search_ptr=&t_search;
            break;
            };
         case 5:  // BYTE
         case 6:  // SHORT
            search_dialog_box( "Число", "");
            search_ptr=&n_search;
            break;
         case 3:  // STRING
         case 4:  // STRING WITH PICTURE
         case 7:  // GROUP
            search_dialog_box( "Строка", " ?=[любой символ] ");
            search_ptr=&s_search[0];
            break;
         case 8:  // DECIMAL
            search_dialog_box( "Число", "Decimal" );
            bytes=(Fields+field)->length;
            if ( bytes > 50 ) return 1;
            search_ptr=&dec_search[0];
            break;
         otherwise:
            return 1;
     }
// напечатаем имя поля и введем данные в виде текста
     Say( 29,6 ,colorWindow, (Fields+field)->fldname );
     if ( batch>0 )
     {
        memcpy( InputStr, copy_value, 20 );
        goto batch_tpl;
     };
     if (Input( 28, 7, 0x700A, 20 )==0)
     {
        batch_tpl:
        // если допустимо представление в виде даты
        if  (search_ptr == &d_search)
        {
           // если дата введена без ошибок
           if ((d_search = str2dataClar( InputStr ))==-1)
           { errorDATE_window(); return 1; }
           else sprintf( oStr, "%s", ClaDate( d_search ) );
        };
        // если допустимо представление в виде времени
        if  (search_ptr == &t_search)
        {
           // если время введено без ошибок
           if ((t_search = str2timeClar( InputStr ))==-1)
           { errorTIME_window(); return 1; }
           else sprintf( oStr, "%s", ClaTime( t_search ) );
        };
        if  (search_ptr == &n_search)
        {
          str2long( InputStr, &n_search );
          if ( error )
          { errorNUM_window(); return 1; }
          else
             sprintf( oStr, "%ld", n_search );
        };
        if  (search_ptr == &s_search[0])
        {
          clip();
          memcpy( s_search, InputStr, 20 );
          str_len=strlen( s_search );
          sprintf( oStr, "\'%s\'", s_search );
          if (str_len==0)
          { errorARG_window(); return 1; }
        };

        if  (search_ptr == &dec_search[0])
        {
          clip();
          sprintf( oStr, "%s", InputStr );
          if (str2decimal( InputStr, dec_search, bytes ))
          { errorNUM_window(); return 1; }
        };
        return 0;
     };
     return 1;
}

// заполняет буфер записями для копирования или поиска
void fill_RecBuf(void)
{
    records_to_read=records_per_buffer;
    if ( records_to_read> hdat.numrecs-recno+1 )
    records_to_read=hdat.numrecs-recno+1;
    // встанем на запись (0..)
    fseek0( in, recno2offset( recno-1 ));
    // прочитаем все, что можно
    fread( RecBuf, records_to_read, hdat.reclen, in );
    search_buffer=RecBuf;
}

// возвр.1 если файл уже есть
int file_exist( char *name )
{
   asm push ds
   asm lds dx, name
   asm mov cx,20h
   asm mov ah,4Eh
   asm int 21h
   asm pop ds
   asm mov ax,0
   asm jc not_exist
   asm inc ax
   not_exist:
   return _AX;
}

ulong copied=0L;
void putLONG2hdr(void)
{
   fwrite( &copied, 1, sizeof(copied), out );
}

struct
{
   uint sign;
   ulong del_chain;
} mem_hdr;

char mem_name[300];  // копия имени файла для мемо-полей (и вспом.буфер)
char file_name_To_copy[80];
// append=1 для дописывания к файлу
void copyTo(char append)
{
   uint i, fld, rel; signed int cmp;
   char *memo_header;
   struct  time t_begin, t_current;
   ulong need_append=0L; // начальное количество записей в файле, куда append
   uchar x=10;
   uchar y=4;
   uchar color=colorWindow;
   if ( mask ) return;

   if ( append )
   dialog_box( 20,6 ,colorWindow, " Добавление ", "К файлу",
                           "");
   else
   dialog_box( 20,6 ,colorWindow, " Копирование ", "В файл",
                           "");

    if ( batch>0 ) goto batch_name;

   if (Input( 30, 7, 0x700A, 20 )) return;
        clip();
        memcpy( file_name_To_copy, InputStr, 20 );

        batch_name:
        str_len=strlen( file_name_To_copy );
        if ( append )
        sprintf( oStr, " Добавить записи к файлу \'%s\' ",
                 file_name_To_copy );
        else
        sprintf( oStr, " Копировать записи в файл \'%s\' ",
                 file_name_To_copy );
        if (str_len==0) return;
   box( x,y,51,10,color);
   Say( x+2,y ,color, oStr );

   if ( batch>0 )
   {
      fld=copy_fld_num;
      goto batch_fld;
   }
   SaveScreen(10,4,51,12);
   view_mask=0;
   fld=field_choice( "┌─ Ключевое поле " );
   RestScreen(10,4,51,12);
   if ( fld-- ==0 ) return;
 batch_fld:
   SaveScreen(10,4,51,10);
   // варианты сравнения меняются в зависимости от типа ключевого поля
   switch ( types[ fld ] )
   {
       case 1:  // LONG
       case 5:  // BYTE
       case 6:  // SHORT
          i=sizeof(relation)/sizeof(relation[0]); // число строк массива
          break;
       case 3:  // STRING
       case 4:  // STRING WITH PICTURE
       case 7:  // GROUP
       case 8:  // DECIMAL
          i=2; // можно только равно-неравно
          break;
       otherwise:
          return;
   };
   if ( batch>0 )
   {
      rel=copy_relation;
      goto batch_rel;
   }
   rel=achoice( "┌─ Отношение ",i, aWidth, Relation2list );
   RestScreen(10,4,51,10);
   if ( rel-- ==0 ) return;
   batch_rel:
   // напечатаем имя поля и отношение
   Say( 29+strlen((Fields+fld)->fldname)+1,6 ,colorWindow, relation[rel] );

   // ввод меняется в зависимости от типа ключевого поля
   if ( GetTemplate( fld ) ) return;

   // построим имя файла memo куда копировать или к чему добавлять
   // предполагая, что файл данных <куда> имеет стандартное расширение
   if ( memo )
   {
      strcpy( mem_name, strupr(file_name_To_copy) );
      sprintf( strstr(mem_name, ".DAT"), ".mem" );
   };
   if ( append )
   {
      if ( memo )
      {
        if ( file_exist( file_name_To_copy ) && file_exist( mem_name ))
        goto begin_work;
      }
      else
        if ( file_exist( file_name_To_copy ) )
        goto begin_work;
      error_window("Нет файла(ов), куда Append");
      return;
   }
   else
   {
      if ( file_exist( file_name_To_copy ))
      {
           error_window("Файл уже есть. Перезаписать ?");
           asm cmp al,'y'
           asm je begin_work
           asm cmp al,'Y'
           asm je begin_work
           asm cmp ax,1C0Dh
           asm je begin_work
               return;
      };
   };

   begin_work:
   if ( append )
   {
      out=fopen(file_name_To_copy, "rb+");
      if (memo) mem2=fopen(mem_name, "rb+");
   }
   else
   {
      out=fopen(file_name_To_copy, "wb");
      if (memo) mem2=fopen(mem_name, "wb");
   };

   if (( out==NULL) || (( memo != 0) && (mem2==NULL)))
           {
               error_window("Ошибка открытия файла"); return;
           };

     // засекаем время
     gettime(&t_begin);

     // прочитаем заголовок основного файла для сравнения
     fseek0( in, 0 );
     fread( RecBuf, 1, hdat.offset, in );

     if ( memo )
     {
        // прочитаем заголовок memo <откуда>
        fseek0( mem, 0 );
        fread( &mem_hdr, 1, sizeof(mem_hdr), mem );
     };

     if ( append )
     {
        if (( memo_header=malloc(hdat.offset) ) == NULL)
        {
           error_window("Не проверен header. Дальше ?");
           asm cmp al,'y'
           asm je hdr
           asm cmp al,'Y'
           asm je hdr
           asm cmp ax,1C0Dh
           asm je hdr
               fclose(out); if (memo) fclose(mem2); return;
           hdr:
	       goto hdr__;
	};
        // читаем заголовок .dat для сравнения типов полей
        fseek0( out, 0 );
	fread( memo_header, 1, hdat.offset, out );
	// согласуем поля, которые могут отличаться в заголовках
      *((uint *)(memo_header+2)) = *((uint *)(RecBuf+2));  /*  file attribute and status */
     need_append =*((ulong *)(memo_header+5));
     *((ulong *)(memo_header+5)) =*((ulong *)(RecBuf+5));  /*  number of records in file */
     *((ulong *)(memo_header+9)) =*((ulong *)(RecBuf+9));  /*  number of deleted records */
     *((ulong *)(memo_header+25))=*((ulong *)(RecBuf+25)); /*  logical end of file */
     *((ulong *)(memo_header+29))=*((ulong *)(RecBuf+29)); /*  logical beginning of file */
     *((ulong *)(memo_header+33))=*((ulong *)(RecBuf+33)); /*  first usable deleted record */
     *((ulong *)(memo_header+71))=*((ulong *)(RecBuf+71)); /*  reserved */
     *((ulong *)(memo_header+75))=*((ulong *)(RecBuf+75)); /*  time of last change */
     *((ulong *)(memo_header+79))=*((ulong *)(RecBuf+79)); /*  date of last change */
      *((uint *)(memo_header+83))= *((uint *)(RecBuf+83)); /*  reserved as CRC */
      cmp=memcmp( RecBuf, memo_header, hdat.offset );
        free( memo_header );
        if ( cmp!=0 )
        {
            error_window("Заголовки файлов разные");
            fclose( out ); if (memo) fclose(mem2); return;
        };
	hdr__:
        fseek( out, 0, 2); // в конец добавляемого файла(ов)
        if ( memo ) fseek( mem2, 0, 2);
     }
     else
     {
        // копируем заголовок
        fwrite( RecBuf, 1, hdat.offset, out );
        if ( memo )
        {
           mem_hdr.del_chain=0L;
           fwrite( &mem_hdr, 1, sizeof(mem_hdr), mem2 );
        }
     };

           wait_box();
           Say( 36,9 ,colorNormal, oStr );
           old_record = recno;
           last_search_fieldtype=-1;

          bytes=len=(Fields+fld)->length;
          // количество байтов, которые должны совпасть
          if ( bytes > str_len ) bytes=str_len;
          n=len-bytes+1; // кол-во различных положений искомой
                         // строки в поле, котором мы ее ищем


           while ( recno <= hdat.numrecs )
           {
              fill_RecBuf();
              i=0;
              while ( i<records_to_read )
              {
                 // копируем совпавшие неудаленные записи
                 cmp=compare_field( search_buffer, fld, search_ptr );
                 if ((*((char *)search_buffer)&0x10) == 0 )
                 if (
                    (( cmp==0 ) && ( rel==0 ))||   // равно, искали равных
                    (( cmp==1 ) && ( rel==1 ))||   // больше, искали неравных
                    (( cmp==1 ) && ( rel==3 ))||   // больше, искали больших
                    (( cmp==-1) && ( rel==1 ))||   // меньше, искали неравных
                    (( cmp==-1) && ( rel==2 ))     // меньше, искали меньших
                    )
                 {
                   // если существует memo, копируем его
                   if (( memo ) && ( *((ulong *)(search_buffer+1))))
                   {
                      fseek0( mem, 6L+
                      ((*((ulong *)(search_buffer+1))-1L) << 8 ));
                      fread( &mem_name, 1, 256, mem );

                      // новая ссылка из .dat на .mem
                      *((ulong *)(search_buffer+1))=
                      ((ftell(mem2)-6L) >> 8)+1L;
                      if (fwrite( &mem_name, 1, 256, mem2 )!=256)
                        {
                           fclose( out ); fclose(mem2);
                           error_window("Ошибка записи");
                           return;
                        };
                   };
                   if ( PutRecord( search_buffer ) )
                   {
                      fclose( out ); if (memo) fclose(mem2);
                      error_window("Ошибка записи");
                      return;
                   };

                   sprintf( oStr, "Скопировано %lu", ++copied );
                   Say( 38, 11, colorWindow, oStr );
                 }
                 search_buffer += hdat.reclen;
                 recno++;
                 if (bioskey(1)) goto escape;
                 i++;
              };
              sprintf( oStr, "Просмотрено #%lu", recno );
              Say( 14, 11,colorWindow, oStr );
              gettime(&t_current);
              t_current.ti_sec -= t_begin.ti_sec;
              if ( (signed char)t_current.ti_sec < 0 )
              {
                t_current.ti_sec += 60;
                t_current.ti_min--;
              }
              t_current.ti_min -= t_begin.ti_min;
              if ( (signed char)t_current.ti_min < 0 )
              {
                t_current.ti_min += 60;
                t_current.ti_hour--;
              }
              t_current.ti_hour -= t_begin.ti_hour;
              sprintf( oStr, "Время поиска %2d:%02d:%02d",
              t_current.ti_hour, t_current.ti_min, t_current.ti_sec);
              Say(24,12,colorWindow, oStr);
           };
           if   ( copied==0L )
           {
               dialog_box( 30,8 ,colorError, "─", "Значение не найдено","" );
           };
      escape:
           // скорректируем заголовок
           asm mov word ptr [i],offset hdat.numrecs - offset hdat.filesig
           fseek0( out, i );
           if (append)
              copied += need_append;
           putLONG2hdr();

           asm mov word ptr [i],offset hdat.logeof - offset hdat.filesig
           fseek0( out, i );
           putLONG2hdr();

           copied=1L;
           putLONG2hdr();  // logbof
           copied=0L;
           if (append==0) putLONG2hdr();  // 1st deleted

           asm mov word ptr [i],offset hdat.numdels - offset hdat.filesig
           fseek0( out, i ); // total deleted
           if (append==0) putLONG2hdr();
           fclose( out ); if (memo) fclose(mem2);
           recno=old_record;
           dialog_box( 30,8 ,colorWindow, "─", "Копирование завершено","" );
           if ( batch>0 ) return;
           asm xor ax,ax
           asm int 16h
   ;
}

// создает фильтр удаленных записей
void filterDeleted(void)
{
    uint i;
    long copied;
    // если фильтр был, то убираем его
    if ( filter )
    {
       hdat.numrecs=old_numrecs; // восстановим прежнее кол-во записей
       filter=0;
       free(filterTABLE);
       return;
    };
    if ( hdat.numdels==0 )
    {
        error_window("Нет удал. записей (header)");
        return;
    };
    if (hdat.numdels > 16000L) // 16000*sizeof(long) < 64k
    {
        e_mem:
        error_window("Мало памяти для фильтра");
        return;
    };
    if (( filterTABLE=malloc(hdat.numdels* sizeof(long)) )== NULL)
    goto e_mem;

    old_numrecs=hdat.numrecs; // запомним прежнее кол-во записей
    filter=1;
    // разыщем удаленные записи (по их заголовкам, а не по header файла)
    fseek0( in, hdat.offset );
    recno=1;
    while ( recno <= hdat.numrecs )
    {
       fill_RecBuf();
       i=0;
       copied=0;
       while ( i<records_to_read )
       {
          // запомним номера удаленных записи
          if (*((char *)search_buffer)&0x10)
          {
            filterTABLE[ copied ]=recno;
            sprintf( oStr, "Найдено %lu", ++copied );
            Say( 38, 11, colorWindow, oStr );
            if ( copied > hdat.numdels )
            {
                error_window("Лишние Deleted в файле");
                return;
            }
          }
          search_buffer += hdat.reclen;
          recno++;
          // рекурсивно (!) вызываем для снятия фильтра
	  if (bioskey(1)) { filterDeleted(); return; };
          i++;
       };
       sprintf( oStr, "Просмотрено #%lu", recno );
       Say( 14, 11,colorWindow, oStr );
    };
	     // скорректируем заголовок
             hdat.numrecs=hdat.numdels;
}

uint selY; // позиция селектора на экране считая от верха экрана
const uint rows=23; // строк в скроллинговой части экрана

void show_recno( void )
{
    char Trecno[80];
    ulong rec=recno+selY-2;
    if ( filter )
    {
      sprintf( Trecno, "Record %lu (%lu) / %lu        ",
      rec, filterTABLE[rec-1], hdat.numrecs );
    }
    else
    {
      sprintf( Trecno, "Record %lu / %lu        ",
      rec, hdat.numrecs );
    };
    Say( 30, 0, colorNormal, Trecno );
    Percent( Rscr, 2, 2, rows-2, colorNormal,
             rec, hdat.numrecs+1, &Vscrollbar );
}

uchar  *where;
// используется для разбора файла status.cv
// возвращает строку или число, следующую за str, или NULL при ошибках
// для строк mode=0, для чисел =1,2,4
char get_value_by_name( uchar *str, void far *to, char mode )
{
     uchar *f;
     ulong num; uint i;
     // если нет строки в тексте, стоп
     if (( f=strstr( where, str ))==NULL) return 0;
     // если строка не первая и левее не разделитель, стоп
     if ( f != where ) if ( *(f-1) > 0x20  ) return 0;
     // пропустим найденное
     f += strlen( str );
     if ( mode )
     {
	str2long( (char *)f, (long *)&num );
        if ( error ) return 0;
	switch ( mode )
        {
           case 1: *((uchar *)to) = (uchar) num; return 1;
           case 2: *((uint *)to) = (uint) num; return 1;
           case 4: *((ulong *)to) = num; return 1;
	};
     }
     else
     {
       i=0;
       while (( i<128 ) && ( f[i] > 0x20 ))
       {
	  *(((uchar *)to)+i)=f[i];
	  i++;
       }
       *(((uchar *)to)+i)=0;
     };
     return 1;
}

// флаги для разрешения сохранять текущее состояние в файлах status.cv
// и пытаться восстанавливать его оттуда при старте без параметров
char save_state=1;
char use_state=1;

// прочитаем status.cv
uint status_restored=0;
char restored_name[129]; // последний просмотренный файл
char *st_ID= "[ClarionView status]";
char *st_ID_ini= "[ClarionView config]";
char *st_file= "file=";
char *st_field= "left_field=";
char *st_recno= "record=";
char *st_page= "page=";
char *st_filter= "filter=";
char *st_colorNormal="colorNormal=";
char *st_colorWindow="colorWindow=";
char *st_colorError="colorError=";
char *st_colorSelect1="colorSelect1=";
char *st_colorSelect2="colorSelect2=";
char *st_saver_delay="SaverDelay=";
char *st_save_state="SaveState=";
char *st_use_state="UseState=";

// чтение файла общей конфигурации, хранится в каталоге где .exe
void restore_ini(void)
{
    FILE *j;
    ulong s;

    sprintf( restored_name, "%scview.ini", programm_name );
    if ((j = fopen( restored_name, "rb"))  == NULL) return;
    s = flen(j);
    if ( s>1024L ) { fclose(j); return; };
    if ((where = malloc( s + 1))== NULL) { fclose(j); return; };
    fread( where, s, 1, j);
    fclose(j);
    *(where+s)=0; // for string op's zero delimiter
    if (where != strstr(where, st_ID_ini) )
    {
       free(where);
       return;
    };
    // цветовые параметры
    get_value_by_name( st_colorNormal, &colorNormal, 1);
    get_value_by_name( st_colorWindow, &colorWindow, 1);
    get_value_by_name( st_colorError, &colorError, 1);
    get_value_by_name( st_colorSelect1, &colorSelect1, 1);
    get_value_by_name( st_colorSelect2, &colorSelect2, 1);
    get_value_by_name( st_saver_delay, &saver_delay, 2);
    get_value_by_name( st_save_state, &save_state, 1);
    get_value_by_name( st_use_state, &use_state, 1);
    free(where);
}


void restore_status(void)
{
    FILE *j;
    ulong s;
    if ( use_state == 0 ) return;

    if ((j = fopen( "status.cv", "rb"))  == NULL) return;
    s = flen(j);
    if ( s>1024L ) { fclose(j); return; };
    if ((where = malloc( s + 1))== NULL) { fclose(j); return; };
    fread( where, s, 1, j);
    fclose(j);
    *(where+s)=0; // for string op's zero delimiter
    if (where != strstr(where, st_ID) )
    {
       free(where);
       return;
    };
    // вытащим имя файла
    get_value_by_name( st_file, &restored_name[0], 0 );
    DATfileName=&restored_name[0];
    // номер поля, крайнего слева на экране
    get_value_by_name( st_field, &LeftFieldNum, 2);
    get_value_by_name( st_recno, &recno, 4 );
    get_value_by_name( st_page, &selY, 2);
    get_value_by_name( st_filter, &filter, 2 );
    free(where);
    status_restored=1;
}

void save_ini(void)
{
    FILE *j;

    sprintf( oStr, "%scview.ini", programm_name );

    if ((j = fopen( oStr, "wt"))  == NULL) return;
    fprintf( j, "%s\n\t%s%u\n\t%s%u\n\t%s%u\n\t%s%u\n\t%s%u\n\t%s%u\n\t%s%u\n\t%s%u\n",
    st_ID_ini,
    st_colorNormal, colorNormal,
    st_colorWindow, colorWindow,
    st_colorError, colorError,
    st_colorSelect1, colorSelect1,
    st_colorSelect2, colorSelect2,
    st_saver_delay, saver_delay,
    st_save_state, save_state,
    st_use_state, use_state
    );
    fclose(j);
}


void save_status(void)
{
    FILE *j;
    if ( save_state == 0 ) return;

    if ((j = fopen( "status.cv", "wt"))  == NULL) return;
    fprintf( j, "%s\n\t%s%s\n\t%s%u\n\t%s%lu\n\t%s%u\n\t%s%u\n\n",
    st_ID, st_file, DATfileName,
    st_field, LeftFieldNum,
    st_recno, recno,
    st_page, selY,
    st_filter, filter
    );
    fclose(j);
}

void show_memo( void )
{
    uint width;
    ulong rec=recno+selY-2;
    if (( memo==0 )||( filter )) return;
    if ((memo_text = malloc( hdat.memolen+4 ))== NULL ) return;
    GetRecHead( rec ); // пpочитаем заголовок заданной записи (1..)
    if ( dh.rptr )
    {
      fseek0( mem, 6L+((dh.rptr-1)<<8));
      fread( memo_text, 1, hdat.memolen+4, mem );
      if ( hdat.memowid > Rscr-Lscr-4 ) width=Rscr-Lscr-4;
      else width=hdat.memowid;
      if ( width<26 ) width=26;
      achoice( "┌─ MEMO field ", hdat.memolen/hdat.memowid, width, mem2list );
    }
    else
    {
      dialog_box( 30,8,colorWindow, " Ошибка ", " MEMO пустое ", " Esc ");
      asm xor ax,ax
      asm int 16h
    }
    free(memo_text);
}

void AllocateMemoryBuffers( void )
{
    Fields = MyMalloc( sizeof(struct FHEAD) * hdat.numflds,
    "Заголовки полей" );

    types = MyMalloc( sizeof(char) * hdat.numflds,
    "Массив типов полей" );

    col_width = MyMalloc( sizeof(int) * hdat.numflds,
    "Массив ширины столбцов" );

    txt_equ = MyMalloc( hdat.numflds * sizeof(int),
    "Массив длины полей (текст)" );

    view_as = MyMalloc( hdat.numflds * sizeof(int),
    "Массив способа просмотра полей" );
    memset( view_as, 0, hdat.numflds * sizeof(int) );

    records_per_buffer = 60*1024 / hdat.reclen;
    RecBuf = MyMalloc( hdat.reclen * records_per_buffer,
    "Буфер для записей данных" );
}

void main(int argc, char *argv[])    // входные паpаметpы
{
    uint i, fld;  int mode;
    ulong s_recno;

    // построим путь, откуда был запущен вьюер
    programm_name=argv[0];
    programm_name += strlen( argv[0] ); // укажем на хвост имени
    while ( programm_name != argv[0] )
    {
        if ( *(--programm_name) == 0x5C ) break; // ищем '\'
        *programm_name = 0;
    };
    programm_name=argv[0];
    // попробуем найти и использовать cview.ini
    restore_ini();

    // предположим, что имя файла все же указано
    DATfileName=argv[1];
    // если без параметров, попробуем восстановить из status.cv
    if (argc < 2)
    {
        restore_status();
        if ( status_restored ) goto begin_main;
    };
    if ( argc==2 ) if (strcmp( argv[1], "/?" )) goto begin_main;
                   else goto cmd_err;
    if ( argc==5 )
    {
        argv[3]=strupr(argv[3]);
        DATfileName=argv[1];
        strcpy( file_name_To_copy, argv[2] );
        mode=1; // copy
        if ( strcmp( argv[3], "/COPY" ) == NULL ) goto begin_main;
        mode=2; // append
        if ( strcmp( argv[3], "/APPEND" ) == NULL ) goto begin_main;
        goto cmd_err;
    }
    else
    {
        cmd_err:
        printf(
        "\nВьюер файлов .dat Clarion 2.1 (версия от %s (C) Милюков А.В.)\n"\
        "\tзапуск: cview Infile.dat\n"\
        "\tили     cview Infile.dat OutFile.dat /mode \"{field}{equ}{value}\"\n"\
        "\tгде {field}:=имя_поля, {equ}:= <,>,<>,=,!=, {value}:=значение\n"\
        "\t{mode}:= COPY | APPEND\n\n"\
        "\tнапример: cview In.dat MyFld /COPY \"IN:TIME=11:52\"\n"\
        "\tили       cview In.dat MyFld /APPEND \"IN:KOD>7845\"\n"\
        "\tили       cview In.dat MyFld /COPY \"IN:NAME!=Alex\"\n\n"\
        "\tФормат даты ДД.ММ.ГГ или ДД/ММ/ГГ, времени ЧЧ:ММ\n\n"\
        "\tесли параметры не заданы, то по умолчанию\n"
        "\tвосстанавливается предыдущий режим работы\n"\
        "\tиз файла status.cv если он имеется в текущем каталоге\n\n",
        __DATE__);
        printf("Press SPACE for more"); getch();
        printf(
        "\nClarion 2.1 data files viewer, %s (C) Milukov A.V.\n"\
        "\tusage:  cview Infile.dat\n"\
        "\tor      cview Infile.dat OutFile.dat /mode \"{field}{equ}{value}\"\n"\
        "\twhere {field}:=field_name, {equ}:= <,>,<>,=,!=, {value}:=pattern\n"\
        "\t{mode}:= COPY | APPEND\n\n"\
        "\texample: cview In.dat MyFld /COPY \"IN:TIME=11:52\"\n"\
        "\tor       cview In.dat MyFld /APPEND \"IN:KOD>7845\"\n"\
        "\tor       cview In.dat MyFld /COPY \"IN:NAME!=Alex\"\n\n"\
        "\tTemplate are DD.MM.YY or DD/MM/YY for date, HH:MM for time\n\n"\
        "\tif no parameter(s) given, then by default\n"
        "\tprevious working state will be restored\n"\
        "\tfrom \'status.cv\', if any.\n\n",
        __DATE__);
	exit(1);
    };

    begin_main:
    if ( saver_delay < 30 ) saver_delay = 30;

    if ( *(ulong *)MK_FP( 0, 51*4 ))
    {
       asm mov ax,0
       asm int 33h
       mouse=1;
    };

    ChkName(DATfileName);

    file_len = flen( in );

    fread( &hdat, 1, sizeof( hdat ), in );
    if ( hdat.filesig != 0x3343 )
    {
        errorFILE_window(); exit(1);
    }
    // может оказаться зашифрован
    if ( hdat.sfatr & aFileOwned )
    {
        printf("File has \'Owner\' attribute, search password...\n");
        CalculateMask();
        DoCrypt(sizeof (hdat) - 4, &hdat.numbkeys);
    }

    AllocateMemoryBuffers();
    GetFieldHeader();
    if ( memo )
    {
        fread( &i, 1, sizeof(i), mem );
        if (( hdat.memolen>250 ) || (i != 0x334D))
        {
           error_window("Unknown MEMO field");
           fclose(mem); memo=0;
        }
    }

    if ( argc==5 )
    {
        if (parseCOPYargs( argv[4] )) batch=mode;
        else {batch=-1; error_window("Условие для /xxxx неверно");};
    };

    // пытаемся восстановить картину
    if ( status_restored )
    {
        // проверим общие условия, которым должны
        // отвечать прочитанные параметры
        if (
           ( LeftFieldNum>hdat.numflds-1 ) ||
           ( selY > rows-1 )
           )
        {
          filter=0;
          goto restart;
        };
        // если был фильтр, попытаемся его установить
        if ( filter )
        {
          // поскольку на момент старта filterDeleted() еще
          // не выполнялась, сбросим признак
          filter=0;
          // если фильтрование имеет шансы выполниться
          if (
          (hdat.numdels>0) &&
          ((long)hdat.numdels<16000L) &&
          ((ulong)recno+(ulong)selY < hdat.numdels+2)
             )
             {
                 s_recno=recno; // запомним старое
                 filterDeleted(); // отфильтруем удаленные записи
                 // если не получилось
                 if ( filter==0 ) goto restart;
                 recno=s_recno;
                 goto skip_init;
             };
          goto restart;
        };
        if ((ulong)recno+(ulong)selY <= hdat.numrecs+2) goto skip_init;
    }

  restart:
    LeftFieldNum = 0; // сначала первое поле выводим слева на экране
    recno=1;
    selY = 2;
  skip_init:
    GetRecord(1);

    SayNchar( 0, 0, colorNormal, 80, 0x20 );
    Say(1,0,colorNormal,"ClarionView (c) Милюков");
    Say( Lscr-1,1,colorNormal, "─" ); Say( Rscr,1,colorNormal, "┐" );
    fLine( Lscr-2,1,2,rows,colorNormal,"┌│└"); // левый край рамки
    Say( Lscr-1,rows,colorNormal, "─Deleted─" );
    Say(Rscr-1,rows,colorNormal,"─┘");
    norm_key_bar();

    while ( 1 )
    {
    vY = 1;
    displayFieldNames();
    show_recno();

    Percent( Lscr+9, rows, 0, Rscr-Lscr-1-9, colorNormal,
             (ulong)LeftFieldNum, (ulong)hdat.numflds, &Hscrollbar );

    vY = 2;
    while ( vY < rows )
    {
    if (recno+vY-2 <= hdat.numrecs)
       {
	 GetRecord(recno+vY-2);
	 displayOneRecord();
       }
    else SayNchar( Lscr-1, vY, colorNormal, Rscr-Lscr+1, 0x20 );
    vY++;
    }

    Only_show_recno:
    show_recno();
    noUpdated:

    Selector( Lscr-1, selY, colorSelect1, Rscr-Lscr+1 );

    shft = bioskey(2)&0x0F;
    o_shft = -1;

    mouseOn();
    if ( batch==1 )
    {
      key=0x4000; // F6
      goto skip_keyboard;
    };
    if ( batch==2 )
    {
      key=0x6D00; // Alt-F6
      goto skip_keyboard;
    };
    if ( batch==-1 )
    {
      key=0x011B; // ESC
      goto skip_keyboard;
    };
    GetKEYBorMOUSE();
    skip_keyboard:
    mouseOff();
    close_alt_help();

    Selector( Lscr-1, selY, colorNormal, Rscr-Lscr+1 );
   switch ( key )
   {
        case 0x5000: // down
	     if (( selY < rows-1 ) &&
		 ((long)selY-2 < (long)hdat.numrecs-(long)recno ))
	     {
	     selY++;
             goto Only_show_recno;
	     }
             else
             {
		if ( (long)recno < (long)hdat.numrecs - (long)rows+3)
                {
		   recno++;
                   scroll( Lscr-1,2,Rscr-Lscr,rows-3,0,colorNormal );
		   vY=rows-1;
		   GetRecord(recno+vY-2);
		   displayOneRecord();
                   goto Only_show_recno;
		}
		else
		goto noUpdated;
	     };
	case 0x4800: // up
	     if ( selY > 2 )
	     {
	     selY--;
             goto Only_show_recno;
	     }
             else
             {
		if ( recno > 1)
		{
		recno--;
                scroll( Lscr-1,2,Rscr-Lscr,rows-3,1,colorNormal );
		vY=2;
		GetRecord(recno+vY-2);
		displayOneRecord();
                goto Only_show_recno;
		}
		else goto noUpdated;
	     };
	case 0x4D00: // right
	     if ( LeftFieldNum < hdat.numflds-1 ) LeftFieldNum++;
	     else goto noUpdated;
	     break;
	case 0x4B00: // left
	     if ( LeftFieldNum > 0 ) LeftFieldNum--;
	     else goto noUpdated;
	     break;
        case 0x5100: // PGdown
	     if ( (long)recno < (long)hdat.numrecs - rows -2) recno += rows;
	     break;
	case 0x4900: // PGup
	     if ( recno > rows+1) recno -= rows;
	     else goto noUpdated;
	     break;
	case 0x2000: // alt-D
             view_mask=1;
             if (( fld=field_choice( "┌─ Показать LONG как дата ") ) !=0)
             view_as[fld-1] ^= 0x0001;
             break;
        case 0x1400: // alt-T
             view_mask=4;
             if (( fld=field_choice( "┌─ Показать LONG как время ") ) !=0)
             view_as[fld-1] ^= 0x0004;
             break;
	case 0x2F00: // alt-V
             view_mask=2;
             if (( fld=field_choice( "┌─ Спрятать поле ") ) !=0)
	     view_as[fld-1] ^= 0x0002;
	     break;
	case 0x3B00: // F1
	     main_help();
	     break;
	case 0x3C00: // F2
             info();
	     break;
	case 0x6900: // Alt+F2
	     KEYinfo();
	     break;
        case 0x3D00: // F3
             show_memo();
	     break;
        case 0x6A00: // Alt+F3
             show_del_lock ^= 0xFF;
             if ( show_del_lock )
                Say( Lscr-1,rows,colorNormal, "─Deleted─" );
             else
                Say( Lscr-1,rows,colorNormal, "─Locked──" );
	     break;
	case 0x3F00: // F5
             dialog_box( 20,6 ,colorWindow, " Перейти на запись ", "Номер",
                                     " Esc отмена ");
	     Changed=0;
             if (Input( 28, 7, 0x700A, 20 )==0)
	     {
                str2long( InputStr, &goto_record );
                if ((goto_record>0) &&
                    (goto_record < hdat.numrecs ) &&
                    ( error==0 ))
		{
		    if (goto_record < hdat.numrecs-rows )
		    {
		       recno=goto_record;
		       selY=2;
		    }
		    else
		    {
		       recno = hdat.numrecs-rows;
		       selY=2+goto_record-recno;
		    };
		}
                else error_window("Недопустимый номер записи");
	     }
	     break;
	case 0x4000: // F6
             copyTo(0);
             clear_batch();
	     break;
        case 0x6D00: // Alt+F6
             copyTo(1);
             clear_batch();
	     break;
	case 0x4100: // F7
        case 0x1F13: // Ctrl+S
             if ( GetTemplate(LeftFieldNum) ) goto brk;

                     wait_box();
                     Say( 36,9 ,colorNormal, oStr );
		     old_record = recno;
                     last_search_fieldtype=types[ LeftFieldNum ];
               Next_search:

                    bytes=len=(Fields+LeftFieldNum)->length;
                    // количество байтов, которые должны совпасть
                    if ( bytes > str_len ) bytes=str_len;
                    n=len-bytes+1; // кол-во различных положений искомой
                                   // строки в поле, котором мы ее ищем

                     if (last_search_fieldtype!=types[ LeftFieldNum ])
                     { errorARG_window(); goto brk; }

		     while ( recno <= hdat.numrecs )
		     {
                        fill_RecBuf();
                        i=0;
                        while ( i<records_to_read )
                        {
                           if (compare_field( search_buffer,
                                              LeftFieldNum,
                                              search_ptr )==0)
                           {
                             selY=2;
                             goto brk;
                           }
                           search_buffer += hdat.reclen;
                           recno++;
                           if (bioskey(1)) goto escape;
                           i++;
                        }
			sprintf( oStr, "#%lu", recno );
                        Say( 48, 10,colorWindow, oStr );
		     }
                     dialog_box( 30,8 ,colorError, "─", "Значение не найдено","" );
		escape:
		     recno=old_record;
		     asm xor ax,ax
                     asm int 16h
	     brk:
             break;
        case 0x5A00: // Shft-F7
        case 0x310E: // Ctrl+N
             old_record = recno;
             if ( recno < hdat.numrecs ) recno++;
             goto Next_search;
        case 0x6F00: // Alt+F8
             filterDeleted();
             goto restart;
	case 0x7700: // Ctrl_Home
        case 0x8400: // Ctrl_PgUp
             selY = 2;
             recno = 1;
             break;
        case 0x7500: // Ctrl_End
        case 0x7600: // Ctrl_PgDn
             selY = rows-1;
	     recno = hdat.numrecs - rows+3;
             break;
        case 0x4700: // Home
             LeftFieldNum = 0;
             break;
        case 0x4F00: // End
             LeftFieldNum = hdat.numflds-1;
             break;

	case 0x011B: // esc
	case 0x2D00: // Alt+X
	case 0x4400: // F10
	     goto done;
   }
   }
   done:
   free( RecBuf ); free( view_as ); free( txt_equ );
   free( col_width ); free( types ); free( Fields ); fclose(in);
   if ( memo ) fclose(mem);

   save_status();
   save_ini();

   // очистим экран
   asm { mov ax,0B800h; mov es,ax; mov ax,720h; mov di,0
        mov cx,80*25; cld; rep stosw };

   exit(0);
}

