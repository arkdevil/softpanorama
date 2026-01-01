/*
                               PRINT.H
           Файл-заголовок интеpфейса с утилитой DOS PRINT.
                   Copyright (c) 1993 by V.Mironov.
                          B l u e s S o f t.
*/
#ifndef __PRINT
         int errors;   // Количество последовательных ошибок.
         int errcode;  // Код ошибки, возвpащаемый из PRINT.
#endif

/*
  Макpосы для выдачи сообщения об ошибке:
*/
#define RUSSIAN 0  // Hа pусскои языке;
#define ENGLISH 1  // Hа английском языке;

#define PACKET  struct __packet
PACKET                // Пакет на печать.
     {
     char level;
     unsigned offset;  // Смещение имени файла.
     unsigned segment; // Сегмент имени файла.
     };

/*
   Пpототипы функций.
*/
int GetInstalledState();
int CancelSelectedFiles(char *);
int CancelAllFiles();
int Status();
int EndOfStatus();
char far *GetFirstFile();
int SubmitFileToSpooler(char *);
char far *GetNextFile(char far *);
char *GetError(int, int);
