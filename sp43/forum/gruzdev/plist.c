#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <io.h>
#include <dos.h>
#include <fcntl.h>
#include <sys\types.h>
#include <sys\stat.h>

char digit [128] =
  { "0123456789_"                      /*  11 */
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ"       /* +26 */
    "abcdefghijklmnopqrstuvwxyz"       /* +26 */
    "АБВГДЕЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ" /* +32 */
    "абвгдежзийклмнопрстуфхцчшщъыьэюя" /* +32 */
  };
char *err[]=
{
"\nTarget file write error",
"\nSourse file read error",
"\nTmp file create error"
};

#define   BufSz   (31*1024)

char lbuf [31*1024];
char mbuf [31*1024];
char tbuf [BufSz];
char *mac [5000]; 
char *str [5000]; 
char *fil [1000]; 

void main (int argc, char *argv[])
{
long l;
int i,j,k,t,k1,s,count,count_f;
int fdh,fdl,line;
char sbuf[200],sym;
char *p,*p1,*p2;

puts ("ANV (R) Protect List Maker for FoxBase Version 1.1, 3-11-91");
puts ("Copyright (C) Груздев Александр Петрович, Пермь тел.39-58-81\n");
if (argc < 5)
   {
   puts ("Usage: PLIST <List_file> <Macros_file> <PRG_list_file> <Binary_file>\n");
   puts ("List_file:     файл со списком имен, подлежащих защите");
   puts ("Macros_file:   имя файла с перечнем подстановок, который будет сгенерирован");
   puts ("PRG_list_file: файл со списком PRG-файлов, которые необходимо обработать");
   puts ("Binary_file:   имя бинарного модуля, которое будет указано для PMAKER");
   exit (0);
   }
/*
 *   Обработка параметров и возможности работы с ними
 */
printf ("List file: %s",argv [1]);
if ( (fdh=open (argv[1],O_BINARY | O_RDONLY)) < 0)
   { puts (" - can't OPEN"); exit (1); }
l = filelength (fdh);
if (l<5)
   { puts (" - too small (must > 1 name"); exit (1); }
if (l>(14*1024L))
   { puts (" - too large (must < 14 Kb)"); exit (1); }
printf (" - open");
s = (unsigned int)l;
if (read (fdh, lbuf, s) != s)
   { puts (err[1]); exit (1); }
puts (" and read");
close (fdh);
printf ("Macros List file: %s",argv [2]);
if ((fdl=open(argv[2],O_BINARY|O_RDWR|O_TRUNC|O_CREAT,S_IREAD|S_IWRITE)) < 0)
   { puts (" - can't CREATE\n"); exit (1); }
puts (" - create");
printf ("PRG list file: %s",argv [3]);
if (access (argv[3], 0) == -1)
   {
   puts (" - can't found\n");
   close (fdl);
   unlink (argv[2]);
   exit (1);
   }
puts (" - access");
printf ("Binary file for LOAD command: %s\n\n",argv [4]);
/*
 *   Составление перечня подстановок (с генерацией символических имен)
 */
puts ("Macros List making..");
count = 0;
k1=1; /*  k1==0 - ждем разделителя  *
       *  k1==1 - ждем начала имени *
       */
for (i=j=k=0; i<s; i++)
   {
   sym = lbuf [i];
   if (sym != ' ' &&
       sym != ',' &&
       sym != (char)0xD &&
       sym != (char)0xA)
      {
      if (k1==1) k1=0;
      if (j>79)
         {
         printf ("\rList compile error in line %d",count);
         close (fdl);
         unlink (argv[2]);
         exit (1);
         }
      sbuf [j++] = sym;
      }
   if ((sym == (char)0xA ||
        sym == ',') && k1==0)
      {
      count++;
      sbuf [j] = '\0';
      for (t=0; t<j; t++)
         {
         k1 = (((unsigned int)sbuf[t])+count) % 127;
         mbuf [k++] = digit [k1];
         }
      mbuf[k++] = '=';
      memcpy (mbuf+k,sbuf,j);
      k+=j;
 /*
  *    mbuf[k] = '\0';
  *    printf ("\r%d. %s\t\t\t",count,mbuf+k-(j<<1)-1);
  */
      mbuf[k++] = (char)0xA;
      j=0;
      k1=1;
      }
   }
puts ("\rMacros List writing..\t\t\t");
if (write (fdl,mbuf,k) != k)
   { puts (err[0]); exit (1); }
close (fdl);
k1=1;
for (i=j=0; i<k; i++)
   {
   if (mbuf [i] != '=' &&
       mbuf [i] != (char)0xA)
      {
      if (k1==0) continue;
      if (k1==1) { mac [j] = mbuf+i; k1=0; }
      if (k1==2) { str [j] = mbuf+i; k1=0; }
      }
   else
   if (k1==0)
      if (mbuf [i] == '=')
         { mbuf [i] = '\0'; k1=2; }
      else
      if (mbuf [i] == (char)0xA)
         { mbuf [i] = '\0'; k1=1; j++; }
   }
if (j!=count)
   {
   printf ("algoritm or data error: j=%d count=%d",j,count);
   exit (1);
   }
/*
 *   Обработка перечисленных PRG-файлов
 */
printf ("\nPRG list file: %s",argv [3]);
if ( (fdh=open (argv[3],O_BINARY | O_RDONLY)) < 0)
   { puts (" - can't OPEN"); exit (1); }
l = filelength (fdh);
if (l<5)
   { puts (" - too small (must > 1 name"); exit (1); }
if (l>(31*1024L))
   { puts (" - too large (must < 31 Kb)"); exit (1); }
printf (" - open");
s = (unsigned int)l;
if (read (fdh, lbuf, s) != s)
   { puts (err[1]); exit (1); }
puts (" and read");
close (fdh);

printf ("Calculating...");
k1=1;
for (count_f=i=0; i<s; i++)
   {
   if (lbuf [i] != (char)0xD &&
       lbuf [i] != (char)0xA &&
       lbuf [i] != '\0'      &&
       lbuf [i] != ' '       &&
       lbuf [i] != ',')
      {
      if (k1==1)
         { fil [count_f] = lbuf+i; k1=0; }
      continue;
      }
   else
      {
      if (k1==0)
         { count_f++; k1=1; }
      lbuf [i] = '\0';
      }
   }
printf ("\rPRG-file count: %d\n",count_f);
for (i=0; i<count_f; i++)
   {
   strcpy (sbuf,fil [i]);
   j = strlen (sbuf);
   if (j>4 && sbuf[j-4] == '.')
      memcpy (sbuf+j-3,"prg",3);
   else
      memcpy (sbuf+j,".prg",5);
   
   printf ("\t\t\t\t\r%d. File: %s", i+1, fil [i]);
   
   if ( (fdh=open (sbuf,O_BINARY | O_RDONLY)) < 0)
      { puts (" - can't OPEN, skipping"); continue; }
   
   j = strlen (sbuf);
   memcpy (sbuf+j-3,"$$$",3);
   if ((fdl=open (sbuf,O_BINARY|O_RDWR|O_TRUNC|O_CREAT,S_IREAD|S_IWRITE)) < 0)
      { puts (err[2]); exit (1); }
   
   puts (" - open");
   if (i==0)
      {
      p = sbuf + strlen (sbuf) + 1;
      sprintf (p,"load %s\r\n_tmp_=\"%s\"\r\ncall %s with _tmp_\r\n",
                  argv[4], mac[0], argv[4]);
      j = strlen (p);
      if (write (fdl,p,j) != j)
         { puts (err[0]); goto err_exit; }
      }
   l = filelength (fdh);
   line = 0;
   while (l>0L)
      {
      if (l > BufSz) s = BufSz;
      else           s = (int)l;
      if (read (fdh, tbuf, s) != s)
         { puts (err[1]); goto err_exit; }
      j=0;
      while (j<s)
         {
         line++;
         printf ("\rLine: %d",line);
         k1 = 0;
         p = tbuf+j;
         while (j<s && tbuf[j] != (char)0xD && tbuf[j] != (char)0xA)
            { j++; k1++; }
         while (j<s && (tbuf[j] == (char)0xD || tbuf[j] == (char)0xA))
            { j++; k1++; }
         if (j==s && tbuf[j-1] != (char)0xD && tbuf[j-1] != (char)0xA) break;
         if (k1>2)
            {
            /*
             *  проверка на синтаксис (procedure,function)
             */
            for (k=0; k<k1; k++)
               if (p [k] != ' ' && p [k] != '\t') break;
            if (!memicmp (p+k,"proc",4) || !memicmp (p+k,"func",4))
               t=0; /* пропуск строки */
            else
            /*
             *  поиск и подстановка имен (если t>0)
             */
            for (k=0; k<count; k++)        /* <-------------------------  */
               {                           /*                          |  */
               t = strlen (str[k]);        /*                          |  */
               p1 = p;                     /*                          |  */
               while (p1 < p+k1-t)         /* <-----------------       |  */
                  {                                        /*  |       |  */
                if (memcmp (p1,str[k],t)==0)               /*  |       |  */
                     {                                     /*  |       |  */
                     p2 = sbuf + strlen (sbuf) + 1;        /*  |       |  */
                     sprintf (p2,"_tmp_=\"%s\"\r\ncall %s with _tmp_\r\n",
                                        mac[k],     argv[4]);
                     k = strlen (p2);                      /*  |       |  */
                     if (write (fdl,p2,k) != k)            /*  |       |  */
                        { puts (err[0]); goto err_exit; }  /*  |       |  */
                     p1 [0] = '\0';                        /*  |       |  */
                     k = strlen (p);                       /*  |       |  */
                     if (write (fdl,p,k) != k)             /*  |       |  */
                        { puts (err[0]); goto err_exit; }  /*  |       |  */
                     if (write (fdl,"&_tmp_.",7) != 7)     /*  |       |  */
                        { puts (err[0]); goto err_exit; }  /*  |       |  */
                     k = k1-(p1-p+t);                      /*  |       |  */
                     if (write (fdl,p1+t,k) != k)          /*  |       |  */
                        { puts (err[0]); goto err_exit; }  /*  |       |  */
                     k=count; p1=p+k1;     /* выход из циклов while и for */
                     k1=0;
                     }
                  p1++;
                  }
               }
            }
         if (k1>0)
            if (write (fdl,p,k1) != k1)
               { puts (err[0]); goto err_exit; }
         k1=0;
         }
      if (k1 > 0)
         {
         if (s< (int)l)
            {
            lseek (fdh,(-k1),SEEK_CUR);
            s -= k1;
            }
         else
            {
            if (write (fdl,p,k1) != k1)
               { puts (err[0]); goto err_exit; }
            }
         }
      l -= s;
      }
   close (fdl);
   close (fdh);
   strcpy (tbuf,sbuf);
   j = strlen (tbuf);
   memcpy (tbuf+j-3,"prg",3);
   p = tbuf + strlen (tbuf) + 1;
   strcpy (p,sbuf);
   j = strlen (p);
   memcpy (p+j-3,"old",3);
   unlink (p);
   if (rename (tbuf,p))
      { puts (" - rename error, save to *.$$$ and skipping"); continue; }
   rename (sbuf,tbuf);
   }
return;
err_exit:
   close (fdl);
   close (fdh);
   unlink (sbuf);
   exit (1);
}
