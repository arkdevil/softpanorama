/***************************************************************/
/*                                                             */
/*               KIVLIB  include file  UTILS.H                 */
/*                                                             */
/*                                                             */
/*        Copyright (c)  1993   by  KIV without Co             */
/***************************************************************/
#ifndef ___UTILS___

#define ___UTILS___

#ifdef __cplusplus
extern "C" {
#endif


unsigned int cdecl BMsearch(void * buf, int buflen, void * key, int keys);

long  cdecl searchFile(char * filename, void * key, int keys, unsigned int BUFSIZE);
/* поиск смещения в файле key с длиной keys -
   возврат  -1  не могу открыть файл
	    -2  не хватает памяти для буфера BUFSIZE
	    -3  не найдено
	    -4  слишком мал буфер
*/


long cdecl searchFilePos(char * filename, void * key, int keys, unsigned int BUFSIZE, long Pos);
/* Аналог searchFile, но ищем со смещения Pos;
   -5 - Pos > длины файла
*/

char * cdecl newS(char * s); /*alloc mem для нновой строки s, удалять - free */


char *  cdecl forceExtension(char * pathname, char * ext);
char *  cdecl addBackSlash(char * str);
char *  cdecl defaultExtension(char * pathname, char * ext);
/*
  Эти функции дописывают в имеющиеся строки - следите, чтобы было место !

*/

char *  cdecl _forceExtension(char * pathname, char * ext);
char *  cdecl _addBackSlash(char * str);
char *  cdecl _defaultExtension(char * pathname, char * ext);
/*
  Эти функции вызывают alloc - не забудьте освободить память,
  а также проверить, не вернулся ли NULL - значит, мало памяти !

*/

char *  cdecl justPathName(char * fullpath);
//return malloc string - path only

char *  cdecl justFileName(char * path, char * name);
//name from path, return name;
//name must have at least 13 bytes

char *  cdecl StrRUpCase(char * r);
unsigned char  cdecl RUpCase(unsigned char r);




char *  cdecl _hexB(char * s, unsigned char B);
char *  cdecl hexB(unsigned char B);
char *  cdecl _hexW(char * s, unsigned int W);
char *  cdecl hexW(unsigned int W);
char *  cdecl _hexP(char * s, void far * p);
char *  cdecl hexP(void far * p);
/* строки в виде HEX'ов - если с _, то в исходную,
   если без - alloc память (NULL - ее мало)
*/

char *  cdecl delSpaces(char * s);
//  удаление начальных и конечных пробелов




void cdecl Reboot();
void cdecl DisableKbd();
void cdecl EnableKbd();
void cdecl NumLockOn(int Yes);
void cdecl CapsLockOn(int Yes);
void cdecl ScrollLockOn(int Yes);

#ifdef __cplusplus
}
#endif


#endif


