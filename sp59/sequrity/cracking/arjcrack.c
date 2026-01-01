#include <stdlib.h>
#include <stdio.h>
#include <conio.h>
#include <string.h>
#include <ctype.h>
#include <time.h>
#include <malloc.h>

#include <fcntl.h>
#include <sys\types.h>
#include <sys\stat.h>
#include <io.h>

#define DDICSIZ         26624
#define GARBLE_FLAG     0x01
#define CRC_MASK        0xFFFFFFFFL
typedef unsigned long UCRC;     /* CRC-32 */

extern short method;
extern UCRC crc;
extern UCRC file_crc;
extern unsigned char garb_char;
extern unsigned char *text;

void make_crctable (void);
long find_header (int);
int  read_header (int,int,struct INFO *);
void unstore  (void);
void decode   (void);
void decode_f (void);

/*----------------------- мои переменные --------------------*/
unsigned char stream [4096];
unsigned char password [20];
int glength;
int bound;
unsigned char cmin,cmax;
unsigned char only [50];
int onlylen;
void (*test)(void);
unsigned char digit [256];        /* место для сбора наборов символов */
unsigned char * digit_set [6] =   /* стандартные наборы символов      */
 { /*123456789-123_456789_-123456789-----------*/
    "@#$%&!?()[]{}\\/:;~^\"`'+-=*,._",  /* +29 */
    "0123456789",                       /*  10 */
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ",       /* +26 */
    "abcdefghijklmnopqrstuvwxyz",       /* +26 */
    "АБВГДЕЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ"  /* +32 */
    "абвгдежзийклмнопрстуфхцчшщъыьэюя", /* +32 */
 };/*123456789-123456789-123456789-12----------*/
                                 /* Итого: 155 */
char hex [] = "0123456789ABCDEF";
char sha []="\rПароль: %s  Проверено: %ld  Время счета: %dч.%2.2dм.%2.2dс.";
struct INFO
 {
 char file [120];     /* имя рабочего файла             */
 int  flags;          /* флаги                          */
 char *buf;           /* буфер для зашифрованного файла */
 long elen;           /* длина сжатого файла            */
 long dlen;           /* длина несжатого файла          */
 char *pwd;           /* буфер для пароля               */
 int  plen;           /* длина пароля                   */
 unsigned long fcrc;  /* контрольная сумма              */
 } info;

char *m[]=
{
"Не могу открыть %s",                          /* 0 */
"Не могу найти заголовок %s",                  /* 1 */
"Не могу прочитать заголовок %s",              /* 2 */
"Указанный файл не защищен: %s",               /* 3 */
"Указанный файл в сжатом виде > 4 Kb: %s",     /* 4 */
"Указанный файл не найден: %s",                /* 5 */
"Не могу прочитать заголовок файла %s",        /* 6 */
"Не могу прочитать файл %s",                   /* 7 */
"Нет ни одного защищенного файла в архиве %s", /* 8 */
"Длина файла в сжатом виде > 4 Kb: %s",        /* 9 */
};
//-----------------------------------------------------------------------

int search1 (char *arj, char *file, struct INFO *x)
{
int fd=0,error=0;
long first_hdr_pos;

if ((fd=open (arj, O_BINARY|O_RDONLY)) < 0) { printf (m[0],arj); error=-1; goto err; }
if ((first_hdr_pos = find_header (fd)) < 0) { printf (m[1],arj); error=-2; goto err; }
lseek (fd, first_hdr_pos, SEEK_SET);
if (read_header (1, fd, x) < 0)             { printf (m[2],arj); error=-3; goto err; }
while ((error=read_header(0, fd, x))==0)
   {
   register int i,j;
   int s1,s2;
   
   s1=strlen (file);
   s2=strlen (x->file);
   for (i=s1-1,j=s2-1; i>=0; i--,j--) 
      { if (toupper(file [i]) != toupper(x->file [j])) break; }
   if (i<0)
      {
      if (!(x->flags & GARBLE_FLAG)) { printf (m[3],x->file); error=-4; goto err; }
      if (x->elen > 4096L)           { printf (m[4],x->file); error=-5; goto err; }
      break;
      }
   lseek (fd, x->elen, SEEK_CUR);
   }
if (error==-4) { printf (m[5],file); error=-6; goto err; }
if (error < 0) { printf (m[6],file); error=-7; goto err; }
if (read (fd, stream, (int)x->elen) != (int)x->elen)
               { printf (m[7],file); error=-8; }
err:
   if (fd>0) close (fd);
   return (error);
}

int search2 (char *arj, struct INFO *x)
{
int fd=0,error=0,i;
long fsize,fpos,hdr_pos;

if ((fd=open (arj, O_BINARY|O_RDONLY)) < 0) { printf (m[0],arj); error=-1; goto err; }
if ((hdr_pos = find_header (fd)) < 0)       { printf (m[1],arj); error=-2; goto err; }
lseek (fd, hdr_pos, SEEK_SET);
if (read_header (1, fd, x) < 0)             { printf (m[2],arj); error=-3; goto err; }
i=0;
fsize = filelength (fd);
hdr_pos = tell (fd);
while ((error=read_header(0, fd, x))==0)
   {
   if (x->flags & GARBLE_FLAG)
      {
      i++;
      if (x->elen < fsize)
         {
         fsize = x->elen;
         fpos  = hdr_pos;
         }
      }
   lseek (fd, x->elen, SEEK_CUR);
   hdr_pos = tell (fd);
   }
if (error!=-4) { printf (m[6],x->file); error=-4; goto err; }
if (i==0)      { printf (m[8],arj);     error=-5; goto err; }
error=0;
lseek (fd, fpos, SEEK_SET);
if (read_header (0, fd, x) < 0) { printf (m[6],x->file); error=-6; goto err; }
if (x->elen > 4096L)            { printf (m[9],x->file); error=-7; goto err; }
if (read (fd, stream, (int)x->elen) != (int)x->elen)
                                { printf (m[7],x->file); error=-8; }
err:
   if (fd>0) close (fd);
   return (error);
}

unsigned char htoi (unsigned char h)
{
register unsigned char i=0;

if ('0'<=h && h<='9') i=h-'0';    else
if ('a'<=h && h<='f') i=10+h-'a'; else
if ('A'<=h && h<='F') i=10+h-'A';
return (i);
}

/*---------------------- основная процедура --------------------*/
//-----------------------------------------------------------------------
//   - если не задано имя файла, то предполагается, что все файлы
//     заархивированы под одним паролем и для работы выбирается
//     файл с наименьшим размером, иначе работа идет с указанным
//     файлом.
//-----------------------------------------------------------------------
char name [120], *arj;
time_t t1,t2,t3;
int  pSizeD;      /* размер общего набора символов       */
int  passbeg;     /* стартовый размер пароля             */
int  passend;     /* конечный (макс.) размер пароля      */
int  curnum [20]; /* номера символов пароля в наборе     */
char pass [20];

void main (int argc,char *argv[])
{
int  i,j,k,l,a,view;
int  fdz;
long all;

puts ("ANV (R) CRACKer for ARJ-files version 1.0, 29-06-93");
puts ("Copyright (C) Груздев Александр Петрович, Пермь т.498-254\n");
if (argc < 2)
  {
help:
  puts ("Формат: ARJCRACK [<ключи>] <имя_архива> [<имя_файла>]");
  puts ("-------");
  puts ("<ключи>:");
  puts ("     /?                - подсказка");
  puts ("     /t<число секунд>  - интервал для выдачи текущего пароля");
  puts ("     /ixx-xx (min-max) - допустимый интервал кодов (включая границы)");
  puts ("     /fxx-xx-..        - первые байты ориг.файла в шестнад.кодах");
  puts ("     /g<пароль>        - стартовый пароль");
  puts ("     /s<спецификаторы> - набор символов для составления пароля");
  puts ("<спецификаторы>:");
  puts ("     c          - 29 спецсимволов: @#$%&!?()[]{}\\/:;`'\"^~*=+-,._");
  puts ("     0          - 0-9 (цифры)");
  puts ("     L          - A-Z (прописная латиница)");
  puts ("     l          - a-z (строчная  латиница)");
  puts ("     K          - А-Я (прописная кириллица) | альтернативная |");
  puts ("     k          - а-я (строчная  кириллица) |   кодировка    |");
  puts ("     :<символы> - произвольный набор символов");
  puts ("\nНапример:  ARJCRACK /s0l:-+= /i20-ef /g0000 test.arj unarj.c");
  return;
  }
/*----------- инициализация параметров по умолчанию ---------*/
view = 5;
pSizeD = 0;
passbeg = 0;         /* стартовый размер пароля по умолчанию */
passend = 10;        /* конечный размер пароля */
bound = 0;
cmin = 0;
cmax = 255;
onlylen = 0;

/*----------- разбор параметров настройки -------------------*/
for (fdz=0,a=1; a<argc; a++)
   {
   if (argv[a][0] != '/' && argv[a][0] != '-') break;
   if (argv[a][1] == '?' || argv[a][1] == 'h') goto help;
   if (argv[a][1] == 's')
      {                        /* Использовать указанный комплект    */
      i=strlen (argv[a]);      /* наборов символов                   */
      for (j=2; j<i; j++)
         {
         if (argv[a][j]=='c')  /* набор допустимых спец-символов     */
            {
            if (fdz & 1) continue;
            fdz |= 1;
            memcpy (digit + pSizeD, digit_set[0], 29);
            pSizeD += 29;
            }
         else if (argv[a][j]=='0') /* набор цифровых символов     */
            {
            if (fdz & 2) continue;
            fdz |= 2;
            memcpy (digit + pSizeD, digit_set[1], 10);
            pSizeD += 10;
            }
         else if (argv[a][j]=='L') /* прописной латинский алфавит  */
            {
            if (fdz & 4) continue;
            fdz |= 4;
            memcpy (digit + pSizeD, digit_set[2], 26);
            pSizeD += 26;
            }
         else if (argv[a][j]=='l') /* строчный латинский алфавит    */
            {
            if (fdz & 8) continue;
            fdz |= 8;
            memcpy (digit + pSizeD, digit_set[3], 26);
            pSizeD += 26;
            }
         else if (argv[a][j]=='K') /* прописной русский алфавит  */
            {
            if (fdz & 16) continue;
            fdz |= 16;
            memcpy (digit + pSizeD, digit_set[4], 32);
            pSizeD += 32;
            }
         else if (argv[a][j]=='k') /* строчный русский алфавит   */
            {
            if (fdz & 32) continue;
            fdz |= 32;
            memcpy (digit + pSizeD, digit_set[5], 32);
            pSizeD += 32;
            }
         else if (argv[a][j]==':') /* произвольный набор символов */
            {
            k=strlen (argv[a]+j+1);
            if (k==0)
               puts ("Дескриптор ':' пуст (пропущен)");
            else
               {
               strcpy (digit + pSizeD, argv[a]+j+1);
               pSizeD += k;
               break;
               }
            }
         else
            printf ("Неизвестный описатель: %c (пропущен)\n",argv [a][j]);
         }
      }
   else
   if (argv[a][1] == 'g')
      {
      strncpy (password,argv [a]+2,10);
      passbeg = strlen (password);
      if (passbeg==0)
         { printf ("Пустой пароль '%s' не обрабатывается",argv [a]); return; }
      }
   else
   if (argv[a][1] == 't')
      {
      view = atoi (argv [a]+2);
      }
   else
   if (argv[a][1] == 'i')
      {
      if (strlen (argv[a]+2) != 5)
         { printf ("Неверный формат параметра '%s'",argv [a]); return; }
      cmin = (htoi (argv [a][2]) << 4) + htoi (argv [a][3]);
      cmax = (htoi (argv [a][5]) << 4) + htoi (argv [a][6]);
      bound=1;
      }
   else
   if (argv[a][1] == 'f')
      {
      j=strlen (argv[a]+2);
      i=k=0;
      while (i<j)
         {
         only [k++] = (char)((htoi (argv [a][i+2])<<4) + htoi (argv [a][i+3]));
         i+=3;
         }
      onlylen = k;
      }
   else
      printf ("Неизвестный параметр: %s (пропущен)\n",argv [a]);
   }
if (pSizeD == 0)
   {                 /* формирование стандартного набора символов */
   sprintf (digit,"%s%s%s",digit_set [1],
                           digit_set [2],
                           digit_set [3]);
   pSizeD = strlen (digit);
   }
if (passbeg==0)
   {                  /* стартовый пароль по умолчанию */
   passbeg=1;
   password [0] = digit [0];
   password [1] = '\0';
   for (i=0; i<10; i++)
      curnum [i] = 0;
   }
else
   {
   for (i=0; i<passbeg; i++)
      {
      for (k=0; k < pSizeD; k++)
         if (digit [k] == password[i]) break;
      if (k >= pSizeD)
         { printf ("Символ '%c' в пароле '%s' не входит в допустимый набор", password[i], password); return; }
      curnum [i] = k;
      }
   }
if (a==argc)
   { puts ("Не указано имя ARJ-файла"); return; }

strcpy (name, argv[a]);
i = strlen (name);
if (i<5 || name [i-4] != '.')  /* добавим расширение, если не указано */
   strcpy (name+i,".ARJ");
a++;                           /* переход к следующему параметру */
info.buf = stream;
info.pwd = password;

make_crctable();
if (argc > a) //-------------- поиск данного файла в архиве ----------------
   { if (search1 (name, argv [a], &info)) return; }
else          //--------- поиск самого маленького файла в архиве -----------
   { if (search2 (name, &info)) return; }
if (method == 0) test = unstore;  else
if (method == 1) test = decode;   else
if (method == 2) test = decode;   else
if (method == 3) test = decode;   else
if (method == 4) test = decode_f; else
{ printf ("Неизвестный метод сжатия файла: %s",info.file); return; }

if ((text=malloc (DDICSIZ))==0) 
   { printf ("Не хватает памяти для работы"); return; }
printf ("ARJ-архив: %s\n",name);
printf ("Рабочий файл: %s\n",info.file);
printf ("Начальный пароль: %s\n",password);
printf ("Используемый набор символов: %s\n",digit);
printf ("Интервал выдачи: %d сек.\n",view);
if (bound>0)
   printf ("Интервал кодов: [%2.2d..%2.2d]\n",(int)cmin,(int)cmax);
if (onlylen>0)
   {
   printf ("Коды первых байт: ");
   printf ("%c%c",hex[(int)((only[0]>>4) & 0xF)],hex[(int)(only[0] & 0xF)]);
   for (i=1; i<onlylen; i++)
      printf ("-%c%c",hex[(int)((only[i]>>4) & 0xF)],hex[(int)(only[i] & 0xF)]);
   printf ("\n");
   }
printf ("\n");
printf (sha, password, 0L, 0, 0, 0);
time (&t1);
time (&t2);
all = 0L;
for (i=0; i<pSizeD; i++)           // учтем поправку на ветер... (шутка)
   digit [i] += garb_char;
for (i=0; i<passbeg; i++)
   password [i] = digit [curnum [i]];
l = curnum [0];
for (glength=passbeg; glength<=passend; )   // цикл по размеру паролей
   {
   int L=0;            //<-- позиция 'флага переноса'
   while (L < glength)             // цикл перебора паролей данного размера
      {
      for (; l<pSizeD; l++)        // цикл по символам набора в 1-й позиции
         {
         curnum   [0] = l;
         password [0] = digit [l];
         crc = CRC_MASK;
         (*test)();
         if ((crc ^ CRC_MASK) == file_crc) goto find;
         all++;
         }
      l=0;
      /*-------------------------*/
      if (view>0)
         {
         time (&t3);
         if (t3-t2 >= view)
            {
            for (i=0; i<glength; i++)
               pass [i] = password [i] - garb_char;
            pass [i]='\0';
            time (&t2);
            t3=t2-t1;
            printf (sha, pass, all,
                    (int)(t3/3600L),
                    (int)((t3/60L)%60L),
                    (int)(t3%60L));
            if (kbhit())
               { if (!getch()) getch(); goto end; }
            }
         }
      /*-------------------------*/
      L=1;
      while (curnum [L] >= (pSizeD-1) && L<glength)  // реализация 'флага переноса'
         {
         curnum   [L] = 0;
         password [L] = digit [0];
         L++;
         }
      curnum   [L]++;
      password [L] = digit [curnum [L]];
      }
   glength++;
   for (i=0; i<glength; i++) curnum [i] = 0;
   memset (password, digit [0], glength);
   password [glength+1]='\0';
   }
end:
   puts ("\nПароль не найден!");
free (text);
return;
find:
   for (i=0; i<glength; i++)
      password [i] -= garb_char;
   printf ("\nНайден пароль: %s", password);
free (text);
return;
}
