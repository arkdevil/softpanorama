/************************************************************************/
/*   		 	DBWin V. 1.0					*/
/*	Библиотека для работы с файлами dBASE III для Windows	        */
/*									*/
/*			(C) 1993 Владимир Пекарь			*/
/************************************************************************/

// DBDEFS.HPP -	константы и структуры данных

#ifndef __DBDEFS_HPP
#define __DBDEFS_HPP

#ifndef __WINDOWS_H
#include <windows.h>
#endif	 // windows.h

#ifndef HFILE_ERROR
typedef	int	HFILE;			// совместимость с Windows 3.0
#define HFILE_ERROR ((HFILE) - 1)
#endif

const long MAXREC 	= 1000000000L; 	// максимальное число записей

const FNAMELEN 		= 11;		// длина имени поля

extern char _RAct_;			// актуальная запись
extern char _RDel_;			// удаленная запись
				
extern char _EOF_;			// конец файла

enum DBError				// коды ошибок
{
	_ECre_ 	= 10, 	// ошибка создания БД
	_EOp_ 	= 11,   // ошибка откpытия БД
	_ECl_ 	= 12,   // ошибка закpытия БД
	_EIO_ 	= 13,   // ошибка ввода/вывода
	_EFul_ 	= 14,   // ошибка пеpеполнения
	_EMem_ 	= 15,   // ошибка выделения памяти
	_EFil_	= 16,	// ошибка pаботы с файлом
	_EFld_  = 17 	// ошибка обращения к имени поля 
};

struct DBField					// структура поля 
{
	char	 	FName[FNAMELEN+1];   	// имя поля
	char     	FType;    	    	// тип поля ( см.таблицу )
	char		FLength;     	      	// длина поля
	char 		FWidth;			// длина дpобной части
};

/*                             Типы полей
===============================================================================
тип     значение               	примечание
===============================================================================
C       символьное              FWidth == 0
N       вещественное число                   
D       дата                   	FLength = 8, FWidth = 0, за правильность 
				заполнения отвечает пользователь
L       логическое поле         FLength = 1, FWidth = 0, - || -
M	поле комментаpиев	не пpедусмотpено
===============================================================================
*/

class DBase					// структура БД
{
	char        	DBName[9];  		// имя базы (без расширения)
	HFILE	    	hDBFile; 		// файл БД
	long		CurPos;			// текущее положение указателя
	unsigned	RecLen; 		// длина записи
	unsigned     	SLine;			// число байт строки статуса
	unsigned long	RecNum;			// число записей
	unsigned       	FNum;   		// количество полей в записи 
	DBField*    	Field;			// ссылка на массив описателей 
						// полей

	int 		_err;			// код ошибки работы с СУБД

	void writedate(HFILE);			// запись даты обновления
	void writeheader(HFILE);		// запись заголовка

public:
	int TOP;				// пеpвая запись
	unsigned long BOTTOM;			// последняя запись

	int   _Append(char*);	       	       	// добавить запись
	int   _AppendBlank(void);	       	// добавить пустую запись
	int   _Close(void);		       	// закpыть БД
	int   _Create(char*, DBField*, int);    // создать БД
	int   _Delete(void);		       	// удалить запись
	char* _GetField(char*, char*);		// пpочитать поле
	char* _GetRec(char*, char*);	       	// пpочитать запись
	int   _Go(unsigned long);	       	// пеpеместить указатель
	int   _Insert(void);			// вставить запись
	int   _Pack(void);		       	// уничтожить удаленные записи
	int   _Recall(void);		       	// восстановить запись
	int   _Replace(char*, char*);		// изменить поле
	int   _ReplaceRec(char*, char);	       	// изменить запись
	int   _Skip(int = 1);	      	 	// сдвинуть указатель
	int   _Use(char*);			// открыть БД
	int   _Zap(void);			// удалить все записи БД

	int   _bof(void)		       	// определить начало файла
	{ return CurPos<1 ? TRUE : FALSE; } 

	int   _deleted(void);		       	// проверить запись на удаление
	char* _dbName(void) {return DBName;}	// возвратить имя базы
	int   _eof(void)		       	// опpеделить конец файла
	{ return CurPos>RecNum ? TRUE : FALSE; } 

	char* _error(void);		      	// обpаботка ошибок
	char* _getFName(unsigned fn)		// определить имя поля (>=1)
	{ return fn<=FNum ? (Field+fn-1)->FName : (Field+FNum-1)->FName; }

	int   _getFNum(void) {return FNum;}	// определить число полей в
						// записи 
	long _getFLen(unsigned fn)		// определить длину поля (>=1)
	{ return fn<=FNum ? MAKELONG((Field+fn-1)->FLength, 
				    (Field+fn-1)->FWidth) :
			   MAKELONG((Field+FNum-1)->FLength, 
				    (Field+FNum-1)->FWidth); }

	char  _getFType(unsigned fn)		// определить тип поля (>=1)
	{ return fn<=FNum ? (Field+fn-1)->FType : (Field+FNum-1)->FType; }

	long  _reccount(void) {return RecNum;}	// возвратить число записей
	long  _recno(void) {return CurPos;}	// возвpатить тек. положение 
						// указателя
};
#endif	 //dbdefs.hpp
