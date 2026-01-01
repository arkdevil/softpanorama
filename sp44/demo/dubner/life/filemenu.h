#ifndef FILEMENU_H         /* To prevent redefinition  */

#define  LOCAL		static
#define  ENTRY		extern

#define FILEMENU_H         /* Prevents redefinition    */

/*
*  Выбор файла по заданной маске из текущего директория.
*  Параметры - адрес строки-маски,
*              адрес буфера для записи имени выбранного файла.
*  Возвращает полное имя файла, если файл выбран, NULL - нажат ESC.
*/
ENTRY char *getFileName(char *mask, char *name);

#endif                  /* Ends "#ifndef FILEMENU_H"   */

