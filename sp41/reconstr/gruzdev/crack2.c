#include <io.h>
#include <memory.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys\types.h>
#include <sys\stat.h>

struct LHEAD   /* A.  Локальный_заголовок_файла. */
  {
  unsigned long sign;  /* Сигнатура Локального_заголовка_файла  4 байта (0x04034B50)*/
  unsigned int  ver;   /* Версия, необходимая для извлечения    2 байта */
  unsigned int  bit;   /* Битовые флаги общего назначения       2 байта */
         /*  бит 0: Если установлен, то файл зашифрован.       */
         /*  бит 1: Если метод сжатия - Imploding (6),         */
         /*         то показывает размер словаря слайдов:      */
         /*             0 - 4K Sliding dictionary              */
         /*             1 - 8K Sliding dictionary              */
         /*  бит 2: Если метод сжатия - Imploding (6),         */
         /*         то показывает число деревьев Shannon-Fano: */
         /*             0 - 2 дерева                           */
         /*             1 - 3 дерева                           */
         /*  Если метод сжатия - НЕ Imploding (6),             */
         /*  то биты 1 и 2 НЕ ОПРЕДЕЛЕНЫ.                      */
  unsigned int  mode;  /* Метод сжатия                          2 байта */
         /*  0 - Файл записан (без сжатия)    */
         /*  1 - Shrunk                       */
         /*  2 - Reduced с фактором сжатия 1  */
         /*  3 - Reduced с фактором сжатия 2  */
         /*  4 - Reduced с фактором сжатия 3  */
         /*  5 - Reduced с фактором сжатия 4  */
         /*  6 - Imploded                     */
  unsigned int  ltime; /* Время последней модификации файла     2 байта */
  unsigned int  ldate; /* Дата последней модификации файла      2 байта */
  unsigned long crc;   /* CRC-32                                4 байта */
              /* Магическое число для CRC - 0xDEBB20E3         */
  unsigned long nsize; /* сжатый размер                         4 байта */
  unsigned long osize; /* Полный размер                         4 байта */
  unsigned int  lfnam; /* Длина имени файла                     2 байта */
  unsigned int  lalt;  /* Длина дополнительного поля            2 байта */
/*unsigned char name [];  Имя файла (переменный размер)
  unsigned char alt [];   Дополнительное поле (переменный размер) */
  } lhead;

char digit [512];        /* место для сбора наборов символов */
char * digit_set [6] =   /* стандартные наборы символов      */
  {
/*---123456789-123456789-_1_2345678------------*/
    "~@#$%^&*()_+-=[]{},.\\\"/?:;`'",   /* +28 */
/*---123456789-123456789-123456----------------*/
    "abcdefghijklmnopqrstuvwxyz",       /* +26 */
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ",       /* +26 */
    "0123456789",                       /*  10 */
/*---123456789-123456789-123456789-12----------*/
    "абвгдежзийклмнопрстуфхцчшщъыьэюя", /* +32 */
    "АБВГДЕЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ"  /* +32 */
  };                                    /*-----*/
                                 /* Итого: 154 */
unsigned char Stream [1024];  /* Буфер для для чтения данных из файла */
struct PARAM                  /* Структура для передачи параметров в  */
   {                          /*          ассемблерный модуль         */
   char * pBufUse;    /* 12 дешифровочных байт               */
   char * pStream;    /* 1-й килобайт данных                 */
   int    passbeg;    /* стартовый размер пароля             */
   int    passend;    /* конечный (макс.) размер пароля      */
   int  * pcurnum;    /* стартовый пароль (номера символов)  */
   int    psize [3];  /* размеры деревьев (возвращаются)     */
   char   pBits [2];  /* [0]=ZIP-флаги, [1]=результат поиска */
   int    pCPU;       /* тип процессора                      */
   int    pSizeD;     /* размер общего набора символов       */
   char * pDigit;     /* общий набор символов                */
   int    pVideo;     /* частота выдачи текущего пароля      */
   } bb;
extern void test_ (struct PARAM *);   /* ассемблерный модуль */
int Point;            /* текущее положение в Stream []       */

/*----------* получение символа из входного потока *---------*/
unsigned char stream (void)
{
register unsigned char Temp;

Temp = Stream [Point];
Point++;
return Temp;
}
/*-------------* построение дерева Shannon-Fano *------------*/
/* возвращает размер построенного дерева                     */
/*-----------------------------------------------------------*/
int ConstructTree (int task)
{
register int i,k,j;
   
j = (unsigned int) stream () + 1;
for (k=i=0; i<j; i++)
   {
   k += ((unsigned int)((stream () >> 4) & 0xF) + 1);
   if (k>task) return (-1);
   }
if (k!=task) return (-1);
j++;
return (j);
}

void main (int argc,char *argv[])
{
int i,j,k,a;
int fdz;
int curnum [10];
long cur;
unsigned char BufUse [12];
unsigned char password [10];
char *p, name [120],*zip;

puts ("ANV (R) CRACKer for ZIP-files version 2.0, 15-11-91");
puts ("Copyright (C) Груздев Александр Петрович, Пермь тел.39-58-81\n");
if (argc < 2)
  {
  puts ("Usage: CRACK [options] ZIP-file [length_of [password]]\n");
  puts ("Option:");
  puts ("  /386 - use 386 CPU instructions (40% faster, default not use)");
  puts ("  /v   - put current password after 100 pass (else after every pass)");
  puts ("  /s[descriptors] - use declared symbol set");
  puts ("Descriptor:");
  puts ("  :symbols - use pointed symbol set (is must last descriptor)");
  puts ("  c        - ~@#$%^&*()_+-=[]{},.\\\"/?:;`' symbol set");
  puts ("  e        - a-z symbol set");
  puts ("  E        - A-Z symbol set");
  puts ("  0        - 0-9 symbol set");
  puts ("  r        - а-я symbol set (alternate ASCII table)");
  puts ("  R        - А-Я symbol set (alternate ASCII table)\n");
  puts ("EXAMPLE Descriptor Option: /s0e:_!=+-");
  puts ("  Will use next set: 0-9,a-z and 5 symbols: _!=+-");
  puts ("DEFAULT Descriptor Option: /sceE0");
  exit (0);
  }
/*----------- инициализация параметров по умолчанию ---------*/
bb.pCPU = 0;
bb.pVideo = 0;
bb.pSizeD = 0;
bb.pDigit = digit;
fdz = 0;
bb.passbeg = 1;      /* стартовый размер пароля по умолчанию */
for (i=0; i<10; i++)
   curnum [i] = 0;   /* стартовый пароль по умолчанию        */
   
/*----------- разбор параметров настройки -------------------*/
for (a=1; a<argc; a++)
   {
   if (argv[a][0] != '/' && argv[a][0] != '-') break;
   if (!memcmp (argv[a]+1,"386",3))
      bb.pCPU = 1;             /* Использовать инструкции 386-го     */
   else if (argv[a][1] == 'v')
      bb.pVideo = 1;           /* Выдавать пароль после 100 проходов (проход-перебор всех символов в 1-й позиции) */
   else if (argv[a][1] == 's')
      {                        /* Использовать указанный комплект    */
      i=strlen (argv[a]);      /* наборов символов                   */
      for (j=2; j<i; j++)
         {
         if (argv[a][j]=='c')  /* набор допустимых спец-символов     */
            {
            if (fdz & 1) continue;
            fdz |= 1;
            memcpy (bb.pDigit + bb.pSizeD, digit_set[0], 28);
            bb.pSizeD += 28;
            }
         else if (argv[a][j]=='e') /* строчный латинский алфавит    */
            {
            if (fdz & 2) continue;
            fdz |= 2;
            memcpy (bb.pDigit + bb.pSizeD, digit_set[1], 26);
            bb.pSizeD += 26;
            }
         else if (argv[a][j]=='E') /* прописной латинский алфавит  */
            {
            if (fdz & 4) continue;
            fdz |= 4;
            memcpy (bb.pDigit + bb.pSizeD, digit_set[2], 26);
            bb.pSizeD += 26;
            }
         else if (argv[a][j]=='0') /* набор цифровых символов     */
            {
            if (fdz & 8) continue;
            fdz |= 8;
            memcpy (bb.pDigit + bb.pSizeD, digit_set[3], 10);
            bb.pSizeD += 10;
            }
         else if (argv[a][j]=='r') /* строчный русский алфавит   */
            {
            if (fdz & 16) continue;
            fdz |= 16;
            memcpy (bb.pDigit + bb.pSizeD, digit_set[4], 32);
            bb.pSizeD += 32;
            }
         else if (argv[a][j]=='R') /* прописной русский алфавит  */
            {
            if (fdz & 32) continue;
            fdz |= 32;
            memcpy (bb.pDigit + bb.pSizeD, digit_set[5], 32);
            bb.pSizeD += 32;
            }
         else if (argv[a][j]==':') /* произвольный набор символов */
            {
            k=strlen (argv[a]+j+1);
            if (k==0)
               puts ("Descriptor ':' is empty (ignored)");
            else
               {
               strcpy (bb.pDigit + bb.pSizeD, argv[a]+j+1);
               bb.pSizeD += k;
               break;
               }
            }
         else
            printf ("UNKNOWN descriptor: %c (ignored)\n",argv [a][j]);
         }
      }
   else
      printf ("UNKNOWN parameter: %s (ignored)\n",argv [i]);
   }
if (bb.pSizeD == 0)
   {                 /* формирование стандартного набора символов */
   bb.pSizeD = 90;
   strcpy (digit,digit_set [0]);
   strcpy (digit+28,digit_set [1]);
   strcpy (digit+28+26,digit_set [2]);
   strcpy (digit+28+26+26,digit_set [3]);
   }
if (a==argc)
  { puts ("ZIP-file parameter must pointed"); exit (0); }
zip = ".ZIP";
strcpy (name, argv[a]);
i = strlen (name);
if (i<5 || name [i-4] != '.')  /* добавим расширение, если не указано */
   strcpy (name+i,zip);
printf ("ZIP file: %s",name);
a++;                           /* переход к следующему параметру */
if (argc > a)
   {
   bb.passbeg = atoi (argv[a]);
   printf (" length= %d",bb.passbeg);
   a++;                        /* переход к следующему параметру */
   if (argc > a)
      {
      j = strlen (argv [a]);
      if (j != bb.passbeg) { puts ("\nNot length assign with password"); exit (0); }
      for (i=0; i<j; i++)
         {
         for (k=0; k < bb.pSizeD; k++)
            if (digit [k]==argv[a][i]) break;
         if (k >= bb.pSizeD)
            {
            printf ("\nSymbol '%c' with password '%s' not include to symbol set",
                              argv[a][i],        argv[a]);
            exit (0);
            }
         curnum [i] = k;
         }
      for (i=0; i<j; i++)
         password [i] = digit [curnum[i]];
      password [i] = '\0';
      printf (" of password= %s",password);
      }
   }
if ( (fdz=open (name,O_BINARY | O_RDONLY)) < 0) { puts (" - can't OPEN"); exit (1); }
if (read (fdz, (char *)&lhead, sizeof (struct LHEAD)) != sizeof (struct LHEAD)) { puts (" - can't HEAD read"); exit (1); }
if (lhead.sign != 0x04034B50) { puts (" - not ZIP-file !"); exit (1); }
memset (name,'\0',13);
if (read (fdz, name, lhead.lfnam) != (int)lhead.lfnam) { puts (" - can't FILE name read"); exit (1); }
if (lhead.bit & 1) p="ENcrypted";
else               p="UNencrypted";
printf ("\nChecking file: %s (%s)",name,p);
     if (lhead.mode == 0) p="Store";
else if (lhead.mode == 1) p="Shrunk";
else if (lhead.mode == 2) p="Reduced with 1";
else if (lhead.mode == 3) p="Reduced with 2";
else if (lhead.mode == 4) p="Reduced with 3";
else if (lhead.mode == 5) p="Reduced with 4";
else if (lhead.mode == 6) p="Implode";
else { puts ("\nWith UNKNOWN mode !"); exit (1); }
printf ("\nMODE: %s  COMPRESS: %ld bytes  ORIGINAL: %ld bytes\n",p,lhead.nsize,lhead.osize);

cur = (long)(sizeof (struct LHEAD) + lhead.lfnam + lhead.lalt);
if (lseek (fdz,cur,SEEK_SET) != cur) { puts ("Lseek error 1"); exit (1); }

if (lhead.mode == 6)
   {
   int tree,dic;
   if (lhead.bit & 2) dic=8; else dic=4;
   if (lhead.bit & 4) tree=3; else tree=2;
   printf ("Used %d Kb Sliding dictionary & %d Shannon-Fano tree\n",dic,tree);
   }
else
   {
   puts ("This MODE not present in this CRACKer version !");
   exit (0);
   }
if (lhead.bit & 1)
   {
   if (read (fdz, BufUse, 12) != 12)
      { puts (" - can't SCRYPT read"); exit (1); }
   digit [bb.pSizeD] = '\0';
   printf ("Used symbol set: %s\n",digit);
   }
if (read (fdz, Stream, 1024) != 1024)
   { puts (" - can't DATA read"); exit (1); }
if (lhead.bit & 1)
   {
   bb.pBufUse = BufUse;
   bb.pStream = Stream;
   bb.passend = 6;       /* конечный размер пароля, если > 10, то */
   bb.pcurnum = curnum;  /* нужно увеличить размерность curnum [] */
   bb.pBits [0]= (char)lhead.bit;
   
   test_ (&bb);          /* вызов ассемблерного модуля */
   if (bb.pBits [1]>0)
      {
      if (lhead.bit & 1)
         {
         for (i=0; i<bb.passbeg; i++) password [i] = digit [curnum[i]];
         password [i] = '\0';
         printf ("\nUsed PASSWORD: %s\n",password);
         }
      if (lhead.bit & 4)
         printf ("Literal tree COMPRESS: %d bytes CONSTRUCT: 256 items\n",bb.psize[0]);
      printf ("Length tree COMPRESS: %d bytes CONSTRUCT: 64 items\n",bb.psize[1]);
      printf ("Distance tree COMPRESS: %d bytes CONSTRUCT: 64 items\n",bb.psize[2]);
      }
   else
      puts ("Not password with length from 1 to 6 with this symbol set");
   }
else
   {
   int size [3];
   
   Point = 0;
   if (lhead.bit & 4)
      {
      if ((size[0] = ConstructTree (256)) < 0)
         { puts ("Bad ZIP-file: cannot buield Literal tree"); exit (0); }
      printf ("Literal tree COMPRESS: %d bytes  CONSTRUCT: 256 items\n",size[0]);
      }
   if ((size[1] = ConstructTree (64)) < 0)
      { puts ("Bad ZIP-file: cannot buield Length tree"); exit (0); }
   printf ("Length tree COMPRESS: %d bytes CONSTRUCT: 64 items\n",size[1]);
   if ((size[2] = ConstructTree (64)) < 0)
      { puts ("Bad ZIP-file: cannot buield Distance tree"); exit (0); }
   printf ("Distance tree COMPRESS: %d bytes CONSTRUCT: 64 items\n",size[2]);
   }
close (fdz);
return;
}
